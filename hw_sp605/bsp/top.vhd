-- top level des beam position monitor
-- für SP605
-- 
-- enthält alle buffer/treiber für die FPGA-Pins
--
--

--------------------------------------------------------------------------------
-- $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/hardware/board_sp605/rtl/top.vhd $
-- $Date: 2011-09-09 14:11:20 +0200 (Fr, 09. Sep 2011) $
-- $Author: lange $
-- $Revision: 1246 $
--------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.bufg;
use unisim.vcomponents.bufgmux;
use unisim.vcomponents.iddr2;
use unisim.vcomponents.ibufgds_diff_out;
use unisim.vcomponents.ibufgds;
use unisim.vcomponents.ibufds;
use unisim.vcomponents.dcm_sp;
use unisim.vcomponents.oddr2;

library work;
use work.components.box;
use work.components.chipscope;
use work.components.testsignal_generator;

library bpm;
use bpm.types_package.all;
use bpm.components_package.testsignal_drain;


entity top is
    generic (
        testgen_use_file_as_source : boolean := false
    );
    port (
        -- pragma translate_off
        simulation_break          : out   std_logic;
        -- pragma translate_on
        cpu_reset                 : in    std_logic; -- SW6 pushbutton (active-high)
        --                                
        -- DVI chip CH7301                
        dvi_d                     : out   std_logic_vector(11 downto 0);
        dvi_de                    : out   std_logic;
        dvi_v                     : out   std_logic;
        dvi_h                     : out   std_logic;
        dvi_gpio1                 : out   std_logic;
        dvi_reset_b               : out   std_logic;
        dvi_xclk_n                : out   std_logic;
        dvi_xclk_p                : out   std_logic;
        -- IIC addresses
        -- Chrontel CH730C: 1110110
        -- DVI connector  : 1010000
        iic_scl_dvi               : inout std_logic; -- clock stretching?
        iic_sda_dvi               : inout std_logic;
        --                                
        -- flash memory                        
        flash_a                   : out   std_logic_vector(23 downto 0);
        flash_d                   : inout std_logic_vector(15 downto 3);
        --
        fpga_d0_din_miso_miso1    : inout std_logic; -- dual use
        fpga_d1_miso2             : inout std_logic; -- dual use
        fpga_d2_miso3             : inout std_logic; -- dual use
        flash_wait                : in    std_logic;
        flash_we_b                : out   std_logic;
        flash_oe_b                : out   std_logic;
        flash_ce_b                : out   std_logic;
        flash_adv_b               : in    std_logic;
        --
        -- FCM connector
        -- M2C   Mezzanine to Carrier
        -- C2M   Carrier to Mezzanine
        fmc_clk0_m2c_n            : in    std_logic;
        fmc_clk0_m2c_p            : in    std_logic;
        fmc_clk1_m2c_n            : in    std_logic;
        fmc_clk1_m2c_p            : in    std_logic;
        -- MGT
        --fmc_dp0_c2m_n             : out   std_logic;  -- new
        --fmc_dp0_c2m_p             : out   std_logic;  -- new, right direction
        --fmc_dp0_m2c_n             : in    std_logic;  -- new, right direction
        --fmc_dp0_m2c_p             : in    std_logic;  -- new, right direction
        --fmc_gbtclk0_m2c_n         : in    std_logic;
        --fmc_gbtclk0_m2c_p         : in    std_logic;
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
        -- ???
        fpga_awake                : out   std_logic;
        fpga_cclk                 : out   std_logic;
        fpga_cmp_clk              : in    std_logic;
        fpga_cmp_cs_b             : in    std_logic;
        fpga_cmp_mosi             : in    std_logic;
        --
        fpga_hswapen              : in    std_logic;
        fpga_init_b               : out   std_logic; -- low active
        fpga_m0_cmp_miso          : in    std_logic; -- mode DIP switch SW1 active high
        fpga_m1                   : in    std_logic; -- mode DIP switch SW1 active high
        fpga_mosi_csi_b_miso0     : inout std_logic;
        fpga_onchip_term1         : inout std_logic;
        fpga_onchip_term2         : inout std_logic;
        fpga_prog_b               : in    std_logic; -- active low
        fpga_suspend              : in    std_logic;
        fpga_tck                  : in    std_logic;
        fpga_tdi                  : in    std_logic;
        fpga_tms                  : in    std_logic;
        fpga_vbatt                : in    std_logic;
        fpga_vtemp                : in    std_logic;
        --
        -- GPIOs
        gpio_button               : in    std_logic_vector(3 downto 0); -- active high
        gpio_header_ls            : inout std_logic_vector(3 downto 0); -- 3.3V with level shifter
        gpio_led                  : out   std_logic_vector(3 downto 0);
        gpio_switch               : in    std_logic_vector(3 downto 0); -- active high
        --
        -- DDR3 memory
        mem1_a                    : out   std_logic_vector(14 downto 0);
        mem1_ba                   : out   std_logic_vector(2 downto 0);
        mem1_cas_b                : out   std_logic;
        mem1_ras_b                : out   std_logic;
        mem1_we_b                 : out   std_logic;
        mem1_cke                  : out   std_logic;
        mem1_clk_n                : out   std_logic; 
        mem1_clk_p                : out   std_logic; 
        mem1_dq                   : inout std_logic_vector(15 downto 0);
        mem1_ldm                  : out   std_logic;
        mem1_udm                  : out   std_logic;
        mem1_ldqs_n               : inout std_logic;
        mem1_ldqs_p               : inout std_logic;
        mem1_udqs_n               : inout std_logic;
        mem1_udqs_p               : inout std_logic;
        mem1_odt                  : out   std_logic;
        mem1_reset_b              : out   std_logic; -- reset_n ?
        --
        -- PCIe (MGT)
        pcie_250m_n               : in    std_logic; -- ??
        pcie_250m_p               : in    std_logic; -- ??
        pcie_perst_b_ls           : in    std_logic; -- ??
        pcie_rx0_n                : in    std_logic; -- ??
        pcie_rx0_p                : in    std_logic; -- ??
        pcie_tx0_n                : out   std_logic; -- ??
        pcie_tx0_p                : out   std_logic; -- ??
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
        phy_int                   : out   std_logic;
        phy_mdc                   : out   std_logic;
        phy_mdio                  : inout std_logic;
        phy_reset                 : out   std_logic;
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
        -- pmbus
        pmbus_alert               : in    std_logic;
        pmbus_clk                 : in    std_logic;
        pmbus_ctrl                : in    std_logic;
        pmbus_data                : in    std_logic;
        --
        -- SFP (MGT)
        sfpclk_qo_n               : in    std_logic;
        sfpclk_qo_p               : in    std_logic;
        -- IIC address: 101000 
        iic_scl_sfp               : inout std_logic;
        iic_sda_sfp               : inout std_logic;
        sfp_los                   : in    std_logic;
        sfp_rx_n                  : in    std_logic;
        sfp_rx_p                  : in    std_logic;
        sfp_tx_disable_fpga       : in    std_logic;
        sfp_tx_n                  : out   std_logic;
        sfp_tx_p                  : out   std_logic;
        --
        -- SMA MGT reference clock 
        sma_refclk_n              : in    std_logic;
        sma_refclk_p              : in    std_logic;
        -- SMA MGT connectors
        sma_rx_n                  : in    std_logic;
        sma_rx_p                  : in    std_logic;
        sma_tx_n                  : out   std_logic;
        sma_tx_p                  : out   std_logic;
        --
        --
        spi_cs_b                  : out   std_logic;
        --
        -- SysACE
        clk_33mhz_sysace          : in    std_logic;
        sysace_cfgtdi             : in    std_logic;
        sysace_d_ls               : inout std_logic_vector(7 downto 0);
        sysace_mpa_ls             : out   std_logic_vector(6 downto 0);
        sysace_mpbrdy_ls          : in    std_logic;
        sysace_mpce_ls            : out   std_logic;
        sysace_mpirq_ls           : in    std_logic;
        sysace_mpoe_ls            : out   std_logic;
        sysace_mpwe_ls            : out   std_logic;
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
        user_sma_clock_p         : in    std_logic;
        user_sma_clock_n         : in    std_logic;
        --
        user_sma_gpio_p          : inout std_logic;
        user_sma_gpio_n          : inout std_logic
    );
