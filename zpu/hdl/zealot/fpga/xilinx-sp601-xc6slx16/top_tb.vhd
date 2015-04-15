-- testbench for
-- SP601 evaluation board
--
-- includes "model" for clock generation
-- simulate press on cpu_reset as reset
--
-- place models for external components (PHY, DDR2) in this file
--


library ieee;
use ieee.std_logic_1164.all;


entity top_tb is
end entity top_tb;

architecture testbench of top_tb is

    ---------------------------
    -- constant declarations
    constant sys_clk_period  : time := 1 sec / 200_000_000;  -- 200 MHz
    constant user_clk_period : time := 1 sec / 27_000_000;   -- 27 MHz


    ---------------------------
    -- signal declarations
    signal simulation_run              : boolean                      := true;
    signal tb_stop_simulation          : std_logic;
    --
    signal tb_cpu_reset                : std_logic;  -- SW9 pushbutton (active-high)
    --
    -- DDR2 memory 128 MB
    signal tb_ddr2_a                   : std_logic_vector(12 downto 0);
    signal tb_ddr2_ba                  : std_logic_vector(2 downto 0);
    signal tb_ddr2_cas_b               : std_logic;
    signal tb_ddr2_ras_b               : std_logic;
    signal tb_ddr2_we_b                : std_logic;
    signal tb_ddr2_cke                 : std_logic;
    signal tb_ddr2_clk_n               : std_logic;
    signal tb_ddr2_clk_p               : std_logic;
    signal tb_ddr2_dq                  : std_logic_vector(15 downto 0);
    signal tb_ddr2_ldm                 : std_logic;
    signal tb_ddr2_udm                 : std_logic;
    signal tb_ddr2_ldqs_n              : std_logic;
    signal tb_ddr2_ldqs_p              : std_logic;
    signal tb_ddr2_udqs_n              : std_logic;
    signal tb_ddr2_udqs_p              : std_logic;
    signal tb_ddr2_odt                 : std_logic;
    --                                
    -- flash memory                        
    signal tb_flash_a                  : std_logic_vector(24 downto 0);
    signal tb_flash_d                  : std_logic_vector(7 downto 3);
    signal tb_fpga_d0_din_miso_miso1   : std_logic;  -- dual use
    signal tb_fpga_d1_miso2            : std_logic;  -- dual use
    signal tb_fpga_d2_miso3            : std_logic;  -- dual use
    signal tb_flash_we_b               : std_logic;
    signal tb_flash_oe_b               : std_logic;
    signal tb_flash_ce_b               : std_logic;
    --
    -- FMC connector
    -- M2C   Mezzanine to Carrier
    -- C2M   Carrier to Mezzanine
    signal tb_fmc_clk0_m2c_n           : std_logic                    := '1';
    signal tb_fmc_clk0_m2c_p           : std_logic                    := '0';
    signal tb_fmc_clk1_m2c_n           : std_logic                    := '1';
    signal tb_fmc_clk1_m2c_p           : std_logic                    := '0';
    -- IIC addresses:
    -- M24C08:                 1010100..1010111
    -- 2kb EEPROM on FMC card: 1010010
    signal tb_iic_scl_main             : std_logic;
    signal tb_iic_sda_main             : std_logic;
    signal tb_fmc_la00_cc_n            : std_logic;
    signal tb_fmc_la00_cc_p            : std_logic;
    signal tb_fmc_la01_cc_n            : std_logic;
    signal tb_fmc_la01_cc_p            : std_logic;
    signal tb_fmc_la02_n               : std_logic;
    signal tb_fmc_la02_p               : std_logic;
    signal tb_fmc_la03_n               : std_logic;
    signal tb_fmc_la03_p               : std_logic;
    signal tb_fmc_la04_n               : std_logic;
    signal tb_fmc_la04_p               : std_logic;
    signal tb_fmc_la05_n               : std_logic;
    signal tb_fmc_la05_p               : std_logic;
    signal tb_fmc_la06_n               : std_logic;
    signal tb_fmc_la06_p               : std_logic;
    signal tb_fmc_la07_n               : std_logic;
    signal tb_fmc_la07_p               : std_logic;
    signal tb_fmc_la08_n               : std_logic;
    signal tb_fmc_la08_p               : std_logic;
    signal tb_fmc_la09_n               : std_logic;
    signal tb_fmc_la09_p               : std_logic;
    signal tb_fmc_la10_n               : std_logic;
    signal tb_fmc_la10_p               : std_logic;
    signal tb_fmc_la11_n               : std_logic;
    signal tb_fmc_la11_p               : std_logic;
    signal tb_fmc_la12_n               : std_logic;
    signal tb_fmc_la12_p               : std_logic;
    signal tb_fmc_la13_n               : std_logic;
    signal tb_fmc_la13_p               : std_logic;
    signal tb_fmc_la14_n               : std_logic;
    signal tb_fmc_la14_p               : std_logic;
    signal tb_fmc_la15_n               : std_logic;
    signal tb_fmc_la15_p               : std_logic;
    signal tb_fmc_la16_n               : std_logic;
    signal tb_fmc_la16_p               : std_logic;
    signal tb_fmc_la17_cc_n            : std_logic;
    signal tb_fmc_la17_cc_p            : std_logic;
    signal tb_fmc_la18_cc_n            : std_logic;
    signal tb_fmc_la18_cc_p            : std_logic;
    signal tb_fmc_la19_n               : std_logic;
    signal tb_fmc_la19_p               : std_logic;
    signal tb_fmc_la20_n               : std_logic;
    signal tb_fmc_la20_p               : std_logic;
    signal tb_fmc_la21_n               : std_logic;
    signal tb_fmc_la21_p               : std_logic;
    signal tb_fmc_la22_n               : std_logic;
    signal tb_fmc_la22_p               : std_logic;
    signal tb_fmc_la23_n               : std_logic;
    signal tb_fmc_la23_p               : std_logic;
    signal tb_fmc_la24_n               : std_logic;
    signal tb_fmc_la24_p               : std_logic;
    signal tb_fmc_la25_n               : std_logic;
    signal tb_fmc_la25_p               : std_logic;
    signal tb_fmc_la26_n               : std_logic;
    signal tb_fmc_la26_p               : std_logic;
    signal tb_fmc_la27_n               : std_logic;
    signal tb_fmc_la27_p               : std_logic;
    signal tb_fmc_la28_n               : std_logic;
    signal tb_fmc_la28_p               : std_logic;
    signal tb_fmc_la29_n               : std_logic;
    signal tb_fmc_la29_p               : std_logic;
    signal tb_fmc_la30_n               : std_logic;
    signal tb_fmc_la30_p               : std_logic;
    signal tb_fmc_la31_n               : std_logic;
    signal tb_fmc_la31_p               : std_logic;
    signal tb_fmc_la32_n               : std_logic;
    signal tb_fmc_la32_p               : std_logic;
    signal tb_fmc_la33_n               : std_logic;
    signal tb_fmc_la33_p               : std_logic;
    signal tb_fmc_prsnt_m2c_l          : std_logic                    := '0';
    signal tb_fmc_pwr_good_flash_rst_b : std_logic;  -- multiple destinations: 1 of Q2 (LED DS1 driver), U1 AB2 FPGA_PROG (through series R260 DNP), 44 of U25
    --
    signal tb_fpga_awake               : std_logic;
    signal tb_fpga_cclk                : std_logic;
    signal tb_fpga_cmp_clk             : std_logic                    := '0';
    signal tb_fpga_cmp_mosi            : std_logic                    := '0';
    signal tb_fpga_hswapen             : std_logic                    := '0';
    signal tb_fpga_init_b              : std_logic;  -- low active
    signal tb_fpga_m0_cmp_miso         : std_logic                    := '0';  -- mode DIP switch SW1 active high
    signal tb_fpga_m1                  : std_logic                    := '0';  -- mode DIP switch SW1 active high
    signal tb_fpga_mosi_csi_b_miso0    : std_logic;
    signal tb_fpga_onchip_term1        : std_logic;
    signal tb_fpga_onchip_term2        : std_logic;
    signal tb_fpga_vtemp               : std_logic                    := '0';
    --
    -- GPIOs
    signal tb_gpio_button              : std_logic_vector(3 downto 0) := (others => '0');  -- active high
    signal tb_gpio_header_ls           : std_logic_vector(7 downto 0);  -- 
    signal tb_gpio_led                 : std_logic_vector(3 downto 0);
    signal tb_gpio_switch              : std_logic_vector(3 downto 0) := (others => '0');  -- active high
    --
    -- Ethernet Gigabit PHY 
    signal tb_phy_col                  : std_logic                    := '0';
    signal tb_phy_crs                  : std_logic                    := '0';
    signal tb_phy_int                  : std_logic                    := '0';
    signal tb_phy_mdc                  : std_logic;
    signal tb_phy_mdio                 : std_logic;
    signal tb_phy_reset                : std_logic;
    signal tb_phy_rxclk                : std_logic                    := '0';
    signal tb_phy_rxctl_rxdv           : std_logic                    := '0';
    signal tb_phy_rxd                  : std_logic_vector(7 downto 0);
    signal tb_phy_rxer                 : std_logic                    := '0';
    signal tb_phy_txclk                : std_logic                    := '0';
    signal tb_phy_txctl_txen           : std_logic;
    signal tb_phy_txc_gtxclk           : std_logic;
    signal tb_phy_txd                  : std_logic_vector(7 downto 0);
    signal tb_phy_txer                 : std_logic;
    --
    --
    signal tb_spi_cs_b                 : std_logic;
    --
    -- 200 MHz oscillator, jitter 50 ppm
    signal tb_sysclk_n                 : std_logic                    := '1';
    signal tb_sysclk_p                 : std_logic                    := '0';
    --
    -- RS232 via USB
    signal tb_usb_1_cts                : std_logic;  -- function: RTS output
    signal tb_usb_1_rts                : std_logic                    := '0';  -- function: CTS input
    signal tb_usb_1_rx                 : std_logic;  -- function: TX data out
    signal tb_usb_1_tx                 : std_logic                    := '0';  -- function: RX data in
    --
    --  27 MHz, oscillator socket
    signal tb_user_clock               : std_logic                    := '0';
    --
    -- user clock provided per SMA
    signal tb_user_sma_clock_p         : std_logic                    := '0';
    signal tb_user_sma_clock_n         : std_logic                    := '0';



