-- top module of
-- Spartan-3e Starter Kit Board
--
-- using following external connections:
--
-- contains buffers (iobuf, bufg, iobufds etc.)


library ieee;
use ieee.std_logic_1164.all;


entity top is
    port (
        --



        -- Analog-to-Digital Converter (ADC)
        ad_conv         : out   std_logic;
        -- Programmable Gain Amplifier (AMP)
        amp_cs          : out   std_logic;  -- active low chip select
        amp_dout        : in    std_logic;
        amp_shdn        : out   std_logic;  -- active high shutdown, reset
        -- Pushbuttons (BTN)
        btn_east        : in    std_logic;
        btn_north       : in    std_logic;
        btn_south       : in    std_logic;
        btn_west        : in    std_logic;
        -- Clock inputs (CLK)
        clk_50mhz       : in    std_logic;
        clk_aux         : in    std_logic;
        clk_sma         : in    std_logic;
        -- Digital-to-Analog Converter (DAC)
        dac_clr         : out   std_logic;  -- async, active low reset input
        dac_cs          : out   std_logic;  -- active low chip select, conv start with rising edge
        -- 1-Wire Secure EEPROM (DS)
        ds_wire         : inout std_logic;
        -- Ethernet PHY (E)
        e_col           : in    std_logic;  -- MII collision detect
        e_crs           : in    std_logic;  -- carrier sense
        e_mdc           : out   std_logic;  -- management clock
        e_mdio          : inout std_logic;  -- management data io
        e_rx_clk        : in    std_logic;  -- receive clock 25MHz@100BaseTx or 2.5MHz@10Base-T
        e_rx_dv         : in    std_logic;  -- receive data valid
        e_rxd           : in    std_logic_vector(3 downto 0);
        e_rx_er         : in    std_logic;
        e_tx_clk        : in    std_logic;  -- transmit clock 25MHz@100BaseTx or 2.5MHz@10Base-T
        e_tx_en         : out   std_logic;  -- transmit enable
        e_txd           : out   std_logic_vector(3 downto 0);
        e_tx_er         : out   std_logic;
        -- FPGA Configuration Mode, INIT_B Pins (FPGA)
        fpga_m0         : inout std_logic;
        fpga_m1         : inout std_logic;
        fpga_m2         : inout std_logic;
        fpga_init_b     : inout std_logic;
        fpga_rdwr_b     : in    std_logic;
        fpga_hswap      : in    std_logic;
        -- FX2 Connector (FX2)
        fx2_clkin       : inout std_logic;
        fx2_clkio       : inout std_logic;
        fx2_clkout      : inout std_logic;
        fx2_io          : inout std_logic_vector(40 downto 1);
        -- These are shared connections with the FX2 connector
        --j1              : inout std_logic_vector(3 downto 0);
        --j2              : inout std_logic_vector(3 downto 0);
        --j4              : inout std_logic_vector(3 downto 0);
        --led             : out   std_logic_vector(7 downto 0);
        -- Character LCD (LCD)
        lcd_e           : out   std_logic;
        lcd_rs          : out   std_logic;
        lcd_rw          : out   std_logic;
        -- LCD data connections are shared with StrataFlash connections SF_D<11:8>
        --sf_d          : inout std_ulogic_vector(11 downto 8);
        -- PS/2 Mouse/Keyboard Port (PS2)
        ps2_clk         : inout std_logic;
        ps2_data        : inout std_logic;
        -- Rotary Pushbutton Switch (ROT)
        rot_a           : in    std_logic;
        rot_b           : in    std_logic;
        rot_center      : in    std_logic;
        -- RS-232 Serial Ports (RS232)
        rs232_dce_rxd   : in    std_logic;
        rs232_dce_txd   : out   std_logic;
        rs232_dte_rxd   : in    std_logic;
        rs232_dte_txd   : out   std_logic;
        -- DDR SDRAM (SD) (I/O Bank 3, VCCO=2.5V)
        sd_a            : out   std_logic_vector(12 downto 0);  -- address inputs
        sd_dq           : inout std_logic_vector(15 downto 0);  -- data io
        sd_ba           : out   std_logic_vector(1 downto 0);   -- bank address inputs
        sd_ras          : out   std_logic;                      -- command output
        sd_cas          : out   std_logic;                      -- command output
        sd_we           : out   std_logic;                      -- command output 
        sd_udm          : out   std_logic;                      -- data mask
        sd_ldm          : out   std_logic;                      -- data mask
        sd_udqs         : inout std_logic;                      -- data strobe
        sd_ldqs         : inout std_logic;                      -- data strobe
        sd_cs           : out   std_logic;                      -- active low chip select
        sd_cke          : out   std_logic;                      -- active high clock enable
        sd_ck_n         : out   std_logic;                      -- differential clock
        sd_ck_p         : out   std_logic;                      -- differential clock
        -- Path to allow connection to top DCM connection
        sd_ck_fb        : in    std_logic;
        -- Intel StrataFlash Parallel NOR Flash (SF)
        sf_a            : out   std_logic_vector(23 downto 0);  -- sf_a<24> = fx_io32 :-(
        sf_byte         : out   std_logic;
        sf_ce0          : out   std_logic;
        sf_d            : inout std_logic_vector(15 downto 1);
        sf_oe           : out   std_logic;
        sf_sts          : in    std_logic;
        sf_we           : out   std_logic;
        -- STMicro SPI serial Flash (SPI)
        spi_mosi        : out   std_logic;  -- master out slave in
        spi_miso        : in    std_logic;  -- master in  slave out
        spi_sck         : out   std_logic;  -- clock
        spi_ss_b        : out   std_logic;  -- active low slave select
        spi_alt_cs_jp11 : out   std_logic;
        -- Slide Switches (SW)
        sw              : in    std_logic_vector(3 downto 0);
        -- VGA Port (VGA)
        vga_blue        : out   std_logic;
        vga_green       : out   std_logic;
        vga_hsync       : out   std_logic;
        vga_red         : out   std_logic;
        vga_vsync       : out   std_logic;
        -- Xilinx CPLD (XC)
        xc_cmd          : out   std_logic_vector(1 downto 0);
        xc_cpld_en      : out   std_logic;
        xc_d            : inout std_logic_vector(2 downto 0);
        xc_trig         : in    std_logic;
        xc_gck0         : inout std_logic;
        gclk10          : inout std_logic
    );
end entity top;


architecture rtl of top is

    ---------------------------
    -- constant declarations
    constant spi_ss_b_disable    : std_ulogic := '1';  -- 1 = disable SPI serial flash
    constant dac_cs_disable      : std_ulogic := '1';  -- 1 = disable DAC 
    constant amp_cs_disable      : std_ulogic := '1';  -- 1 = disable programmable pre-amplifier
    constant ad_conv_disable     : std_ulogic := '0';  -- 0 = disable ADC
    constant sf_ce0_disable      : std_ulogic := '1';
    constant fpga_init_b_disable : std_ulogic := '1';  -- 1 = disable pflatform flash PROM
 
    -- connect ldc to fpga
    constant sf_ce0_lcd_to_fpga : std_ulogic := '1';
    constant lcd_rw_lcd_to_fpga : std_ulogic := '1';

    ---------------------------
    -- alias declarations
    alias led : std_logic_vector(7 downto 0) is fx2_io(20 downto 13);


begin

    -- default output drivers
    -- to pass bitgen DRC 
    -- outputs used by design are commented
    --
    ad_conv           <= ad_conv_disable;
    amp_cs            <= amp_cs_disable;
    amp_shdn          <= '1';
    --
    dac_clr           <= '0';
    dac_cs            <= dac_cs_disable;
    --
    ds_wire           <= 'Z';
    --
    e_txd(3 downto 0) <= (others => '1');
    e_tx_en           <= '0';
    e_tx_er           <= '0';
    e_mdc             <= '1';
    e_mdio            <= 'Z';
    --
    fpga_m0           <= 'Z';
    fpga_m1           <= 'Z';
    fpga_m2           <= 'Z';
    fpga_init_b       <= fpga_init_b_disable;
    --
    fx2_clkin         <= 'Z';
    fx2_clkio         <= 'Z';
    fx2_clkout        <= 'Z';
    fx2_io            <= (others => 'Z');
    --
    lcd_e             <= '0';
    lcd_rs            <= '0';
    lcd_rw            <= '0';
    --
    ps2_clk           <= 'Z';
    ps2_data          <= 'Z';
    --
    rs232_dce_txd     <= '1';
    rs232_dte_txd     <= '1';
    --
    sd_a              <= (others => '1');
    sd_dq             <= (others => 'Z');
    sd_ba             <= (others => '1');
    sd_ras            <= '0';
    sd_cas            <= '0';
    sd_we             <= '0';
    sd_udm            <= '1';
    sd_ldm            <= '1';
    sd_udqs           <= '1';
    sd_ldqs           <= '1';
    sd_cs             <= '1';
    sd_cke            <= '1';
    sd_ck_n           <= '0';
    sd_ck_p           <= '1';
    --
    sf_a              <= (others => '0');
    sf_byte           <= '0';
    sf_ce0            <= sf_ce0_lcd_to_fpga;
    sf_d              <= (others => 'Z');
    sf_oe             <= '1';
    sf_we             <= '0';
    --
    spi_mosi          <= '0';
    spi_sck           <= '0';
    spi_ss_b          <= spi_ss_b_disable;
    spi_alt_cs_jp11   <= spi_ss_b_disable;
    --
    vga_red           <= '0';
    vga_green         <= '0';
    vga_blue          <= '0';
    vga_hsync         <= '0';
    vga_vsync         <= '0';
    --
    xc_cmd            <= "00";
    xc_d              <= (others => 'Z');
    xc_cpld_en        <= '0';
    xc_gck0           <= 'Z';
    gclk10            <= 'Z';

  -- led out
  fx2_io(20 downto 13) <= (others => '0');

end architecture rtl;
