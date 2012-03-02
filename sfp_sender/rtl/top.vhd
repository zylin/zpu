-- top module of
-- SP601 evaluation board
--
-- using following external connections:
--
--


library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.bufg;
use unisim.vcomponents.dcm_sp;
use unisim.vcomponents.ibufds;
use unisim.vcomponents.ibufgds;
use unisim.vcomponents.obufds;
use unisim.vcomponents.oddr2;
use unisim.vcomponents.pll_base;

library gaisler;
use gaisler.misc.all; -- types
use gaisler.uart.all; -- types

library work;
use work.types_package.all;
use work.component_package.box;



entity top is
    port (
        -- pragma translate_off
        simulation_run            : in    boolean;
        simulation_break          : out   std_logic;
        -- pragma translate_on
        --
        cpu_reset                 : in    std_logic; -- SW9 pushbutton (active-high)
        --
        -- DDR2 memory 128 MB
        ddr2_a                    : out   std_logic_vector(12 downto 0);
        ddr2_ba                   : out   std_logic_vector(2 downto 0);
        ddr2_cas_b                : out   std_logic;
        ddr2_ras_b                : out   std_logic;
        ddr2_we_b                 : out   std_logic;
        ddr2_cke                  : out   std_logic;
        ddr2_clk_n                : out   std_logic; 
        ddr2_clk_p                : out   std_logic; 
        ddr2_dq                   : inout std_logic_vector(15 downto 0);
        ddr2_ldm                  : out   std_logic;
        ddr2_udm                  : out   std_logic;
        ddr2_ldqs_n               : inout std_logic;
        ddr2_ldqs_p               : inout std_logic;
        ddr2_udqs_n               : inout std_logic;
        ddr2_udqs_p               : inout std_logic;
        ddr2_odt                  : out   std_logic;
        --                                
        -- flash memory                        
        flash_a                   : out   std_logic_vector(24 downto 0);
        flash_d                   : inout std_logic_vector(7  downto 3);
        --
        fpga_d0_din_miso_miso1    : inout std_logic; -- dual use
        fpga_d1_miso2             : inout std_logic; -- dual use
        fpga_d2_miso3             : inout std_logic; -- dual use
        flash_we_b                : out   std_logic;
        flash_oe_b                : out   std_logic;
        flash_ce_b                : out   std_logic;
        --
        -- FMC connector
        -- M2C   Mezzanine to Carrier
        -- C2M   Carrier to Mezzanine
        fmc_clk0_m2c_n            : in    std_logic;
        fmc_clk0_m2c_p            : in    std_logic;
        fmc_clk1_m2c_n            : in    std_logic;
        fmc_clk1_m2c_p            : in    std_logic;
        -- IIC addresses:
        -- M24C08:                 1010100..1010111
        -- 2kb EEPROM on FMC card: 1010010
        iic_scl_main              : inout std_logic;
        iic_sda_main              : inout std_logic;
        fmc_la00_cc_n             : inout std_logic;
        fmc_la00_cc_p             : inout std_logic;
        fmc_la01_cc_n             : inout std_logic;
        fmc_la01_cc_p             : inout std_logic;
        fmc_la02_n                : inout std_logic;
        fmc_la02_p                : inout std_logic;
        fmc_la03_n                : inout std_logic;
        fmc_la03_p                : inout std_logic;
        fmc_la04_n                : inout std_logic;
        fmc_la04_p                : inout std_logic;
        fmc_la05_n                : inout std_logic;
        fmc_la05_p                : inout std_logic;
        fmc_la06_n                : inout std_logic;
        fmc_la06_p                : inout std_logic;
        fmc_la07_n                : inout std_logic;
        fmc_la07_p                : inout std_logic;
        fmc_la08_n                : inout std_logic;
        fmc_la08_p                : inout std_logic;
        fmc_la09_n                : inout std_logic;
        fmc_la09_p                : inout std_logic;
        fmc_la10_n                : inout std_logic;
        fmc_la10_p                : inout std_logic;
        fmc_la11_n                : inout std_logic;
        fmc_la11_p                : inout std_logic;
        fmc_la12_n                : inout std_logic;
        fmc_la12_p                : inout std_logic;
        fmc_la13_n                : inout std_logic;
        fmc_la13_p                : inout std_logic;
        fmc_la14_n                : inout std_logic;
        fmc_la14_p                : inout std_logic;
        fmc_la15_n                : inout std_logic;
        fmc_la15_p                : inout std_logic;
        fmc_la16_n                : inout std_logic;
        fmc_la16_p                : inout std_logic;
        fmc_la17_cc_n             : inout std_logic;
        fmc_la17_cc_p             : inout std_logic;
        fmc_la18_cc_n             : inout std_logic;
        fmc_la18_cc_p             : inout std_logic;
        fmc_la19_n                : inout std_logic;
        fmc_la19_p                : inout std_logic;
        fmc_la20_n                : inout std_logic;
        fmc_la20_p                : inout std_logic;
        fmc_la21_n                : inout std_logic;
        fmc_la21_p                : inout std_logic;
        fmc_la22_n                : inout std_logic;
        fmc_la22_p                : inout std_logic;
        fmc_la23_n                : inout std_logic;
        fmc_la23_p                : inout std_logic;
        fmc_la24_n                : inout std_logic;
        fmc_la24_p                : inout std_logic;
        fmc_la25_n                : inout std_logic;
        fmc_la25_p                : inout std_logic;
        fmc_la26_n                : inout std_logic;
        fmc_la26_p                : inout std_logic;
        fmc_la27_n                : inout std_logic;
        fmc_la27_p                : inout std_logic;
        fmc_la28_n                : inout std_logic;
        fmc_la28_p                : inout std_logic;
        fmc_la29_n                : inout std_logic;
        fmc_la29_p                : inout std_logic;
        fmc_la30_n                : inout std_logic;
        fmc_la30_p                : inout std_logic;
        fmc_la31_n                : inout std_logic;
        fmc_la31_p                : inout std_logic;
        fmc_la32_n                : inout std_logic;
        fmc_la32_p                : inout std_logic;
        fmc_la33_n                : inout std_logic;
        fmc_la33_p                : inout std_logic;
        fmc_prsnt_m2c_l           : in    std_logic;
        fmc_pwr_good_flash_rst_b  : out   std_logic; -- multiple destinations: 1 of Q2 (LED DS1 driver), U1 AB2 FPGA_PROG (through series R260 DNP), 44 of U25
        --
        fpga_awake                : out   std_logic;
        fpga_cclk                 : out   std_logic;
        fpga_cmp_clk              : in    std_logic;
        fpga_cmp_mosi             : in    std_logic;
        --
        fpga_hswapen              : in    std_logic;
        fpga_init_b               : out   std_logic; -- low active
        fpga_m0_cmp_miso          : in    std_logic; -- mode DIP switch SW1 active high
        fpga_m1                   : in    std_logic; -- mode DIP switch SW1 active high
        fpga_mosi_csi_b_miso0     : inout std_logic;
        fpga_onchip_term1         : inout std_logic;
        fpga_onchip_term2         : inout std_logic;
        fpga_vtemp                : in    std_logic;
        --
        -- GPIOs
        gpio_button               : in    std_logic_vector(3 downto 0); -- active high
        gpio_header_ls            : inout std_logic_vector(7 downto 0);
        gpio_led                  : out   std_logic_vector(3 downto 0);
        gpio_switch               : in    std_logic_vector(3 downto 0); -- active high
        --
        -- Ethernet Gigabit PHY, 
        -- default settings:
        -- phy address    = 0b00111
        -- ANEG[3..0]     = "1111"
        -- ENA_XC         = 1
        -- DIS_125        = 1
        -- HWCFG_MD[3..0] = "1111"
        -- DIS_FC         = 1
        -- DIS_SLEEP      = 1
        -- SEL_BDT        = 0
        -- INT_POL        = 1
        -- 75/50Ohm       = 0
        phy_col                   : in    std_logic;
        phy_crs                   : in    std_logic;
        phy_int                   : in    std_logic;
        phy_mdc                   : out   std_logic;
        phy_mdio                  : inout std_logic;
        phy_reset_b               : out   std_logic;
        phy_rxclk                 : in    std_logic;
        phy_rxctl_rxdv            : in    std_logic;
        phy_rxd                   : in    std_logic_vector(7 downto 0);
        phy_rxer                  : in    std_logic;
        phy_txclk                 : in    std_logic;
        phy_txctl_txen            : out   std_logic;
        phy_txc_gtxclk            : out   std_logic;
        phy_txd                   : out   std_logic_vector(7 downto 0);
        phy_txer                  : out   std_logic;
        --
        --
        spi_cs_b                  : out   std_logic;
        --
        -- 200 MHz oscillator, jitter 50 ppm
        sysclk_n                  : in    std_logic;
        sysclk_p                  : in    std_logic;
        --
        -- RS232 via USB
        usb_1_cts                 : out   std_logic;  -- function: RTS output
        usb_1_rts                 : in    std_logic;  -- function: CTS input
        usb_1_rx                  : out   std_logic;  -- function: TX data out
        usb_1_tx                  : in    std_logic;  -- function: RX data in
        --
        --  27 MHz, oscillator socket
        user_clock               : in    std_logic;
        --
        -- user clock provided per SMA
        user_sma_clock_p         : inout std_logic;
        user_sma_clock_n         : inout std_logic
    );
