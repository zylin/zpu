-- top testbench
--
-- contains:
--
--  +--------------+     +-------------+        +---------+
--  |  board_sp605 |     | bpm_adc_dac |        | dc1369  |
--  |              |XFMCX|  board      |XXEDGEXX|  board  |
--  |              |XLPCX|             |XX100XXX|         |
--  |  FPGA        |     | LCD + DAC   |        |  ADC    |
--  +--------------+     +-------------+        +---------+
--
--
--  +-------------------------------------------------------------------------+
--  | top_tb (= eval board sp605)                                             |
--  |                                                                         |
--  |  +----------------+                                                     |
--  |  | top (= FPGA)   |                                                     |
--  |  |                |                                                     |
--  |  |                |                                                     |
--  |  +----------------+                                                     |
--  |      *FMC LPC*                                                          |
--  |  +------------------------------------------------------------------+   |
--  |  | bpm_adc_dac_testboard                                            |   |
--  |  |                                                                  |   |
--  |  |                                                                  |   |
--  |  | - SPI LCD (=EA DOGS 102)                                         |   |
--  |  | - LCD background LEDs                                            |   |
--  |  | - DAC                                                            |   |
--  |  |                                                                  |   |
--  |  |                                                                  |   |
--  |  |                                                                  |   |
--  |  +------------------------------------------------------------------+   |
--  |                                                                         |
--  +-------------------------------------------------------------------------+

--------------------------------------------------------------------------------
-- $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/hardware/board_sp605/rtl_tb/top_tb.vhd $
-- $Date: 2011-09-07 15:09:11 +0200 (Mi, 07. Sep 2011) $
-- $Author: lange $
-- $Revision: 1244 $
--------------------------------------------------------------------------------

entity top_tb is
end entity top_tb;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.components.top;

library std;
use std.textio.all;

library bpm;
use bpm.debug_package.all;



