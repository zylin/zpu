

library ieee;
use ieee.std_logic_1164.all;

library gaisler;
use gaisler.misc.all;    -- types
use gaisler.uart.all;    -- types
use gaisler.net.all;     -- types
use gaisler.memctrl.all; -- spimctrl types + spmictrl component

library rena3;
use rena3.types_package.all;

library zpu;
use zpu.zpu_wrapper_package.all; -- type definitions


package component_package is


    component rena3_controller is
        port (
            -- system
            clock     : std_ulogic;
            -- rena3 (connection to chip)
            rena3_in  : in  rena3_controller_in_t;
            rena3_out : out rena3_controller_out_t;
            -- connection to soc
            zpu_in    : in  zpu_out_t;
            zpu_out   : out zpu_in_t
        );
    end component rena3_controller;


    component box is
        port (
            clk                       : in    std_ulogic;
            reset_n                   : in    std_ulogic;
            break                     : out   std_ulogic;
            --                        
            uarti                     : in    uart_in_type;
            uarto                     : out   uart_out_type;
            --                        
            gpioi                     : in    gpio_in_type;
            gpioo                     : out   gpio_out_type;
            --                        
            fmc_i2ci                  : in    i2c_in_type;
            fmc_i2co                  : out   i2c_out_type;
            --                        
            dvi_i2ci                  : in    i2c_in_type;
            dvi_i2co                  : out   i2c_out_type;
            --                        
            clk_vga                   : in    std_ulogic;
            vgao                      : out   apbvga_out_type;
            --
            spmi                      : in    spimctrl_in_type;
            spmo                      : out   spimctrl_out_type;
            --
            memi                      : in    memory_in_type;
            memo                      : out   memory_out_type;
            --
            ethi                      : in    eth_in_type;
            etho                      : out   eth_out_type;
            --                        
            rena3_0_in                : in    rena3_controller_in_t;
            rena3_0_out               : out   rena3_controller_out_t;
            rena3_1_in                : in    rena3_controller_in_t;
            rena3_1_out               : out   rena3_controller_out_t;
            --
            ad9854_out                : out   ad9854_out_t;
            ad9854_in                 : in    ad9854_in_t;
            --
            clk_adc                   : out   std_ulogic;
            adc_data                  : in    std_ulogic_vector(13 downto 0);
            adc_otr                   : in    std_ulogic
        );
    end component box;


    component top is
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
            user_sma_clock_p         : inout std_logic;
            user_sma_clock_n         : inout std_logic;
            --
            user_sma_gpio_p          : inout std_logic;
            user_sma_gpio_n          : inout std_logic
        );
    end component top;


end package component_package;
