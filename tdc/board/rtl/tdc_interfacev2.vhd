library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;


entity tdc_interfacev2 is
  generic (
    ENABLE_DMA          :     positive;
    NUMBER_OFF_ADD_DATA :     natural;
    TRBV2_TYPE          :     natural
    );
  port (
    CLK                 : in  std_logic;
    TDC_CLK             : in  std_logic;  -- for input clock should be
                                          -- through clock buffer
    RESET               : in  std_logic;
    TDC_DATA_IN         : in  std_logic_vector (31 downto 0);
    --data from TDC
    START_TDC_READOUT   : in  std_logic;
    --signal from rpc_trb_v2_fpga - trigger has arrived,one pulse (40MHz long)
    --or 100MHz long  - but make 25 ns from this !!!
    A_TDC_READY         : in  std_logic;
    B_TDC_READY         : in  std_logic;
    C_TDC_READY         : in  std_logic;
    D_TDC_READY         : in  std_logic;
    A_TDC_ERROR         : in  std_logic;
    B_TDC_ERROR         : in  std_logic;
    C_TDC_ERROR         : in  std_logic;
    D_TDC_ERROR         : in  std_logic;
    SEND_TDC_TOKEN      : out std_logic;
    RECEIVED_TDC_TOKEN  : in  std_logic;
    GET_TDC_DATA        : out std_logic;  --Signal to TDC chip

--TDC state mechines has to cut data
--but this should be in FIFO entity and should goes to tdc_interfacev2.vhd (
--to stop writing to fifo just finish read out)
--copyt to internal FIFO

    --add checking of reference time and checking the difference (<= 3)

    --add mem busy

    LVL2_READOUT_COMPLETED : out std_logic;
    LVL1_TAG               : in  std_logic_vector(15 downto 0);
    LVL1_RND_CODE          : in  std_logic_vector(7 downto 0);
    LVL1_CODE              : in  std_logic_vector(3 downto 0);
    LVL2_TAG               : in  std_logic_vector(7 downto 0);
    HOW_MANY_ADD_DATA      : in  std_logic_vector(7 downto 0);
-- ADDITIONAL_DATA : in std_logic_vector(NUMBER_OFF_ADD_DATA*32-1 downto 0);
    LVL2_TRIGGER           : in  std_logic;  --_vector(1 downto 0);
    TDC_DATA_OUT           : out std_logic_vector (31 downto 0);  --data to ETRAX (LVL2)
    TDC_DATA_VALID         : out std_logic;  -- The TDC_DATA_OUT can be written
    ETRAX_IS_READY_TO_READ : in  std_logic;
    ETRAX_IS_BUSY          : in  std_logic;
    LVL1_BUSY              : out std_logic;
    LVL2_BUSY              : out std_logic;
    TDC_REGISTER_00        : out std_logic_vector(31 downto 0);
    TDC_REGISTER_01        : out std_logic_vector(31 downto 0);
    TDC_REGISTER_02        : out std_logic_vector(31 downto 0);
    TDC_REGISTER_03        : out std_logic_vector(31 downto 0);
    TDC_REGISTER_04        : out std_logic_vector(31 downto 0);
    TDC_REGISTER_05        : in  std_logic_vector(31 downto 0);
    BUNCH_RESET            : out std_logic;
    EVENT_RESET            : out std_logic;
    DELAY_TRIGGER          : in  std_logic_vector(7 downto 0);
    DELAY_TOKEN            : in  std_logic_vector(7 downto 0);
    TDC_START              : out std_logic;
    TRIGGER_WITH_GEN_EN    : in  std_logic;
    TRIGGER_WITH_GEN       : in  std_logic;
    TRB_ID                 : in  std_logic_vector(31 downto 0);
    LVL1_FINISHED          : out std_logic;
    LVL2_FINISHED          : out std_logic;
    TRBNET_HEADER_BUILD    : in  std_logic
    );
end tdc_interfacev2;

architecture tdc_interfacev2 of tdc_interfacev2 is

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
      wr_data_count : out std_logic_vector(9 downto 0));
  end component;

