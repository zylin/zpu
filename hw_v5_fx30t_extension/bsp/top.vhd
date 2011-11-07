-- top module of
-- Avnet Virtex 5 FX Evaluation Board

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.ibufds;


entity top is
  port (
    clk_100MHz          : in    std_logic;  -- 100 MHz clock
    clk_socket          : in    std_logic;  -- user clock
    user_clk_p          : in    std_logic;  -- diff user clock
    user_clk_n          : in    std_logic;  -- diff user clock
    --                                         
    --  RS232                                  
    rs232_rx            : in    std_logic;
    rs232_tx            : out   std_logic;
    rs232_rts           : in    std_logic;
    rs232_cts           : out   std_logic;
    --  RS232 USB                              
    rs232_usb_rx        : in    std_logic;
    rs232_usb_tx        : out   std_logic;
    rs232_usb_reset_n   : out   std_logic;
    --
    gpio_led_n          : out   std_logic_vector(7 downto 0);
    gpio_dipswitch      : in    std_logic_vector(7 downto 0);
    gpio_button         : in    std_logic_vector(3 downto 0);
    --
    --  FLASH 8Mx16 
    flash_a             : out   std_logic_vector(31 downto 7);
    flash_dq            : inout std_logic_vector(15 downto 0);
    flash_wen           : out   std_logic;
    flash_oen           : out   std_logic_vector(0 downto 0);
    flash_cen           : out   std_logic_vector(0 downto 0);
    flash_rp_n          : out   std_logic;
    flash_byte_n        : out   std_logic;
    flash_adv_n         : out   std_logic;
    flash_clk           : out   std_logic;
    flash_wait          : in    std_logic;
    --
    --  DDR2 SDRAM 16Mx32 
    ddr2_odt            : in    std_logic_vector(0 downto 0);
    ddr2_a              : out   std_logic_vector(12 downto 0);
    ddr2_ba             : out   std_logic_vector(1 downto 0);
    ddr2_cas_n          : out   std_logic;
    ddr2_cke            : out   std_logic;
    ddr2_cs_n           : out   std_logic;
    ddr2_ras_n          : out   std_logic;
    ddr2_we_n           : out   std_logic;
    ddr2_dm             : out   std_logic_vector(3 downto 0);
    ddr2_dqs_p          : inout std_logic_vector(3 downto 0);
    ddr2_dqs_n          : inout std_logic_vector(3 downto 0);
    ddr2_dq             : inout std_logic_vector(31 downto 0);
    ddr2_ck_p           : in    std_logic_vector(1 downto 0);
    ddr2_ck_n           : in    std_logic_vector(1 downto 0);
    --
    --  Ethernet MAC 
    gmii_txer           : out   std_logic;
    gmii_tx_clk         : in    std_logic;  -- 25 MHz
    gmii_rx_clk         : in    std_logic;  -- 25 MHz
    gmii_gtc_clk        : out   std_logic;
    gmii_crs            : in    std_logic;
    gmii_dv             : in    std_logic;
    gmii_rx_data        : in    std_logic_vector(7 downto 0);
    gmii_col            : in    std_logic;
    gmii_rx_er          : in    std_logic;
    gmii_tx_en          : out   std_logic;
    gmii_tx_data        : out   std_logic_vector(7 downto 0);
    gbe_rst_n           : out   std_logic;
    gbe_mdc             : out   std_logic;
    gbe_mdio            : inout std_logic;
    gbe_int_n           : inout std_logic;
    gbe_mclk            : in    std_logic;
    --
    --  SysACE CompactFlash 
    sam_clk             : in    std_logic;
    sam_a               : out   std_logic_vector(6 downto 0);
    sam_d               : inout std_logic_vector(15 downto 0);
    sam_cen             : out   std_logic;
    sam_oen             : out   std_logic;
    sam_wen             : out   std_logic;
    sam_mpirq           : in    std_logic;
    sam_brdy            : in    std_logic;
    sam_reset_n         : out   std_logic;
    --
    --  Expansion Header
    exp1_se_io          : inout std_logic_vector(33 downto 0);
    exp1_diff_p         : inout std_logic_vector(21 downto 0);
    exp1_diff_n         : inout std_logic_vector(21 downto 0);
    exp1_se_clk_out     : out   std_logic;
    exp1_se_clk_in      : in    std_logic;
    exp1_diff_clk_out_p : out   std_logic;
    exp1_diff_clk_out_n : out   std_logic;
    exp1_diff_clk_in_p  : in    std_logic;
    exp1_diff_clk_in_n  : in    std_logic;
    --
    -- Debug/Trace
    atdd                : inout std_logic_vector(19 downto 8);
    trace_ts10          : inout std_logic;
    trace_ts20          : inout std_logic;
    trace_ts1e          : inout std_logic;
    trace_ts2e          : inout std_logic;
    trace_ts3           : inout std_logic;
    trace_ts4           : inout std_logic;
    trace_ts5           : inout std_logic;
    trace_ts6           : inout std_logic;
    trace_clk           : in    std_logic;
    cpu_hreset          : in    std_logic;
    cpu_tdo             : out   std_logic;
    cpu_tms             : in    std_logic;
    cpu_tdi             : in    std_logic;
    cpu_trst            : in    std_logic;
    cpu_tck             : in    std_logic;
    cpu_halt_n          : in    std_logic
    );
end entity top;


architecture rtl of top is

  signal ibufds_i0_o : std_ulogic;
  signal ibufds_i1_o : std_ulogic;

begin
  
  ibufds_i0 : ibufds
    generic map (
      diff_term => true
      )
    port map (
      o  => ibufds_i0_o,
      i  => ddr2_ck_p(0),
      ib => ddr2_ck_n(0)
      );

  ibufds_i1 : ibufds
    generic map (
      diff_term => true
      )
    port map (
      o  => ibufds_i1_o,
      i  => ddr2_ck_p(1),
      ib => ddr2_ck_n(1)
      );

  -- default output drivers
  -- to pass bitgen DRC 
  rs232_tx            <= '1';
  rs232_cts           <= '1';
  rs232_usb_tx        <= '1';
  rs232_usb_reset_n   <= '1';
  gpio_led_n          <= (others => '1');
  flash_cen           <= "1";
  flash_oen           <= "1";
  flash_wen           <= '1';
  flash_rp_n          <= '1';
  flash_byte_n        <= '1';
  flash_adv_n         <= '1';
  flash_clk           <= '0';
  flash_a             <= (others => '0');
  ddr2_a              <= (others => '0');
  ddr2_ba             <= (others => '0');
  ddr2_dm             <= (others => '0');
  ddr2_cs_n           <= '1';
  ddr2_we_n           <= '1';
  ddr2_cke            <= '1';
  ddr2_cas_n          <= '1';
  ddr2_ras_n          <= '1';
  gmii_gtc_clk        <= '0';
  gmii_tx_data        <= (others => '0');
  gmii_tx_en          <= '0';
  gmii_txer           <= '0';
  gbe_rst_n           <= '1';
  gbe_mdc             <= '1';
  sam_cen             <= '1';
  sam_oen             <= '1';
  sam_wen             <= '1';
  sam_a               <= (others => '0');
  sam_reset_n         <= '1';
  exp1_se_clk_out     <= '0';
  exp1_diff_clk_out_p <= '0';
  exp1_diff_clk_out_n <= '1';
  cpu_tdo             <= '1';

end architecture rtl;

