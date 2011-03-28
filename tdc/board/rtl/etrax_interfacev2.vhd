library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use ieee.std_logic_textio.all;

library std;
use std.textio.all;


entity etrax_interfacev2 is
  generic (
    ENABLE_DMA             :       positive;
    RW_SYSTEM              :       positive;
    RW_REGISTERS_NUMBER    :       natural;
    R_REGISTERS_NUMBER     :       natural;
    TRBNET_ENABLE          :       natural
    );
  port (
    CLK                    : in    std_logic;
    RESET                  : in    std_logic;
    DATA_BUS               : in    std_logic_vector(31 downto 0);
    ETRAX_DATA_BUS_B       : inout std_logic_vector(16 downto 0);
    ETRAX_DATA_BUS_B_17    : in    std_logic;  --_vector(16 downto 0);
    ETRAX_DATA_BUS_C       : inout std_logic_vector(17 downto 0);
    ETRAX_DATA_BUS_E       : inout std_logic_vector(9 downto 8);
    IPU_READY_IN           : in    std_logic;
    IPU_DATAREADY_OUT      : out   std_logic;
    IPU_DATA_OUT           : out   std_logic_vector(31 downto 0);
    DATA_VALID             : in    std_logic;
    ETRAX_BUS_BUSY         : in    std_logic;
    ETRAX_IS_READY_TO_READ : out   std_logic;
    TDC_TCK                : out   std_logic;
    TDC_TDI                : out   std_logic;
    TDC_TMS                : out   std_logic;
    TDC_TRST               : out   std_logic;
    TDC_TDO                : in    std_logic;
    TDC_RESET              : out   std_logic;
    EXTERNAL_ADDRESS       : out   std_logic_vector(31 downto 0);
    EXTERNAL_DATA_OUT      : out   std_logic_vector(31 downto 0);
    EXTERNAL_DATA_IN       : in    std_logic_vector(31 downto 0);
    EXTERNAL_ACK           : out   std_logic;
    EXTERNAL_VALID         : in    std_logic;
    EXTERNAL_MODE          : out   std_logic_vector(15 downto 0);
    RW_REGISTER            : out   std_logic_vector(RW_REGISTERS_NUMBER*32-1 downto 0);
    R_REGISTER             : in    std_logic_vector(R_REGISTERS_NUMBER*32-1 downto 0);
    LVL2_VALID             : in    std_logic;
    TRB_LVL2_BUSY          : in    std_logic
    --  DEBUG_REGISTER_OO       : out   std_logic_vector(31 downto 0)
    );
end etrax_interfacev2;

architecture etrax_interfacev2 of etrax_interfacev2 is

  component edge_to_pulse
    port (
      clock     : in  std_logic;
      en_clk    : in  std_logic;
      signal_in : in  std_logic;
      pulse     : out std_logic);
  end component;

  component up_down_counter
    generic (
      NUMBER_OF_BITS :     positive);
    port (
      CLK            : in  std_logic;
      RESET          : in  std_logic;
      COUNT_OUT      : out std_logic_vector(NUMBER_OF_BITS-1 downto 0);
      UP_IN          : in  std_logic;
      DOWN_IN        : in  std_logic);
  end component;

  signal rw_operation_finished_pulse : std_logic;
  signal saved_rw_mode               : std_logic_vector(15 downto 0)                       := (others => '0');
  signal saved_address               : std_logic_vector (31 downto 0)                      := (others => '0');
  signal saved_data                  : std_logic_vector(31 downto 0)                       := (others => '0');
  signal saved_data_fpga             : std_logic_vector(31 downto 0)                       := (others => '0');
  signal r_register_i                : std_logic_vector(R_REGISTERS_NUMBER*32-1 downto 0)  := (others => '0');
  signal rw_register_i               : std_logic_vector(RW_REGISTERS_NUMBER*32-1 downto 0) := (others => '0');


  signal saved_external_data      : std_logic_vector(31 downto 0);
  signal etrax_is_ready_to_read_i : std_logic;
  signal lvl2_not_valid_pulse     : std_logic;
  signal counter_for_pulses       : unsigned(2 downto 0);
  signal internal_reset_i         : std_logic := '0';

  signal data_from_etrax        : std_logic_vector(80 downto 0) := (others => '0');
  signal etrax_std_data_counter : unsigned(7 downto 0)  := x"00";
  signal enable_transmition     : std_logic                     := '1';
  signal etrax_strobe           : std_logic;
  signal data_to_etrax          : std_logic_vector(31 downto 0);


  signal not_etrax_busy : std_logic;


  signal data_bus_reg : std_logic_vector(31 downto 0);


  signal readout_lvl2_fifo : std_logic;

  signal data_valid_start_pulse   : std_logic;
  signal data_valid_end_pulse     : std_logic;
  signal data_valid_not           : std_logic;
  signal etrax_busy_end           : std_logic;
  signal write_to_dma_synch       : std_logic;
  signal word16_counter           : unsigned(7 downto 0);
  signal write_to_dma_synch_synch : std_logic;
  signal reg_address              : integer range 0 to 256 := 1;
  signal data_valid_synch         : std_logic;
  signal how_many_data_was_sent   : std_logic_vector(4 downto 0);
  signal time_out_cntr            : unsigned(31 downto 0);
  signal time_out_pulse           : std_logic;