architecture testbench of top_tb is
    

    constant me_c                         : string  := testbench'path_name;

    -- file names for test data input and output
    constant suffix_c                     : string  := "Daten7";-- "01" for adc_01.txt
    --
    constant linfilter_filename_c         : string  := "data/linfilter_" & suffix_c & ".txt";
    constant linfilter_samples_c          : natural := 2**16;
    constant quadsum_filename_c           : string  := "data/quadsum_"   & suffix_c & ".txt";
    constant quadsum_samples_c            : natural := 2**8;


    constant gnd                          : std_logic := '0';

    signal   simulation_run               : boolean := true;
    signal   tb_simulation_break          : std_logic;


    signal   tb_cpu_reset                 : std_logic; -- SW6 pushbutton (active-high)
    --                                
    -- DVI chip CH7301                
    signal   tb_dvi_d                     : std_logic_vector(11 downto 0);
    signal   tb_dvi_de                    : std_logic;
    signal   tb_dvi_v                     : std_logic;
    signal   tb_dvi_h                     : std_logic;
    signal   tb_dvi_gpio1                 : std_logic;
    signal   tb_dvi_reset_b               : std_logic;
    signal   tb_dvi_xclk_n                : std_logic;
    signal   tb_dvi_xclk_p                : std_logic;
    signal   tb_iic_scl_dvi               : std_logic; -- clock stretching?
    signal   tb_iic_sda_dvi               : std_logic;
    --                                
    -- flash memory                        
    signal   tb_flash_a                   : std_logic_vector(23 downto 0);
    signal   tb_flash_d                   : std_logic_vector(15 downto 3);
    --
    signal   tb_fpga_d0_din_miso_miso1    : std_logic; -- dual use
    signal   tb_fpga_d1_miso2             : std_logic; -- dual use    
    signal   tb_fpga_d2_miso3             : std_logic; -- dual use    
    signal   tb_flash_wait                : std_logic;
    signal   tb_flash_we_b                : std_logic;
    signal   tb_flash_oe_b                : std_logic;
    signal   tb_flash_ce_b                : std_logic;
    signal   tb_flash_adv_b               : std_logic;
    --
    -- FCM connector
    -- M2C   Mezzanine to Carrier
    -- C2M   Carrier to Mezzanine
    signal   tb_FMC_DP0_C2M_N             : std_logic;  -- new
    signal   tb_FMC_DP0_C2M_P             : std_logic;  -- new, right direction
    signal   tb_FMC_DP0_M2C_N             : std_logic;  -- new, right direction
    signal   tb_FMC_DP0_M2C_P             : std_logic;  -- new, right direction
    signal   tb_FMC_GBTCLK0_M2C_N         : std_logic;
    signal   tb_FMC_GBTCLK0_M2C_P         : std_logic;
    signal   tb_iic_scl_main              : std_logic;
    signal   tb_iic_sda_main              : std_logic;
    signal   tb_fmc_prsnt_m2c_l           : std_logic;
    signal   tb_FMC_PWR_GOOD_FLASH_RST_B  : std_logic; -- multiple destinations: 1 of Q2 (LED DS1 driver), U1 AB2 FPGA_PROG (through series R260 DNP), 44 of U25
    --       
    -- ???  
    signal   tb_FPGA_AWAKE                : std_logic;
    signal   tb_fpga_cclk                 : std_logic;
    signal   tb_FPGA_CMP_CLK              : std_logic;
    signal   tb_FPGA_CMP_CS_B             : std_logic;
    signal   tb_FPGA_CMP_MOSI             : std_logic;
    --       
    signal   tb_FPGA_HSWAPEN              : std_logic;
    signal   tb_FPGA_INIT_B               : std_logic;
    signal   tb_FPGA_M0_CMP_MISO          : std_logic;
    signal   tb_FPGA_M1                   : std_logic;
    signal   tb_fpga_mosi_csi_b_miso0     : std_logic;
    signal   tb_FPGA_ONCHIP_TERM1         : std_logic;
    signal   tb_FPGA_ONCHIP_TERM2         : std_logic;
    signal   tb_FPGA_PROG_B               : std_logic;
    signal   tb_FPGA_SUSPEND              : std_logic;
    signal   tb_FPGA_TCK                  : std_logic;
    signal   tb_FPGA_TDI                  : std_logic;
    signal   tb_FPGA_TMS                  : std_logic;
    signal   tb_FPGA_VBATT                : std_logic;
    signal   tb_FPGA_VTEMP                : std_logic;
    --
    -- GPIOs
    signal   tb_gpio_button               : std_logic_vector(3 downto 0); -- active high
    signal   tb_gpio_header_ls            : std_logic_vector(3 downto 0);
    signal   tb_gpio_led                  : std_logic_vector(3 downto 0);
    signal   tb_gpio_switch               : std_logic_vector(3 downto 0); -- active high
    --
    -- DDR3 memory
    signal   tb_mem1_a                    : std_logic_vector(14 downto 0);
    signal   tb_mem1_ba                   : std_logic_vector(2  downto 0);
    signal   tb_mem1_cas_b                : std_logic;
    signal   tb_mem1_ras_b                : std_logic;
    signal   tb_mem1_we_b                 : std_logic;
    signal   tb_mem1_cke                  : std_logic;
    signal   tb_mem1_clk_n                : std_logic; 
    signal   tb_mem1_clk_p                : std_logic; 
    signal   tb_mem1_dq                   : std_logic_vector(15 downto 0);
    signal   tb_mem1_ldm                  : std_logic;
    signal   tb_mem1_udm                  : std_logic;
    signal   tb_mem1_ldqs_n               : std_logic;
    signal   tb_mem1_ldqs_p               : std_logic;
    signal   tb_mem1_udqs_n               : std_logic;
    signal   tb_mem1_udqs_p               : std_logic;
    signal   tb_mem1_odt                  : std_logic;
    signal   tb_mem1_reset_b              : std_logic; -- reset_n ?
    --
    -- PCIe
    signal   tb_PCIE_250M_N               : std_logic; -- ??
    signal   tb_PCIE_250M_P               : std_logic; -- ??
    signal   tb_PCIE_PERST_B_LS           : std_logic; -- ??
    signal   tb_PCIE_RX0_N                : std_logic; -- ??
    signal   tb_PCIE_RX0_P                : std_logic; -- ??
    signal   tb_PCIE_TX0_N                : std_logic; -- ??
    signal   tb_PCIE_TX0_P                : std_logic; -- ??
    --
    -- Ethernet Gigabit PHY
    signal   tb_PHY_COL                   : std_logic;
    signal   tb_PHY_CRS                   : std_logic;
    signal   tb_PHY_INT                   : std_logic;
    signal   tb_PHY_MDC                   : std_logic;
    signal   tb_PHY_MDIO                  : std_logic;
    signal   tb_PHY_RESET                 : std_logic;
    signal   tb_PHY_RXCLK                 : std_logic;
    signal   tb_PHY_RXCTL_RXDV            : std_logic;
    signal   tb_PHY_RXD                   : std_logic_vector(7 downto 0);
    signal   tb_PHY_RXER                  : std_logic;
    signal   tb_PHY_TXCLK                 : std_logic;
    signal   tb_PHY_TXCTL_TXEN            : std_logic;
    signal   tb_PHY_TXC_GTXCLK            : std_logic;
    signal   tb_PHY_TXD                   : std_logic_vector(7 downto 0);
    signal   tb_PHY_TXER                  : std_logic;
    --
    -- pmbus
    signal   tb_PMBUS_ALERT               : std_logic;
    signal   tb_PMBUS_CLK                 : std_logic;
    signal   tb_PMBUS_CTRL                : std_logic;
    signal   tb_PMBUS_DATA                : std_logic;
    --
    -- SFP
    signal   tb_sfpclk_qo_n               : std_logic;
    signal   tb_sfpclk_qo_p               : std_logic;
    signal   tb_iic_scl_sfp               : std_logic;
    signal   tb_iic_sda_sfp               : std_logic;
    signal   tb_SFP_LOS                   : std_logic;
    signal   tb_SFP_RX_N                  : std_logic;
    signal   tb_SFP_RX_p                  : std_logic;
    signal   tb_SFP_TX_DISABLE_FPGA       : std_logic;
    signal   tb_SFP_tX_N                  : std_logic;
    signal   tb_SFP_tX_p                  : std_logic;
    --
    -- SMA
    signal   tb_SMA_REFCLK_N              : std_logic;
    signal   tb_SMA_REFCLK_P              : std_logic;
    signal   tb_SMA_RX_N                  : std_logic;
    signal   tb_SMA_RX_P                  : std_logic;
    signal   tb_SMA_TX_N                  : std_logic;
    signal   tb_SMA_TX_P                  : std_logic;
    --
    --
    signal   tb_spi_cs_b                  : std_logic;
    --
    -- SysACE
    constant tb_clk_33mhz_sysace_period   : time      := (1 sec / 33_000_000);
    signal   tb_clk_33mhz_sysace          : std_logic := '0';
    signal   tb_SYSACE_CFGTDI             : std_logic;
    signal   tb_SYSACE_D_LS               : std_logic_vector(7 downto 0);
    signal   tb_SYSACE_MPA_LS             : std_logic_vector(6 downto 0);
    signal   tb_SYSACE_MPBRDY_LS          : std_logic;
    signal   tb_SYSACE_MPCE_LS            : std_logic;
    signal   tb_SYSACE_MPIRQ_LS           : std_logic;
    signal   tb_SYSACE_MPOE_LS            : std_logic;
    signal   tb_SYSACE_MPWE_LS            : std_logic;
    --
    -- 200 MHz oscillator
    constant tb_sysclk_period             : time      := (1 sec / 200_000_000);
    signal   tb_sysclk_n                  : std_logic := '0';
    signal   tb_sysclk_p                  : std_logic := '1';
    --
    -- RS232 via USB
    signal   tb_usb_1_cts                 : std_logic;
    signal   tb_usb_1_rts                 : std_logic;
    signal   tb_usb_1_rx                  : std_logic;
    signal   tb_usb_1_tx                  : std_logic;
    --
    --  27 MHz, oscillator socket
    constant tb_user_clock_period         : time      := (1 sec / 27_000_000);
    signal   tb_user_clock                : std_logic := '0';
    signal   tb_user_sma_clock_p          : std_logic;
    signal   tb_user_sma_clock_n          : std_logic;
    --
    signal   tb_user_sma_gpio_p           : std_logic;
    signal   tb_user_sma_gpio_n           : std_logic;
    --
    --
    --
    signal   tb_fmc_lpc_row_c             : std_logic_vector(40 downto 1);
    signal   tb_fmc_lpc_row_d             : std_logic_vector(40 downto 1);
    signal   tb_fmc_lpc_row_g             : std_logic_vector(40 downto 1);
    signal   tb_fmc_lpc_row_h             : std_logic_vector(40 downto 1);
      

