----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:34:08 09/29/2009 
-- Design Name: 
-- Module Name:    readout_modul - Behavioral 
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
use work.tdline_pack.all;



entity readout_modul is
  port(
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
    FS_PB               : inout std_logic_vector (16 downto 0);
    FS_PB_17            : in    std_logic
    );
end readout_modul;

architecture Behavioral of readout_modul is

  component edge_to_pulse is
                            port (
                              clock     : in  std_logic;
                              en_clk    : in  std_logic;
                              signal_in : in  std_logic;
                              pulse     : out std_logic);
  end component;


  component etrax_interfacev2
    generic (
      ENABLE_DMA             :       positive;
      RW_SYSTEM              :       positive;
      RW_REGISTERS_NUMBER    :       natural;
      R_REGISTERS_NUMBER     :       natural;
      TRBNET_ENABLE          :       natural);
    port (
      clk                    : in    std_logic;
      RESET                  : in    std_logic;
      DATA_BUS               : in    std_logic_vector(31 downto 0);
      ETRAX_DATA_BUS_B       : inout std_logic_vector(16 downto 0);
      ETRAX_DATA_BUS_B_17    : in    std_logic;
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
      TRB_LVL2_BUSY          : in    std_logic);
  end component;

  component tdc_interfacev2
    generic (
      ENABLE_DMA             :     positive;
      NUMBER_OFF_ADD_DATA    :     natural;
      TRBV2_TYPE             :     natural);
    port (
      clk                    : in  std_logic;
      TDC_clk                : in  std_logic;
      RESET                  : in  std_logic;
      TDC_DATA_IN            : in  std_logic_vector (31 downto 0);
      START_TDC_READOUT      : in  std_logic;
      A_TDC_READY            : in  std_logic;
      B_TDC_READY            : in  std_logic;
      C_TDC_READY            : in  std_logic;
      D_TDC_READY            : in  std_logic;
      A_TDC_ERROR            : in  std_logic;
      B_TDC_ERROR            : in  std_logic;
      C_TDC_ERROR            : in  std_logic;
      D_TDC_ERROR            : in  std_logic;
      SEND_TDC_TOKEN         : out std_logic;
      RECEIVED_TDC_TOKEN     : in  std_logic;
      GET_TDC_DATA           : out std_logic;
      LVL2_READOUT_COMPLETED : out std_logic;
      LVL1_TAG               : in  std_logic_vector(15 downto 0);
      LVL1_RND_CODE          : in  std_logic_vector(7 downto 0);
      LVL1_CODE              : in  std_logic_vector(3 downto 0);
      LVL2_TAG               : in  std_logic_vector(7 downto 0);
      HOW_MANY_ADD_DATA      : in  std_logic_vector(7 downto 0);
-- ADDITIONAL_DATA : in std_logic_vector(NUMBER_OFF_ADD_DATA*32-1 downto 0);
      LVL2_TRIGGER           : in  std_logic;
      TDC_DATA_OUT           : out std_logic_vector (31 downto 0);
      TDC_DATA_VALID         : out std_logic;
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
      TRBNET_HEADER_BUILD    : in  std_logic);
  end component;




-------------------------------------------------------------------------------
-- SIGNALS
-------------------------------------------------------------------------------

-- constant VaaaaaaaaaERSION_NUMBER_TIME : integer := 1245150983;  --interface
  constant HOW_MANY_CHANNELS : integer := 1;

  --clk
  signal                           clk_lvds   : std_logic;
  signal                           addon_clk  : std_logic;
  --signal clk              : std_logic;
  signal                           clk50      : std_logic;
  signal                           clk200     : std_logic;
  signal                           locked_out : std_logic;
  attribute period                            : string;
  attribute period of clk                     : signal is "10 ns";

  --reset
  --signal global_reset_counter : std_logic_vector(3 downto 0) := x"0";
  -- signal reset_i              : std_logic                    := '0';

  --TDC
  signal tdc_clk                      : std_logic;
  signal tdc_clk_i                    : std_logic;
  signal tdc_data_in_i                : std_logic_vector(31 downto 0);
  signal a_data_ready_i               : std_logic;