begin


-------------------------------------------------------------------------------
-- serial transmition for reading, writing fpga registers, dsp, sdram , addon . . .
-------------------------------------------------------------------------------

  TRB_SYSTEM      : if RW_SYSTEM = 1 generate
    ETRAX_DATA_BUS_C(17) <= 'Z';
    STROBE_PULSER : edge_to_pulse
      port map (
        clock     => CLK,
        en_clk    => '1',
        signal_in => ETRAX_DATA_BUS_C(17),
        pulse     => etrax_strobe);

    SAVE_ETRAX_DATA               : process (CLK, RESET)
      variable etrax_data_counter : integer := 0;
    begin
      if rising_edge(CLK)then
        if RESET = '1' or (etrax_std_data_counter = 81 and saved_rw_mode(15) = '0') or (etrax_std_data_counter = 114 and saved_rw_mode(15) = '1') then
          etrax_data_counter                := 0;
          data_from_etrax                     <= data_from_etrax;
          ETRAX_DATA_BUS_C(16)                <= 'Z';
          enable_transmition                  <= '1';
          etrax_std_data_counter              <= x"00";
        elsif etrax_strobe = '1' and etrax_std_data_counter < 81 then  -- and etrax_data_counter < 81 and etrax_data_counter > 0 then
          data_from_etrax(etrax_data_counter) <= ETRAX_DATA_BUS_C(16);
          etrax_data_counter                := etrax_data_counter + 1;
          ETRAX_DATA_BUS_C(16)                <= 'Z';
          enable_transmition                  <= '0';
          etrax_std_data_counter              <= etrax_std_data_counter + 1;
          --elsif etrax_std_data_counter = 81 and saved_rw_mode(15) = '1' and saved_rw_mode(7 downto 0) = x"00" then
        elsif etrax_std_data_counter = 81 and saved_rw_mode(15) = '1' then
          data_from_etrax                     <= data_from_etrax;
          ETRAX_DATA_BUS_C(16)                <= data_to_etrax(0);
          etrax_data_counter                := etrax_data_counter + 1;
          etrax_std_data_counter              <= etrax_std_data_counter + 1;
          enable_transmition                  <= '0';
        elsif etrax_strobe = '1' and etrax_std_data_counter > 81 and saved_rw_mode(15) = '1' then
          data_from_etrax                     <= data_from_etrax;
          ETRAX_DATA_BUS_C(16)                <= data_to_etrax((etrax_data_counter-81) mod 32);  --+reg_address*32
          etrax_data_counter                := etrax_data_counter + 1;
          etrax_std_data_counter              <= etrax_std_data_counter + 1;
          enable_transmition                  <= '0';
        end if;
      end if;
    end process SAVE_ETRAX_DATA;
  end generate TRB_SYSTEM;
  -- we should add one state to wait for the data from external device (valid
  -- pulse- > one long puls on the data bus !)
  ADDON_SYSTEM                    : if RW_SYSTEM = 2 generate
    ETRAX_DATA_BUS_E(9)                       <= 'Z';
    STROBE_PULSER                 : edge_to_pulse
      port map (
        clock     => CLK,
        en_clk    => '1',
        signal_in => ETRAX_DATA_BUS_E(9),  --
        pulse     => etrax_strobe);

    SAVE_ETRAX_DATA               : process (CLK, RESET)
      variable etrax_data_counter : integer := 0;
    begin
      if rising_edge(CLK)then
        if RESET = '1' or (etrax_std_data_counter = 81 and saved_rw_mode(15) = '0') or (etrax_std_data_counter = 114 and saved_rw_mode(15) = '1') then
          etrax_data_counter                := 0;
          data_from_etrax                     <= data_from_etrax;
          ETRAX_DATA_BUS_E(8)                 <= 'Z';
          enable_transmition                  <= '1';
          etrax_std_data_counter              <= x"00";
        elsif etrax_strobe = '1' and etrax_std_data_counter < 81 then  -- and etrax_data_counter < 81 and etrax_data_counter > 0 then
          data_from_etrax(etrax_data_counter) <= ETRAX_DATA_BUS_E(8);
          etrax_data_counter                := etrax_data_counter + 1;
          ETRAX_DATA_BUS_E(8)                 <= 'Z';
          enable_transmition                  <= '0';
          etrax_std_data_counter              <= etrax_std_data_counter + 1;
