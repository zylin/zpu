-- top testbench
--
-- contains:
--
--  +--------------+     
--  |  board_sp601 |     
--  |              |XFMCX
--  |              |XLPCX
--  |  FPGA        |     
--  +--------------+     
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
--  |                                                                         |
--  +-------------------------------------------------------------------------+

--------------------------------------------------------------------------------
-- $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/hardware/board_sp601_amba/rtl_tb/top_tb.vhd $
-- $Date$
-- $Author$
-- $Revision$
--------------------------------------------------------------------------------

entity top_tb is
end entity top_tb;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;



architecture testbench of top_tb is
    

    constant me_c                         : string  := testbench'path_name;

    constant gnd                          : std_logic := '0';

    signal   simulation_run               : boolean := true;
    signal   tb_simulation_break          : std_logic;


    signal   tb_cpu_reset                 : std_logic; -- SW6 pushbutton (active-high)
    --
    -- DDR2 memory
    signal   tb_ddr2_a                    : std_logic_vector(12 downto 0);
    signal   tb_ddr2_ba                   : std_logic_vector(2 downto 0);
    signal   tb_ddr2_cas_b                : std_logic;
    signal   tb_ddr2_ras_b                : std_logic;
    signal   tb_ddr2_we_b                 : std_logic;
    signal   tb_ddr2_cke                  : std_logic;
    signal   tb_ddr2_clk_n                : std_logic; 
    signal   tb_ddr2_clk_p                : std_logic; 
    signal   tb_ddr2_dq                   : std_logic_vector(15 downto 0);
    signal   tb_ddr2_ldm                  : std_logic;
    signal   tb_ddr2_udm                  : std_logic;
    signal   tb_ddr2_ldqs_n               : std_logic;
    signal   tb_ddr2_ldqs_p               : std_logic;
    signal   tb_ddr2_udqs_n               : std_logic;
    signal   tb_ddr2_udqs_p               : std_logic;
    signal   tb_ddr2_odt                  : std_logic;
    --                                
    -- flash memory                        
    signal   tb_flash_a                   : std_logic_vector(24 downto 0);
    signal   tb_flash_d                   : std_logic_vector( 7 downto 0);
    --
    signal   tb_fpga_d0_din_miso_miso1    : std_logic; -- dual use
    signal   tb_fpga_d1_miso2             : std_logic; -- dual use    
    signal   tb_fpga_d2_miso3             : std_logic; -- dual use    
    signal   tb_flash_we_b                : std_logic;
    signal   tb_flash_oe_b                : std_logic;
    signal   tb_flash_ce_b                : std_logic;
    --
    -- FCM connector
    -- M2C   Mezzanine to Carrier
    -- C2M   Carrier to Mezzanine
    signal   tb_iic_scl_main              : std_logic;
    signal   tb_iic_sda_main              : std_logic;
    signal   tb_fmc_prsnt_m2c_l           : std_logic;
    signal   tb_FMC_PWR_GOOD_FLASH_RST_B  : std_logic; -- multiple destinations: 1 of Q2 (LED DS1 driver), U1 AB2 FPGA_PROG (through series R260 DNP), 44 of U25
    --       
    -- ???  
    signal   tb_FPGA_AWAKE                : std_logic;
    signal   tb_FPGA_CCLK                 : std_logic;
    signal   tb_FPGA_CMP_CLK              : std_logic;
    signal   tb_FPGA_CMP_CS_B             : std_logic;
    signal   tb_FPGA_CMP_MOSI             : std_logic;
    --       
    signal   tb_FPGA_HSWAPEN              : std_logic;
    signal   tb_FPGA_INIT_B               : std_logic;
    signal   tb_FPGA_M0_CMP_MISO          : std_logic;
    signal   tb_FPGA_M1                   : std_logic;
    signal   tb_FPGA_MOSI_CSI_B_MISO0     : std_logic;
    signal   tb_FPGA_ONCHIP_TERM1         : std_logic;
    signal   tb_FPGA_ONCHIP_TERM2         : std_logic;
    signal   tb_FPGA_VTEMP                : std_logic;
    --
    -- GPIOs
    signal   tb_gpio_button               : std_logic_vector(3 downto 0); -- active high
    signal   tb_gpio_header_ls            : std_logic_vector(7 downto 0);
    signal   tb_gpio_led                  : std_logic_vector(3 downto 0);
    signal   tb_gpio_switch               : std_logic_vector(3 downto 0); -- active high
    --
    -- Ethernet Gigabit PHY
    signal   tb_phy_col                   : std_logic;
    signal   tb_phy_crs                   : std_logic;
    signal   tb_phy_int                   : std_logic;
    signal   tb_phy_mdc                   : std_logic;
    signal   tb_phy_mdio                  : std_logic;
    signal   tb_phy_reset_b               : std_logic;
    signal   tb_phy_rxclk                 : std_logic;
    signal   tb_phy_rxctl_rxdv            : std_logic;
    signal   tb_phy_rxd                   : std_logic_vector(7 downto 0);
    signal   tb_phy_rxer                  : std_logic;
    signal   tb_phy_txclk                 : std_logic;
    signal   tb_phy_txctl_txen            : std_logic;
    signal   tb_phy_txc_gtxclk            : std_logic;
    signal   tb_phy_txd                   : std_logic_vector(7 downto 0);
    signal   tb_phy_txer                  : std_logic;
    --
    --
    signal   tb_SPI_CS_B                  : std_logic;
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
    --
    --
    signal   tb_fmc_lpc_row_c             : std_logic_vector(40 downto 1);
    signal   tb_fmc_lpc_row_d             : std_logic_vector(40 downto 1);
    signal   tb_fmc_lpc_row_g             : std_logic_vector(40 downto 1);
    signal   tb_fmc_lpc_row_h             : std_logic_vector(40 downto 1);
      