-- signal b_data_ready_i : std_logic;
-- signal c_data_ready_i : std_logic;
-- signal d_data_ready_i : std_logic;
  signal a_trigg                      : std_logic;
-- signal b_trigg : std_logic;
-- signal c_trigg : std_logic;
-- signal d_trigg : std_logic;
  signal reference_signal             : std_logic;
  signal tdc_readout_completed_i      : std_logic;
  signal tdc_data_out_i               : std_logic_vector(31 downto 0);
  signal tdc_data_valid_i             : std_logic;
  signal lvl2_readout_completed_i     : std_logic;
  signal tdc_register_00_i            : std_logic_vector(31 downto 0);
  signal tdc_register_01_i            : std_logic_vector(31 downto 0);
  signal tdc_register_02_i            : std_logic_vector(31 downto 0);
  signal tdc_register_03_i            : std_logic_vector(31 downto 0);
  signal tdc_register_04_i            : std_logic_vector(31 downto 0);
  signal tdc_register_05_i            : std_logic_vector(31 downto 0);
  signal bunch_reset_i                : std_logic;
  signal event_reset_i                : std_logic;
  signal trigger_to_tdc_i             : std_logic;
  signal token_out_i                  : std_logic;
  signal token_out_long_a             : std_logic;
  signal token_out_long_b             : std_logic;
  signal fast_ref_trigger             : std_logic;
  signal fast_ref_trigger_synch       : std_logic;
  signal fast_ref_trigger_pulse       : std_logic;
  signal fast_ref_trigger_pulse_synch : std_logic;
  signal token_in_i                   : std_logic;
  signal not_hades_trigger            : std_logic;
  signal trigger_miss_match           : std_logic;
-- signal additional_data_i : std_logic_vector(NUMBER_OFF_ADD_DATA*32-1 downto 0);
  signal NUMBER_OFF_ADD_DATA_RANGE    : integer := 0;
  signal self_trigg                   : std_logic;
  signal lvl1_finished_i              : std_logic;
  signal lvl2_finished_i              : std_logic;
  signal start_tdc_readout_i          : std_logic;

  --common signals for triggers 
  signal lvl1_busy_i          : std_logic;
  signal lvl2_busy_i          : std_logic;
  signal lvl1_trigger_code_i  : std_logic_vector(3 downto 0);
  signal lvl1_trigger_tag_i   : std_logic_vector(15 downto 0);
  signal lvl2_trigger_i       : std_logic;
  signal lvl2_trigger_synch   : std_logic;
  signal lvl1_trigger_i       : std_logic;
  signal lvl2_trigger_code_i  : std_logic_vector(3 downto 0)  := x"0";
  signal lvl2_trigger_tag_i   : std_logic_vector(15 downto 0) := x"0000";
  signal lvl2_local_busy_i    : std_logic                     := '0';
  signal lvl1_local_busy_i    : std_logic                     := '0';
  signal lvl1_external_busy_i : std_logic;
  signal lvl2_external_busy_i : std_logic;

  --etrax 
  signal etrax_bus_busy_i         : std_logic;  --should go to busy logic !? 
  signal etrax_is_ready_to_read_i : std_logic;
  signal fpga_register_01_i       : std_logic_vector(31 downto 0);
  signal fpga_register_02_i       : std_logic_vector(31 downto 0);
  signal fpga_register_03_i       : std_logic_vector(31 downto 0);
  signal fpga_register_04_i       : std_logic_vector(31 downto 0);
  signal fpga_register_05_i       : std_logic_vector(31 downto 0);
  signal fpga_register_06_i       : std_logic_vector(31 downto 0);
  signal fpga_register_07_i       : std_logic_vector(31 downto 0);
  signal fpga_register_08_i       : std_logic_vector(31 downto 0);
  signal fpga_register_09_i       : std_logic_vector(31 downto 0);
  signal fpga_register_0A_i       : std_logic_vector(31 downto 0);
  signal fpga_register_0b_i       : std_logic_vector(31 downto 0);
  signal fpga_register_0c_i       : std_logic_vector(31 downto 0);
  signal fpga_register_0d_i       : std_logic_vector(31 downto 0);
  signal fpga_register_0e_i       : std_logic_vector(31 downto 0);
  signal fpga_register_0f_i       : std_logic_vector(31 downto 0);