begin

    -- generate clocks
    tb_sysclk_p   <= not tb_sysclk_p   after sys_clk_period / 2  when simulation_run;
    tb_sysclk_n   <= not tb_sysclk_n   after sys_clk_period / 2  when simulation_run;
    tb_user_clock <= not tb_user_clock after user_clk_period / 2 when simulation_run;

    -- generate reset
    tb_cpu_reset <= '1', '0' after 6.66 * sys_clk_period;


    -- simulate keypress
    tb_gpio_button(2) <= '0', '1' after 50 us, '0' after 52 us;

    -- dut
    top_i0 : entity work.top
        port map (
            stop_simulation          => tb_stop_simulation,        -- : out   std_logic;
            --
            cpu_reset                => tb_cpu_reset,              -- : in    std_logic;
            --                                                     
            -- DDR2 memory 128 MB                                  
            ddr2_a                   => tb_ddr2_a,                 -- : out   std_logic_vector(12 downto 0);
            ddr2_ba                  => tb_ddr2_ba,                -- : out   std_logic_vector(2 downto 0);
            ddr2_cas_b               => tb_ddr2_cas_b,             -- : out   std_logic;
            ddr2_ras_b               => tb_ddr2_ras_b,             -- : out   std_logic;
            ddr2_we_b                => tb_ddr2_we_b,              -- : out   std_logic;
            ddr2_cke                 => tb_ddr2_cke,               -- : out   std_logic;
            ddr2_clk_n               => tb_ddr2_clk_n,             -- : out   std_logic; 
            ddr2_clk_p               => tb_ddr2_clk_p,             -- : out   std_logic; 
            ddr2_dq                  => tb_ddr2_dq,                -- : inout std_logic_vector(15 downto 0);
            ddr2_ldm                 => tb_ddr2_ldm,               -- : out   std_logic;
            ddr2_udm                 => tb_ddr2_udm,               -- : out   std_logic;
            ddr2_ldqs_n              => tb_ddr2_ldqs_n,            -- : inout std_logic;
            ddr2_ldqs_p              => tb_ddr2_ldqs_p,            -- : inout std_logic;
            ddr2_udqs_n              => tb_ddr2_udqs_n,            -- : inout std_logic;
            ddr2_udqs_p              => tb_ddr2_udqs_p,            -- : inout std_logic;
            ddr2_odt                 => tb_ddr2_odt,               -- : out   std_logic;
            --                                                     
            -- flash memory                                        
            flash_a                  => tb_flash_a,                -- : out   std_logic_vector(24 downto 0);
            flash_d                  => tb_flash_d,                -- : inout std_logic_vector(7  downto 3);
            --                              --
            fpga_d0_din_miso_miso1   => tb_fpga_d0_din_miso_miso1, -- : inout std_logic;
            fpga_d1_miso2            => tb_fpga_d1_miso2,          -- : inout std_logic;
            fpga_d2_miso3            => tb_fpga_d2_miso3,          -- : inout std_logic;
            flash_we_b               => tb_flash_we_b,             -- : out   std_logic;
            flash_oe_b               => tb_flash_oe_b,             -- : out   std_logic;
            flash_ce_b               => tb_flash_ce_b,             -- : out   std_logic;
            --
            -- FMC connector
            -- M2C   Mezzanine to Carrier
            -- C2M   Carrier to Mezzanine
            fmc_clk0_m2c_n           => tb_fmc_clk0_m2c_n,         -- : in    std_logic;
            fmc_clk0_m2c_p           => tb_fmc_clk0_m2c_p,         -- : in    std_logic;
            fmc_clk1_m2c_n           => tb_fmc_clk1_m2c_n,         -- : in    std_logic;
            fmc_clk1_m2c_p           => tb_fmc_clk1_m2c_p,         -- : in    std_logic;
            iic_scl_main             => tb_iic_scl_main,           -- : inout std_logic;
            iic_sda_main             => tb_iic_sda_main,           -- : inout std_logic;
            fmc_la00_cc_n            => tb_fmc_la00_cc_n,          -- : inout std_logic;
            fmc_la00_cc_p            => tb_fmc_la00_cc_p,          -- : inout std_logic;
            fmc_la01_cc_n            => tb_fmc_la01_cc_n,          -- : inout std_logic;
            fmc_la01_cc_p            => tb_fmc_la01_cc_p,          -- : inout std_logic;
            fmc_la02_n               => tb_fmc_la02_n,             -- : inout std_logic;
            fmc_la02_p               => tb_fmc_la02_p,             -- : inout std_logic;
            fmc_la03_n               => tb_fmc_la03_n,             -- : inout std_logic;
            fmc_la03_p               => tb_fmc_la03_p,             -- : inout std_logic;
            fmc_la04_n               => tb_fmc_la04_n,             -- : inout std_logic;
            fmc_la04_p               => tb_fmc_la04_p,             -- : inout std_logic;
            fmc_la05_n               => tb_fmc_la05_n,             -- : inout std_logic;
            fmc_la05_p               => tb_fmc_la05_p,             -- : inout std_logic;
            fmc_la06_n               => tb_fmc_la06_n,             -- : inout std_logic;
            fmc_la06_p               => tb_fmc_la06_p,             -- : inout std_logic;
            fmc_la07_n               => tb_fmc_la07_n,             -- : inout std_logic;
            fmc_la07_p               => tb_fmc_la07_p,             -- : inout std_logic;
            fmc_la08_n               => tb_fmc_la08_n,             -- : inout std_logic;
            fmc_la08_p               => tb_fmc_la08_p,             -- : inout std_logic;
            fmc_la09_n               => tb_fmc_la09_n,             -- : inout std_logic;
            fmc_la09_p               => tb_fmc_la09_p,             -- : inout std_logic;
            fmc_la10_n               => tb_fmc_la10_n,             -- : inout std_logic;
            fmc_la10_p               => tb_fmc_la10_p,             -- : inout std_logic;
            fmc_la11_n               => tb_fmc_la11_n,             -- : inout std_logic;
            fmc_la11_p               => tb_fmc_la11_p,             -- : inout std_logic;
            fmc_la12_n               => tb_fmc_la12_n,             -- : inout std_logic;
            fmc_la12_p               => tb_fmc_la12_p,             -- : inout std_logic;
            fmc_la13_n               => tb_fmc_la13_n,             -- : inout std_logic;
            fmc_la13_p               => tb_fmc_la13_p,             -- : inout std_logic;
            fmc_la14_n               => tb_fmc_la14_n,             -- : inout std_logic;
            fmc_la14_p               => tb_fmc_la14_p,             -- : inout std_logic;
            fmc_la15_n               => tb_fmc_la15_n,             -- : inout std_logic;
            fmc_la15_p               => tb_fmc_la15_p,             -- : inout std_logic;
            fmc_la16_n               => tb_fmc_la16_n,             -- : inout std_logic;
            fmc_la16_p               => tb_fmc_la16_p,             -- : inout std_logic;
            fmc_la17_cc_n            => tb_fmc_la17_cc_n,          -- : inout std_logic;
            fmc_la17_cc_p            => tb_fmc_la17_cc_p,          -- : inout std_logic;
            fmc_la18_cc_n            => tb_fmc_la18_cc_n,          -- : inout std_logic;
            fmc_la18_cc_p            => tb_fmc_la18_cc_p,          -- : inout std_logic;
            fmc_la19_n               => tb_fmc_la19_n,             -- : inout std_logic;
            fmc_la19_p               => tb_fmc_la19_p,             -- : inout std_logic;
            fmc_la20_n               => tb_fmc_la20_n,             -- : inout std_logic;
            fmc_la20_p               => tb_fmc_la20_p,             -- : inout std_logic;
            fmc_la21_n               => tb_fmc_la21_n,             -- : inout std_logic;
            fmc_la21_p               => tb_fmc_la21_p,             -- : inout std_logic;
            fmc_la22_n               => tb_fmc_la22_n,             -- : inout std_logic;
            fmc_la22_p               => tb_fmc_la22_p,             -- : inout std_logic;
            fmc_la23_n               => tb_fmc_la23_n,             -- : inout std_logic;
            fmc_la23_p               => tb_fmc_la23_p,             -- : inout std_logic;
            fmc_la24_n               => tb_fmc_la24_n,             -- : inout std_logic;
            fmc_la24_p               => tb_fmc_la24_p,             -- : inout std_logic;
            fmc_la25_n               => tb_fmc_la25_n,             -- : inout std_logic;
            fmc_la25_p               => tb_fmc_la25_p,             -- : inout std_logic;
            fmc_la26_n               => tb_fmc_la26_n,             -- : inout std_logic;
            fmc_la26_p               => tb_fmc_la26_p,             -- : inout std_logic;
            fmc_la27_n               => tb_fmc_la27_n,             -- : inout std_logic;
            fmc_la27_p               => tb_fmc_la27_p,             -- : inout std_logic;
            fmc_la28_n               => tb_fmc_la28_n,             -- : inout std_logic;
            fmc_la28_p               => tb_fmc_la28_p,             -- : inout std_logic;
            fmc_la29_n               => tb_fmc_la29_n,             -- : inout std_logic;
            fmc_la29_p               => tb_fmc_la29_p,             -- : inout std_logic;
            fmc_la30_n               => tb_fmc_la30_n,             -- : inout std_logic;
            fmc_la30_p               => tb_fmc_la30_p,             -- : inout std_logic;
            fmc_la31_n               => tb_fmc_la31_n,             -- : inout std_logic;
            fmc_la31_p               => tb_fmc_la31_p,             -- : inout std_logic;
            fmc_la32_n               => tb_fmc_la32_n,             -- : inout std_logic;
            fmc_la32_p               => tb_fmc_la32_p,             -- : inout std_logic;
            fmc_la33_n               => tb_fmc_la33_n,             -- : inout std_logic;
            fmc_la33_p               => tb_fmc_la33_p,             -- : inout std_logic;
            fmc_prsnt_m2c_l          => tb_fmc_prsnt_m2c_l,        -- : in    std_logic;
            fmc_pwr_good_flash_rst_b => tb_fmc_pwr_good_flash_rst_b,  -- : out   std_logic;
            --
            fpga_awake               => tb_fpga_awake,             -- : out   std_logic;
            fpga_cclk                => tb_fpga_cclk,              -- : out   std_logic;
            fpga_cmp_clk             => tb_fpga_cmp_clk,           -- : in    std_logic;
            fpga_cmp_mosi            => tb_fpga_cmp_mosi,          -- : in    std_logic;
            --                              --
            fpga_hswapen             => tb_fpga_hswapen,           -- : in    std_logic;
            fpga_init_b              => tb_fpga_init_b,            -- : out   std_logic;
            fpga_m0_cmp_miso         => tb_fpga_m0_cmp_miso,       -- : in    std_logic;
            fpga_m1                  => tb_fpga_m1,                -- : in    std_logic;
            fpga_mosi_csi_b_miso0    => tb_fpga_mosi_csi_b_miso0,  -- : inout std_logic;
            fpga_onchip_term1        => tb_fpga_onchip_term1,      -- : inout std_logic;
            fpga_onchip_term2        => tb_fpga_onchip_term2,      -- : inout std_logic;
            fpga_vtemp               => tb_fpga_vtemp,             -- : in    std_logic;
            --
            -- GPIOs
            gpio_button              => tb_gpio_button,            -- : in    std_logic_vector(3 downto 0);
            gpio_header_ls           => tb_gpio_header_ls,         -- : inout std_logic_vector(7 downto 0);
            gpio_led                 => tb_gpio_led,               -- : out   std_logic_vector(3 downto 0);
            gpio_switch              => tb_gpio_switch,            -- : in    std_logic_vector(3 downto 0);
            --
            -- Ethernet Gigabit PHY 
            phy_col                  => tb_phy_col,                -- : in    std_logic;
            phy_crs                  => tb_phy_crs,                -- : in    std_logic;
            phy_int                  => tb_phy_int,                -- : in    std_logic;
            phy_mdc                  => tb_phy_mdc,                -- : out   std_logic;
            phy_mdio                 => tb_phy_mdio,               -- : inout std_logic;
            phy_reset                => tb_phy_reset,              -- : out   std_logic;
            phy_rxclk                => tb_phy_rxclk,              -- : in    std_logic;
            phy_rxctl_rxdv           => tb_phy_rxctl_rxdv,         -- : in    std_logic;
            phy_rxd                  => tb_phy_rxd,                -- : in    std_logic_vector(7 downto 0);
            phy_rxer                 => tb_phy_rxer,               -- : in    std_logic;
            phy_txclk                => tb_phy_txclk,              -- : in    std_logic;
            phy_txctl_txen           => tb_phy_txctl_txen,         -- : out   std_logic;
            phy_txc_gtxclk           => tb_phy_txc_gtxclk,         -- : out   std_logic;
            phy_txd                  => tb_phy_txd,                -- : out   std_logic_vector(7 downto 0);
            phy_txer                 => tb_phy_txer,               -- : out   std_logic;
            --
            --
            spi_cs_b                 => tb_spi_cs_b,               -- : out   std_logic;
            --                                                     
            -- 200 MHz oscillator, jitter 50 ppm                   
            sysclk_n                 => tb_sysclk_n,               -- : in    std_logic;
            sysclk_p                 => tb_sysclk_p,               -- : in    std_logic;
            --
            -- RS232 via USB
            usb_1_cts                => tb_usb_1_cts,              -- : out   std_logic;
            usb_1_rts                => tb_usb_1_rts,              -- : in    std_logic;
            usb_1_rx                 => tb_usb_1_rx,               -- : out   std_logic;
            usb_1_tx                 => tb_usb_1_tx,               -- : in    std_logic;
            --
            --  27 MHz, oscillator socket
            user_clock               => tb_user_clock,             -- : in    std_logic;
            --
            -- user clock provided per SMA
            user_sma_clock_p         => tb_user_sma_clock_p,       -- : in    std_logic;
            user_sma_clock_n         => tb_user_sma_clock_n        -- : in    std_logic
            );


    -- check for simulation stopping
    process (tb_stop_simulation)
    begin
        if tb_stop_simulation = '1' then
            report "Simulation end." severity note;
            simulation_run <= false;
        end if;
    end process;


end architecture testbench;

