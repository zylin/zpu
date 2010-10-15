----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:22:20 09/09/2009 
-- Design Name: 
-- Module Name:    fpga_top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library unisim;
use unisim.vcomponents.all;


library work;
use work.tdline_pack.all;


library tdc;
use tdc.components.my_tdc;
use tdc.types.all;


entity fpga_top is
    port (
--      REF_TDC_CLK  : in    STD_LOGIC;
--      REF_TDC_CLKB : in    STD_LOGIC;
--      sim_clk      : in    STD_LOGIC;
--      sim_start    : in    STD_LOGIC;
--      RESET_VIRT   : in    STD_LOGIC;
--      VIRT_CLK     : in    STD_LOGIC;
--      VIRT_CLKB    : in    STD_LOGIC;
        REF_TDC_CLK  : in    std_logic;
        REF_TDC_CLKB : in    std_logic;
        DWAIT        : out   std_logic;
        DINT         : out   std_logic;
        FS_PC        : inout std_logic_vector(17 downto 0);
        FS_PB        : inout std_logic_vector (16 downto 0);
        FS_PB_17     : in    std_logic;     --_vector (16 downto 0);
        
        ETRAX_IRQ    : out std_logic;
        ADO_LV       : out std_logic_vector(1 downto 0);  --1
        ADO_LV_in    : in  std_logic_vector(5 downto 0);
--      ADO_TTL_16   : out STD_LOGIC;
--      ADO_TTL_17   : out STD_LOGIC;
        ADO_TTL_36   : out std_logic;
        ADO_TTL_37   : out std_logic;
        ADO_TTL      : out std_logic_vector(27 downto 0)
    );

end fpga_top;




architecture Behavioral of fpga_top is


    component bFIFO_512dual_full17
        port (
            din    : in  std_logic_vector(31 downto 0);
            rd_clk : in  std_logic;
            rd_en  : in  std_logic;
            rst    : in  std_logic;
            wr_clk : in  std_logic;
            wr_en  : in  std_logic;
            dout   : out std_logic_vector(31 downto 0);
            empty  : out std_logic;
            full   : out std_logic;
            valid  : out std_logic
        );
    end component bFIFO_512dual_full17;

    component fifo_1kW
        port (
            din           : in  std_logic_vector(33 downto 0);
            rd_clk        : in  std_logic;
            rd_en         : in  std_logic;
            rst           : in  std_logic;
            wr_clk        : in  std_logic;
            wr_en         : in  std_logic;
            dout          : out std_logic_vector(33 downto 0);
            empty         : out std_logic;
            full          : out std_logic;
            rd_data_count : out std_logic_vector(9 downto 0);
            wr_data_count : out std_logic_vector(9 downto 0)
        );
    end component fifo_1kW;

    component readout_modul is
        port (
            clk                 : in    std_logic;
            reset_i             : in    std_logic;
            readout_busy_out    : out   std_logic;
            fifo_empty_in       : in    std_logic;
            fifo_full_in        : in    std_logic;
            fifo_rd_en_out      : out   std_logic;
            fifo_out_data_in    : in    std_logic_vector(31 downto 0);
            rw_register_vec_out : out   std_logic_vector(RW_REGISTERS_NUMBER*32-1 downto 0);
            r_register_vec_in   : in    std_logic_vector(R_REGISTERS_NUMBER*32-1 downto 0);
            FS_PC               : inout std_logic_vector(17 downto 0);
            FS_PB               : inout std_logic_vector(16 downto 0);
            FS_PB_17            : in    std_logic
        );
    end component;

    component clk_manager is
        port(
          clk_in      : in  std_logic;
          reset       : in  std_logic;
          clk_x1_out  : out std_logic;
          clk_x2_out  : out std_logic;
          clk_fx_out  : out std_logic;
          clk_dv_out  : out std_logic
        );
    end component clk_manager;


  signal CLK, clk_fx, clk_x1, clk_x2, clk_100 : std_logic;



  signal state_logicport        : std_logic_vector(4 downto 0);
  signal mod_reset_sig          : std_logic;