-- signal r_register_i : std_logic_vector(R_REGISTERS_NUMBER*32-1 downto 0);
-- signal rw_register_i : std_logic_vector(RW_REGISTERS_NUMBER*32-1 downto 0);

  signal fs_pc_i   : std_logic_vector(17 downto 0);
  signal fs_pb_i   : std_logic_vector(16 downto 0);
  signal fs_pb_17i : std_logic;



--trbnet endpoint
  signal trigger_monitor_in_i      : std_logic;
  signal global_time_out_i         : std_logic_vector(31 downto 0);
  signal local_time_out_i          : std_logic_vector(7 downto 0);
  signal time_since_last_trg_out_i : std_logic_vector(31 downto 0);
  signal timer_us_tick_out_i       : std_logic;
  signal stat_debug_1_i            : std_logic_vector(31 downto 0);
  signal stat_debug_2_i            : std_logic_vector(31 downto 0);
  signal regio_idram_data_in_i     : std_logic_vector(15 downto 0) := (others => '0');
  signal regio_idram_data_out_i    : std_logic_vector(15 downto 0);
  signal regio_idram_addr_in_i     : std_logic_vector(2 downto 0)  := "000";
  signal regio_idram_wr_in_i       : std_logic                     := '0';
  signal stat_debug_ipu_i          : std_logic_vector (31 downto 0);
  signal ipu_read_out_i            : std_logic                     := '0';
  signal ipu_dataready_in_i        : std_logic;
  signal lvl2_trigger_i_pulse      : std_logic;
  signal cntr_for_dummy_header     : std_logic_vector(1 downto 0)  := "00";
  signal ipu_data_in_i             : std_logic_vector(31 downto 0);








  signal lvl1_cts_busy_out_i    : std_logic;
  signal lvl2_cts_busy_out_i    : std_logic;
  signal lvl1_rnd_number_out_i  : std_logic_vector(7 downto 0);
  signal lvl2_rnd_number_out_i  : std_logic_vector(7 downto 0);
  signal lvl1_in_chain_busy     : std_logic;
  signal lvl2_in_chain_busy     : std_logic;
  signal lvl1_in_chain_busy_end : std_logic;
  signal lvl2_in_chain_busy_end : std_logic;
  signal lvl1_all_busy_or       : std_logic;
  signal lvl2_all_busy_or       : std_logic;

  --lvl1 trigger logic
  signal trigger_rw_valid_out_i                            : std_logic;
  signal trigger_rw_data_out_i                             : std_logic_vector(31 downto 0);
  signal not_fifo_empty, fifo_empty, fifo_full, fifo_rd_en : std_logic;
  signal fifo_out_data                                     : std_logic_vector(31 downto 0);

  type r_register_array is array(0 to R_REGISTERS_NUMBER) of std_logic_vector(31 downto 0);
  signal r_register_i         : r_register_array;
  type rw_register_array is array(0 to RW_REGISTERS_NUMBER) of std_logic_vector(31 downto 0);
  signal rw_register_i        : rw_register_array;
  signal r_register_vector    : std_logic_vector(R_REGISTERS_NUMBER*32-1 downto 0);
  signal rw_register_vector   : std_logic_vector(RW_REGISTERS_NUMBER*32-1 downto 0);
  signal full_syn1, full_syn2 : std_logic;