end entity top;


architecture rtl of top is

    ---------------------------
    -- constant declarations

    ---------------------------
    -- signal declarations
    signal sys_clk                : std_ulogic;
    signal dcm_sp_i0_clk0         : std_ulogic;
    signal dcm_sp_i0_status       : std_logic_vector(7 downto 0);
    signal dcm_sp_i0_locked       : std_ulogic;
    signal dcm_sp_i0_clkfx        : std_ulogic;
    signal dcm_sp_i0_clkfx180     : std_ulogic;
    signal clk_fb                 : std_ulogic;
    signal clk                    : std_ulogic;
    signal dcm_sp_i1_clk0         : std_ulogic;
    signal dcm_sp_i1_clkfx        : std_ulogic;
    signal dcm_sp_i1_clkfx180     : std_ulogic;
    signal clk_fb2                : std_ulogic;
    --
    signal top_pll_reset          : std_ulogic := '0';
    signal pll_base_i0_clkfbout   : std_ulogic;
    signal pll_base_i0_clkout0    : std_ulogic;
    signal pll_base_i0_clkout1    : std_ulogic;
    --                            
    signal clk_in_260             : std_ulogic;
    signal clk_in_13              : std_ulogic;
    --                            
    signal reset_shift_reg        : std_ulogic_vector(3 downto 0) := (others => '1');
    signal reset                  : std_ulogic;
    signal reset_n                : std_ulogic;
    --
    --
    signal top_fpga_uarti         : uart_in_type;
    signal box_i0_uarto           : uart_out_type;
    --                                                      
    signal top_fpga_gpioi         : gpio_in_type;
    signal box_i0_gpioo           : gpio_out_type;
    --                                                      
    signal fmc_i2ci               : i2c_in_type;
    signal box_i0_fmc_i2co        : i2c_out_type;
    --
    signal sfp_status             : sfp_status_in_t;
    signal box_i0_sfp_control     : sfp_control_out_t;
    signal sfp_rx                 : std_ulogic;
    signal box_i0_sfp_tx          : std_ulogic;
    --
    signal box_i0_trigger_signals : std_ulogic_vector(9 downto 0); 
                             



    function simulation_active return std_ulogic is
        variable result : std_ulogic;
    begin
        result := '0';
        -- pragma translate_off
        result := '1';
        -- pragma translate_on
        return result;
    end function simulation_active;