begin

    -- clock generators
    tb_user_clock       <= not tb_user_clock       after tb_user_clock_period       / 2 when simulation_run;
    tb_sysclk_n         <= not tb_sysclk_n         after tb_sysclk_period           / 2 when simulation_run;
    tb_sysclk_p         <= not tb_sysclk_p         after tb_sysclk_period           / 2 when simulation_run;
    tb_clk_33mhz_sysace <= not tb_clk_33mhz_sysace after tb_clk_33mhz_sysace_period / 2 when simulation_run;

    
    -- stimuli for buttons and switches
    tb_gpio_button <= "0000", "0001" after 500 us, "0000" after 700 us;
    tb_gpio_switch <= "0000", "0010" after 380 us, "0011" after 400 us, "1111" after 600 us;


    top_i0: top
        generic map (
            testgen_use_file_as_source  => true                      --: boolean
        )                                                        
        port map (
            simulation_break            => tb_simulation_break,      --: out   std_logic;
            cpu_reset                   => tb_cpu_reset,             --: in    std_logic; -- SW6 pushbutton (active-high)
            --
            -- DVI chip CH7301
            dvi_d                       => tb_dvi_d,                 --: out   std_logic_vector(11 downto 0);
            dvi_de                      => tb_dvi_de,                --: out   std_logic;
            dvi_v                       => tb_dvi_v,                 --: out   std_logic;
            dvi_h                       => tb_dvi_h,                 --: out   std_logic;
            dvi_gpio1                   => tb_dvi_gpio1,             --: out   std_logic;
            dvi_reset_b                 => tb_dvi_reset_b,           --: out   std_logic;
            dvi_xclk_n                  => tb_dvi_xclk_n,            --: out   std_logic;
            dvi_xclk_p                  => tb_dvi_xclk_p,            --: out   std_logic;
            iic_scl_dvi                 => tb_iic_scl_dvi,           --: out   std_logic; -- clock stretching?
            iic_sda_dvi                 => tb_iic_sda_dvi,           --: inout std_logic;
            --
            -- flash memory
            flash_a                     => tb_flash_a,               --: out   std_logic_vector(23 downto 0);
            flash_d                     => tb_flash_d,               --: inout std_logic_vector(15 downto 0);
            --
            fpga_d0_din_miso_miso1      => tb_fpga_d0_din_miso_miso1,--: inout std_logic; -- dual use
            fpga_d1_miso2               => tb_fpga_d1_miso2,         --: inout std_logic; -- dual use
            fpga_d2_miso3               => tb_fpga_d2_miso3,         --: inout std_logic; -- dual use
            flash_wait                  => tb_flash_wait,            --: in    std_logic;
            flash_we_b                  => tb_flash_we_b,            --: out   std_logic;
            flash_oe_b                  => tb_flash_oe_b,            --: out   std_logic;
            flash_ce_b                  => tb_flash_ce_b,            --: out   std_logic;
            flash_adv_b                 => tb_flash_adv_b,           --: in    std_logic;
            --
            -- FCM connector
            -- M2C   Mezzanine to Carrier
            -- C2M   Carrier to Mezzanine
            fmc_clk0_m2c_n              => tb_fmc_lpc_row_h(5),      --: inout std_logic;
            fmc_clk0_m2c_p              => tb_fmc_lpc_row_h(4),      --: inout std_logic;
            fmc_clk1_m2c_n              => tb_fmc_lpc_row_g(3),      --: inout std_logic;
            fmc_clk1_m2c_p              => tb_fmc_lpc_row_g(2),      --: inout std_logic;
            -- MGT
            --fmc_dp0_c2m_n             => tb_fmc_dp0_c2m_n,         --: std_logic;  -- new
            --fmc_dp0_c2m_p             => tb_fmc_dp0_c2m_p,         --: std_logic;  -- new, right direction
            --fmc_dp0_m2c_n             => tb_fmc_dp0_m2c_n,         --: std_logic;  -- new, right direction
            --fmc_dp0_m2c_p             => tb_fmc_dp0_m2c_p,         --: std_logic;  -- new, right direction
            --fmc_gbtclk0_m2c_n         => tb_fmc_gbtclk0_m2c_n,     --: std_logic;
            --fmc_gbtclk0_m2c_p         => tb_fmc_gbtclk0_m2c_p,     --: std_logic;
            iic_scl_main                => tb_fmc_lpc_row_c(30),     --: inout std_logic;
            iic_sda_main                => tb_fmc_lpc_row_c(31),     --: inout std_logic;
            fmc_la00_cc_n               => tb_fmc_lpc_row_g(7),      --: inout std_logic;
            fmc_la00_cc_p               => tb_fmc_lpc_row_g(6),      --: inout std_logic;
            fmc_la01_cc_n               => tb_fmc_lpc_row_d(9),      --: inout std_logic := 'Z';
            fmc_la01_cc_p               => tb_fmc_lpc_row_d(8),      --: inout std_logic := 'Z';
            fmc_la02_n                  => tb_fmc_lpc_row_h(8),      --: inout std_logic;
            fmc_la02_p                  => tb_fmc_lpc_row_h(7),      --: inout std_logic;
            fmc_la03_n                  => tb_fmc_lpc_row_g(10),     --: inout std_logic;
            fmc_la03_p                  => tb_fmc_lpc_row_g(9),      --: inout std_logic;
            fmc_la04_n                  => tb_fmc_lpc_row_h(11),     --: inout std_logic;
            fmc_la04_p                  => tb_fmc_lpc_row_h(10),     --: inout std_logic;
            fmc_la05_n                  => tb_fmc_lpc_row_d(12),     --: inout std_logic := 'Z';
            fmc_la05_p                  => tb_fmc_lpc_row_d(11),     --: inout std_logic := 'Z';
            fmc_la06_n                  => tb_fmc_lpc_row_c(11),     --: inout std_logic := 'Z';
            fmc_la06_p                  => tb_fmc_lpc_row_c(10),     --: inout std_logic := 'Z';
            fmc_la07_n                  => tb_fmc_lpc_row_h(14),     --: inout std_logic;
            fmc_la07_p                  => tb_fmc_lpc_row_h(13),     --: inout std_logic;
            fmc_la08_n                  => tb_fmc_lpc_row_g(13),     --: inout std_logic;
            fmc_la08_p                  => tb_fmc_lpc_row_g(12),     --: inout std_logic;
            fmc_la09_n                  => tb_fmc_lpc_row_d(15),     --: inout std_logic := 'Z';
            fmc_la09_p                  => tb_fmc_lpc_row_d(14),     --: inout std_logic := 'Z';
            fmc_la10_n                  => tb_fmc_lpc_row_c(15),     --: inout std_logic := 'Z';
            fmc_la10_p                  => tb_fmc_lpc_row_c(14),     --: inout std_logic := 'Z';
            fmc_la11_n                  => tb_fmc_lpc_row_h(17),     --: inout std_logic;
            fmc_la11_p                  => tb_fmc_lpc_row_h(16),     --: inout std_logic;
            fmc_la12_n                  => tb_fmc_lpc_row_g(16),     --: inout std_logic := 'Z';
            fmc_la12_p                  => tb_fmc_lpc_row_g(15),     --: inout std_logic;
            fmc_la13_n                  => tb_fmc_lpc_row_d(18),     --: inout std_logic := 'Z';
            fmc_la13_p                  => tb_fmc_lpc_row_d(17),     --: inout std_logic := 'Z';
            fmc_la14_n                  => tb_fmc_lpc_row_c(19),     --: inout std_logic := 'Z';
            fmc_la14_p                  => tb_fmc_lpc_row_c(18),     --: inout std_logic := 'Z';
            fmc_la15_n                  => tb_fmc_lpc_row_h(20),     --: inout std_logic;
            fmc_la15_p                  => tb_fmc_lpc_row_h(19),     --: inout std_logic;
            fmc_la16_n                  => tb_fmc_lpc_row_g(19),     --: inout std_logic := 'Z';
            fmc_la16_p                  => tb_fmc_lpc_row_g(18),     --: inout std_logic := 'Z';
            fmc_la17_cc_n               => tb_fmc_lpc_row_d(21),     --: inout std_logic := 'Z';
            fmc_la17_cc_p               => tb_fmc_lpc_row_d(20),     --: inout std_logic := 'Z';
            fmc_la18_cc_n               => tb_fmc_lpc_row_c(23),     --: inout std_logic := 'Z';
            fmc_la18_cc_p               => tb_fmc_lpc_row_c(22),     --: inout std_logic := 'Z';
            fmc_la19_n                  => tb_fmc_lpc_row_h(23),     --: inout std_logic;
            fmc_la19_p                  => tb_fmc_lpc_row_h(22),     --: inout std_logic;
            fmc_la20_n                  => tb_fmc_lpc_row_g(22),     --: inout std_logic := 'Z';
            fmc_la20_p                  => tb_fmc_lpc_row_g(21),     --: inout std_logic := 'Z';
            fmc_la21_n                  => tb_fmc_lpc_row_h(26),     --: inout std_logic;
            fmc_la21_p                  => tb_fmc_lpc_row_h(25),     --: inout std_logic;
            fmc_la22_n                  => tb_fmc_lpc_row_g(25),     --: inout std_logic := 'Z';
            fmc_la22_p                  => tb_fmc_lpc_row_g(24),     --: inout std_logic := 'Z';
            fmc_la23_n                  => tb_fmc_lpc_row_d(24),     --: inout std_logic := 'Z';
            fmc_la23_p                  => tb_fmc_lpc_row_d(23),     --: inout std_logic := 'Z';
            fmc_la24_n                  => tb_fmc_lpc_row_h(29),     --: inout std_logic;
            fmc_la24_p                  => tb_fmc_lpc_row_h(28),     --: inout std_logic;
            fmc_la25_n                  => tb_fmc_lpc_row_g(28),     --: inout std_logic := 'Z';
            fmc_la25_p                  => tb_fmc_lpc_row_g(27),     --: inout std_logic := 'Z';
            fmc_la26_n                  => tb_fmc_lpc_row_d(27),     --: inout std_logic := 'Z';
            fmc_la26_p                  => tb_fmc_lpc_row_d(26),     --: inout std_logic := 'Z';
            fmc_la27_n                  => tb_fmc_lpc_row_c(27),     --: inout std_logic := 'Z';
            fmc_la27_p                  => tb_fmc_lpc_row_c(26),     --: inout std_logic := 'Z';
            fmc_la28_n                  => tb_fmc_lpc_row_h(32),     --: inout std_logic;
            fmc_la28_p                  => tb_fmc_lpc_row_h(31),     --: inout std_logic;
            fmc_la29_n                  => tb_fmc_lpc_row_g(31),     --: inout std_logic := 'Z';
            fmc_la29_p                  => tb_fmc_lpc_row_g(30),     --: inout std_logic := 'Z';
            fmc_la30_n                  => tb_fmc_lpc_row_h(35),     --: inout std_logic;
            fmc_la30_p                  => tb_fmc_lpc_row_h(34),     --: inout std_logic := 'Z';
            fmc_la31_n                  => tb_fmc_lpc_row_g(34),     --: inout std_logic := 'Z';
            fmc_la31_p                  => tb_fmc_lpc_row_g(33),     --: inout std_logic := 'Z';
            fmc_la32_n                  => tb_fmc_lpc_row_h(38),     --: inout std_logic;
            fmc_la32_p                  => tb_fmc_lpc_row_h(37),     --: inout std_logic;
            fmc_la33_n                  => tb_fmc_lpc_row_g(37),     --: inout std_logic := 'Z';
            fmc_la33_p                  => tb_fmc_lpc_row_g(36),     --: inout std_logic := 'Z';
            fmc_prsnt_m2c_l             => tb_fmc_prsnt_m2c_l,       --: inout std_logic;
            FMC_PWR_GOOD_FLASH_RST_B    => tb_FMC_PWR_GOOD_FLASH_RST_B, --: out std_logic; -- multiple destinations: 1 of Q2 (LED DS1 driver), U1 AB2 FPGA_PROG (through series R260 DNP), 44 of U25
            --
            -- ???
            FPGA_AWAKE                  => tb_FPGA_AWAKE,            --: out   std_logic;
            fpga_cclk                   => tb_fpga_cclk,             --: out   std_logic;
            FPGA_CMP_CLK                => tb_FPGA_CMP_CLK,          --: in    std_logic;
            FPGA_CMP_CS_B               => tb_FPGA_CMP_CS_B,         --: in    std_logic;
            FPGA_CMP_MOSI               => tb_FPGA_CMP_MOSI,         --: in    std_logic;
            --
            FPGA_HSWAPEN                => tb_FPGA_HSWAPEN,          --: in    std_logic;
            FPGA_INIT_B                 => tb_FPGA_INIT_B,           --: out   std_logic;
            FPGA_M0_CMP_MISO            => tb_FPGA_M0_CMP_MISO,      --: in    std_logic;
            FPGA_M1                     => tb_FPGA_M1,               --: in    std_logic;
            fpga_mosi_csi_b_miso0       => tb_fpga_mosi_csi_b_miso0, --: inout std_logic;
            FPGA_ONCHIP_TERM1           => tb_FPGA_ONCHIP_TERM1,     --: inout std_logic;
            FPGA_ONCHIP_TERM2           => tb_FPGA_ONCHIP_TERM2,     --: inout std_logic;
            FPGA_PROG_B                 => tb_FPGA_PROG_B,           --: in    std_logic;
            FPGA_SUSPEND                => tb_FPGA_SUSPEND,          --: in    std_logic;
            FPGA_TCK                    => tb_FPGA_TCK,              --: in    std_logic;
            FPGA_TDI                    => tb_FPGA_TDI,              --: in    std_logic;
            FPGA_TMS                    => tb_FPGA_TMS,              --: in    std_logic;
            FPGA_VBATT                  => tb_FPGA_VBATT,            --: in    std_logic;
            FPGA_VTEMP                  => tb_FPGA_VTEMP,            --: in    std_logic;
            --
            -- GPIOs
            gpio_button                 => tb_gpio_button,           --: in    std_logic_vector(3 downto 0); -- active high
            gpio_header_ls              => tb_gpio_header_ls,        --: inout std_logic_vector(3 downto 0);
            gpio_led                    => tb_gpio_led,              --: out   std_logic_vector(3 downto 0);
            gpio_switch                 => tb_gpio_switch,           --: in    std_logic_vector(3 downto 0); -- active high
            --
            -- DDR3 memory
            mem1_a                      => tb_mem1_a,                --: out   std_logic_vector(14 downto 0);
            mem1_ba                     => tb_mem1_ba,               --: out   std_logic_vector(2 downto 0);
            mem1_cas_b                  => tb_mem1_cas_b,            --: out   std_logic;
            mem1_ras_b                  => tb_mem1_ras_b,            --: out   std_logic;
            mem1_we_b                   => tb_mem1_we_b,             --: out   std_logic;
            mem1_cke                    => tb_mem1_cke,              --: out   std_logic;
            mem1_clk_n                  => tb_mem1_clk_n,            --: out   std_logic; 
            mem1_clk_p                  => tb_mem1_clk_p,            --: out   std_logic; 
            mem1_dq                     => tb_mem1_dq,               --: inout std_logic_vector(15 downto 0);
            mem1_ldm                    => tb_mem1_ldm,              --: out   std_logic;
            mem1_udm                    => tb_mem1_udm,              --: out   std_logic;
            mem1_ldqs_n                 => tb_mem1_ldqs_n,           --: inout std_logic;
            mem1_ldqs_p                 => tb_mem1_ldqs_p,           --: inout std_logic;
            mem1_udqs_n                 => tb_mem1_udqs_n,           --: inout std_logic;
            mem1_udqs_p                 => tb_mem1_udqs_p,           --: inout std_logic;
            mem1_odt                    => tb_mem1_odt,              --: out   std_logic;
            mem1_reset_b                => tb_mem1_reset_b,          --: out   std_logic; -- reset_n ?
            --
            -- PCIe
            PCIE_250M_N                 => tb_PCIE_250M_N,           --: in    std_logic; -- ??
            PCIE_250M_P                 => tb_PCIE_250M_P,           --: in    std_logic; -- ??
            PCIE_PERST_B_LS             => tb_PCIE_PERST_B_LS,       --: in    std_logic; -- ??
            PCIE_RX0_N                  => tb_PCIE_RX0_N,            --: in    std_logic; -- ??
            PCIE_RX0_P                  => tb_PCIE_RX0_P,            --: in    std_logic; -- ??
            PCIE_TX0_N                  => tb_PCIE_TX0_N,            --: out   std_logic; -- ??
            PCIE_TX0_P                  => tb_PCIE_TX0_P,            --: out   std_logic; -- ??
            --
            -- Ethernet Gigabit PHY
            PHY_COL                     => tb_PHY_COL,               --: in    std_logic;
            PHY_CRS                     => tb_PHY_CRS,               --: in    std_logic;
            PHY_INT                     => tb_PHY_INT,               --: out   std_logic;
            PHY_MDC                     => tb_PHY_MDC,               --: out   std_logic;
            PHY_MDIO                    => tb_PHY_MDIO,              --: inout std_logic;
            PHY_RESET                   => tb_PHY_RESET,             --: out   std_logic;
            PHY_RXCLK                   => tb_PHY_RXCLK,             --: in    std_logic;
            PHY_RXCTL_RXDV              => tb_PHY_RXCTL_RXDV,        --: in    std_logic;
            PHY_RXD                     => tb_PHY_RXD,               --: in    std_logic_vector(7 downto 0);
            PHY_RXER                    => tb_PHY_RXER,              --: in    std_logic;
            PHY_TXCLK                   => tb_PHY_TXCLK,             --: in    std_logic;
            PHY_TXCTL_TXEN              => tb_PHY_TXCTL_TXEN,        --: out   std_logic;
            PHY_TXC_GTXCLK              => tb_PHY_TXC_GTXCLK,        --: out   std_logic;
            PHY_TXD                     => tb_PHY_TXD,               --: out   std_logic_vector(7 downto 0);
            PHY_TXER                    => tb_PHY_TXER,              --: out    std_logic;
            --
            -- pmbus
            PMBUS_ALERT                 => tb_PMBUS_ALERT,           --: in    std_logic;
            PMBUS_CLK                   => tb_PMBUS_CLK,             --: in    std_logic;
            PMBUS_CTRL                  => tb_PMBUS_CTRL,            --: in    std_logic;
            PMBUS_DATA                  => tb_PMBUS_DATA,            --: in    std_logic;
            --                                                 
            -- SFP                                             
            sfpclk_qo_n                 => tb_sfpclk_qo_n,           --: in    std_logic;
            sfpclk_qo_p                 => tb_sfpclk_qo_p,           --: in    std_logic;
            iic_scl_sfp                 => tb_iic_scl_sfp,           --: inout std_logic;
            iic_sda_sfp                 => tb_iic_sda_sfp,           --: inout std_logic;
            sfp_los                     => tb_sfp_los,               --: in    std_logic;
            sfp_rx_n                    => tb_sfp_rx_n,              --: in    std_logic;
            sfp_rx_p                    => tb_sfp_rx_p,              --: in    std_logic;
            sfp_tx_disable_fpga         => tb_sfp_tx_disable_fpga,   --: in    std_logic;
            sfp_tx_n                    => tb_sfp_tx_n,              --: out   std_logic;
            sfp_tx_p                    => tb_sfp_tx_p,              --: out   std_logic;
            --                                                 
            -- SMA                                             
            SMA_REFCLK_N                => tb_SMA_REFCLK_N,          --: in    std_logic;
            SMA_REFCLK_P                => tb_SMA_REFCLK_P,          --: in    std_logic;
            SMA_RX_N                    => tb_SMA_RX_N,              --: in    std_logic;
            SMA_RX_P                    => tb_SMA_RX_P,              --: in    std_logic;
            SMA_TX_N                    => tb_SMA_TX_N,              --: out   std_logic;
            SMA_TX_P                    => tb_SMA_TX_P,              --: out   std_logic;
            --
            --
            spi_cs_b                    => tb_spi_cs_b,              --: out   std_logic;
            --
            -- SysACE
            clk_33mhz_sysace            => tb_clk_33mhz_sysace,      --: in    std_logic;
            SYSACE_CFGTDI               => tb_SYSACE_CFGTDI,         --: in    std_logic;
            SYSACE_D_LS                 => tb_SYSACE_D_LS,           --: inout std_logic_vector(7 downto 0);
            SYSACE_MPA_LS               => tb_SYSACE_MPA_LS,         --: out   std_logic_vector(6 downto 0);
            SYSACE_MPBRDY_LS            => tb_SYSACE_MPBRDY_LS,      --: in    std_logic;
            SYSACE_MPCE_LS              => tb_SYSACE_MPCE_LS,        --: out   std_logic;
            SYSACE_MPIRQ_LS             => tb_SYSACE_MPIRQ_LS,       --: in    std_logic;
            SYSACE_MPOE_LS              => tb_SYSACE_MPOE_LS,        --: out   std_logic;
            SYSACE_MPWE_LS              => tb_SYSACE_MPWE_LS,        --: out   std_logic;
            --
            -- 200 MHz oscillator
            SYSCLK_N                    => tb_sysclk_n,              --: in    std_logic;
            SYSCLK_P                    => tb_sysclk_p,              --: in    std_logic;
            --
            -- RS232 via USB
            usb_1_cts                   => tb_usb_1_cts,             --: out   std_logic;
            usb_1_rts                   => tb_usb_1_rts,             --: in    std_logic;
            usb_1_rx                    => tb_usb_1_rx,              --: out   std_logic;
            usb_1_tx                    => tb_usb_1_tx,              --: in    std_logic;
            --
            --  27 MHz, oscillator socket
            user_clock                  => tb_user_clock,            --: in    std_logic;
            user_sma_clock_p            => tb_user_sma_clock_p,      --: in    std_logic;
            user_sma_clock_n            => tb_user_sma_clock_n,      --: in    std_logic;
            --
            user_sma_gpio_p             => tb_user_sma_gpio_p,       --: inout std_logic;
            user_sma_gpio_n             => tb_user_sma_gpio_n        --: inout std_logic
        );

    
    -- dvi i2c signals (pull ups)
    tb_iic_scl_dvi       <= 'H';
    tb_iic_sda_dvi       <= 'H';


    -- ethernet phy signals 
    tb_phy_mdio          <= 'H';              -- pullup
    tb_phy_txclk         <= 'H';              -- : out std_logic;
    tb_phy_rxclk         <= 'H';              -- : out std_logic; 
    tb_phy_rxd           <= (others => 'H');  -- : out std_logic_vector(7 downto 0);   
    tb_phy_rxctl_rxdv    <= 'H';              -- : out std_logic; 
    tb_phy_rxer          <= 'H';              -- : out std_logic; 
    tb_phy_col           <= 'H';              -- : out std_logic;
    tb_phy_crs           <= 'H';              -- : out std_logic;


    -- predefined connections on fmc connector
    -- X - power, 0 - gnd, U - unknown signal
    -- row c
    tb_fmc_lpc_row_c(1)  <= gnd;
    tb_fmc_lpc_row_c(2)  <= 'U';
    tb_fmc_lpc_row_c(3)  <= 'U';
    tb_fmc_lpc_row_c(4)  <= gnd;
    tb_fmc_lpc_row_c(5)  <= gnd;
    tb_fmc_lpc_row_c(6)  <= 'U';
    tb_fmc_lpc_row_c(7)  <= 'U';
    tb_fmc_lpc_row_c(8)  <= gnd;
    tb_fmc_lpc_row_c(9)  <= gnd;
    tb_fmc_lpc_row_c(12) <= gnd;
    tb_fmc_lpc_row_c(13) <= gnd;
    tb_fmc_lpc_row_c(16) <= gnd;
    tb_fmc_lpc_row_c(17) <= gnd;
    tb_fmc_lpc_row_c(20) <= gnd;
    tb_fmc_lpc_row_c(21) <= gnd;
    tb_fmc_lpc_row_c(24) <= gnd;
    tb_fmc_lpc_row_c(25) <= gnd;
    tb_fmc_lpc_row_c(28) <= gnd;
    tb_fmc_lpc_row_c(29) <= gnd;
    tb_fmc_lpc_row_c(30) <= tb_iic_scl_main;
    tb_fmc_lpc_row_c(31) <= tb_iic_sda_main;
    tb_fmc_lpc_row_c(32) <= gnd;
    tb_fmc_lpc_row_c(33) <= gnd;
    tb_fmc_lpc_row_c(34) <= 'U';
    tb_fmc_lpc_row_c(35) <= 'X';
    tb_fmc_lpc_row_c(36) <= gnd;
    tb_fmc_lpc_row_c(37) <= 'X';
    tb_fmc_lpc_row_c(38) <= gnd;
    tb_fmc_lpc_row_c(39) <= 'X';
    tb_fmc_lpc_row_c(40) <= gnd;
    -- row d
    tb_fmc_lpc_row_d(2)  <= gnd;
    tb_fmc_lpc_row_d(3)  <= gnd;
    tb_fmc_lpc_row_d(4)  <= 'U';
    tb_fmc_lpc_row_d(5)  <= 'U';
    tb_fmc_lpc_row_d(6)  <= gnd;
    tb_fmc_lpc_row_d(7)  <= gnd;
    tb_fmc_lpc_row_d(10) <= gnd;
    tb_fmc_lpc_row_d(13) <= gnd;
    tb_fmc_lpc_row_d(16) <= gnd;
    tb_fmc_lpc_row_d(19) <= gnd;
    tb_fmc_lpc_row_d(22) <= gnd;
    tb_fmc_lpc_row_d(25) <= gnd;
    tb_fmc_lpc_row_d(28) <= gnd;
    tb_fmc_lpc_row_d(29) <= 'U';
    tb_fmc_lpc_row_d(30) <= 'U';
    tb_fmc_lpc_row_d(31) <= 'U';
    tb_fmc_lpc_row_d(32) <= 'X';
    tb_fmc_lpc_row_d(33) <= 'U';
    tb_fmc_lpc_row_d(34) <= 'U';
    tb_fmc_lpc_row_d(35) <= 'U';
    tb_fmc_lpc_row_d(36) <= 'X';
    tb_fmc_lpc_row_d(37) <= gnd;
    tb_fmc_lpc_row_d(38) <= 'X';
    tb_fmc_lpc_row_d(39) <= gnd;
    tb_fmc_lpc_row_d(40) <= 'X';
    -- row g
    tb_fmc_lpc_row_g(1)  <= gnd;
    tb_fmc_lpc_row_g(4)  <= gnd;
    tb_fmc_lpc_row_g(5)  <= gnd;
    tb_fmc_lpc_row_g(8)  <= gnd;
    tb_fmc_lpc_row_g(11) <= gnd;
    tb_fmc_lpc_row_g(14) <= gnd;
    tb_fmc_lpc_row_g(17) <= gnd;
    tb_fmc_lpc_row_g(20) <= gnd;
    tb_fmc_lpc_row_g(23) <= gnd;
    tb_fmc_lpc_row_g(26) <= gnd;
    tb_fmc_lpc_row_g(29) <= gnd;
    tb_fmc_lpc_row_g(32) <= gnd;
    tb_fmc_lpc_row_g(35) <= gnd;
    tb_fmc_lpc_row_g(38) <= gnd;
    tb_fmc_lpc_row_g(39) <= 'X';
    tb_fmc_lpc_row_g(40) <= gnd;
    -- row h
    tb_fmc_lpc_row_h(1)  <= 'X';
    tb_fmc_lpc_row_h(3)  <= gnd;
    tb_fmc_lpc_row_h(6)  <= gnd;
    tb_fmc_lpc_row_h(9)  <= gnd;
    tb_fmc_lpc_row_h(12) <= gnd;
    tb_fmc_lpc_row_h(15) <= gnd;
    tb_fmc_lpc_row_h(18) <= gnd;
    tb_fmc_lpc_row_h(21) <= gnd;
    tb_fmc_lpc_row_h(24) <= gnd;
    tb_fmc_lpc_row_h(27) <= gnd;
    tb_fmc_lpc_row_h(30) <= gnd;
    tb_fmc_lpc_row_h(33) <= gnd;
    tb_fmc_lpc_row_h(36) <= gnd;
    tb_fmc_lpc_row_h(39) <= gnd;
    tb_fmc_lpc_row_h(40) <= 'X';


    bpm_adc_dac_testboard_i0: entity work.bpm_adc_dac_testboard
    generic map (
        adc_stimuli_file_name => "data/adc_amplitude_ch0.txt",
        adc_output_randomizer => true
    )
    port map (
        simulation_run        => simulation_run,
        fmc_lpc_row_c         => tb_fmc_lpc_row_c,  --: inout std_logic_vector(40 downto 1);
        fmc_lpc_row_d         => tb_fmc_lpc_row_d,  --: inout std_logic_vector(40 downto 1);
        fmc_lpc_row_g         => tb_fmc_lpc_row_g,  --: inout std_logic_vector(40 downto 1);
        fmc_lpc_row_h         => tb_fmc_lpc_row_h   --: inout std_logic_vector(40 downto 1)
    );
    
    
    main: process
    begin

        wait until rising_edge( tb_simulation_break);
        simulation_run <= false;
        report "Simlation ended." severity note;
        wait;

    end process;



    -- simulation debug output
    file_save_linfilter_p: process
      file     f      : text;
      variable status : file_open_status;
      variable l      : line;
      variable count  : natural;
    begin
      file_open(status, f, linfilter_filename_c, write_mode);
      count := 0;
      if status = open_ok then
          report me_c & "logging linfilter output to " & linfilter_filename_c
             severity note;
          while (count < linfilter_samples_c) loop
              wait until rising_edge( debug_sample_clk);
              write(l, to_integer( debug.linfilter_i0_data_out));
              writeline(f, l);
              count := count + 1;
          end loop;
          file_close(f);
          report me_c & "logging linfilter done after " & integer'image(linfilter_samples_c) & " samples"
             severity note;
      else
          report me_c & "could not write linfilter debugging output!"
              severity warning;
      end if;
      wait;
    end process file_save_linfilter_p;
 
    
    -- simulation debug output
    file_save_quadsum_p: process
      file     f      : text;
      variable status : file_open_status;
      variable count  : natural;
      variable l      : line;
      variable l_rev  : line;
      variable v      : unsigned( debug.quadsum_i0_data_out.value'range);
    begin
      file_open(status, f, quadsum_filename_c, write_mode);
      count := 0;
      if status = open_ok then
          report me_c & "log quadsum output to:" & quadsum_filename_c 
             severity note;
          while (count < quadsum_samples_c) loop
              wait until rising_edge( debug_sample_clk);
              if debug.quadsum_i0_data_out.enable = '1' then
                  -- work only up to 32 bit:
                  --write(l, to_integer( quadsum_i0_data_out.value));
                  -- do it the oldscool way:
                  v := debug.quadsum_i0_data_out.value;
                  deallocate(l_rev);
                  if (v > 0) then
                      while (v > 0) loop
                        write(l_rev, to_integer( v mod 10));
                        v := v / 10;
                      end loop;
                  else
                      write(l_rev, 0);
                  end if;
                  -- reverse the string
                  for i in l_rev.all'range loop
                      write(l, l_rev(l_rev'length + 1 - i));
                  end loop;
                  writeline(f, l);
                  count := count + 1;
              end if; -- data enable
          end loop;
          file_close(f);
          report me_c & "logging quadsum done after " & integer'image(quadsum_samples_c) & " samples"
             severity note;
      else
          report me_c & "could not write quadsum debugging output!"
              severity warning;
      end if;
      wait;
    end process file_save_quadsum_p;


end architecture testbench;