----------------------ETRAX             ---------------------------------------------------
--signal rw_register_reg, rw_register_reg2: std_logic_vector(31 downto 0);
--signal rw_register_i          : std_logic_vector(RW_REGISTERS_NUMBER*32-1 downto 0);
--signal r_register_i           : std_logic_vector(R_REGISTERS_NUMBER*32-1 downto 0);
--type   r_register_array is array(0 to R_REGISTERS_NUMBER) of std_logic_vector(31 downto 0);
--signal r_register_i           : r_register_array;
  type   rw_register_array is array(0 to RW_REGISTERS_NUMBER) of std_logic_vector(31 downto 0);
  signal rw_register_i          : rw_register_array;
  type   r_register_array is array(0 to R_REGISTERS_NUMBER) of std_logic_vector(31 downto 0);
  signal r_register_i           : r_register_array;
                                
  signal r_register_vector      : std_logic_vector(R_REGISTERS_NUMBER*32-1 downto 0);
  signal rw_register_vector     : std_logic_vector(RW_REGISTERS_NUMBER*32-1 downto 0);
--signal bus_c_dummy            : STD_LOGIC_VECTOR(17 downto 0);
  signal external_ack_i         : std_logic;
  signal valid_reg, valid_reg0  : std_logic;
                                
    -- added BLa                
    signal reset                : std_logic;
    signal readout_busy         : std_logic;
    signal global_reset_counter : unsigned( 3 downto 0);
    signal c_cnt                : unsigned(15 downto 0);
    signal sig_rnd_int          : std_logic;
    signal sig_rnd1             : std_logic;
    signal sig_rnd2             : std_logic;
    signal sig_rnd3             : std_logic;
    
    signal temp_for_pins        : std_logic := '0';


---------------------FIFO               ---------------------------------------------------------
    signal fifo_in_data        : std_logic_vector(31 downto 0);
    signal fifo_out_data       : std_logic_vector(31 downto 0);
    signal fifo_wr_en          : std_logic;
    signal fifo_rd_en          : std_logic;
    signal fifo_valid          : std_logic;
    signal fifo_empty          : std_logic;
    signal fifo_full           : std_logic;







begin
-- ADO_TTL(0)<= CLK;
-- ADO_TTL(1)<= reset;
-- ADO_TTL(2)<= state_logicport(0);
-- ADO_TTL(3)<= state_logicport(1);
-- ADO_TTL(4)<= state_logicport(2);
-- ADO_TTL(5)<= state_logicport(3);
-- ADO_TTL(6)<= state_logicport(4);
-- ADO_TTL(7)<= ch_fifo_empty_reg;
-- ADO_TTL(11 downto 8) <= trg_ts_diff(3 downto 0);
-- ADO_TTL(15 downto 12) <= trg_ts_diff(15 downto 12);
--
-- ADO_TTL(20)<= fifo_wr_en;
-- ADO_TTL(21)<= store;
-- ADO_TTL(22)<= switch;
-- ADO_TTL(23)<= sig_rnd_int;
-- ADO_TTL(24)<= debug_1_reg;
-- ADO_TTL(25)<= fifo_full;
-- ADO_TTL(26)<= syn_busy2;
-- ADO_TTL(27)<= fifo_empty;
--
-- ADO_TTL(19 downto 16)<= "0000";
--
-- ADO_TTL_36<= '0';
-- ADO_TTL_37<= '0';



  ------------FIFO                      -----------------------------------------------------

  TRB_FIFO1 : bFIFO_512dual_full17
    port map (
      din    => fifo_in_data,
      rd_clk => clk_100,
      rd_en  => fifo_rd_en,
      rst    => reset,
      wr_clk => CLK,
      wr_en  => fifo_wr_en,
      dout   => fifo_out_data,
      empty  => fifo_empty,
      full   => fifo_full,
      valid  => fifo_valid
      );


  ---------READ_OUT_INTERFACE           ---------------------------------------
  --Vector ins Array:
  REWRITE_RW_REGISTER : for i in 1 to RW_REGISTERS_NUMBER generate
    rw_register_i(i-1) <= rw_register_vector(32*i-1 downto 32*(i-1));
  end generate REWRITE_RW_REGISTER;

  REWRITE_R_REGISTER : for i in 1 to R_REGISTERS_NUMBER generate
    r_register_vector(32*i-1 downto 32*(i-1)) <= r_register_i(i-1);
  end generate REWRITE_R_REGISTER;


  READOUT_INST : readout_modul
    port map(
      clk                 => clk_100,
      reset_i             => reset,
      readout_busy_out    => readout_busy,
      fifo_empty_in       => fifo_empty,
      fifo_full_in        => fifo_full,
      fifo_rd_en_out      => fifo_rd_en,
      fifo_out_data_in    => fifo_out_data,
      rw_register_vec_out => rw_register_vector,
      r_register_vec_in   => r_register_vector,
      FS_PC               => FS_PC,
      FS_PB               => FS_PB,
      FS_PB_17            => FS_PB_17
      );





  ----------------------RESET           ----------------------------------------

  MAKE_START_RESET : process (CLK)
  begin
    if rising_edge(CLK) then
      if global_reset_counter < x"e" then
        global_reset_counter <= global_reset_counter + 1;
        reset                <= '1';
      else
        global_reset_counter <= global_reset_counter;
        reset                <= '0';
      end if;
    end if;
  end process MAKE_START_RESET;