begin

    -- default output drivers
    -- to pass bitgen DRC 
    -- outputs used by design are commented
    --
    ddr2_a                   <= (others => '1');
    ddr2_ba                  <= (others => '1');
    ddr2_cas_b               <= '1';
    ddr2_ras_b               <= '1';
    ddr2_we_b                <= '1';
    ddr2_cke                 <= '0';
    ddr2_clk_n               <= '0';
    ddr2_clk_p               <= '1';
    ddr2_dq                  <= (others => 'Z');
    ddr2_ldm                 <= '0';
    ddr2_udm                 <= '0';
    ddr2_ldqs_n              <= 'Z';
    ddr2_ldqs_p              <= 'Z';
    ddr2_udqs_n              <= 'Z';
    ddr2_udqs_p              <= 'Z';
    ddr2_odt                 <= '1';
    --
    flash_a                  <= (others => '1');
    flash_d                  <= (others => 'Z');
    flash_we_b               <= '1';
    flash_oe_b               <= '1';
    flash_ce_b               <= '1';
    --
    fpga_d0_din_miso_miso1   <= 'Z';
    fpga_d1_miso2            <= 'Z';
    fpga_d2_miso3            <= 'Z';
    --
    --iic_scl_main             <= 'Z';
    --iic_sda_main             <= 'Z';
    fmc_la00_cc_n            <= 'Z';
    fmc_la00_cc_p            <= 'Z';
    fmc_la01_cc_n            <= 'Z';
    fmc_la01_cc_p            <= 'Z';
    --fmc_la02_n               <= 'Z';
    --fmc_la02_p               <= 'Z';
    --fmc_la03_n               <= 'Z';
    --fmc_la03_p               <= 'Z';
    --fmc_la04_n               <= 'Z';
    --fmc_la04_p               <= 'Z';
    --fmc_la05_n               <= 'Z';
    --fmc_la05_p               <= 'Z';
    --fmc_la06_n               <= 'Z';
    --fmc_la06_p               <= 'Z';
    --fmc_la07_n               <= 'Z';
    --fmc_la07_p               <= 'Z';
    --fmc_la08_n               <= 'Z';
    --fmc_la08_p               <= 'Z';
    --fmc_la09_n               <= 'Z';
    --fmc_la09_p               <= 'Z';
    --fmc_la10_n               <= 'Z';
    --fmc_la10_p               <= 'Z';
    --fmc_la11_n               <= 'Z';
    --fmc_la11_p               <= 'Z';
    --fmc_la12_n               <= 'Z';
    --fmc_la12_p               <= 'Z';
    --fmc_la13_n               <= 'Z';
    --fmc_la13_p               <= 'Z';
    --fmc_la14_n               <= 'Z';
    --fmc_la14_p               <= 'Z';
    --fmc_la15_n               <= 'Z';
    --fmc_la15_p               <= 'Z';
    fmc_la16_n               <= 'Z';
    fmc_la16_p               <= 'Z';
    fmc_la17_cc_n            <= 'Z';
    fmc_la17_cc_p            <= 'Z';
    fmc_la18_cc_n            <= 'Z';
    fmc_la18_cc_p            <= 'Z';
    --fmc_la19_n               <= 'Z';
    --fmc_la19_p               <= 'Z';
    fmc_la20_n               <= 'Z';
    fmc_la20_p               <= 'Z';
    --fmc_la21_n               <= 'Z';
    --fmc_la21_p               <= 'Z';
    fmc_la22_n               <= 'Z';
    fmc_la22_p               <= 'Z';
    --fmc_la23_n               <= 'Z';
    --fmc_la23_p               <= 'Z';
    --fmc_la24_n               <= 'Z';
    --fmc_la24_p               <= 'Z';
    fmc_la25_n               <= 'Z';
    fmc_la25_p               <= 'Z';
    fmc_la26_n               <= 'Z';
    fmc_la26_p               <= 'Z';
    --fmc_la27_n               <= 'Z';
    --fmc_la27_p               <= 'Z';
    fmc_la28_n               <= 'Z';
    fmc_la28_p               <= 'Z';
    fmc_la29_n               <= 'Z';
    fmc_la29_p               <= 'Z';
    fmc_la30_n               <= 'Z';
    fmc_la30_p               <= 'Z';
    fmc_la31_n               <= 'Z';
    fmc_la31_p               <= 'Z';
    fmc_la32_n               <= 'Z';
    fmc_la32_p               <= 'Z';
    --fmc_la33_n               <= 'Z';
    --fmc_la33_p               <= 'Z';
    fmc_pwr_good_flash_rst_b <= '1';
    --
    fpga_awake               <= '1';
    fpga_cclk                <= '1'; -- SPI clk
    fpga_init_b              <= '1';
    fpga_mosi_csi_b_miso0    <= 'Z';
    fpga_onchip_term1        <= 'Z';
    fpga_onchip_term2        <= 'Z';
    --
    --gpio_led                 <= (others => '0'); 
    --gpio_header_ls           <= (others => 'Z'); 
    --
    phy_mdc                  <= '0';
    phy_mdio                 <= 'Z';
    phy_reset_b              <= '0';
    phy_txc_gtxclk           <= '0';
    phy_txctl_txen           <= '0';
    phy_txd                  <= (others => '1');
    phy_txer                 <= '0';
    --
    spi_cs_b                 <= '1';
    --
    --usb_1_rx                 <= '1';  -- function: TX data out
    --usb_1_cts                <= '1';  -- function: RTS


    -- global differential input buffer 
    ibufgds_i0 : ibufgds
        generic map (
            diff_term => true
        )
        port map (
            i  => sysclk_p,
            ib => sysclk_n,
            o  => sys_clk
        );

    ibufgds_i1 : ibufgds
        generic map (
            diff_term => true
        )
        port map (
            i  => fmc_clk0_m2c_p,
            ib => fmc_clk0_m2c_n,
            o  => clk_in_260
        );


    ibufgds_i2 : ibufgds
        generic map (
            diff_term => true
        )
        port map (
            i  => fmc_la00_cc_p,
            ib => fmc_la00_cc_n,
            o  => clk_in_13
        );


    -- digital clock manager (DCM)
    -- to generate higher/other system clock frequencys
    dcm_sp_i0 : dcm_sp
        generic map (
            dfs_frequency_mode => "HIGH",
            clkfx_multiply     => 2,
            clkfx_divide       => 8,
            clk_feedback       => "1X"
            )
        port map (
            rst      => '0',
            clkin    => clk_in_260,
            clk0     => dcm_sp_i0_clk0,
            clkfx    => dcm_sp_i0_clkfx,
            clkfx180 => dcm_sp_i0_clkfx180,
            status   => dcm_sp_i0_status,
            locked   => dcm_sp_i0_locked,
            clkfb    => clk_fb
            );

    clk_fb <= dcm_sp_i0_clk0;
    clk    <= dcm_sp_i0_clkfx;