-- elsif etrax_std_data_counter = 81 and saved_rw_mode(15) = '1' and saved_rw_mode(7 downto 0) = x"00" then
        elsif etrax_std_data_counter = 81 and saved_rw_mode(15) = '1' then
          data_from_etrax                     <= data_from_etrax;
          ETRAX_DATA_BUS_E(8)                 <= data_to_etrax(0);
          etrax_data_counter                := etrax_data_counter + 1;
          etrax_std_data_counter              <= etrax_std_data_counter + 1;
          enable_transmition                  <= '0';
        elsif etrax_strobe = '1' and etrax_std_data_counter > 81 and saved_rw_mode(15) = '1' then
          data_from_etrax                     <= data_from_etrax;
          ETRAX_DATA_BUS_E(8)                 <= data_to_etrax((etrax_data_counter-81) mod 32);  --+reg_address*32
          etrax_data_counter                := etrax_data_counter + 1;
          etrax_std_data_counter              <= etrax_std_data_counter + 1;
          enable_transmition                  <= '0';
        end if;
      end if;
    end process SAVE_ETRAX_DATA;

  end generate ADDON_SYSTEM;

  SYNC_DATA_TO_ETRAX : process (CLK, RESET)
  begin
    if rising_edge(CLK) then
      if RESET = '1' then
        data_to_etrax <= (others => '0');
      elsif saved_rw_mode(7 downto 0) = x"00" then
        data_to_etrax <= saved_data_fpga;
      else
        data_to_etrax <= saved_external_data;
      end if;
    end if;
  end process SYNC_DATA_TO_ETRAX;

  TIME_OUT : process (CLK, RESET)
  begin
    if rising_edge(CLK) then
      if RESET = '1' then
        time_out_cntr <= x"00000000";
      elsif etrax_std_data_counter = 81 then
        time_out_cntr <= time_out_cntr + 1;
      else
        time_out_cntr <= x"00000000";
      end if;
    end if;
  end process TIME_OUT;

  TIME_OUT_PULSER : edge_to_pulse
    port map (
      clock     => CLK,
      en_clk    => '1',
      signal_in => time_out_cntr(26),
      pulse     => time_out_pulse);

  RW_FINISHED_PULSER : edge_to_pulse
    port map (
      clock     => CLK,
      en_clk    => '1',
      signal_in => EXTERNAL_VALID,
      pulse     => rw_operation_finished_pulse);
  --for reading only 1us for responce for any external device !!! - ask RADEK
  --abut timing
  REGISTER_ETRAX_BUS : process (CLK, RESET)
  begin
    if rising_edge(CLK) then
      if RESET = '1' then
        saved_external_data <= x"bad1face";
      elsif rw_operation_finished_pulse = '1' then
        saved_external_data <= EXTERNAL_DATA_IN;
      else
        saved_external_data <= saved_external_data;
      end if;
    end if;
  end process REGISTER_ETRAX_BUS;

  EXTERNAL_ADDRESS  <= saved_address;
  EXTERNAL_MODE     <= saved_rw_mode(15 downto 0);
  EXTERNAL_DATA_OUT <= saved_data;
  EXTERNAL_ACK      <= '1' when etrax_std_data_counter = 80 else '0';

  CLOCK_SAVED_DATA : process (CLK, RESET)
  begin
    if rising_edge(CLK) then
      if RESET = '1' then
        saved_rw_mode <= (others => '0');
        saved_address <= (others => '0');
        saved_data    <= (others => '0');
        reg_address   <= 1;
      else
        saved_rw_mode <= data_from_etrax(15 downto 0);
        saved_address <= data_from_etrax(47 downto 16);
        reg_address   <= to_integer( unsigned( data_from_etrax(23 downto 16)));
        --only 16 lowest bits - the 8 highest is not taken into address for
        --internal registers
        saved_data    <= data_from_etrax(79 downto 48);
      end if;
    end if;
  end process CLOCK_SAVED_DATA;

  REGISTERS : process (CLK)
  begin
    if rising_edge(CLK) then