----------------------------------------------------------------------------------------------
--------------------GLOBAL_COARSE_COUNTER  ----------------------------------------------------
------------------------------------------------------------------------------------------------


  COARSE_CNT : process(CLK)
  begin
    if (CLK'event and CLK = '1') then
      if(reset = '1' or c_cnt = x"FFFF") then
        c_cnt <= x"0000";
      else
        c_cnt <= c_cnt + 1;
      end if;
    end if;
  end process COARSE_CNT;




--------------------------------------------------------------------------------------------
------------------------------------PINS  ---------------------------------------------------
----------------------------------------------------------------------------------------------
  OBUFDS_inst : OBUFDS
    generic map (
      IOSTANDARD => "DEFAULT")
    port map (
      O          => ADO_LV(0),
      OB         => ADO_LV(1),
      I          => sig_rnd_int
    );
--
--
-- PULSER : edge_to_pulse
-- port map (
-- clock => clk_100,
-- en_clk => '1',
-- signal_in => cnt(7),
-- pulse => pulse);
--
--
--
-- IBUFGDS_inst2 : IBUFGDS
-- generic map (
-- DIFF_TERM => TRUE,                   -- Differential Termination (Virtex-4/5 only)
--      IBUF_DELAY_VALUE => "0",        -- Specify the amount of added input delay for buffer, 
--                               -- "0"-"12" (Spartan-3E)
--                               -- "0"-"16" (Spartan-3A)
--      IOSTANDARD => "LVDS_25")
--   port map (
--      O => sig_rnd1,                  -- Clock buffer output
--      I => ADO_LV_in(0),              -- Diff_p clock buffer input (connect directly to top-level port)
--      IB => ADO_LV_in(1)              -- Diff_n clock buffer input (connect directly to top-level port)
--   );

  IBUFDS_inst1 : IBUFDS
    generic map (
      CAPACITANCE      => "NORMAL",     -- "LOW", "NORMAL", "DONT_CARE" (Virtex-4 only)
      DIFF_TERM        => true,         -- Differential Termination (Virtex-4/5, Spartan-3E/3A)
      IBUF_DELAY_VALUE => "0",          -- Specify the amount of added input delay for buffer, 
      -- "0"-"12" (Spartan-3E)
      -- "0"-"16" (Spartan-3A)
      IFD_DELAY_VALUE  => "AUTO",       -- Specify the amount of added delay for input register, 
      -- "AUTO", "0"-"6" (Spartan-3E)
      -- "AUTO", "0"-"8" (Spartan-3A)
      IOSTANDARD       => "LVDS_25")
    port map (
      O                => sig_rnd1,     -- Clock buffer output
      I                => ADO_LV_in(0),  -- Diff_p clock buffer input (connect directly to top-level port)
      IB               => ADO_LV_in(1)  -- Diff_n clock buffer input (connect directly to top-level port)
      );

-- IBUFGDS_inst3 : IBUFGDS
-- generic map (
-- DIFF_TERM => TRUE,                   -- Differential Termination (Virtex-4/5 only)
--      IBUF_DELAY_VALUE => "0",        -- Specify the amount of added input delay for buffer, 
--                               -- "0"-"12" (Spartan-3E)
--                               -- "0"-"16" (Spartan-3A)
--      IOSTANDARD => "LVDS_25")
--   port map (
--      O => sig_rnd2,                  -- Clock buffer output
--      I => ADO_LV_in(2),              -- Diff_p clock buffer input (connect directly to top-level port)
--      IB => ADO_LV_in(3)              -- Diff_n clock buffer input (connect directly to top-level port)
--   );

  IBUFDS_inst2 : IBUFDS
    generic map (
      CAPACITANCE      => "NORMAL",     -- "LOW", "NORMAL", "DONT_CARE" (Virtex-4 only)
      DIFF_TERM        => true,         -- Differential Termination (Virtex-4/5, Spartan-3E/3A)
      IBUF_DELAY_VALUE => "0",          -- Specify the amount of added input delay for buffer, 
      -- "0"-"12" (Spartan-3E)
      -- "0"-"16" (Spartan-3A)
      IFD_DELAY_VALUE  => "AUTO",       -- Specify the amount of added delay for input register, 
      -- "AUTO", "0"-"6" (Spartan-3E)
      -- "AUTO", "0"-"8" (Spartan-3A)
      IOSTANDARD       => "LVDS_25")
    port map (
      O                => sig_rnd2,     -- Clock buffer output
      I                => ADO_LV_in(2),  -- Diff_p clock buffer input (connect directly to top-level port)
      IB               => ADO_LV_in(3)  -- Diff_n clock buffer input (connect directly to top-level port)
      );




-- IBUFGDS_inst4 : IBUFGDS
-- generic map (
-- DIFF_TERM => TRUE,                   -- Differential Termination (Virtex-4/5 only)
--      IBUF_DELAY_VALUE => "0",        -- Specify the amount of added input delay for buffer, 
--                               -- "0"-"12" (Spartan-3E)
--                               -- "0"-"16" (Spartan-3A)
--      IOSTANDARD => "LVDS_25")
--   port map (
--      O => sig_rnd3,                  -- Clock buffer output
--      I => ADO_LV_in(4),              -- Diff_p clock buffer input (connect directly to top-level port)
--      IB => ADO_LV_in(5)              -- Diff_n clock buffer input (connect directly to top-level port)
--   );
--      

  IBUFDS_inst3 : IBUFDS
    generic map (
      CAPACITANCE      => "NORMAL",     -- "LOW", "NORMAL", "DONT_CARE" (Virtex-4 only)
      DIFF_TERM        => true,         -- Differential Termination (Virtex-4/5, Spartan-3E/3A)
      IBUF_DELAY_VALUE => "0",          -- Specify the amount of added input delay for buffer, 
      -- "0"-"12" (Spartan-3E)
      -- "0"-"16" (Spartan-3A)
      IFD_DELAY_VALUE  => "AUTO",       -- Specify the amount of added delay for input register, 
      -- "AUTO", "0"-"6" (Spartan-3E)
      -- "AUTO", "0"-"8" (Spartan-3A)
      IOSTANDARD       => "LVDS_25")
    port map (
      O                => sig_rnd3,     -- Clock buffer output
      I                => ADO_LV_in(4),  -- Diff_p clock buffer input (connect directly to top-level port)
      IB               => ADO_LV_in(5)  -- Diff_n clock buffer input (connect directly to top-level port)
      );

--


  ---------------------CLK_OUTs         ------------------------------------------------

-- OBUFDS_inst2 : OBUFDS
-- generic map (
-- IOSTANDARD => "DEFAULT")
-- port map (
-- O => ADO_LV(2),
-- OB => ADO_LV(3),
-- I => clk_x1
-- );
--
--
-- OBUFDS_inst3 : OBUFDS
-- generic map (
-- IOSTANDARD => "DEFAULT")
-- port map (
-- O => ADO_LV(4),
-- OB => ADO_LV(5),
-- I => clk_fx
-- );
--
--

---------------------------------------------------------------------------------

--ADO_LV(2) <= not temp;
--ADO_LV(4) <= CLK;
--ADO_LV(5) <= '0';

--DINT_proc:process(fstate)
--begin
--if(data_ready_ch1 = '1') then
-- DINT <= '0';
--else
-- DINT <= CLK or fifo_rd_en;
--end if;
--end process DINT_proc;


-------------------CLK                  ------------------------
  IBUFGDS_inst : IBUFGDS
    generic map (
      DIFF_TERM        => TRUE,         -- Differential Termination (Virtex-4/5 only)
      IBUF_DELAY_VALUE => "0",          -- Specify the amount of added input delay for buffer, 
      -- "0"-"12" (Spartan-3E)
      -- "0"-"16" (Spartan-3A)
      IOSTANDARD       => "LVDS_25")
    port map (
      O                => CLK,          -- Clock buffer output
      I                => REF_TDC_CLK,  -- Diff_p clock buffer input (connect directly to top-level port)
      IB               => REF_TDC_CLKB  -- Diff_n clock buffer input (connect directly to top-level port)
    );


  CLK_MANAGER_INST:clk_manager
    port map(
      clk_in     => CLK,    -- 200
      reset      => reset,
      clk_x1_out => clk_x1, -- 200
      clk_x2_out => clk_x2, -- 400
      clk_fx_out => open,
      clk_dv_out => clk_100 -- 100
    );


    ------------------------------------------------------------
    --
    tdc_block: block

        signal input_signals        : std_ulogic_vector(2 downto 0);
        signal my_tdc_i0_results    : unsigned_vector(2 downto 0);
        signal timestamp            : std_logic_vector(14 downto 0);
        
        type   state_t is (IDLE, READ_OUT, WRITE_FIFO0, WRITE_FIFO1, WRITE_FIFO2);
        signal state                 : state_t;
                                     
        signal trigger               : std_logic_vector(1 downto 0);
        signal data_cnt              : unsigned(7 downto 0);
                                     
        signal readout_sm_rd_0       : std_logic;
        signal readout_sm_rd_1       : std_logic;
        signal readout_sm_rd_2       : std_logic;

        signal my_tdc_i0_fifo_data0  : std_logic_vector(33 downto 0);
        signal my_tdc_i0_fifo_data1  : std_logic_vector(33 downto 0);
        signal my_tdc_i0_fifo_data2  : std_logic_vector(33 downto 0);

        signal fifo_1kW_i0_dout      : std_logic_vector(33 downto 0);
        signal fifo_1kW_i1_dout      : std_logic_vector(33 downto 0);
        signal fifo_1kW_i2_dout      : std_logic_vector(33 downto 0);
        
        signal fifo_1kW_i0_empty     : std_logic;
        signal fifo_1kW_i1_empty     : std_logic;
        signal fifo_1kW_i2_empty     : std_logic;

    begin
        input_signals <= std_ulogic(sig_rnd3) & std_ulogic(sig_rnd2) & std_ulogic(sig_rnd1);
  
        my_tdc_i0: my_tdc 
            generic map (
                no_channels_g => 3            --     : natural
            )                                 
            port map (                        
                channels => input_signals,    --     : in  std_ulogic_vector(no_channels_g-1 downto 0);
                clk      => clk,              --     : in  std_ulogic;
                results  => my_tdc_i0_results --     : out unsigned_vector(no_channels_g-1 downto 0)
            );
    
        my_tdc_i0_fifo_data0 <= "000" & '0' & "00000" & timestamp & std_logic_vector( resize( my_tdc_i0_results(0), 10));
        my_tdc_i0_fifo_data1 <= "000" & '0' & "00001" & timestamp & std_logic_vector( resize( my_tdc_i0_results(1), 10));
        my_tdc_i0_fifo_data2 <= "000" & '0' & "00010" & timestamp & std_logic_vector( resize( my_tdc_i0_results(2), 10));

        -- Data:
        -- |0|_ch_nummer(5 bit)__|__timestamp(15 bit)__|__fine_value(10 bit)__|
        fifo_1kW_i0: fifo_1kW
            port map (
                rst           => reset, 
                din           => my_tdc_i0_fifo_data0,
                wr_clk        => clk_x2, 
                wr_en         => my_tdc_i0_results(0)(0),
                rd_clk        => CLK,
                rd_en         => readout_sm_rd_0, 
                dout          => fifo_1kW_i0_dout, 
                empty         => fifo_1kW_i0_empty,
                full          => open, 
                rd_data_count => open,
                wr_data_count => open
            );
 
        fifo_1kW_i1: fifo_1kW
            port map (
                rst           => reset, 
                din           => my_tdc_i0_fifo_data1,
                wr_clk        => clk_x2, 
                wr_en         => my_tdc_i0_results(1)(0),
                rd_clk        => CLK,
                rd_en         => readout_sm_rd_1, 
                dout          => fifo_1kW_i1_dout, 
                empty         => fifo_1kW_i1_empty,
                full          => open, 
                rd_data_count => open,
                wr_data_count => open
            );
 
        fifo_1kW_i2: fifo_1kW
            port map (
                rst           => reset, 
                din           => my_tdc_i0_fifo_data2,
                wr_clk        => clk_x2, 
                wr_en         => my_tdc_i0_results(2)(0),
                rd_clk        => CLK,
                rd_en         => readout_sm_rd_2, 
                dout          => fifo_1kW_i2_dout, 
                empty         => fifo_1kW_i2_empty,
                full          => open, 
                rd_data_count => open,
                wr_data_count => open
            );
 
        timestamp <= (others => '1');
        trigger   <= "01"; -- normal, "10" - sync trigger
        
        readout_sm: process
        begin
            wait until rising_edge( CLK);
            readout_sm_rd_0 <= '0';
            readout_sm_rd_1 <= '0';
            readout_sm_rd_2 <= '0';
            fifo_in_data    <= (others => '0');
            fifo_wr_en      <= '0';

            case state is

                when IDLE     =>
                    if (fifo_1kW_i0_empty = '0') or (fifo_1kW_i0_empty = '0') or (fifo_1kW_i0_empty = '0') then
                        -- Header:
                        -- |1|tt|000|0_timestamp(15 bit)__|00|__data_cnt(8bit)*__|
                        fifo_in_data <= '0' & '1' & trigger & "000" & std_logic_vector(timestamp) & "00" & std_logic_vector(data_cnt);
                        fifo_wr_en   <= '1';
                        state        <= READ_OUT;

                    end if;
        
                when READ_OUT =>
                    if    fifo_1kW_i0_empty = '0' then
                        readout_sm_rd_0  <= '1';
                        state            <= WRITE_FIFO0;
                    elsif fifo_1kW_i1_empty = '0' then
                        readout_sm_rd_1  <= '1';
                        state            <= WRITE_FIFO1;
                    elsif fifo_1kW_i2_empty = '0' then
                        readout_sm_rd_2  <= '1';
                        state            <= WRITE_FIFO2;
                    else  -- nothing more to read out
                        state <= IDLE;
                    end if;

                when WRITE_FIFO0 =>
                    fifo_in_data <= fifo_1kW_i0_dout(fifo_in_data'range);
                    fifo_wr_en   <= '1';
                    state        <= READ_OUT;

                when WRITE_FIFO1 =>
                    fifo_in_data <= fifo_1kW_i1_dout(fifo_in_data'range);
                    fifo_wr_en   <= '1';
                    state        <= READ_OUT;

                when WRITE_FIFO2 =>
                    fifo_in_data <= fifo_1kW_i2_dout(fifo_in_data'range);
                    fifo_wr_en   <= '1';
                    state        <= READ_OUT;

            end case;

        end process readout_sm; 
    
    
    end block tdc_block;

    ADO_TTL_36 <= temp_for_pins;
    ADO_TTL_37 <= temp_for_pins;
    ADO_TTL    <= (others => temp_for_pins);





    DINT      <= '0';
    DWAIT     <= readout_busy;
    ETRAX_IRQ <= '1';


end Behavioral;