end entity top;




library gaisler;
use gaisler.misc.all; -- types
use gaisler.uart.all; -- types
use gaisler.net.all;  -- types
use gaisler.memctrl.all; -- spimctrl types

library work;
use work.types.all;


architecture rtl of top is

    constant system_frequency_c : natural := 52_000_000;
    --constant system_frequency_c : natural := 27_000_000;

    function simulation_active return std_ulogic is
        variable result : std_ulogic;
    begin
        result := '0';
        -- pragma translate_off
        result := '1';
        -- pragma translate_on
        return result;
    end function simulation_active;

    --
    -- signal definitions to resolve inout signals
    --
    signal sys_clk                            : std_ulogic;
    signal clk_52                             : std_ulogic;
    signal clk_adc_52                         : std_ulogic;
    signal clk_adc_52_n                       : std_ulogic;
    signal clk_box                            : std_ulogic;
    signal clk_vga                            : std_ulogic;
    signal clk_vga_n                          : std_ulogic;
    signal clk_gtx_125                        : std_ulogic;
    --
    signal reset_shreg                        : std_ulogic_vector(3 downto 0) := (others => '1');
    signal reset                              : std_ulogic := '1';
    signal reset_n                            : std_ulogic := '0';
    --
    signal adc_clk                            : std_ulogic;
    signal adc_clk_n                          : std_ulogic;
    signal adc_clk_buf                        : std_ulogic;
    signal adc_clk_n_buf                      : std_ulogic;
    signal clk_adc_active                     : std_ulogic;
    signal clk_adc_select                     : std_ulogic;
    --
    signal adc_data                           : std_ulogic_vector(13 downto 0);
    signal adc_data_16bit                     : std_ulogic_vector(15 downto 0);
    --
    signal uarti                              : uart_in_type;
    signal gpioi                              : gpio_in_type;
    signal fmc_i2ci                           : i2c_in_type;
    signal dvi_i2ci                           : i2c_in_type;
    signal spmi                               : spimctrl_in_type;
    signal memi                               : memory_in_type;
    signal ethi                               : eth_in_type;
    --
    signal box_i0_break                       : std_ulogic;
    signal box_i0_uarto                       : uart_out_type;
    signal box_i0_gpioo                       : gpio_out_type;
    signal box_i0_fmc_i2co                    : i2c_out_type;
    signal box_i0_dvi_i2co                    : i2c_out_type;
    signal box_i0_vgao                        : apbvga_out_type;
    signal box_i0_spmo                        : spimctrl_out_type;
    signal box_i0_memo                        : memory_out_type;
    signal box_i0_etho                        : eth_out_type;
    --
    signal box_i0_testsignal_generator_ctrl   : testsignal_generator_ctrl_t;
    signal box_i0_dac0                        : dac_spi_t;
    signal box_i0_dac1                        : dac_spi_t;
    signal box_i0_dac2                        : dac_spi_t;
    signal box_i0_dac3                        : dac_spi_t;
    signal box_i0_glcd                        : ea_dogs_out_t;
    signal box_i0_error_led                   : std_ulogic;

    --
    signal dvi_data_0                         : std_logic_vector(dvi_d'range);
    signal dvi_data_1                         : std_logic_vector(dvi_d'range);
    --
    signal micropulse                         : std_ulogic;
    signal dcm_in                             : dcm_in_t;
    signal testsignal_generator_i0_micropulse : std_ulogic;
    signal testsignal_generator_i0_adc0       : std_ulogic_vector(15 downto 0);
    signal testsignal_generator_i0_adc1       : std_ulogic_vector(15 downto 0);
    signal testsignal_generator_i0_adc2       : std_ulogic_vector(15 downto 0);
    signal testsignal_generator_i0_adc3       : std_ulogic_vector(15 downto 0);
    signal testsignal_generator_i0_dcm        : std_ulogic_vector(15 downto 0);
    signal testsignal_generator_i0_dcm_enable : std_ulogic;
    --
    signal testsignal_drain_i0_sig            : std_ulogic;


begin


    ------------------------------------------------------------ 
    -- clock stuff
    --
    clk_driver_b : block
        signal clk_fb0           : std_ulogic;
        signal dcm_sp_i0_clk0    : std_ulogic;
        signal dcm_sp_i0_clkfx   : std_ulogic;
        signal dcm_sp_i0_clkdv   : std_ulogic;
        signal dcm_sp_i0_clkdv_n : std_ulogic;
        --
        signal clk_fb1           : std_ulogic;
        signal dcm_sp_i1_clk0    : std_ulogic;
        signal dcm_sp_i1_clk180  : std_ulogic;
        signal dcm_sp_i1_locked  : std_ulogic;
        signal dcm_sp_i1_status  : std_logic_vector(7 downto 0);
        --
        signal clk_fb2           : std_ulogic;
        signal dcm_sp_i2_clk0    : std_ulogic;
        signal dcm_sp_i2_clkfx   : std_ulogic;
    begin

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
        
        -- DCM
        dcm_sp_i0: dcm_sp
        generic map (
            startup_wait      => true, -- wait with DONE till locked
            clkin_divide_by_2 => true,
            clkdv_divide      => 4.0,
            clkfx_multiply    => 13,
            clkfx_divide      => 25,
            clk_feedback      => "1x"
        )
        port map (
            clkin => sys_clk,
            clk0  => dcm_sp_i0_clk0,
            clkdv => dcm_sp_i0_clkdv,
            clkfx => dcm_sp_i0_clkfx,
            clkfb => clk_fb0
        );
        
        clk_fb0   <= dcm_sp_i0_clk0;
        clk_52    <= dcm_sp_i0_clkfx;
        

        -- ADC clk input pads
        ibufgds_diff_out_i0 : ibufgds_diff_out
            generic map (
                diff_term => true
            )
            port map (
                i   => fmc_la01_cc_p,
                ib  => fmc_la01_cc_n,
                o   => adc_clk,
                ob  => adc_clk_n
            );

        -- use bufg for adc clk (necessary for timing!)
        bug_i0 : bufg
            port map (
                i => adc_clk,
                o => adc_clk_buf
        );

        bug_i1 : bufg
            port map (
                i => adc_clk_n,
                o => adc_clk_n_buf
        );


        -- DCM just for detecting an active ADC clock
        dcm_sp_i1: dcm_sp
            generic map (
                clk_feedback      => "1x"
            )
            port map (
                clkin  => adc_clk,
                clk0   => dcm_sp_i1_clk0,
                clk180 => dcm_sp_i1_clk180,
                clkfb  => clk_fb1,
                locked => dcm_sp_i1_locked,
                status => dcm_sp_i1_status
            );
        clk_fb1        <= dcm_sp_i1_clk0;
        clk_adc_52     <= dcm_sp_i1_clk0;
        clk_adc_52_n   <= dcm_sp_i1_clk180;
        clk_adc_active <= dcm_sp_i1_locked and not dcm_sp_i1_status(1);

        bufgmux_i0: bufgmux
            generic map (
                clk_sel_type => "SYNC"
            )
            port map (
                o  => clk_box,
                i0 => clk_52,
                i1 => clk_adc_52,
                s  => clk_adc_select
            );

       
        -- chrontel chip needs both clk edges
        clk_vga   <= dcm_sp_i0_clkdv;
        clk_vga_n <= not dcm_sp_i0_clkdv;
        

        -- DCM for GTX clock (ethernet)
        dcm_sp_i2: dcm_sp
        generic map (
            startup_wait      => true, -- wait with DONE till locked
            clkfx_multiply    => 5,
            clkfx_divide      => 8,
            clk_feedback      => "1x"
        )
        port map (
            clkin => sys_clk,
            clk0  => dcm_sp_i2_clk0,
            clkfx => dcm_sp_i2_clkfx,
            clkfb => clk_fb2
        );
        
        clk_fb2     <= dcm_sp_i2_clk0;
        clk_gtx_125 <= dcm_sp_i2_clkfx;

    end block clk_driver_b;


    ------------------------------------------------------------ 
    -- reset generation
    reset_generator_p: process
    begin
        wait until rising_edge( clk_box);
        reset_shreg <= reset_shreg(reset_shreg'left-1 downto 0) & '0';
        reset       <= reset_shreg(reset_shreg'left);
        if cpu_reset = '1' then
            reset_shreg <= (others => '1');
        end if;
    end process;
    reset_n <= not reset;


    ------------------------------------------------------------ 
    -- adc connection
    adc_driver_b : block
        signal d01           : std_ulogic;
        signal d23           : std_ulogic;
        signal d45           : std_ulogic;
        signal d67           : std_ulogic;
        signal d89           : std_ulogic;
        signal d1011         : std_ulogic;
        signal d1213         : std_ulogic;
        signal adc_ddr       : std_ulogic_vector( 6 downto 0);
        signal adc_data_rand : std_ulogic_vector(13 downto 0) := (others => '0');
    begin

        -- differential input buffer
        ibufds_i00 : ibufds
            generic map (
                diff_term => true
            )
            port map (
                o  => d01,
                i  => fmc_la02_p,
                ib => fmc_la02_n
            );
   
        ibufds_i01 : ibufds
            generic map (
                diff_term => true
            )
            port map (
                o  => d23,
                i  => fmc_la04_p,
                ib => fmc_la04_n
            );
   
        ibufds_i02 : ibufds
            generic map (
                diff_term => true
            )
            port map (
                o  => d45,
                i  => fmc_la07_p,
                ib => fmc_la07_n
            );
   
        ibufds_i03 : ibufds
            generic map (
                diff_term => true
            )
            port map (
                o  => d67,
                i  => fmc_la11_p,
                ib => fmc_la11_n
            );
   
        ibufds_i04 : ibufds
            generic map (
                diff_term => true
            )
            port map (
                o  => d89,
                i  => fmc_la15_p,
                ib => fmc_la15_n
            );
   
        ibufds_i05 : ibufds
            generic map (
                diff_term => true
            )
            port map (
                o  => d1011,
                i  => fmc_la19_p,
                ib => fmc_la19_n
            );
   
        ibufds_i06 : ibufds
            generic map (
                diff_term => true
            )
            port map (
                o  => d1213,
                i  => fmc_la21_p,
                ib => fmc_la21_n
            );
   
        -- collect signals to vector
        -- 14 bit ADC:
        adc_ddr <= d1213 & d1011 & d89 & d67 & d45 & d23 & d01; 
      
        -- make double data rate to single data rate signals
        iddr2_ix : for i in 0 to 6 generate
            iddr2_i : iddr2
                generic map (
                    ddr_alignment => "c0",
                    init_q0       => '0',
                    init_q1       => '0'
                )
                port map (
                    ce => '1',
                    c0 => adc_clk_buf,
                    c1 => adc_clk_n_buf,
                    d  => adc_ddr(i),
                    r  => '0',
                    s  => '0',
                    q0 => adc_data_rand(2 * i + 1),
                    q1 => adc_data_rand(2 * i)
               );
        end generate;
    
        de_randomizer : for i in 1 to 13 generate
            adc_data(i) <= adc_data_rand(i) xor adc_data_rand(0);
        end generate;
        -- unrandomized LSB
        adc_data(0) <= adc_data_rand(0);
        
        -- emulate 16 Bit DAC (copy the lower bits)
        adc_data_16bit <= adc_data & adc_data(0) & adc_data(0);

    end block adc_driver_b;


    chipscope_i0 : chipscope
        port map (
            clk  => adc_clk_buf,               --: in std_ulogic;
            data => x"0000" & adc_data_16bit,  --: in std_ulogic_vector(15 downto 0);
            trig => '1'                        --: in std_ulogic
            );


    -- default output drivers
    -- mainly unused signals
    dvi_gpio1                <= '1';-- hot plug detect ?
    --
    --
    fmc_la00_cc_n            <= 'Z';
    fmc_la00_cc_p            <= 'Z';
    fmc_la01_cc_n            <= 'Z';
    fmc_la01_cc_p            <= 'Z';
    fmc_la02_n               <= 'Z';
    fmc_la02_p               <= 'Z';
    fmc_la03_n               <= 'Z';
    fmc_la03_p               <= 'Z';
    fmc_la04_n               <= 'Z';
    fmc_la04_p               <= 'Z';
    fmc_la05_n               <= 'Z';
    fmc_la05_p               <= 'Z';
    fmc_la06_n               <= 'Z';
    fmc_la06_p               <= 'Z';
    fmc_la07_n               <= 'Z';
    fmc_la07_p               <= 'Z';
    fmc_la08_n               <= 'Z';
    fmc_la08_p               <= 'Z';
    fmc_la09_n               <= 'Z';
    fmc_la09_p               <= 'Z';
    fmc_la10_n               <= 'Z';
    fmc_la10_p               <= 'Z';
    fmc_la11_n               <= 'Z';
    fmc_la11_p               <= 'Z';
    fmc_la12_n               <= 'Z';
    fmc_la12_p               <= 'Z';
    fmc_la13_n               <= 'Z';
    fmc_la13_p               <= 'Z';
    fmc_la14_n               <= 'Z';
    fmc_la14_p               <= 'Z';
    fmc_la15_n               <= 'Z';
    fmc_la15_p               <= 'Z';
    fmc_la16_n               <= 'Z';
    fmc_la16_p               <= 'Z';
    fmc_la17_cc_n            <= 'Z';
    fmc_la17_cc_p            <= 'Z';
    fmc_la18_cc_n            <= 'Z';
    fmc_la18_cc_p            <= 'Z';
    fmc_la19_n               <= 'Z';
    fmc_la19_p               <= 'Z';
    fmc_la20_n               <= 'Z';
    fmc_la20_p               <= 'Z';
    fmc_la21_n               <= 'Z';
    fmc_la21_p               <= 'Z';
    fmc_la22_n               <= 'Z';
    fmc_la22_p               <= 'Z';
    fmc_la23_n               <= 'Z';
    fmc_la23_p               <= 'Z';
    fmc_la24_n               <= 'Z';
    fmc_la24_p               <= 'Z';
    fmc_la25_n               <= 'Z';
    fmc_la25_p               <= 'Z';
    fmc_la26_n               <= 'Z';
    fmc_la26_p               <= 'Z';
    fmc_la27_n               <= 'Z';
    fmc_la27_p               <= 'Z';
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
    fmc_la33_n               <= 'Z';
    fmc_la33_p               <= 'Z';
    fpga_init_b              <= '1';
    fpga_onchip_term1        <= 'Z';
    fpga_onchip_term2        <= 'Z';
    --
    mem1_a                   <= (others => '1');
    mem1_ba                  <= (others => '1');
    mem1_cas_b               <= '1';
    mem1_ras_b               <= '1';
    mem1_we_b                <= '1';
    mem1_cke                 <= '0';
    mem1_clk_n               <= '0';
    mem1_clk_p               <= '1';
    mem1_dq                  <= (others => 'Z');
    mem1_ldm                 <= '0';
    mem1_udm                 <= '0';
    mem1_ldqs_n              <= 'Z';
    mem1_ldqs_p              <= 'Z';
    mem1_udqs_n              <= 'Z';
    mem1_udqs_p              <= 'Z';
    mem1_odt                 <= '1';
    mem1_reset_b             <= '1';
    --
    pcie_tx0_n               <= 'Z';
    pcie_tx0_p               <= 'Z';
    --
    iic_scl_sfp              <= 'Z';
    iic_sda_sfp              <= 'Z';
    sfp_tx_n                 <= 'Z';
    sfp_tx_p                 <= 'Z';
    --
    sma_tx_n                 <= 'Z';
    sma_tx_p                 <= 'Z';
    --
    sysace_d_ls              <= (others => 'Z');
    sysace_mpa_ls            <= (others => '1');
    sysace_mpce_ls           <= '1';
    sysace_mpoe_ls           <= '1';
    sysace_mpwe_ls           <= '1';
    --
    user_sma_gpio_n          <= 'Z';
    user_sma_gpio_p          <= 'Z';

    

    
    ------------------------------------------------------------ 
    -- SPI memory pads
    -- SPI X4 (Winbond W25Q64VSFIG) 64-Mbit flash memory 
    -- in
    spmi.miso             <= fpga_d0_din_miso_miso1;  -- shared with flash data
    spmi.mosi             <= fpga_mosi_csi_b_miso0;   -- bidi for 2x mode
    spmi.cd               <= '0';        -- card detection
    -- out
    fpga_d2_miso3         <= '1' when box_i0_spmo.csn = '0' else 'Z'; -- /hold
    fpga_d1_miso2         <= '0' when box_i0_spmo.csn = '0' else 'Z'; -- /write_protect
    fpga_cclk             <= box_i0_spmo.sck;
    fpga_mosi_csi_b_miso0 <= box_i0_spmo.mosi when box_i0_spmo.mosioen = '0' else 'Z';
    spi_cs_b              <= '0'              when box_i0_spmo.csn     = '0' else 'Z';


    ------------------------------------------------------------ 
    -- BPI parallel flash
    -- in
    memi.brdyn               <= '1';               -- bus ready strobe
    memi.bexcn               <= '1';               -- bus exception
    memi.wrn(3 downto 0)     <= "1111";            -- sram write enable feedback
    memi.bwidth(1 downto 0)  <= "00";              -- data width of prom area = 8 bit
    memi.sd                  <= (others => '1');   -- sdram separate data bus
    memi.data                <= flash_d & fpga_d2_miso3 & fpga_d1_miso2 & fpga_d0_din_miso_miso1 & x"0000";
    memi.cb                  <= (others => '1');
    memi.scb                 <= (others => '1');
    memi.writen              <= '1';
    memi.edac                <= '1';

    -- inout
    fpga_d0_din_miso_miso1   <= box_i0_memo.data(16)           when box_i0_memo.bdrive(0) = '0' else 'Z';
    fpga_d1_miso2            <= box_i0_memo.data(17)           when box_i0_memo.bdrive(0) = '0' else 'Z'; 
    fpga_d2_miso3            <= box_i0_memo.data(18)           when box_i0_memo.bdrive(0) = '0' else 'Z'; 
    flash_d(15 downto 3)     <= box_i0_memo.data(31 downto 19) when box_i0_memo.bdrive(0) = '0' else "ZZZZZZZZZZZZZ";
    -- out
    fmc_pwr_good_flash_rst_b <= reset_n;
    flash_ce_b               <= box_i0_memo.romsn(0);
    flash_oe_b               <= box_i0_memo.oen;
    flash_we_b               <= box_i0_memo.writen;

    flash_a                  <= box_i0_memo.address(23 downto 0);


    
    ------------------------------------------------------------ 
    -- gpio input pads
    gpioi.sig_in            <= (others => '0');
    gpioi.sig_en            <= (others => '0');
    gpioi.din( 3 downto  0) <= gpio_switch;
    gpioi.din( 7 downto  4) <= gpio_button;
    gpioi.din(11 downto  8) <= gpio_header_ls;
    gpioi.din(29 downto 12) <= (others => '0');
    gpioi.din(31)           <= simulation_active;

    
    ------------------------------------------------------------ 
    -- uart input
    uarti.rxd    <= usb_1_tx;  -- function: RX data in
    uarti.ctsn   <= usb_1_rts; -- not( usb_1_rts); function: CTS input
    uarti.extclk <= '0';

    
    ------------------------------------------------------------ 
    -- ethernet (10/100)
    -- in
    ethi.gtx_clk    <= clk_gtx_125;
    ethi.rmii_clk   <= '0';
    ethi.tx_clk     <= phy_txclk;
    ethi.rx_clk     <= phy_rxclk;
    ethi.rxd        <= phy_rxd;
    ethi.rx_dv      <= phy_rxctl_rxdv;
    ethi.rx_er      <= phy_rxer;
    ethi.rx_col     <= phy_col;
    ethi.rx_crs     <= phy_crs;
    ethi.mdio_i     <= phy_mdio;
    ethi.mdint      <= '0';
    ethi.phyrstaddr <= "00111";
    ethi.edcladdr   <= (others => '0');
    -- out
    phy_reset       <= '0';
    phy_int         <= 'Z';
    phy_txc_gtxclk  <= clk_gtx_125;
    phy_txd         <= box_i0_etho.txd;
    phy_txctl_txen  <= box_i0_etho.tx_en;
    phy_txer        <= box_i0_etho.tx_er;
    phy_mdc         <= box_i0_etho.mdc;
    -- inout
    phy_mdio        <= box_i0_etho.mdio_o when box_i0_etho.mdio_oe = '0' else 'Z';


    ------------------------------------------------------------ 
    -- test signals
    testsignal_generator_i0: testsignal_generator 
        generic map (
            use_file_as_source   => testgen_use_file_as_source,           -- : boolean
            disable_ch2_ch3      => false                                 -- : boolean
        )                                                        
        port map (                                               
            clk                  => clk_box,                              -- : in  std_ulogic;
            simulation           => simulation_active,                    -- : in  std_ulogic;
            ctrl                 => box_i0_testsignal_generator_ctrl,     -- : in  testsignal_generator_ctrl_t;
            micropulse           => testsignal_generator_i0_micropulse,   -- : out std_ulogic
            adc_0                => testsignal_generator_i0_adc0,         -- : out std_ulogic_vector(15 downto 0);
            adc_1                => testsignal_generator_i0_adc1,         -- : out std_ulogic_vector(15 downto 0);
            adc_2                => testsignal_generator_i0_adc2,         -- : out std_ulogic_vector(15 downto 0);
            adc_3                => testsignal_generator_i0_adc3,         -- : out std_ulogic_vector(15 downto 0)
            dcm                  => testsignal_generator_i0_dcm,          -- : out std_ulogic_vector(15 downto 0);
            dcm_enable           => testsignal_generator_i0_dcm_enable    -- : out std_ulogic
        );
    dcm_in <= ( data    => (
                    enable => testsignal_generator_i0_dcm_enable, 
                    value  => signed( testsignal_generator_i0_dcm)
                    ),
                active  => gpio_switch(0),
                link_up => gpio_switch(1));


    ------------------------------------------------------------ 
    -- box system
    box_i0: box
        port map (
            clk          => clk_box,                                       --: in    std_ulogic;
            reset_n      => reset_n,                                       --: in    std_ulogic;
            break        => box_i0_break,                                  --: out   std_ulogic;
            --                                                             
            uarti        => uarti,                                         --: in    uart_in_type;
            uarto        => box_i0_uarto,                                  --: out   uart_out_type;
            --                                                             
            gpioi        => gpioi,                                         --: in    gpio_in_type;
            gpioo        => box_i0_gpioo,                                  --: out   gpio_out_type;
            --                                                             
            fmc_i2ci     => fmc_i2ci,                                      --: in    i2c_in_type;
            fmc_i2co     => box_i0_fmc_i2co,                               --: out   i2c_out_type;
            --                                                             
            dvi_i2ci     => dvi_i2ci,                                      --: in    i2c_in_type;
            dvi_i2co     => box_i0_dvi_i2co,                               --: out   i2c_out_type;
            --                                                             
            clk_vga      => clk_vga,                                       --: in    std_ulogic;
            vgao         => box_i0_vgao,                                   --: out   apbvga_out_type
            --
            spmi         => spmi,                                          --: in    spmictrl_in_type;
            spmo         => box_i0_spmo,                                   --: out   spmictrl_out_type;
            --  
            memi         => memi,                                          --: in    memory_in_type;
            memo         => box_i0_memo,                                   --: out   memory_out_type;
            --
            ethi         => ethi,                                          --: in    eth_in_type;
            etho         => box_i0_etho,                                   --: out   eth_out_type;
            --
            testsignal_generator_ctrl => box_i0_testsignal_generator_ctrl, --: out testsignal_generator_ctrl_t;
            --
            micropulse   => micropulse,                                    --: in  std_ulogic;
            channel0     => adc_data_16bit,                                --: in  std_ulogic_vector(15 downto 0);
            channel1     => testsignal_generator_i0_adc1,                  --: in  std_ulogic_vector(15 downto 0);
            channel2     => testsignal_generator_i0_adc2,                  --: in  std_ulogic_vector(15 downto 0);
            channel3     => testsignal_generator_i0_adc3,                  --: in  std_ulogic_vector(15 downto 0)
            dcm_in       => dcm_in,                                        --: in    int16_t;
            --                                                             
            dac0         => box_i0_dac0,                                   --: out dac_spi_t;
            dac1         => box_i0_dac1,                                   --: out dac_spi_t;
            dac2         => box_i0_dac2,                                   --: out dac_spi_t;
            dac3         => box_i0_dac3,                                   --: out dac_spi_t
            --                                                             
            glcd         => box_i0_glcd,                                   --: out   ea_dogs_out_t;
            --                                                             
            error_led    => box_i0_error_led                               --: out   std_ulogic
        );
        
    ------------------------------------------------------------ 
    -- break for simulation
    --
    -- pragma translate_off
    simulation_break <= box_i0_break;
    -- pragma translate_on

    ------------------------------------------------------------
    -- testsignal drain
    testsignal_drain_i0: testsignal_drain
        port map (
            clk  => clk_box,                 --: in  std_ulogic;
            dac0 => box_i0_dac0,             --: in  dac_spi_t;
            dac1 => box_i0_dac1,             --: in  dac_spi_t;
            dac2 => box_i0_dac2,             --: in  dac_spi_t;
            dac3 => box_i0_dac3,             --: in  dac_spi_t;
            sig  => testsignal_drain_i0_sig  --: out std_ulogic;
        );

    ------------------------------------------------------------ 
    -- gpio output pads
    -- placement on board: LED0, LED1, LED2, LED3
    gpio_led       <= box_i0_gpioo.dout(3  downto 0);
    gpio_header_ls <= box_i0_gpioo.dout(11 downto 8);
    fpga_awake     <= testsignal_drain_i0_sig;


    ------------------------------------------------------------ 
    -- adc clk detect/select
    gpioi.din(30)  <= clk_adc_active;
    clk_adc_select <= 
    -- enable clock running in simulation
    -- pragma translate_off
        'L' and
    -- pragma translate_on
        box_i0_gpioo.dout(30);

    
    ------------------------------------------------------------ 
    -- micropulse select
    -- 0 = internal: testsignal_generator_i0_micropulse
    -- 1 = external: user_sma_clock_p
    micropulse <= user_sma_clock_p when box_i0_gpioo.dout(29) = '1' else 
                  testsignal_generator_i0_micropulse;


    ------------------------------------------------------------ 
    -- uart output
    usb_1_rx   <= box_i0_uarto.txd;  -- function: TX data out
    usb_1_cts  <= box_i0_uarto.rtsn; -- function: RTS

    
    ------------------------------------------------------------ 
    -- fmc/main i2c io pads
    fmc_i2ci.scl  <= iic_scl_main;
    iic_scl_main  <= box_i0_fmc_i2co.scl when box_i0_fmc_i2co.scloen = '0' else 'Z';

    fmc_i2ci.sda  <= iic_sda_main;
    iic_sda_main  <= box_i0_fmc_i2co.sda when box_i0_fmc_i2co.sdaoen = '0' else 'Z';

    ------------------------------------------------------------ 
    -- dvi i2c io pads
    dvi_i2ci.scl  <= iic_scl_dvi;
    iic_scl_dvi   <= box_i0_dvi_i2co.scl when box_i0_dvi_i2co.scloen = '0' else 'Z';

    dvi_i2ci.sda  <= iic_sda_dvi;
    iic_sda_dvi   <= box_i0_dvi_i2co.sda when box_i0_dvi_i2co.sdaoen = '0' else 'Z';

    ------------------------------------------------------------ 
    -- dvi vga pads
    -- idf = 0

    dvi_vga_driver_b : block
    begin

        dvi_ddr_d: for i in dvi_d'range generate
            dvi_oddr: oddr2
                port map (
                    q   => dvi_d(i),
                    c0  => clk_vga,
                    c1  => clk_vga_n,
                    ce  => '1',
                    d0  => dvi_data_1(i),
                    d1  => dvi_data_0(i),
                    r   => '0',
                    s   => '0'
                );
        end generate;
            
        dvi_de      <= box_i0_vgao.blank; -- blank is low acitve
        dvi_h       <= box_i0_vgao.hsync;
        dvi_v       <= box_i0_vgao.vsync;
        dvi_data_0  <= box_i0_vgao.video_out_g(3 downto 0) & box_i0_vgao.video_out_b(7 downto 0);
        dvi_data_1  <= box_i0_vgao.video_out_r(7 downto 0) & box_i0_vgao.video_out_g(7 downto 4);
        
        dvi_reset_b <= reset_n;

        oddr2_i0: oddr2
            generic map (
                ddr_alignment => "C0",
                srtype        => "ASYNC"
            )
            port map (
                q   => dvi_xclk_p,
                c0  => clk_vga,
                c1  => clk_vga_n,
                ce  => '1',
                d0  => '1',
                d1  => '0',
                r   => '0',
                s   => '0'
            );

        oddr2_ii: oddr2
            generic map (
                ddr_alignment => "C0",
                srtype        => "ASYNC"
            )
            port map (
                q   => dvi_xclk_n,
                c0  => clk_vga,
                c1  => clk_vga_n,
                ce  => '1',
                d0  => '0',
                d1  => '1',
                r   => '0',
                s   => '0'
            );
    end block dvi_vga_driver_b;

    ------------------------------------------------------------ 
    -- dac pads (on fmc)
    fmc_la03_n    <= box_i0_dac0.sclk;         -- fmc G10
    fmc_la03_p    <= box_i0_dac0.fsync;        -- fmc G9
    fmc_la08_p    <= box_i0_dac0.sdo;          -- fmc G12
    fmc_la08_n    <= box_i0_gpioo.dout(19);    -- fmc G13  dac_muteb_n;
    fmc_la12_p    <= box_i0_gpioo.dout(20);    -- fmc G15  dac_resetb_n;
    fmc_la12_n    <= box_i0_gpioo.dout(21);    -- fmc G16  dac_bpb_n;
    fmc_la16_p    <= box_i0_gpioo.dout(22);    -- fmc G18  dac_osr1;
    fmc_la16_n    <= box_i0_gpioo.dout(23);    -- fmc G19  dac_osr2;

    ------------------------------------------------------------ 
    -- LCD pads (on fmc)
    fmc_la27_p    <= box_i0_glcd.reset_n;      -- fmc C26  LCD RST_n
    fmc_la27_n    <= box_i0_glcd.cs0_n;        -- fmc C27  LCD CS0_n
    fmc_la10_n    <= box_i0_glcd.sck;          -- fmc C15  LCD SCK
    fmc_la10_p    <= box_i0_glcd.sda;          -- fmc C14  LCD SDA
    fmc_la14_p    <= box_i0_glcd.cd;           -- fmc C18  LCD CD
    fmc_la18_cc_n <= box_i0_glcd.backlight;    -- fmc C23  LCD BL green
    fmc_la18_cc_p <= box_i0_error_led;         -- fmc C22  LCD BL red


end architecture rtl;