-- component fifo_1kW
-- port (
-- din : IN std_logic_VECTOR(33 downto 0);
-- rd_clk : IN std_logic;
-- rd_en : IN std_logic;
-- rst : IN std_logic;
-- wr_clk : IN std_logic;
-- wr_en : IN std_logic;
-- dout : OUT std_logic_VECTOR(33 downto 0);
-- empty : OUT std_logic;
-- full : OUT std_logic;
-- rd_data_count : OUT std_logic_VECTOR(9 downto 0);
-- wr_data_count : OUT std_logic_VECTOR(9 downto 0));
-- end component;

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

  component edge_to_pulse
    port (
      clock     : in  std_logic;
      en_clk    : in  std_logic;
      signal_in : in  std_logic;
      pulse     : out std_logic);
  end component;

  signal tdc_ready        : std_logic;
  signal add_data_counter : unsigned(7 downto 0)  := (others => '0');
  signal add_data_pulse   : std_logic;
  signal first_header     : std_logic_vector(31 downto 0) := (others => '0');
  signal second_header    : std_logic_vector(31 downto 0) := (others => '0');
  signal words_in_event   : std_logic_vector(15 downto 0) := (others => '0');
  signal tdc_data_valid_i : std_logic;

  --signals to delay trigger
  signal delay_up                                    : std_logic;
  signal delay_clr                                   : std_logic;
  signal delay_qout                                  : std_logic_vector(7 downto 0);
  signal lvl1_trigger_pulse_start                    : std_logic;
  signal lvl1_trigger_pulse_delay                    : std_logic;
  type DELAY_FSM_TRIGG is
    (IDLE, DELAY_1, DELAY_2);
  signal delay_fsm_currentstate, delay_fsm_nextstate : DELAY_FSM_TRIGG;


  --lvl1
  type LVL1_START_FSM is
    (IDLE, WAIT_BEFORE_TRIGG, SEND_TRIGGER, WAIT_BEFORE_TOKEN, WAIT_FOR_TOKEN, SEND_AND_WAIT_FOR_TOKEN, SAVE_DATA_MARKER, SAVE_EB_HEADER_1, SAVE_EB_HEADER_2, SAVE_EB_HEADER_3, SAVE_EB_HEADER_4, SAVE_HEADER_1, SAVE_HEADER_2, SAVE_TRBNET_HEADER_1, SAVE_TRBNET_HEADER_2, SAVE_ADD_DATA, SAVE_HEADER_MARKER, WAIT_FOR_EMPTYING_BUFFERS);
  signal LVL1_START_fsm_currentstate, LVL1_START_fsm_nextstate : LVL1_START_FSM;
  signal lvl1_busy_i                                           : std_logic;
  signal lvl1_busy_i_not                                       : std_logic;
  signal lvl1_memory_busy_i                                    : std_logic;
  signal lvl1_trigger_pulse                                    : std_logic;
  signal lvl1_tdc_trigg_i                                      : std_logic;
  signal lvl1_tdc_token_i                                      : std_logic;
  signal lvl1_buffer_in                                        : std_logic_vector(31 downto 0);
  signal lvl1_busy_end_pulse                                   : std_logic;
  signal test_counter_0                                        : std_logic_vector(7 downto 0);  --lvl1 started
  signal test_counter_1                                        : std_logic_vector(7 downto 0);  --lvl` finished
  signal start_tdc_readout_pulse                               : std_logic;
  --lvl2
  type LVL2_START_FSM is
    (IDLE, WAIT_FOR_BUSY_END, READOUT_HEADER_MARKER_1, READOUT_HEADER_MARKER_2, SEND_HEADERS_AND_DATA, READOUT_DATA_MARKER_1, READOUT_DATA_MARKER_2, SEND_DATA);
  signal LVL2_START_fsm_currentstate, LVL2_START_fsm_nextstate : LVL2_START_FSM;
  signal lvl2_busy_i                                           : std_logic;
  signal not_lvl2_busy                                         : std_logic;
  signal lvl2_busy_end_pulse                                   : std_logic;
  signal test_counter_2                                        : std_logic_vector(7 downto 0);  --lvl2 started 
  signal test_counter_3                                        : std_logic_vector(7 downto 0);  --lvl2 finished

  --debug registers
  signal trigger_register_00_i : std_logic_vector(5 downto 0);
  signal add_data_i            : std_logic_vector(31 downto 0);





  signal trigger_with_gen_pulse : std_logic;
  signal lvl1_tag_minus1        : std_logic_vector(7 downto 0);
  signal lvl2_debug             : std_logic_vector(3 downto 0);
  signal tdc_start_i            : std_logic;
  signal lvl2_busy_start_pulse  : std_logic;

  signal lvl1_tdc_trigg_i_fsm : std_logic;
  signal lvl1_tdc_token_i_fsm : std_logic;

  signal lvl1_busy_i_fsm      : std_logic;
  signal tdc_data_valid_i_fsm : std_logic;
  signal lvl1_data_counter    : std_logic_vector(15 downto 0) := (others => '0');
  signal trigger_counter      : unsigned(7 downto 0);
  signal lvl1_code_i          : std_logic_vector(3 downto 0);

  signal lvl2_trigger_pulse : std_logic;

  signal additional_data_i               : std_logic_vector(NUMBER_OFF_ADD_DATA*32-1 downto 0);
  signal reg_address                     : integer range 0 to 8 := 1;
  signal event_number_cntr               : std_logic_vector(23 downto 0);
  signal full_event_size                 : std_logic_vector(31 downto 0);
  signal lvl1_trigger_hades_or_not       : std_logic;
  signal lvl1_trigger_hades_or_not_pulse : std_logic;

-------------------------------------------------------------------------------
-- new
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--data fifo
  signal data_din_i           : std_logic_vector(33 downto 0);
  signal data_rd_en_i         : std_logic;
  signal data_wr_en_i         : std_logic;
  signal data_dout_i          : std_logic_vector(33 downto 0) := (others => '0');
  signal data_empty_i         : std_logic;
  signal data_full_i          : std_logic;
  signal data_rd_data_count_i : std_logic_vector(9 downto 0);
  signal data_wr_data_count_i : std_logic_vector(9 downto 0);
  --in fsm
  signal data_din_i_fsm       : std_logic_vector(33 downto 0);
  signal data_rd_en_i_fsm     : std_logic;
  signal data_wr_en_i_fsm     : std_logic;

--headers and additional data fifo
  signal hd_din_i           : std_logic_vector(33 downto 0);
  signal hd_rd_en_i         : std_logic;
  signal hd_wr_en_i         : std_logic;
  signal hd_dout_i          : std_logic_vector(33 downto 0) := (others => '0');
  signal hd_empty_i         : std_logic;
  signal hd_full_i          : std_logic;
  signal hd_rd_data_count_i : std_logic_vector(9 downto 0);
  signal hd_wr_data_count_i : std_logic_vector(9 downto 0);
  --in fsm
  signal hd_din_i_fsm       : std_logic_vector(33 downto 0);
  signal hd_rd_en_i_fsm     : std_logic;
  signal hd_wr_en_i_fsm     : std_logic;

  --TDC
  signal received_tdc_token_i : std_logic;
  signal lvl1_trigger_tdc     : std_logic;

  --counters for token and trigger delay 
  signal wait_for_token_clr  : std_logic;
  signal wait_for_token_up   : std_logic;
  signal wait_for_token_cntr : std_logic_vector(7 downto 0);
  signal wait_for_trigg_clr  : std_logic;
  signal wait_for_trigg_up   : std_logic;
  signal wait_for_trigg_cntr : std_logic_vector(7 downto 0);

begin

  TDC_REGISTER : process (CLK, RESET)
  begin
    if rising_edge(CLK) then
      TDC_REGISTER_00(0)            <= A_TDC_ERROR;
      TDC_REGISTER_00(1)            <= B_TDC_ERROR;
      TDC_REGISTER_00(2)            <= C_TDC_ERROR;
      TDC_REGISTER_00(3)            <= D_TDC_ERROR;
      TDC_REGISTER_00(13 downto 4)  <= (others => '0');
      TDC_REGISTER_00(14)           <= lvl1_busy_i;
      TDC_REGISTER_00(15)           <= lvl1_memory_busy_i;
      TDC_REGISTER_00(30)           <= '0';
      TDC_REGISTER_00(31)           <= lvl2_busy_i;
      TDC_REGISTER_00(29 downto 16) <= (others => '0');
      TDC_REGISTER_01(27 downto 0)  <= lvl2_debug & trigger_register_00_i(5 downto 2) & "00" & trigger_register_00_i(1 downto 0)& words_in_event(15 downto 0);
      TDC_REGISTER_01(30 downto 28) <= (others => '0');
      TDC_REGISTER_01(31)           <= ETRAX_IS_BUSY;
      --     TDC_REGISTER_02(31 downto 0)  <=  hd_full_i & hd_empty_i & hd_wr_en_i & hd_dout_i(32) & hd_rd_data_count_i & data_full_i & data_empty_i & data_wr_en_i  & data_dout_i(32) & data_rd_data_count_i(11 downto 0);
      TDC_REGISTER_02(31 downto 0)  <= (others => '0');
      TDC_REGISTER_03(31 downto 0)  <= x"0"& LVL1_CODE & LVL1_TAG(7 downto 0) & x"0" & lvl1_code_i & lvl1_tag_minus1;
      TDC_REGISTER_04(31 downto 0)  <= test_counter_3 & test_counter_2 & test_counter_1 & test_counter_0;
    end if;
  end process TDC_REGISTER;


  SYNC_TDC_DATA : process (TDC_CLK, RESET)
  begin
    if rising_edge(TDC_CLK) then
      if RESET = '1' then
        tdc_ready            <= '0';
        lvl1_buffer_in       <= (others => '0');
        received_tdc_token_i <= '0';
      else
        tdc_ready            <= A_TDC_READY or B_TDC_READY or C_TDC_READY or D_TDC_READY;
        lvl1_buffer_in       <= TDC_DATA_IN;
        received_tdc_token_i <= RECEIVED_TDC_TOKEN;
      end if;
    end if;
  end process SYNC_TDC_DATA;

  GET_TDC_DATA <= '1';

  INTERNAL_TRIGGER_FOR_EVENT_BUILDER : up_down_counter
    generic map (
      NUMBER_OF_BITS => 24)
    port map (
      CLK            => TDC_CLK,
      RESET          => RESET,
      COUNT_OUT      => event_number_cntr,
      UP_IN          => received_tdc_token_i,
      DOWN_IN        => '0');

  SEND_BUNCH_RESET : process (TDC_CLK, RESET)
  begin
    if rising_edge(TDC_CLK) then
      if RESET = '1' then
        BUNCH_RESET <= '1';
        EVENT_RESET <= '1';
      else
        EVENT_RESET <= '0';
        BUNCH_RESET <= received_tdc_token_i;
      end if;
    end if;
  end process SEND_BUNCH_RESET;

  -- LVL1 logic

  LVL1_PULSER : edge_to_pulse
    port map (
      clock     => TDC_CLK,
      en_clk    => '1',
      signal_in => START_TDC_READOUT,
      pulse     => start_tdc_readout_pulse);

  SELECT_TRIGGER : process (CLK, RESET)
  begin
    if rising_edge(CLK) then
      if RESET = '1' or lvl1_trigger_hades_or_not_pulse = '1' then
        lvl1_trigger_hades_or_not <= '0';
      elsif start_tdc_readout_pulse = '1' then
        lvl1_trigger_hades_or_not <= '1';
      else
        lvl1_trigger_hades_or_not <= lvl1_trigger_hades_or_not;
-- lvl1_trigger_hades_or_not <= TRIGGER_WITH_GEN_EN and TRIGGER_WITH_GEN and (not lvl1_busy_i) and (not lvl2_busy_i);
      end if;
    end if;
  end process SELECT_TRIGGER;

  TDC_LVL1_PULSER : edge_to_pulse
    port map (
      clock     => TDC_CLK,
      en_clk    => '1',
      signal_in => lvl1_trigger_hades_or_not,
      pulse     => lvl1_trigger_hades_or_not_pulse);

  MAKE_CORRECT_LVL1_LENGHT : process (CLK, RESET)
  begin
    if rising_edge(CLK) then
      if RESET = '1' or LVL1_START_fsm_currentstate = WAIT_BEFORE_TOKEN then
        lvl1_trigger_tdc <= '0';
      elsif lvl1_trigger_hades_or_not_pulse = '1' then
        lvl1_trigger_tdc <= '1';
      else
        lvl1_trigger_tdc <= lvl1_trigger_tdc;
      end if;
    end if;
  end process MAKE_CORRECT_LVL1_LENGHT;

  DELAY_FOR_TOKEN_CNTR : up_down_counter
    generic map (
      NUMBER_OF_BITS => 8)
    port map (
      CLK            => TDC_CLK,
      RESET          => wait_for_token_clr,
      COUNT_OUT      => WAIT_FOR_TOKEN_cntr,
      UP_IN          => wait_for_token_up,
      DOWN_IN        => '0');

  DELAY_FOR_TRIGGER_CNTR : up_down_counter
    generic map (
      NUMBER_OF_BITS => 8)
    port map (
      CLK            => TDC_CLK,
      RESET          => wait_for_trigg_clr,
      COUNT_OUT      => wait_for_trigg_cntr,
      UP_IN          => wait_for_trigg_up,
      DOWN_IN        => '0');

  LVL1_DATA_FIFO : fifo_1kW
    port map (
      din           => data_din_i,
      rd_clk        => CLK,
      rd_en         => data_rd_en_i,
      rst           => RESET,
      wr_clk        => TDC_CLK,
      wr_en         => data_wr_en_i,
      dout          => data_dout_i,
      empty         => data_empty_i,
      full          => data_full_i,
      rd_data_count => data_rd_data_count_i,
      wr_data_count => data_wr_data_count_i);

  HEADER_DATA_FIFO : fifo_1kW
    port map (
      din           => hd_din_i,
      rd_clk        => CLK,
      rd_en         => hd_rd_en_i,
      rst           => RESET,
      wr_clk        => TDC_CLK,
      wr_en         => hd_wr_en_i,
      dout          => hd_dout_i,
      empty         => hd_empty_i,
      full          => hd_full_i,
      rd_data_count => hd_rd_data_count_i,
      wr_data_count => hd_wr_data_count_i);

  LVL1_START : process (TDC_CLK, RESET)
  begin
    if rising_edge(TDC_CLK) then
      if RESET = '1' then
        LVL1_START_fsm_currentstate <= IDLE;
        lvl1_busy_i                 <= '0';
        lvl1_tdc_trigg_i            <= '0';
        lvl1_tdc_token_i            <= '0';
        data_wr_en_i                <= '0';
        hd_wr_en_i                  <= '0';
        data_din_i                  <= (others => '0');
        hd_din_i                    <= (others => '0');
      else
        LVL1_START_fsm_currentstate <= LVL1_START_fsm_nextstate;
        lvl1_tdc_trigg_i            <= lvl1_tdc_trigg_i_fsm;
        lvl1_tdc_token_i            <= lvl1_tdc_token_i_fsm;
        lvl1_busy_i                 <= lvl1_busy_i_fsm;
        data_wr_en_i                <= data_wr_en_i_fsm;
        hd_wr_en_i                  <= hd_wr_en_i_fsm;
        data_din_i                  <= data_din_i_fsm;
        hd_din_i                    <= hd_din_i_fsm;
      end if;
    end if;
  end process LVL1_START;

  LVL1_START_FSM_PROC : process (LVL1_START_fsm_currentstate, received_tdc_token_i, trigger_with_gen_pulse, lvl1_trigger_pulse_start, add_data_counter, lvl1_data_counter, how_many_add_data, lvl1_code, trigger_with_gen_en, add_data_i, second_header, first_header, TDC_CLK)
  begin
    lvl1_tdc_trigg_i_fsm     <= '0';
    lvl1_tdc_token_i_fsm     <= '0';
    add_data_pulse           <= '0';
    LVL1_START_fsm_nextstate <= IDLE;
    lvl1_busy_i_fsm          <= '1';
    data_wr_en_i_fsm         <= '0';
    hd_wr_en_i_fsm           <= '0';
    data_din_i_fsm           <= (others => '0');
    hd_din_i_fsm             <= (others => '0');
    wait_for_token_up        <= '0';
    wait_for_token_clr       <= '1';
    wait_for_trigg_up        <= '0';
    wait_for_trigg_clr       <= '1';

    case (LVL1_START_fsm_currentstate) is

      when IDLE                    =>
        trigger_register_00_i(5 downto 2) <= x"1";
        lvl1_busy_i_fsm                   <= '0';
        if (lvl1_trigger_tdc = '1'and LVL1_CODE /= x"d") then
          LVL1_START_fsm_nextstate        <= WAIT_BEFORE_TRIGG;
        else
          LVL1_START_fsm_nextstate        <= IDLE;
        end if;
      when WAIT_BEFORE_TRIGG       =>
        trigger_register_00_i(5 downto 2) <= x"2";
        wait_for_trigg_up                 <= '1';
        wait_for_trigg_clr                <= '0';
        if wait_for_trigg_cntr = DELAY_TRIGGER then
          LVL1_START_fsm_nextstate        <= SEND_TRIGGER;
        else
          LVL1_START_fsm_nextstate        <= WAIT_BEFORE_TRIGG;
        end if;
      when SEND_TRIGGER            =>
        trigger_register_00_i(5 downto 2) <= x"2";
        lvl1_tdc_trigg_i_fsm              <= '1';
        LVL1_START_fsm_nextstate          <= WAIT_BEFORE_TOKEN;
      when WAIT_BEFORE_TOKEN       =>
        trigger_register_00_i(5 downto 2) <= x"2";
        wait_for_token_up                 <= '1';
        wait_for_token_clr                <= '0';
        if wait_for_token_cntr = DELAY_TOKEN then
          LVL1_START_fsm_nextstate        <= SEND_AND_WAIT_FOR_TOKEN;
        else
          LVL1_START_fsm_nextstate        <= WAIT_BEFORE_TOKEN;
        end if;
      when SEND_AND_WAIT_FOR_TOKEN =>
        trigger_register_00_i(5 downto 2) <= x"3";
        lvl1_tdc_token_i_fsm              <= '1';
        data_wr_en_i_fsm                  <= tdc_ready;
        data_din_i_fsm                    <= "01" & lvl1_buffer_in;
        if received_tdc_token_i = '1' then
          LVL1_START_fsm_nextstate        <= SAVE_DATA_MARKER;
        else
          LVL1_START_fsm_nextstate        <= SEND_AND_WAIT_FOR_TOKEN;
        end if;

      when SAVE_DATA_MARKER                          =>
        trigger_register_00_i(5 downto 2) <= x"4";
        data_wr_en_i_fsm                  <= '1';
        data_din_i_fsm                    <= (others => '0');
        if TDC_REGISTER_05(31) = '1' then
          LVL1_START_fsm_nextstate        <= SAVE_EB_HEADER_1;
        elsif TRBNET_HEADER_BUILD = '1' then
          LVL1_START_fsm_nextstate        <= SAVE_TRBNET_HEADER_1;
        else
          LVL1_START_fsm_nextstate        <= SAVE_HEADER_1;
        end if;

      when SAVE_EB_HEADER_1 =>
        hd_wr_en_i_fsm                    <= '1';
        hd_din_i_fsm                      <= std_logic_vector( unsigned( "01" & x"000" & "00" & words_in_event & "00") + 16);
        trigger_register_00_i(5 downto 2) <= x"5";
        LVL1_START_fsm_nextstate          <= SAVE_EB_HEADER_2;

      when SAVE_EB_HEADER_2 =>
        hd_wr_en_i_fsm                    <= '1';
        hd_din_i_fsm                      <= "01" & x"00020001";
        trigger_register_00_i(5 downto 2) <= x"6";
        LVL1_START_fsm_nextstate          <= SAVE_EB_HEADER_3;

      when SAVE_EB_HEADER_3 =>
        hd_wr_en_i_fsm                    <= '1';
        hd_din_i_fsm                      <= "01" & TRB_ID;
        trigger_register_00_i(5 downto 2) <= x"7";
        LVL1_START_fsm_nextstate          <= SAVE_EB_HEADER_4;

      when SAVE_EB_HEADER_4 =>
        hd_wr_en_i_fsm                    <= '1';
        hd_din_i_fsm                      <= "01" & std_logic_vector(unsigned(event_number_cntr) - 1) & (lvl1_tag_minus1);
        trigger_register_00_i(5 downto 2) <= x"8";
        if TRBNET_HEADER_BUILD = '1' then
          LVL1_START_fsm_nextstate        <= SAVE_TRBNET_HEADER_1;
        else
          LVL1_START_fsm_nextstate        <= SAVE_HEADER_1;
        end if;

      when SAVE_TRBNET_HEADER_1 =>
        hd_wr_en_i_fsm                    <= '1';
        trigger_register_00_i(5 downto 2) <= x"d";
        hd_din_i_fsm                      <= "01" & x"0" & lvl1_code_i & LVL1_RND_CODE & LVL1_TAG;
        LVL1_START_fsm_nextstate          <= SAVE_TRBNET_HEADER_2;

      when SAVE_TRBNET_HEADER_2 =>
        hd_wr_en_i_fsm                    <= '1';
        trigger_register_00_i(5 downto 2) <= x"e";
        hd_din_i_fsm                      <= "01" & words_in_event & x"0000";
        LVL1_START_fsm_nextstate          <= SAVE_HEADER_2;

      when SAVE_HEADER_1 =>
        hd_wr_en_i_fsm                    <= '1';
        hd_din_i_fsm                      <= "01" & x"0" & lvl1_code_i & lvl1_tag_minus1 & words_in_event;
        trigger_register_00_i(5 downto 2) <= x"9";
        LVL1_START_fsm_nextstate          <= SAVE_HEADER_2;

      when SAVE_HEADER_2 =>
        hd_wr_en_i_fsm                    <= '1';
        hd_din_i_fsm                      <= "01" & TDC_REGISTER_05(15 downto 8) & x"0000" & HOW_MANY_ADD_DATA;
        trigger_register_00_i(5 downto 2) <= x"a";
        --if add_data_counter > 0  then
        --  LVL1_START_fsm_nextstate   <= SAVE_ADD_DATA;
        --else
        LVL1_START_fsm_nextstate          <= SAVE_HEADER_MARKER;
        --end if;

      when SAVE_ADD_DATA =>
        trigger_register_00_i(5 downto 2) <= x"b";
        hd_wr_en_i_fsm                    <= '1';
        hd_din_i_fsm                      <= "01" & add_data_i;
        if add_data_counter = x"00" then  -- adapt to fifo, memory (  --external)?
          LVL1_START_fsm_nextstate        <= SAVE_HEADER_MARKER;
        else
          LVL1_START_fsm_nextstate        <= SAVE_ADD_DATA;
        end if;

      when SAVE_HEADER_MARKER                        =>
        trigger_register_00_i(5 downto 2) <= x"c";
        hd_wr_en_i_fsm                    <= '1';
        hd_din_i_fsm                      <= (others => '0');
        --here add memory busy
        if lvl1_memory_busy_i = '0' then
          LVL1_START_fsm_nextstate        <= IDLE;
        else
          LVL1_START_fsm_nextstate        <= WAIT_FOR_EMPTYING_BUFFERS;
        end if;

      when WAIT_FOR_EMPTYING_BUFFERS =>
        trigger_register_00_i(5 downto 2) <= x"d";
        if lvl1_memory_busy_i = '0' then
          LVL1_START_fsm_nextstate        <= IDLE;
        else
          LVL1_START_fsm_nextstate        <= WAIT_FOR_EMPTYING_BUFFERS;
        end if;

      when others =>
        trigger_register_00_i(5 downto 2) <= x"0";
        LVL1_START_fsm_nextstate          <= IDLE;
    end case;
  end process LVL1_START_FSM_PROC;

  TDC_TRIGGER_PULSER : edge_to_pulse
    port map (
      clock     => TDC_CLK,
      en_clk    => '1',
      signal_in => lvl1_tdc_trigg_i,
      pulse     => TDC_START);

  TDC_TOKEN_PULSER : edge_to_pulse
    port map (
      clock     => TDC_CLK,
      en_clk    => '1',
      signal_in => lvl1_tdc_token_i,
      pulse     => SEND_TDC_TOKEN);

-- SAVE_DATA : process (CLK, RESET,lvl1_tdc_trigg_i)
-- begin
-- if rising_edge(CLK) then
-- if RESET = '1' then
-- additional_data_i <= (others => '1');
-- elsif lvl1_tdc_trigg_i = '1' then
-- additional_data_i <= ADDITIONAL_DATA;
-- end if;
-- end if;
-- end process SAVE_DATA;

-- CHOOSE_DATA : process (CLK, RESET, add_data_counter)
-- begin
-- if rising_edge(CLK) then
-- if RESET = '1' then
-- reg_address <= 1;
-- add_data_i <= x"00000000";
-- elsif reg_address > 0 then
-- reg_address <= conv_integer(add_data_counter);
-- add_data_i <= additional_data_i(reg_address*32-1 downto 0);
-- else
-- reg_address <= 1;
-- add_data_i <= x"00000000";
-- end if;
-- end if;
-- end process CHOOSE_DATA;

-- add_data_pulse <= '1' when SAVE_ADD_DATA_3 = LVL1_START_fsm_nextstate else '0';

  ADD_DATA_COUNTER_CONTROL : process (CLK, RESET, lvl1_tdc_trigg_i, add_data_pulse)
  begin
    if rising_edge(CLK) then
      if RESET = '1' or lvl1_tdc_trigg_i = '1' then
        add_data_counter <= unsigned(x"0" & HOW_MANY_ADD_DATA(3 downto 0));
      elsif add_data_pulse = '1' then
        add_data_counter <= add_data_counter -1;
      end if;
    end if;
  end process ADD_DATA_COUNTER_CONTROL;

  COUNT_WORDS_IN_EVENT : process (TDC_CLK, RESET, tdc_ready, lvl1_tdc_trigg_i)
  begin
    if rising_edge(TDC_CLK) then
      if RESET = '1' or lvl1_tdc_trigg_i = '1' then
        words_in_event <= std_logic_vector(x"0002" + unsigned(HOW_MANY_ADD_DATA));
      elsif tdc_ready = '1' then
        words_in_event <= std_logic_vector(unsigned(words_in_event) + 1);
      end if;
    end if;
  end process COUNT_WORDS_IN_EVENT;

  TRIGGER_COUNTER_PROC : process (CLK, RESET, LVL1_START_fsm_currentstate)
  begin
    if rising_edge(TDC_CLK) then
      if RESET = '1' then
        trigger_counter <= x"ff";
      elsif LVL1_START_fsm_currentstate = SAVE_DATA_MARKER then
        trigger_counter <= trigger_counter + 1;
      else
        trigger_counter <= trigger_counter;
      end if;
    end if;
  end process TRIGGER_COUNTER_PROC;

  SAVE_CODE_AND_TAG : process (CLK, RESET)
  begin
    if rising_edge(CLK) then
      if RESET = '1' then
        lvl1_tag_minus1 <= (others => '0');
        lvl1_code_i     <= (others => '0');
      elsif TRIGGER_WITH_GEN_EN = '1' then
        lvl1_tag_minus1 <= std_logic_vector(trigger_counter);
        lvl1_code_i     <= x"1";
      else
        lvl1_tag_minus1 <= LVL1_TAG(7 downto 0);
        lvl1_code_i     <= LVL1_CODE;
      end if;
    end if;
  end process SAVE_CODE_AND_TAG;

  -----------------------------------------------------------------------------
  ----------------------------------------------------------------------------
  -- LVL2 logic (only CLK domain)
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------

  LVL2_START : process (CLK, RESET)
  begin
    if rising_edge(CLK) then
      if RESET = '1' then
        LVL2_START_fsm_currentstate <= IDLE;
        tdc_data_valid_i            <= '0';
        data_rd_en_i                <= '0';
        hd_rd_en_i                  <= '0';
      else
        tdc_data_valid_i            <= tdc_data_valid_i_fsm;
        LVL2_START_fsm_currentstate <= LVL2_START_fsm_nextstate;
        data_rd_en_i                <= data_rd_en_i_fsm;
        hd_rd_en_i                  <= hd_rd_en_i_fsm;
      end if;
    end if;
  end process LVL2_START;

  LVL2_TRIGG_PULSER : edge_to_pulse
    port map (
      clock     => CLK,
      en_clk    => '1',
      signal_in => LVL2_TRIGGER,
      pulse     => lvl2_trigger_pulse);

  START_LVL2_FSM : process (LVL2_TRIGGER, LVL2_START_fsm_currentstate, LVL1_START_fsm_currentstate, ETRAX_IS_BUSY, ETRAX_IS_READY_TO_READ, hd_dout_i, data_dout_i, clk)
  begin
    lvl2_busy_i              <= '1';
    lvl2_debug               <= x"a";
    tdc_data_valid_i_fsm     <= '0';
    LVL2_START_fsm_nextstate <= IDLE;
    TDC_DATA_OUT             <= (others => '0');
    data_rd_en_i_fsm         <= '0';
    hd_rd_en_i_fsm           <= '0';

    case (LVL2_START_fsm_currentstate) is
      when IDLE =>
        lvl2_debug                 <= x"1";
        lvl2_busy_i                <= '0';
        if lvl2_trigger_pulse = '1' or (TRIGGER_WITH_GEN_EN = '1' and LVL1_START_fsm_currentstate = SAVE_HEADER_MARKER ) or ( LVL1_START_fsm_currentstate = SAVE_HEADER_MARKER and TRBV2_TYPE = 5)then
          LVL2_START_fsm_nextstate <= WAIT_FOR_BUSY_END;  --READOUT_WORD1;  --SAVE_EVENT_SIZE;
        else
          LVL2_START_fsm_nextstate <= IDLE;
        end if;

      when WAIT_FOR_BUSY_END =>
        lvl2_debug                 <= x"2";
        if ETRAX_IS_BUSY = '0' then
          LVL2_START_fsm_nextstate <= READOUT_HEADER_MARKER_1;
        else
          LVL2_START_fsm_nextstate <= WAIT_FOR_BUSY_END;
        end if;

      when READOUT_HEADER_MARKER_1 =>
        lvl2_debug                 <= x"3";
        if hd_dout_i(32) = '0' then
          hd_rd_en_i_fsm           <= '1';
          LVL2_START_fsm_nextstate <= READOUT_HEADER_MARKER_2;
        else
          hd_rd_en_i_fsm           <= '0';
          LVL2_START_fsm_nextstate <= SEND_HEADERS_AND_DATA;
        end if;

      when READOUT_HEADER_MARKER_2 =>
        lvl2_debug               <= x"4";
        LVL2_START_fsm_nextstate <= READOUT_HEADER_MARKER_1;

      when SEND_HEADERS_AND_DATA =>
        lvl2_debug                 <= x"5";
        hd_rd_en_i_fsm             <= ETRAX_IS_READY_TO_READ;
        tdc_data_valid_i_fsm       <= hd_dout_i(32);
        TDC_DATA_OUT               <= hd_dout_i(31 downto 0);
        if hd_dout_i(32) = '0' then
          LVL2_START_fsm_nextstate <= READOUT_DATA_MARKER_1;
        else
          LVL2_START_fsm_nextstate <= SEND_HEADERS_AND_DATA;
        end if;

      when READOUT_DATA_MARKER_1 =>
        lvl2_debug                 <= x"6";
        if data_dout_i(32) = '0' then
          data_rd_en_i_fsm         <= '1';
          LVL2_START_fsm_nextstate <= READOUT_DATA_MARKER_2;
        else
          data_rd_en_i_fsm         <= '0';
          LVL2_START_fsm_nextstate <= SEND_DATA;
        end if;

      when READOUT_DATA_MARKER_2 =>
        lvl2_debug               <= x"7";
        LVL2_START_fsm_nextstate <= READOUT_DATA_MARKER_1;

      when SEND_DATA =>
        lvl2_debug                 <= x"8";
        data_rd_en_i_fsm           <= ETRAX_IS_READY_TO_READ;
        tdc_data_valid_i_fsm       <= data_dout_i(32);
        TDC_DATA_OUT               <= data_dout_i(31 downto 0);
        if data_dout_i(32) = '0' then
          LVL2_START_fsm_nextstate <= IDLE;
        else
          LVL2_START_fsm_nextstate <= SEND_DATA;
        end if;

      when others =>
        lvl2_debug               <= x"9";
        LVL2_START_fsm_nextstate <= IDLE;

    end case;
  end process START_LVL2_FSM;


  TDC_DATA_VALID <= tdc_data_valid_i;
  not_lvl2_busy  <= not lvl2_busy_i;

  LVL2_BUSY_END_PULSER : edge_to_pulse
    port map (
      clock     => CLK,
      en_clk    => '1',
      signal_in => not_lvl2_busy,
      pulse     => lvl2_busy_end_pulse);

  LVL2_BUSY_START_PULSER : edge_to_pulse
    port map (
      clock     => CLK,
      en_clk    => '1',
      signal_in => lvl2_busy_i,
      pulse     => lvl2_busy_start_pulse);
                                        --set
                                        --to
                                        --max
                                        --value
                                        --!!!!!!! and cut data process should
                                        --be implemented - with busy or max
                                        --size or last event ? or both
  LVL2_BUSY              <= lvl2_busy_i;
  LVL2_READOUT_COMPLETED <= lvl2_busy_end_pulse;


  LVL1_STARTED_CNTR : up_down_counter
    generic map (
      NUMBER_OF_BITS => 8)
    port map (
      CLK            => TDC_CLK,
      RESET          => RESET,
      COUNT_OUT      => test_counter_0,
      UP_IN          => lvl1_tdc_trigg_i,
      DOWN_IN        => '0');

  LVL1_FINISHED_CNTR : up_down_counter
    generic map (
      NUMBER_OF_BITS => 8)
    port map (
      CLK            => TDC_CLK,
      RESET          => RESET,
      COUNT_OUT      => test_counter_1,
      UP_IN          => received_tdc_token_i,
      DOWN_IN        => '0');

  lvl1_busy_i_not <= not lvl1_busy_i;
  LVL1_BUSY_END_PULSER : edge_to_pulse
    port map (
      clock     => CLK,
      en_clk    => '1',
      signal_in => lvl1_busy_i_not,
      pulse     => lvl1_busy_end_pulse);

  LVL1_FINISHED <= lvl1_busy_end_pulse;

  LVL2_STARTED_CNTR : up_down_counter
    generic map (
      NUMBER_OF_BITS => 8)
    port map (
      CLK            => CLK,
      RESET          => RESET,
      COUNT_OUT      => test_counter_2,
      UP_IN          => lvl2_busy_start_pulse,
      DOWN_IN        => '0');

  LVL2_FINISHED_CNTR : up_down_counter
    generic map (
      NUMBER_OF_BITS => 8)
    port map (
      CLK            => CLK,
      RESET          => RESET,
      COUNT_OUT      => test_counter_3,
      UP_IN          => lvl2_busy_end_pulse,
      DOWN_IN        => '0');

  LVL2_FINISHED <= lvl2_busy_end_pulse;

  LVL1_MEMOMRY_BUSY_PROC : process (CLK, RESET)
  begin
    if rising_edge(CLK) then
      if RESET = '1' then
        lvl1_memory_busy_i <= '0';
      elsif (data_wr_data_count_i(9 downto 8) = "11") or (hd_wr_data_count_i(9 downto 2) = x"ff") then
        lvl1_memory_busy_i <= '1';
      else
        lvl1_memory_busy_i <= '0';
      end if;
    end if;
  end process LVL1_MEMOMRY_BUSY_PROC;



  REGISTERING_SIGNALS : process (CLK, RESET)
  begin
    if rising_edge(CLK) then            -- rising clock edge
      if RESET = '1' then
        LVL1_BUSY <= '0';
      else
        LVL1_BUSY <= lvl1_busy_i or lvl1_memory_busy_i;  --lvl1_busy_i or lvl1_memory_busy_i;--lvl1_or_lvl2_is_busy;--lvl1_busy_i;  --here
      end if;
    end if;
  end process REGISTERING_SIGNALS;

end tdc_interfacev2;