begin

    -- clock generators
    tb_user_clock       <= not tb_user_clock       after tb_user_clock_period / 2       when simulation_run;
    tb_sysclk_n         <= not tb_sysclk_n         after tb_sysclk_period     / 2       when simulation_run;
    tb_sysclk_p         <= not tb_sysclk_p         after tb_sysclk_period     / 2       when simulation_run;

    
    -- stimuli for buttons and switches
    tb_gpio_button <= "0000", "0001" after 500 us, "0000" after 700 us;
    tb_gpio_switch <= "0000", "0010" after 380 us, "0011" after 400 us, "1111" after 600 us;


    top_i0: entity work.top
        port map (
            simulation_break          => tb_simulation_break,            --: out   std_logic;
            cpu_reset                 => tb_cpu_reset,                   --: in    std_logic; -- SW6 pushbutton (active-high)
            --
            -- DDR2 memory
            ddr2_a                    => tb_ddr2_a,                      --: out   std_logic_vector(12 downto 0);
            ddr2_ba                   => tb_ddr2_ba,                     --: out   std_logic_vector(2 downto 0);
            ddr2_cas_b                => tb_ddr2_cas_b,                  --: out   std_logic;
            ddr2_ras_b                => tb_ddr2_ras_b,                  --: out   std_logic;
            ddr2_we_b                 => tb_ddr2_we_b,                   --: out   std_logic;
            ddr2_cke                  => tb_ddr2_cke,                    --: out   std_logic;
            ddr2_clk_n                => tb_ddr2_clk_n,                  --: out   std_logic; 
            ddr2_clk_p                => tb_ddr2_clk_p,                  --: out   std_logic; 
            ddr2_dq                   => tb_ddr2_dq,                     --: inout std_logic_vector(15 downto 0);
            ddr2_ldm                  => tb_ddr2_ldm,                    --: out   std_logic;
            ddr2_udm                  => tb_ddr2_udm,                    --: out   std_logic;
            ddr2_ldqs_n               => tb_ddr2_ldqs_n,                 --: inout std_logic;
            ddr2_ldqs_p               => tb_ddr2_ldqs_p,                 --: inout std_logic;
            ddr2_udqs_n               => tb_ddr2_udqs_n,                 --: inout std_logic;
            ddr2_udqs_p               => tb_ddr2_udqs_p,                 --: inout std_logic;
            ddr2_odt                  => tb_ddr2_odt,                    --: out   std_logic;
            --
            -- flash memory
            flash_a                   => tb_flash_a,                     --: out   std_logic_vector(24 downto 0);
            flash_d                   => tb_flash_d(7 downto 3),         --: inout std_logic_vector( 7 downto 3);
            --
            fpga_d0_din_miso_miso1    => tb_fpga_d0_din_miso_miso1,      --: inout std_logic; -- dual use
            fpga_d1_miso2             => tb_fpga_d1_miso2,               --: inout std_logic; -- dual use
            fpga_d2_miso3             => tb_fpga_d2_miso3,               --: inout std_logic; -- dual use
            flash_we_b                => tb_flash_we_b,                  --: out   std_logic;
            flash_oe_b                => tb_flash_oe_b,                  --: out   std_logic;
            flash_ce_b                => tb_flash_ce_b,                  --: out   std_logic;
            --
            -- FCM connector
            -- M2C   Mezzanine to Carrier
            -- C2M   Carrier to Mezzanine
            fmc_clk0_m2c_n            => tb_fmc_lpc_row_h(5),            --: std_logic;
            fmc_clk0_m2c_p            => tb_fmc_lpc_row_h(4),            --: std_logic;
            fmc_clk1_m2c_n            => tb_fmc_lpc_row_g(3),            --: std_logic;
            fmc_clk1_m2c_p            => tb_fmc_lpc_row_g(2),            --: std_logic;
            iic_scl_main              => tb_fmc_lpc_row_c(30),           --: inout std_logic;
            iic_sda_main              => tb_fmc_lpc_row_c(31),           --: inout std_logic;
            fmc_la00_cc_n             => tb_fmc_lpc_row_g(7),            --: std_logic;
            fmc_la00_cc_p             => tb_fmc_lpc_row_g(6),            --: std_logic;
            fmc_la01_cc_n             => tb_fmc_lpc_row_d(9),            --: std_logic := 'Z';
            fmc_la01_cc_p             => tb_fmc_lpc_row_d(8),            --: std_logic := 'Z';
            fmc_la02_n                => tb_fmc_lpc_row_h(8),            --: std_logic;
            fmc_la02_p                => tb_fmc_lpc_row_h(7),            --: std_logic;
            fmc_la03_n                => tb_fmc_lpc_row_g(10),           --: std_logic;
            fmc_la03_p                => tb_fmc_lpc_row_g(9),            --: std_logic;
            fmc_la04_n                => tb_fmc_lpc_row_h(11),           --: std_logic;
            fmc_la04_p                => tb_fmc_lpc_row_h(10),           --: std_logic;
            fmc_la05_n                => tb_fmc_lpc_row_d(12),           --: std_logic := 'Z';
            fmc_la05_p                => tb_fmc_lpc_row_d(11),           --: std_logic := 'Z';
            fmc_la06_n                => tb_fmc_lpc_row_c(11),           --: std_logic := 'Z';
            fmc_la06_p                => tb_fmc_lpc_row_c(10),           --: std_logic := 'Z';
            fmc_la07_n                => tb_fmc_lpc_row_h(14),           --: std_logic;
            fmc_la07_p                => tb_fmc_lpc_row_h(13),           --: std_logic;
            fmc_la08_n                => tb_fmc_lpc_row_g(13),           --: std_logic;
            fmc_la08_p                => tb_fmc_lpc_row_g(12),           --: std_logic;
            fmc_la09_n                => tb_fmc_lpc_row_d(15),           --: std_logic := 'Z';
            fmc_la09_p                => tb_fmc_lpc_row_d(14),           --: std_logic := 'Z';
            fmc_la10_n                => tb_fmc_lpc_row_c(15),           --: std_logic := 'Z';
            fmc_la10_p                => tb_fmc_lpc_row_c(14),           --: std_logic := 'Z';
            fmc_la11_n                => tb_fmc_lpc_row_h(17),           --: std_logic;
            fmc_la11_p                => tb_fmc_lpc_row_h(16),           --: std_logic;
            fmc_la12_n                => tb_fmc_lpc_row_g(16),           --: std_logic := 'Z';
            fmc_la12_p                => tb_fmc_lpc_row_g(15),           --: std_logic;
            fmc_la13_n                => tb_fmc_lpc_row_d(18),           --: std_logic := 'Z';
            fmc_la13_p                => tb_fmc_lpc_row_d(17),           --: std_logic := 'Z';
            fmc_la14_n                => tb_fmc_lpc_row_c(19),           --: std_logic := 'Z';
            fmc_la14_p                => tb_fmc_lpc_row_c(18),           --: std_logic := 'Z';
            fmc_la15_n                => tb_fmc_lpc_row_h(20),           --: std_logic;
            fmc_la15_p                => tb_fmc_lpc_row_h(19),           --: std_logic;
            fmc_la16_n                => tb_fmc_lpc_row_g(19),           --: std_logic := 'Z';
            fmc_la16_p                => tb_fmc_lpc_row_g(18),           --: std_logic := 'Z';
            fmc_la17_cc_n             => tb_fmc_lpc_row_d(21),           --: std_logic := 'Z';
            fmc_la17_cc_p             => tb_fmc_lpc_row_d(20),           --: std_logic := 'Z';
            fmc_la18_cc_n             => tb_fmc_lpc_row_c(23),           --: std_logic := 'Z';
            fmc_la18_cc_p             => tb_fmc_lpc_row_c(22),           --: std_logic := 'Z';
            fmc_la19_n                => tb_fmc_lpc_row_h(23),           --: std_logic;
            fmc_la19_p                => tb_fmc_lpc_row_h(22),           --: std_logic;
            fmc_la20_n                => tb_fmc_lpc_row_g(22),           --: std_logic := 'Z';
            fmc_la20_p                => tb_fmc_lpc_row_g(21),           --: std_logic := 'Z';
            fmc_la21_n                => tb_fmc_lpc_row_h(26),           --: std_logic;
            fmc_la21_p                => tb_fmc_lpc_row_h(25),           --: std_logic;
            fmc_la22_n                => tb_fmc_lpc_row_g(25),           --: std_logic := 'Z';
            fmc_la22_p                => tb_fmc_lpc_row_g(24),           --: std_logic := 'Z';
            fmc_la23_n                => tb_fmc_lpc_row_d(24),           --: std_logic := 'Z';
            fmc_la23_p                => tb_fmc_lpc_row_d(23),           --: std_logic := 'Z';
            fmc_la24_n                => tb_fmc_lpc_row_h(29),           --: std_logic;
            fmc_la24_p                => tb_fmc_lpc_row_h(28),           --: std_logic;
            fmc_la25_n                => tb_fmc_lpc_row_g(28),           --: std_logic := 'Z';
            fmc_la25_p                => tb_fmc_lpc_row_g(27),           --: std_logic := 'Z';
            fmc_la26_n                => tb_fmc_lpc_row_d(27),           --: std_logic := 'Z';
            fmc_la26_p                => tb_fmc_lpc_row_d(26),           --: std_logic := 'Z';
            fmc_la27_n                => tb_fmc_lpc_row_c(27),           --: std_logic := 'Z';
            fmc_la27_p                => tb_fmc_lpc_row_c(26),           --: std_logic := 'Z';
            fmc_la28_n                => tb_fmc_lpc_row_h(32),           --: std_logic;
            fmc_la28_p                => tb_fmc_lpc_row_h(31),           --: std_logic;
            fmc_la29_n                => tb_fmc_lpc_row_g(31),           --: std_logic := 'Z';
            fmc_la29_p                => tb_fmc_lpc_row_g(30),           --: std_logic := 'Z';
            fmc_la30_n                => tb_fmc_lpc_row_h(35),           --: std_logic;
            fmc_la30_p                => tb_fmc_lpc_row_h(34),           --: std_logic := 'Z';
            fmc_la31_n                => tb_fmc_lpc_row_g(34),           --: std_logic := 'Z';
            fmc_la31_p                => tb_fmc_lpc_row_g(33),           --: std_logic := 'Z';
            fmc_la32_n                => tb_fmc_lpc_row_h(38),           --: std_logic;
            fmc_la32_p                => tb_fmc_lpc_row_h(37),           --: std_logic;
            fmc_la33_n                => tb_fmc_lpc_row_g(37),           --: std_logic := 'Z';
            fmc_la33_p                => tb_fmc_lpc_row_g(36),           --: std_logic := 'Z';
            fmc_prsnt_m2c_l           => tb_fmc_prsnt_m2c_l,             --: std_logic;
            FMC_PWR_GOOD_FLASH_RST_B  => tb_FMC_PWR_GOOD_FLASH_RST_B,    --: out std_logic; -- multiple destinations: 1 of Q2 (LED DS1 driver), U1 AB2 FPGA_PROG (through series R260 DNP), 44 of U25
            --
            -- ???
            FPGA_AWAKE                => tb_FPGA_AWAKE,                  --: out   std_logic;
            FPGA_CCLK                 => tb_FPGA_CCLK,                   --: in    std_logic;
            FPGA_CMP_CLK              => tb_FPGA_CMP_CLK,                --: in    std_logic;
            FPGA_CMP_CS_B             => tb_FPGA_CMP_CS_B,               --: in    std_logic;
            FPGA_CMP_MOSI             => tb_FPGA_CMP_MOSI,               --: in    std_logic;
            --
            FPGA_HSWAPEN              => tb_FPGA_HSWAPEN,                --: in    std_logic;
            FPGA_INIT_B               => tb_FPGA_INIT_B,                 --: out   std_logic;
            FPGA_M0_CMP_MISO          => tb_FPGA_M0_CMP_MISO,            --: in    std_logic;
            FPGA_M1                   => tb_FPGA_M1,                     --: in    std_logic;
            FPGA_MOSI_CSI_B_MISO0     => tb_FPGA_MOSI_CSI_B_MISO0,       --: in    std_logic;
            FPGA_ONCHIP_TERM1         => tb_FPGA_ONCHIP_TERM1,           --: inout std_logic;
            FPGA_ONCHIP_TERM2         => tb_FPGA_ONCHIP_TERM2,           --: inout std_logic;
            FPGA_VTEMP                => tb_FPGA_VTEMP,                  --: in    std_logic;
            --
            -- GPIOs
            gpio_button               => tb_gpio_button,                 --: in    std_logic_vector(3 downto 0); -- active high
            gpio_header_ls            => tb_gpio_header_ls,              --: inout std_logic_vector(7 downto 0);
            gpio_led                  => tb_gpio_led,                    --: out   std_logic_vector(3 downto 0);
            gpio_switch               => tb_gpio_switch,                 --: in    std_logic_vector(3 downto 0); -- active high
            --
            -- Ethernet Gigabit PHY
            phy_col                   => tb_phy_col,                     --: in    std_logic;
            phy_crs                   => tb_phy_crs,                     --: in    std_logic;
            phy_int                   => tb_phy_int,                     --: out   std_logic;
            phy_mdc                   => tb_phy_mdc,                     --: out   std_logic;
            phy_mdio                  => tb_phy_mdio,                    --: inout std_logic;
            phy_reset_b               => tb_phy_reset_b,                 --: out   std_logic;
            phy_rxclk                 => tb_phy_rxclk,                   --: in    std_logic;
            phy_rxctl_rxdv            => tb_phy_rxctl_rxdv,              --: in    std_logic;
            phy_rxd                   => tb_phy_rxd,                     --: in    std_logic_vector(7 downto 0);
            phy_rxer                  => tb_phy_rxer,                    --: in    std_logic;
            phy_txclk                 => tb_phy_txclk,                   --: in    std_logic;
            phy_txctl_txen            => tb_phy_txctl_txen,              --: out   std_logic;
            phy_txc_gtxclk            => tb_phy_txc_gtxclk,              --: out   std_logic;
            phy_txd                   => tb_phy_txd,                     --: out   std_logic_vector(7 downto 0);
            phy_txer                  => tb_phy_txer,                    --: out   std_logic;
            --
            --
            SPI_CS_B                  => tb_SPI_CS_B,                    --: in    std_logic;
            --
            -- 200 MHz oscillator
            SYSCLK_N                  => tb_sysclk_n,                    --: in    std_logic;
            SYSCLK_P                  => tb_sysclk_p,                    --: in    std_logic;
            --
            -- RS232 via USB
            usb_1_cts                 => tb_usb_1_cts,                   --: out   std_logic;
            usb_1_rts                 => tb_usb_1_rts,                   --: in    std_logic;
            usb_1_rx                  => tb_usb_1_rx,                    --: out   std_logic;
            usb_1_tx                  => tb_usb_1_tx,                    --: in    std_logic;
            --
            --  27 MHz, oscillator socket
            user_clock                => tb_user_clock,                  --: in    std_logic;
            user_sma_clock_p          => tb_user_sma_clock_p,            --: inout std_logic;
            user_sma_clock_n          => tb_user_sma_clock_n             --: inout std_logic;
        );

    

    -- ethernet phy signals 
    tb_phy_mdio       <= 'H';              -- pullup
    tb_phy_txclk      <= 'H';              -- : out std_logic;
    tb_phy_rxclk      <= 'H';              -- : out std_logic; 
    tb_phy_rxd        <= (others => 'H');  -- : out std_logic_vector(7 downto 0);   
    tb_phy_rxctl_rxdv <= 'H';              -- : out std_logic; 
    tb_phy_rxer       <= 'H';              -- : out std_logic; 
    tb_phy_col        <= 'H';              -- : out std_logic;
    tb_phy_crs        <= 'H';              -- : out std_logic;
    
    phy_i0: entity work.phy
        generic map (
            address        => 7,  -- : integer range 0 to 31 := 0;
            base1000_t_fd  => 1,  -- : integer range 0 to 1  := 1;
            base1000_t_hd  => 1   -- : integer range 0 to 1  := 1;
        ) 
        port map (
            simulation_run => simulation_run,
            rstn           => tb_phy_reset_b,      -- : in std_logic;
            mdio           => tb_phy_mdio,         -- : inout std_logic;
            tx_clk         => tb_phy_txclk,        -- : out std_logic;
            rx_clk         => tb_phy_rxclk,        -- : out std_logic; 
            rxd            => tb_phy_rxd,          -- : out std_logic_vector(7 downto 0);   
            rx_dv          => tb_phy_rxctl_rxdv,   -- : out std_logic; 
            rx_er          => tb_phy_rxer,         -- : out std_logic; 
            rx_col         => tb_phy_col,          -- : out std_logic;
            rx_crs         => tb_phy_crs,          -- : out std_logic;
            txd            => tb_phy_txd,          -- : in std_logic_vector(7 downto 0);   
            tx_en          => tb_phy_txctl_txen,   -- : in std_logic; 
            tx_er          => tb_phy_txer,         -- : in std_logic; 
            mdc            => tb_phy_mdc,          -- : in std_logic;
            gtx_clk        => tb_phy_txc_gtxclk    -- : in std_logic  
        );


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
    
    
    main: process
    begin

        wait until rising_edge( tb_simulation_break);
        simulation_run <= false;
        report "Simlation ended." severity note;
        wait;

    end process;


end architecture testbench;