--  gpio_led <= dcm_sp_i0_status(3 downto 1) & dcm_sp_i0_locked;


    -- generate  266 MHz as main refernce clock
--  dcm_sp_i1 : dcm_sp
--      generic map (
--          dfs_frequency_mode => "HIGH",
--          clkfx_multiply => 5,
--          clkfx_divide   => 4,        
--          clk_feedback   => "NONE" --"1X"
--          )
--      port map (
--          rst      => '0',
--          clkin    => sys_clk,
--          clk0     => dcm_sp_i1_clk0,
--          clkfx    => dcm_sp_i1_clkfx,
--          clkfx180 => dcm_sp_i1_clkfx180,
--          clkfb    => clk_fb2
--          );

--  clk_fb2          <= dcm_sp_i1_clk0;

    pll_base_i0 : pll_base
        generic map (
            clkfbout_mult         => 12,           -- : integer := 1;
            clkin_period          => 5.0,          -- : real := 0.000;
            clkout0_divide        =>  3,           -- : integer := 1;
            clkout1_divide        =>  3,           -- : integer := 1;
            clkout1_phase         => 180.0,        -- : real := 0.0;
            compensation          => "INTERNAL",   -- : string := "SYSTEM_SYNCHRONOUS";
            divclk_divide         => 3             -- : integer := 1;
        )
        port map (
            clkfbout => pll_base_i0_clkfbout, -- : out std_ulogic;
            clkout0  => pll_base_i0_clkout0,  -- : out std_ulogic;
            clkout1  => pll_base_i0_clkout1,  -- : out std_ulogic;
            clkfbin  => pll_base_i0_clkfbout, -- : in std_ulogic;
            clkin    => sys_clk,              -- : in std_ulogic;
            rst      => top_pll_reset         -- : in std_ulogic
        );
    -- pragma translate_off
    -- reset the pll to stop the simulation
    top_pll_reset <= '0' when simulation_run else '1';
    -- pragma translate_on

    -- output for generated 266 MHz
    oddr2_i0: oddr2
        generic map (
            ddr_alignment => "C0",
            srtype        => "ASYNC"
        )
        port map (
            q   => user_sma_clock_p,
            c0  => pll_base_i0_clkout0, --dcm_sp_i1_clkfx,
            c1  => pll_base_i0_clkout1, --dcm_sp_i1_clkfx180,
            ce  => '1',
            d0  => '1',
            d1  => '0',
            r   => '0',
            s   => '0'
        );