begin

  fifo_empty     <= fifo_empty_in;
  fifo_full      <= fifo_full_in;
  fifo_rd_en_out <= fifo_rd_en;
  fifo_out_data  <= fifo_out_data_in;

---------synchronize fifo_full          ----------
  FULL_SYNC : process(reset_i, clk)
  begin
    if(rising_edge(clk))then
      if(reset_i = '1')then
        full_syn1 <= '0';
        full_syn2 <= '0';
      else
        full_syn1 <= fifo_full;
        full_syn2 <= full_syn1;
      end if;
    end if;

  end process FULL_SYNC;



  ETRAX_INTERFACE_LOGIC : etrax_interfacev2
    generic map (
      ENABLE_DMA             => ENABLE_DMA,
      RW_SYSTEM              => RW_SYSTEM,
      RW_REGISTERS_NUMBER    => RW_REGISTERS_NUMBER,
      R_REGISTERS_NUMBER     => R_REGISTERS_NUMBER,
      TRBNET_ENABLE          => TRBNET_ENABLE
      )
    port map (
      clk                    => clk,
      RESET                  => reset_i,
      DATA_BUS               => tdc_data_out_i,
      ETRAX_DATA_BUS_B       => FS_PB,
      ETRAX_DATA_BUS_B_17    => FS_PB_17,
      ETRAX_DATA_BUS_C       => FS_PC,
      ETRAX_DATA_BUS_E       => open,
      IPU_READY_IN           => '0',    --ipu_read_out_i,
      IPU_DATAREADY_OUT      => open,   --ipu_dataready_in_i,
      IPU_DATA_OUT           => open,   --ipu_data_in_i,
      DATA_VALID             => tdc_data_valid_i,
      ETRAX_BUS_BUSY         => etrax_bus_busy_i,
      ETRAX_IS_READY_TO_READ => etrax_is_ready_to_read_i,
      TDC_TCK                => open,
      TDC_TDI                => open,
      TDC_TMS                => open,
      TDC_TRST               => open,   --VIRT_TRST,
      TDC_TDO                => '0',
      TDC_RESET              => open,   --TDC_RESET,
      EXTERNAL_ADDRESS       => open,   --external_address_i,
      EXTERNAL_DATA_OUT      => open,
      EXTERNAL_DATA_IN       => (others => '0'),
      EXTERNAL_ACK           => open,
      EXTERNAL_VALID         => '0',
      EXTERNAL_MODE          => open,
      RW_REGISTER            => rw_register_vector,
      R_REGISTER             => r_register_vector,
      LVL2_VALID             => lvl2_trigger_code_i(3),
      TRB_LVL2_BUSY          => lvl2_busy_i
      );

  -- REWRITE_R_REGISTER : for i in 1 to R_REGISTERS_NUMBER generate
  --   r_register_vector(32*i-1 downto 32*(i-1)) <= r_register_i(i-1);
  -- end generate REWRITE_R_REGISTER;
  r_register_vector   <= r_register_vec_in;
  --REWRITE_RW_REGISTER : for i in 1 to RW_REGISTERS_NUMBER generate
  rw_register_vec_out <= rw_register_vector;
  -- end generate REWRITE_RW_REGISTER;

  start_tdc_readout_i <= full_syn2;

  EXT_TRIGGER_1      : edge_to_pulse
    port map (
      clock     => clk,
      en_clk    => '1',
      signal_in => fifo_empty,
      pulse     => token_in_i
      );
  ENABLE_RD_FOR_FIFO : process (clk, reset_i)
  begin
    if rising_edge(clk) then
      if reset_i = '1' or fifo_empty = '1' then
        fifo_rd_en <= '0';
      elsif token_out_i = '1' then
        fifo_rd_en <= '1';
      end if;
    end if;
  end process ENABLE_RD_FOR_FIFO;

  tdc_clk_i      <= clk;
  tdc_data_in_i  <= fifo_out_data;
  not_fifo_empty <= not fifo_empty;



  TDC_INT : tdc_interfacev2
    generic map (
      ENABLE_DMA             => ENABLE_DMA,
      NUMBER_OFF_ADD_DATA    => NUMBER_OFF_ADD_DATA,
      TRBV2_TYPE             => TRBV2_TYPE
      )
    port map (
      clk                    => clk,
      TDC_clk                => tdc_clk_i,
      RESET                  => reset_i,
      TDC_DATA_IN            => tdc_data_in_i,
      START_TDC_READOUT      => start_tdc_readout_i,  --lvl1_trigger_i,
      A_TDC_ERROR            => '0',
      B_TDC_ERROR            => '0',
      C_TDC_ERROR            => '0',
      D_TDC_ERROR            => '0',
      A_TDC_READY            => not_fifo_empty,
      B_TDC_READY            => '0',
      C_TDC_READY            => '0',
      D_TDC_READY            => '0',
      SEND_TDC_TOKEN         => token_out_i,
      RECEIVED_TDC_TOKEN     => token_in_i,
      GET_TDC_DATA           => open,
      LVL2_READOUT_COMPLETED => lvl2_readout_completed_i,
      LVL1_TAG               => lvl1_trigger_tag_i,  --apl_seqnr_out_i,  --tdc_tag_i,
      LVL1_RND_CODE          => lvl1_rnd_number_out_i,  --apl_seqnr_out_i,  --tdc_tag_i,
      LVL1_CODE              => lvl1_trigger_code_i,  --apl_data_out_i(3 downto 0),  --tdc_code_i,
      LVL2_TAG               => lvl2_trigger_tag_i(7 downto 0),  --apl_seqnr_out_i,  --tdc_tag_i,
      HOW_MANY_ADD_DATA      => fpga_register_06_i(23 downto 16),
-- ADDITIONAL_DATA => additional_data_i,
      LVL2_TRIGGER           => lvl2_trigger_i,
      TDC_DATA_OUT           => tdc_data_out_i,
      TDC_DATA_VALID         => tdc_data_valid_i,
      ETRAX_IS_READY_TO_READ => etrax_is_ready_to_read_i,
      ETRAX_IS_BUSY          => FS_PB_17,
      LVL1_BUSY              => lvl1_busy_i,
      LVL2_BUSY              => lvl2_busy_i,
      TDC_REGISTER_00        => tdc_register_00_i,
      TDC_REGISTER_01        => tdc_register_01_i,
      TDC_REGISTER_02        => tdc_register_02_i,
      TDC_REGISTER_03        => tdc_register_03_i,
      TDC_REGISTER_04        => tdc_register_04_i,
      TDC_REGISTER_05        => rw_register_i(0),
      BUNCH_RESET            => open,
      EVENT_RESET            => open,
      DELAY_TRIGGER          => fpga_register_06_i(31 downto 24),
      DELAY_TOKEN            => fpga_register_0e_i(23 downto 16),
      TDC_START              => trigger_to_tdc_i,
      TRIGGER_WITH_GEN_EN    => '1',
      TRIGGER_WITH_GEN       => not_hades_trigger,
      TRB_ID                 => rw_register_i(4),
      LVL1_FINISHED          => lvl1_finished_i,
      LVL2_FINISHED          => lvl2_finished_i,
      TRBNET_HEADER_BUILD    => '0'
      );

  SET_READOUT_BUSY : process (clk, reset_i)
  begin
    if rising_edge(clk) then
      if reset_i = '1' or lvl2_finished_i = '1' then
        readout_busy_out <= '0';
      elsif lvl1_busy_i = '1' then
        readout_busy_out <= '1';
      end if;
    end if;
  end process SET_READOUT_BUSY;
  
--        r_register_i(0) <= tdc_register_00_i;
--        r_register_i(1) <= tdc_register_01_i;
--        r_register_i(2) <= tdc_register_02_i;
--        r_register_i(3) <= tdc_register_03_i;
--        r_register_i(4) <= tdc_register_04_i;
  

end Behavioral;