-- if RESET = '1' or (ETRAX_DATA_BUS_C(16)='1' and ETRAX_DATA_BUS_C(17)='1') then
      RW_REGISTER  <= rw_register_i;
      r_register_i <= R_REGISTER;
    end if;
  end process REGISTERS;

  DATA_SOURCE_SELECT : process (CLK, RESET, saved_rw_mode, saved_address)

  begin
    if rising_edge(CLK) then
      if RESET = '1' then               --(ETRAX_DATA_BUS_C(16) = '1' and ETRAX_DATA_BUS_C(17) = '1') then
        rw_register_i                                                             <= (others => '0');
      else
        case saved_rw_mode(7 downto 0) is
          when x"00"                                                                         =>
            if saved_rw_mode(15) = '1' and etrax_std_data_counter = 80 and reg_address > 127 and reg_address < 192 then
              saved_data_fpga                                                     <= r_register((reg_address+1-128)*32-1 downto ((reg_address-128)*32));
            elsif saved_rw_mode(15) = '1' and etrax_std_data_counter = 80 and reg_address > 191 and reg_address < 256 then
              saved_data_fpga                                                     <= rw_register_i((reg_address+1-192)*32-1 downto (reg_address-192)*32);
            elsif saved_rw_mode(15) = '0' and etrax_std_data_counter = 80 then
              rw_register_i((reg_address+1-192)*32-1 downto (reg_address-192)*32) <= saved_data;
            else
              saved_data_fpga                                                     <= saved_data_fpga;
            end if;
          when x"01"                                                                         =>  --DSP write read
            saved_data_fpga                                                       <= saved_external_data;
          when x"02"                                                                         =>  --sdram
            saved_data_fpga                                                       <= saved_external_data;
          when x"03"                                                                         =>  --ADDON board write read
            saved_data_fpga                                                       <= saved_external_data;
          when x"05"                                                                         =>  --trigger interface
            saved_data_fpga                                                       <= saved_external_data;
          when x"06"                                                                         =>  --SFP read
            saved_data_fpga                                                       <= saved_external_data;
          when others                                                                        =>
            saved_data_fpga                                                       <= x"deadface";
        end case;
      end if;
    end if;
  end process DATA_SOURCE_SELECT;