--  -- check output
--  oddr2_i1: oddr2
--      generic map (
--          ddr_alignment => "C0",
--          srtype        => "ASYNC"
--      )
--      port map (
--          q   => user_sma_clock_n,
--          c0  => dcm_sp_i0_clkfx,
--          c1  => dcm_sp_i0_clkfx180,
--          ce  => '1',
--          d0  => '1',
--          d1  => '0',
--          r   => '0',
--          s   => '0'
--      );
--  user_sma_clock_n <= dcm_sp_i0_clkfx;





    reset_generator_p: process
    begin
        wait until rising_edge( clk);
        reset_shift_reg <= reset_shift_reg(reset_shift_reg'left-1 downto 0) & '0';
    end process;
    reset   <=     reset_shift_reg(reset_shift_reg'left);
    reset_n <= not reset_shift_reg(reset_shift_reg'left);

    
    ---------------------------------------------------------------------
    -- pads for gpio (buttons i)
    top_fpga_gpioi.sig_in            <= (others => '0');
    top_fpga_gpioi.sig_en            <= (others => '0');
    top_fpga_gpioi.din( 3 downto  0) <= std_logic_vector( gpio_switch);
    top_fpga_gpioi.din( 7 downto  4) <= gpio_button;
    top_fpga_gpioi.din(15 downto  8) <= gpio_header_ls;
    top_fpga_gpioi.din(30 downto 16) <= (others => '0');
    top_fpga_gpioi.din(31)           <= simulation_active;


    ------------------------------------------------------------ 
    -- uart connection
    top_fpga_uarti.rxd    <= usb_1_tx;          -- function: RX data in
    top_fpga_uarti.ctsn   <= usb_1_rts;         -- not( usb_1_rts); function: CTS input
    top_fpga_uarti.extclk <= '0';
    usb_1_rx              <= box_i0_uarto.txd;  -- function: TX data out
    usb_1_cts             <= box_i0_uarto.rtsn; -- function: RTS

    
    ------------------------------------------------------------ 
    -- fmc/main i2c io pads
    fmc_i2ci.scl  <= iic_scl_main;
    iic_scl_main  <= box_i0_fmc_i2co.scl when box_i0_fmc_i2co.scloen = '0' else 'Z';

    fmc_i2ci.sda  <= iic_sda_main;
    iic_sda_main  <= box_i0_fmc_i2co.sda when box_i0_fmc_i2co.sdaoen = '0' else 'Z';


    ------------------------------------------------------------ 
    -- fmc SFP connections
    sfp_status.tx_fault    <= fmc_la23_p;
    sfp_status.mod_detect  <= fmc_la23_n;
    sfp_status.los         <= fmc_la27_p;

    -- crippeld output buffer (with external pull-up)
    fmc_la27_n             <= 'Z' when box_i0_sfp_control.tx_disable = '1' else '0';
    -- box_i0_sfp_control.rt_sel; !!ATTN -> Jumper/hardwired

    obufds_i10 : obufds
        port map (
            i  => box_i0_sfp_tx,
            o  => fmc_la14_p, 
            ob => fmc_la14_n
        );
    user_sma_clock_n <= box_i0_sfp_tx;
    --user_sma_clock_n <= clk_in_260;

    ibufds_i00 : ibufds
        generic map (
            diff_term    => true,
            ibuf_low_pwr => true
        )
        port map (
            i  => fmc_la13_p, 
            ib => fmc_la13_n,
            o  => sfp_rx
        );


    ---------------------------------------------------------------------
    -- box system

    box_i0: box
        port map (
            -- pragma translate_off
            simulation_break => simulation_break,      -- : out   std_ulogic;
            -- pragma translate_on
            clk              => clk,                   -- : in    std_ulogic;
            reset_n          => reset_n,               -- : in    std_ulogic;
            --                                     
            uarti            => top_fpga_uarti,        -- : in    uart_in_type
            uarto            => box_i0_uarto,          -- : out   uart_out_type
            --                                     
            gpioi            => top_fpga_gpioi,        -- : in    gpio_in_type;
            gpioo            => box_i0_gpioo,          -- : out   gpio_out_type;
            --                                                             
            fmc_i2ci         => fmc_i2ci,              -- : in    i2c_in_type;
            fmc_i2co         => box_i0_fmc_i2co,       -- : out   i2c_out_type;
            --
            sfp_status       => sfp_status,            -- : in    sfp_status_in_t;
            sfp_control      => box_i0_sfp_control,    -- : out   sfp_control_out_t;
            sfp_rx           => sfp_rx,                -- : in    std_ulogic;
            sfp_tx           => box_i0_sfp_tx,         -- : out   std_ulogic;
            --               
            trigger_signals  => box_i0_trigger_signals -- : out   std_ulogic_vector(7 downto 0)
        );


    ---------------------------------------------------------------------
    -- output buffer for trigger signals
    -- and LEDs
    obufds_i00 : obufds
        port map (
            i  => box_i0_trigger_signals(0),
            o  => fmc_la09_p, 
            ob => fmc_la09_n
        );
    fmc_la11_p <= box_i0_trigger_signals(0);



    obufds_i01 : obufds
        port map (
            i  => box_i0_trigger_signals(1),
            o  => fmc_la10_p, 
            ob => fmc_la10_n
        );
    fmc_la11_n <= box_i0_trigger_signals(1);


    obufds_i02 : obufds
        port map (
            i  => box_i0_trigger_signals(2),
            o  => fmc_la05_p, 
            ob => fmc_la05_n
        );
    fmc_la15_p <= box_i0_trigger_signals(2);


    obufds_i03 : obufds
        port map (
            i  => box_i0_trigger_signals(3),
            o  => fmc_la06_p, 
            ob => fmc_la06_n
        );
    fmc_la15_n <= box_i0_trigger_signals(3);


    obufds_i04 : obufds
        port map (
            i  => box_i0_trigger_signals(4),
            o  => fmc_la12_p, 
            ob => fmc_la12_n
        );
    fmc_la19_p <= box_i0_trigger_signals(4);


    obufds_i05 : obufds
        port map (
            i  => box_i0_trigger_signals(5),
            o  => fmc_la07_p, 
            ob => fmc_la07_n
        );
    fmc_la19_n <= box_i0_trigger_signals(5);


    obufds_i06 : obufds
        port map (
            i  => box_i0_trigger_signals(6),
            o  => fmc_la08_p, 
            ob => fmc_la08_n
        );
    fmc_la21_p <= box_i0_trigger_signals(6);


    obufds_i07 : obufds
        port map (
            i  => box_i0_trigger_signals(7),
            o  => fmc_la04_p, 
            ob => fmc_la04_n
        );
    fmc_la21_n <= box_i0_trigger_signals(7);


    obufds_i08 : obufds
        port map (
            i  => box_i0_trigger_signals(8),
            o  => fmc_la03_p, 
            ob => fmc_la03_n
        );
    fmc_la24_p <= box_i0_trigger_signals(8);


    obufds_i09 : obufds
        port map (
            i  => box_i0_trigger_signals(9),
            o  => fmc_la02_p, 
            ob => fmc_la02_n
        );
    fmc_la24_n <= box_i0_trigger_signals(9);


    obufds_i11 : obufds
        port map (
            i  => reset,
            o  => fmc_la33_p, 
            ob => fmc_la33_n
        );

    ------------------------------------------------------------ 
    -- gpio output pads
    -- placement on board: LED0, LED1, LED2, LED3
    gpio_led       <= box_i0_gpioo.dout( 3 downto 0);
    gpio_header_ls <= box_i0_gpioo.dout(15 downto 8);



end architecture rtl;