-------------------------------------------------------------------------------
-- data transmitio fpga <-> etrax
-------------------------------------------------------------------------------
--DMA
  DMA_INTERFACE : if ENABLE_DMA = 1 generate

    REG_DATA_TO_ETRAXa : process (CLK, RESET)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          data_bus_reg             <= (others => '0');
          write_to_dma_synch       <= '0';
          write_to_dma_synch_synch <= '0';
          data_valid_synch         <= '0';
        else
          data_bus_reg             <= DATA_BUS;
          write_to_dma_synch       <= readout_lvl2_fifo;        --write_to_dma;
          write_to_dma_synch_synch <= write_to_dma_synch and (DATA_VALID or (not(TRB_LVL2_BUSY)));
          data_valid_synch         <= DATA_VALID;
        end if;
      end if;
    end process REG_DATA_TO_ETRAXa;
    ETRAX_DATA_BUS_B(7 downto 0)   <= data_bus_reg(31 downto 24);
-- ETRAX_DATA_BUS_B(6 downto 0) <= data_bus_reg(30 downto 24);  --!!!test
    ETRAX_DATA_BUS_B(15 downto 8)  <= data_bus_reg(23 downto 16);
    ETRAX_DATA_BUS_C(15 downto 8)  <= data_bus_reg(15 downto 8);
    ETRAX_DATA_BUS_C(7 downto 4)   <= data_bus_reg(7 downto 4);
-- ETRAX_DATA_BUS_B(7) <= ETRAX_DATA_BUS_B_17;                  --for test

    TDC_TMS             <= ETRAX_DATA_BUS_C(1) when rw_register_i(0) = '1' else '1';
    TDC_TCK             <= ETRAX_DATA_BUS_C(2) when rw_register_i(0) = '1' else '1';
    TDC_TDI             <= ETRAX_DATA_BUS_C(3) when rw_register_i(0) = '1' else '1';
    ETRAX_DATA_BUS_C(0) <= TDC_TDO             when rw_register_i(0) = '1' else data_bus_reg(0);
    ETRAX_DATA_BUS_C(1) <= 'Z'                 when rw_register_i(0) = '1' else data_bus_reg(1);
    ETRAX_DATA_BUS_C(2) <= 'Z'                 when rw_register_i(0) = '1' else data_bus_reg(2);
    ETRAX_DATA_BUS_C(3) <= 'Z'                 when rw_register_i(0) = '1' else data_bus_reg(3);

    COUNT_CORRECT_WORD_NUMBER : up_down_counter
      generic map (
        NUMBER_OF_BITS => 5)
      port map (
        CLK            => CLK,
        RESET          => data_valid_start_pulse,
        COUNT_OUT      => how_many_data_was_sent,
        UP_IN          => write_to_dma_synch_synch,
        DOWN_IN        => '0');

    START_READOUT : edge_to_pulse
      port map (
        clock     => CLK,
        en_clk    => '1',
        signal_in => TRB_LVL2_BUSY,     --DATA_VALID,
        pulse     => data_valid_start_pulse);
    data_valid_not <= not TRB_LVL2_BUSY;

    END_READOUT : edge_to_pulse
      port map (
        clock     => CLK,
        en_clk    => '1',
        signal_in => data_valid_not,
        pulse     => data_valid_end_pulse);

    not_etrax_busy <= not ETRAX_DATA_BUS_B_17;

    ETRAX_BUSY_END_PULSER : edge_to_pulse
      port map (
        clock     => CLK,
        en_clk    => '1',
        signal_in => not_etrax_busy,
        pulse     => etrax_busy_end);

    COUNTER_FOR_READOUT : process (CLK, RESET)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          word16_counter             <= x"FF";
        elsif (data_valid_start_pulse = '1') or (etrax_busy_end = '1' and DATA_VALID = '1') then
          word16_counter             <= x"00";
        elsif (word16_counter < x"1e") and (DATA_VALID = '1' or TRB_LVL2_BUSY = '0') then
          word16_counter             <= word16_counter + 1;
        elsif (word16_counter < x"1e") and (DATA_VALID = '0' and TRB_LVL2_BUSY = '1') then
          word16_counter(4 downto 0) <= unsigned( how_many_data_was_sent(3 downto 0)) & '0';
        else
          word16_counter             <= word16_counter;
        end if;
      end if;
    end process COUNTER_FOR_READOUT;

    READOUT_LVL2_FIFO_PROC : process (CLK, RESET)
    begin
      if rising_edge(CLK) then
        if RESET = '1' or data_valid_end_pulse = '1' or word16_counter = x"1e" then
          readout_lvl2_fifo <= '0';
        elsif word16_counter < x"1e" and (DATA_VALID = '1' or TRB_LVL2_BUSY = '0') then
          readout_lvl2_fifo <= word16_counter(0);
        else
          readout_lvl2_fifo <= '0';
        end if;
      end if;
    end process READOUT_LVL2_FIFO_PROC;


-- etrax_is_ready_to_read_i <= (data_valid_start_pulse or readout_lvl2_fifo) and DATA_VALID;
    ETRAX_IS_READY_TO_READ <= readout_lvl2_fifo;
    ETRAX_DATA_BUS_B(16)   <= write_to_dma_synch_synch;  --(not CLK) and (write_to_dma_synch_synch);

  end generate DMA_INTERFACE;


-- NO DMA
  WITHOUT_DMA_ETRAX_INTERFACE : if ENABLE_DMA = 2 generate

    WITH_TRBNET : if TRBNET_ENABLE = 1 generate
      etrax_is_ready_to_read_i <= IPU_READY_IN;
      ETRAX_DATA_BUS_B(16)     <= '0';
    end generate WITH_TRBNET;


    WITHOUT_TRBNET      : if TRBNET_ENABLE /= 1 generate
      ETRAX_READY_PULSE : edge_to_pulse
        port map (
          clock     => CLK,
          en_clk    => '1',
          signal_in => ETRAX_DATA_BUS_B_17,
          pulse     => etrax_is_ready_to_read_i);
      ETRAX_DATA_BUS_B(16) <= DATA_VALID and (not LVL2_VALID);
    end generate WITHOUT_TRBNET;

    MAKE_PULSES : process (CLK, RESET)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          counter_for_pulses <= "000";
        else
          counter_for_pulses <= counter_for_pulses + 1;
        end if;
      end if;
    end process make_pulses;

    LVL2_NOT_VALID_READY_PULSE : edge_to_pulse
      port map (
        clock     => CLK,
        en_clk    => '1',
        signal_in => counter_for_pulses(2),
        pulse     => lvl2_not_valid_pulse);



    ETRAX_IS_READY_TO_READ <= DATA_VALID and ((etrax_is_ready_to_read_i and (not LVL2_VALID)) or (lvl2_not_valid_pulse and LVL2_VALID));

    TDC_TMS                       <= ETRAX_DATA_BUS_C(1) when rw_register_i(0) = '1' else '1';
    TDC_TCK                       <= ETRAX_DATA_BUS_C(2) when rw_register_i(0) = '1' else '1';
    TDC_TDI                       <= ETRAX_DATA_BUS_C(3) when rw_register_i(0) = '1' else '1';
    ETRAX_DATA_BUS_C(0)           <= TDC_TDO             when rw_register_i(0) = '1' else data_bus_reg(16);
    ETRAX_DATA_BUS_C(1)           <= 'Z'                 when rw_register_i(0) = '1' else data_bus_reg(17);
    ETRAX_DATA_BUS_C(2)           <= 'Z'                 when rw_register_i(0) = '1' else data_bus_reg(18);
    ETRAX_DATA_BUS_C(3)           <= 'Z'                 when rw_register_i(0) = '1' else data_bus_reg(19);
    ETRAX_DATA_BUS_C(15 downto 4) <= data_bus_reg(31 downto 20);
    ETRAX_DATA_BUS_B(15 downto 0) <= data_bus_reg(15 downto 0);


    REG_DATA_TO_ETRAXb : process (CLK, RESET)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          data_bus_reg      <= (others => '0');
          IPU_DATAREADY_OUT <= '0';
          IPU_DATA_OUT      <= (others => '0');
        else
          data_bus_reg      <= DATA_BUS;
          IPU_DATAREADY_OUT <= DATA_VALID and (not LVL2_VALID);
          IPU_DATA_OUT      <= DATA_BUS;
        end if;
      end if;
    end process REG_DATA_TO_ETRAXb;

  end generate WITHOUT_DMA_ETRAX_INTERFACE;

end etrax_interfacev2;
