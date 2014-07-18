library ieee;
use ieee.std_logic_1164.all;


entity top_tb is
end top_tb;


architecture testbench of top_tb is

    constant system_frequency       : integer := 125_000_000; -- MHz
    constant tb_clk_period          : time    := (1 sec) / system_frequency;

    signal simulation_run           : boolean := true;
    signal tb_simulation_break      : std_logic;
    --
    signal tb_clk                   : std_logic := '0';
    signal tb_reset_n               : std_logic;
    signal tb_power_fail_n          : std_logic;
    signal tb_watchdog              : std_logic;
    signal tb_reprog_n              : std_logic;
    --
    signal tb_user_clk              : std_logic;
    --
    signal tb_mcb1_dram_a           : std_logic_vector(14 downto 0);
    signal tb_mcb1_dram_ba          : std_logic_vector(2 downto 0);
    signal tb_mcb1_dram_cas_b       : std_logic; 
    signal tb_mcb1_dram_ras_b       : std_logic; 
    signal tb_mcb1_dram_we_b        : std_logic; 
    signal tb_mcb1_dram_cke         : std_logic; 
    signal tb_mcb1_dram_ck_n        : std_logic; 
    signal tb_mcb1_dram_ck_p        : std_logic; 
    signal tb_mcb1_dram_dq          : std_logic_vector(15 downto 0);
    signal tb_mcb1_dram_ldm         : std_logic; 
    signal tb_mcb1_dram_udm         : std_logic; 
    signal tb_mcb1_dram_dqs_n       : std_logic_vector( 1 downto 0); 
    signal tb_mcb1_dram_dqs_p       : std_logic_vector( 1 downto 0); 
    signal tb_mcb1_dram_odt         : std_logic; 
    signal tb_mcb1_dram_reset_b     : std_logic; 
    --                      
    signal tb_mcb3_dram_a           : std_logic_vector(14 downto 0);
    signal tb_mcb3_dram_ba          : std_logic_vector(2 downto 0);
    signal tb_mcb3_dram_cas_b       : std_logic; 
    signal tb_mcb3_dram_ras_b       : std_logic; 
    signal tb_mcb3_dram_we_b        : std_logic; 
    signal tb_mcb3_dram_cke         : std_logic; 
    signal tb_mcb3_dram_ck_n        : std_logic; 
    signal tb_mcb3_dram_ck_p        : std_logic; 
    signal tb_mcb3_dram_dq          : std_logic_vector(15 downto 0);
    signal tb_mcb3_dram_ldm         : std_logic; 
    signal tb_mcb3_dram_udm         : std_logic; 
    signal tb_mcb3_dram_dqs_n       : std_logic_vector( 1 downto 0); 
    signal tb_mcb3_dram_dqs_p       : std_logic_vector( 1 downto 0); 
    signal tb_mcb3_dram_odt         : std_logic; 
    signal tb_mcb3_dram_reset_b     : std_logic; 
    --
    signal tb_phy_mdio              : std_logic; 
    signal tb_phy_mdc               : std_logic; 
    signal tb_phy_int               : std_logic; 
    signal tb_phy_reset_b           : std_logic; 
    signal tb_phy_crs               : std_logic; 
    signal tb_phy_col               : std_logic; 
    signal tb_phy_txen              : std_logic; 
    signal tb_phy_txclk             : std_logic; 
    signal tb_phy_txer              : std_logic; 
    signal tb_phy_txd               : std_logic_vector(7 downto 0);
    signal tb_phy_gtxclk            : std_logic; 
    signal tb_phy_rxclk             : std_logic;
    signal tb_phy_rxer              : std_logic; 
    signal tb_phy_rxdv              : std_logic; 
    signal tb_phy_rxd               : std_logic_vector(7 downto 0);
    --
    signal tb_spi_flash_cso_b       : std_logic;
    signal tb_spi_flash_cclk        : std_logic;
    signal tb_spi_flash_io          : std_logic_vector(3 downto 0); -- ( 0=di, 1=do, 2=wp_n, 3=hold_n)
    --
    signal tb_mac_data              : std_logic;
    --
    signal tb_b2b_b2_l57_n          : std_logic; 
    signal tb_b2b_b2_l57_p          : std_logic; 
    signal tb_b2b_b2_l49_n          : std_logic; 
    signal tb_b2b_b2_l49_p          : std_logic; 
    signal tb_b2b_b2_l48_n          : std_logic; 
    signal tb_b2b_b2_l48_p          : std_logic; 
    signal tb_b2b_b2_l45_n          : std_logic; 
    signal tb_b2b_b2_l45_p          : std_logic; 
    signal tb_b2b_b2_l43_n          : std_logic; 
    signal tb_b2b_b2_l43_p          : std_logic; 
    signal tb_b2b_b2_l41_n          : std_logic; 
    signal tb_b2b_b2_l41_p          : std_logic; 
    signal tb_b2b_b2_l21_p          : std_logic; 
    signal tb_b2b_b2_l21_n          : std_logic; 
    signal tb_b2b_b2_l15_p          : std_logic; 
    signal tb_b2b_b2_l15_n          : std_logic; 
    signal tb_b2b_b2_l31_n          : std_logic; -- single ended
    signal tb_b2b_b2_l32_n          : std_logic; -- single ended
    signal tb_b2b_b2_l60_p          : std_logic; 
    signal tb_b2b_b2_l60_n          : std_logic; 
    signal tb_b2b_b2_l59_n          : std_logic; 
    signal tb_b2b_b2_l59_p          : std_logic; 
    signal tb_b2b_b2_l44_n          : std_logic; 
    signal tb_b2b_b2_l44_p          : std_logic; 
    signal tb_b2b_b2_l42_n          : std_logic; 
    signal tb_b2b_b2_l42_p          : std_logic; 
    signal tb_b2b_b2_l18_p          : std_logic; 
    signal tb_b2b_b2_l18_n          : std_logic; 
    signal tb_b2b_b2_l8_n           : std_logic; 
    signal tb_b2b_b2_l8_p           : std_logic; 
    signal tb_b2b_b2_l11_p          : std_logic; 
    signal tb_b2b_b2_l11_n          : std_logic; 
    signal tb_b2b_b2_l6_p           : std_logic; 
    signal tb_b2b_b2_l6_n           : std_logic; 
    signal tb_b2b_b2_l5_p           : std_logic; 
    signal tb_b2b_b2_l5_n           : std_logic; 
    signal tb_b2b_b2_l9_n           : std_logic; 
    signal tb_b2b_b2_l9_p           : std_logic; 
    signal tb_b2b_b2_l4_n           : std_logic; 
    signal tb_b2b_b2_l4_p           : std_logic; 
    signal tb_b2b_b2_l29_n          : std_logic; -- single ended 
    signal tb_b2b_b2_l10_n          : std_logic; 
    signal tb_b2b_b2_l10_p          : std_logic; 
    signal tb_b2b_b2_l2_n           : std_logic; 
    signal tb_b2b_b2_l2_p           : std_logic; 
    --
    signal tb_b2b_b3_l60_n          : std_logic; 
    signal tb_b2b_b3_l60_p          : std_logic; 
    signal tb_b2b_b3_l9_n           : std_logic; 
    signal tb_b2b_b3_l9_p           : std_logic; 
    signal tb_b2b_b0_l3_p           : std_logic; 
    signal tb_b2b_b0_l3_n           : std_logic; 
    signal tb_b2b_b3_l59_p          : std_logic; 
    signal tb_b2b_b3_l59_n          : std_logic; 
    signal tb_b2b_b0_l32_p          : std_logic; 
    signal tb_b2b_b0_l32_n          : std_logic; 
    signal tb_b2b_b0_l7_n           : std_logic; 
    signal tb_b2b_b0_l7_p           : std_logic; 
    signal tb_b2b_b0_l33_n          : std_logic; 
    signal tb_b2b_b0_l33_p          : std_logic; 
    signal tb_b2b_b0_l36_p          : std_logic; 
    signal tb_b2b_b0_l36_n          : std_logic; 
    signal tb_b2b_b0_l49_p          : std_logic; 
    signal tb_b2b_b0_l49_n          : std_logic; 
    signal tb_b2b_b0_l62_p          : std_logic; 
    signal tb_b2b_b0_l62_n          : std_logic; 
    signal tb_b2b_b0_l66_p          : std_logic; 
    signal tb_b2b_b0_l66_n          : std_logic; 
    signal tb_b2b_b1_l10_p          : std_logic; 
    signal tb_b2b_b1_l10_n          : std_logic; 
    signal tb_b2b_b1_l9_p           : std_logic; 
    signal tb_b2b_b1_l9_n           : std_logic; 
    signal tb_b2b_b1_l21_n          : std_logic; 
    signal tb_b2b_b1_l21_p          : std_logic; 
    signal tb_b2b_b1_l61_p          : std_logic; 
    signal tb_b2b_b1_l61_n          : std_logic; 
    --
    signal tb_b2b_b0_l2_p           : std_logic; 
    signal tb_b2b_b0_l2_n           : std_logic; 
    signal tb_b2b_b0_l4_n           : std_logic; 
    signal tb_b2b_b0_l4_p           : std_logic; 
    signal tb_b2b_b0_l5_n           : std_logic; 
    signal tb_b2b_b0_l5_p           : std_logic; 
    signal tb_b2b_b0_l6_n           : std_logic; 
    signal tb_b2b_b0_l6_p           : std_logic; 
    signal tb_b2b_b0_l8_n           : std_logic; 
    signal tb_b2b_b0_l8_p           : std_logic; 
    signal tb_b2b_b0_l34_n          : std_logic; 
    signal tb_b2b_b0_l34_p          : std_logic; 
    signal tb_b2b_b0_l35_n          : std_logic; 
    signal tb_b2b_b0_l35_p          : std_logic; 
    signal tb_b2b_b0_l37_n          : std_logic; 
    signal tb_b2b_b0_l37_p          : std_logic; 
    signal tb_b2b_b0_l38_n          : std_logic; 
    signal tb_b2b_b0_l38_p          : std_logic; 
    signal tb_b2b_b0_l50_n          : std_logic; 
    signal tb_b2b_b0_l50_p          : std_logic; 
    signal tb_b2b_b0_l51_n          : std_logic; 
    signal tb_b2b_b0_l51_p          : std_logic; 
    signal tb_b2b_b0_l63_n          : std_logic; 
    signal tb_b2b_b0_l63_p          : std_logic; 
    signal tb_b2b_b0_l64_n          : std_logic; 
    signal tb_b2b_b0_l64_p          : std_logic; 
    signal tb_b2b_b0_l65_n          : std_logic; 
    signal tb_b2b_b0_l65_p          : std_logic; 
    signal tb_b2b_b1_l20_p          : std_logic; 
    signal tb_b2b_b1_l20_n          : std_logic; 
    signal tb_b2b_b1_l19_p          : std_logic; 
    signal tb_b2b_b1_l19_n          : std_logic; 
    signal tb_b2b_b1_l59            : std_logic; 
    --
    signal tb_user_led_n            : std_logic;
    signal tb_av                    : std_logic_vector(3 downto 0);
    signal tb_br                    : std_logic_vector(3 downto 0);

	
begin

    tb_clk     <= not tb_clk after tb_clk_period / 2 when simulation_run;
    tb_reset_n <= '0', '1'   after tb_clk_period * 6.66;

    top_i0: entity work.top
    port map ( 
        -- pragma translate_off
        simulation_break      => tb_simulation_break,    -- : out   std_logic;
        -- pragma translate_on                           
        -- system stuff                                  
        CLK                   => tb_clk,                 -- : in    std_logic; -- 125 MHz
        --RESET_N               => tb_reset_n,             -- : in    std_logic;
        POWER_FAIL_N          => tb_power_fail_n,        -- : in    std_logic;
        WATCHDOG              => tb_watchdog,            -- : out   std_logic;
        REPROG_N              => tb_reprog_n,            -- : out   std_logic;
        -- user clock                                    -- 
        USER_CLK              => tb_user_clk,            -- : in    std_logic;
        --                                               -- 
        -- DDR3 SDRAM                                    -- 
        MCB1_DRAM_A           => tb_mcb1_dram_a,         -- : out   std_logic_vector(14 downto 0);
        MCB1_DRAM_BA          => tb_mcb1_dram_ba,        -- : out   std_logic_vector(2 downto 0);
        MCB1_DRAM_CAS_B       => tb_mcb1_dram_cas_b,     -- : out   std_logic; 
        MCB1_DRAM_RAS_B       => tb_mcb1_dram_ras_b,     -- : out   std_logic; 
        MCB1_DRAM_WE_B        => tb_mcb1_dram_we_b,      -- : out   std_logic; 
        MCB1_DRAM_CKE         => tb_mcb1_dram_cke,       -- : out   std_logic; 
        MCB1_DRAM_CK_N        => tb_mcb1_dram_ck_n,      -- : out   std_logic; 
        MCB1_DRAM_CK_P        => tb_mcb1_dram_ck_p,      -- : out   std_logic; 
        MCB1_DRAM_DQ          => tb_mcb1_dram_dq,        -- : inout std_logic_vector(15 downto 0);
        MCB1_DRAM_LDM         => tb_mcb1_dram_ldm,       -- : out   std_logic; 
        MCB1_DRAM_UDM         => tb_mcb1_dram_udm,       -- : out   std_logic; 
        MCB1_DRAM_DQS_N       => tb_mcb1_dram_dqs_n,     -- : inout std_logic_vector; 
        MCB1_DRAM_DQS_P       => tb_mcb1_dram_dqs_p,     -- : inout std_logic_vector; 
        MCB1_DRAM_ODT         => tb_mcb1_dram_odt,       -- : out   std_logic; 
        MCB1_DRAM_RESET_B     => tb_mcb1_dram_reset_b,   -- : out   std_logic; 
        --                       --                      
        MCB3_DRAM_A           => tb_mcb3_dram_a,         -- : out   std_logic_vector(14 downto 0);
        MCB3_DRAM_BA          => tb_mcb3_dram_ba,        -- : out   std_logic_vector(2 downto 0);
        MCB3_DRAM_CAS_B       => tb_mcb3_dram_cas_b,     -- : out   std_logic; 
        MCB3_DRAM_RAS_B       => tb_mcb3_dram_ras_b,     -- : out   std_logic; 
        MCB3_DRAM_WE_B        => tb_mcb3_dram_we_b,      -- : out   std_logic; 
        MCB3_DRAM_CKE         => tb_mcb3_dram_cke,       -- : out   std_logic; 
        MCB3_DRAM_CK_N        => tb_mcb3_dram_ck_n,      -- : out   std_logic; 
        MCB3_DRAM_CK_P        => tb_mcb3_dram_ck_p,      -- : out   std_logic; 
        MCB3_DRAM_DQ          => tb_mcb3_dram_dq,        -- : inout std_logic_vector(15 downto 0);
        MCB3_DRAM_LDM         => tb_mcb3_dram_ldm,       -- : out   std_logic; 
        MCB3_DRAM_UDM         => tb_mcb3_dram_udm,       -- : out   std_logic; 
        MCB3_DRAM_DQS_N       => tb_mcb3_dram_dqs_n,     -- : inout std_logic_vector; 
        MCB3_DRAM_DQS_P       => tb_mcb3_dram_dqs_p,     -- : inout std_logic_vector; 
        MCB3_DRAM_ODT         => tb_mcb3_dram_odt,       -- : out   std_logic; 
        MCB3_DRAM_RESET_B     => tb_mcb3_dram_reset_b,   -- : out   std_logic; 
        --                      
        -- Ethernet PHY         
        -- phy address = 0b00111
        -- config(0)   = '1'    
        -- config(1)   = '0'    
        -- config(2)   = '1'    
        -- config(3)   = PHY_L10
        -- config(4)   = '1'    
        -- config(5)   = '1'    
        -- config(6)   = PHY_LED_RX
        --PHY_125                                        -- : in    std_logic; -- 125 MHz from phy, used as clk
        PHY_MDIO              => tb_phy_mdio,            -- : inout std_logic; 
        PHY_MDC               => tb_phy_mdc,             -- : out   std_logic; 
        PHY_INT               => tb_phy_int,             -- : in    std_logic; 
        PHY_RESET_B           => tb_phy_reset_b,         -- : out   std_logic; 
        PHY_CRS               => tb_phy_crs,             -- : in    std_logic; 
        PHY_COL               => tb_phy_col,             -- : inout std_logic; 
        PHY_TXEN              => tb_phy_txen,            -- : out   std_logic; 
        PHY_TXCLK             => tb_phy_txclk,           -- : in    std_logic; 
        PHY_TXER              => tb_phy_txer,            -- : out   std_logic; 
        PHY_TXD               => tb_phy_txd,             -- : out   std_logic_vector(7 downto 0);
        PHY_GTXCLK            => tb_phy_gtxclk,          -- : out   std_logic; 
        PHY_RXCLK             => tb_phy_rxclk,           -- : in    std_logic;
        PHY_RXER              => tb_phy_rxer,            -- : in    std_logic; 
        PHY_RXDV              => tb_phy_rxdv,            -- : in    std_logic; 
        PHY_RXD               => tb_phy_rxd,             -- : in    std_logic_vector(7 downto 0);
        --
        -- quad SPI Flash (W25Q64BV)
        SPI_FLASH_CSO_B       => tb_spi_flash_cso_b,     -- : out   std_logic;
        SPI_FLASH_CCLK        => tb_spi_flash_cclk,      -- : out   std_logic;
        SPI_FLASH_IO          => tb_spi_flash_io,        -- : inout std_logic_vector(3 downto 0); -- ( 0=di, 1=do, 2=wp_n, 3=hold_n)
        --
        -- EEPROM (48bit MAC address, DS2502-E48)
        MAC_DATA              => tb_mac_data,            -- : inout std_logic;
        --
        -- B2B J1 user IO
        B2B_B2_L57_N          => tb_b2b_b2_l57_n,        -- : inout std_logic; 
        B2B_B2_L57_P          => tb_b2b_b2_l57_p,        -- : inout std_logic; 
        B2B_B2_L49_N          => tb_b2b_b2_l49_n,        -- : inout std_logic; 
        B2B_B2_L49_P          => tb_b2b_b2_l49_p,        -- : inout std_logic; 
        B2B_B2_L48_N          => tb_b2b_b2_l48_n,        -- : inout std_logic; 
        B2B_B2_L48_P          => tb_b2b_b2_l48_p,        -- : inout std_logic; 
        B2B_B2_L45_N          => tb_b2b_b2_l45_n,        -- : inout std_logic; 
        B2B_B2_L45_P          => tb_b2b_b2_l45_p,        -- : inout std_logic; 
        B2B_B2_L43_N          => tb_b2b_b2_l43_n,        -- : inout std_logic; 
        B2B_B2_L43_P          => tb_b2b_b2_l43_p,        -- : inout std_logic; 
        B2B_B2_L41_N          => tb_b2b_b2_l41_n,        -- : inout std_logic; 
        B2B_B2_L41_P          => tb_b2b_b2_l41_p,        -- : inout std_logic; 
        B2B_B2_L21_P          => tb_b2b_b2_l21_p,        -- : inout std_logic; 
        B2B_B2_L21_N          => tb_b2b_b2_l21_n,        -- : inout std_logic; 
        B2B_B2_L15_P          => tb_b2b_b2_l15_p,        -- : inout std_logic; 
        B2B_B2_L15_N          => tb_b2b_b2_l15_n,        -- : inout std_logic; 
        B2B_B2_L31_N          => tb_b2b_b2_l31_n,        -- : inout std_logic; -- single ended
        B2B_B2_L32_N          => tb_b2b_b2_l32_n,        -- : inout std_logic; -- single ended
        B2B_B2_L60_P          => tb_b2b_b2_l60_p,        -- : inout std_logic; 
        B2B_B2_L60_N          => tb_b2b_b2_l60_n,        -- : inout std_logic; 
        B2B_B2_L59_N          => tb_b2b_b2_l59_n,        -- : inout std_logic; 
        B2B_B2_L59_P          => tb_b2b_b2_l59_p,        -- : inout std_logic; 
        B2B_B2_L44_N          => tb_b2b_b2_l44_n,        -- : inout std_logic; 
        B2B_B2_L44_P          => tb_b2b_b2_l44_p,        -- : inout std_logic; 
        B2B_B2_L42_N          => tb_b2b_b2_l42_n,        -- : inout std_logic; 
        B2B_B2_L42_P          => tb_b2b_b2_l42_p,        -- : inout std_logic; 
        B2B_B2_L18_P          => tb_b2b_b2_l18_p,        -- : inout std_logic; 
        B2B_B2_L18_N          => tb_b2b_b2_l18_n,        -- : inout std_logic; 
        B2B_B2_L8_N           => tb_b2b_b2_l8_n,         -- : inout std_logic; 
        B2B_B2_L8_P           => tb_b2b_b2_l8_p,         -- : inout std_logic; 
        B2B_B2_L11_P          => tb_b2b_b2_l11_p,        -- : inout std_logic; 
        B2B_B2_L11_N          => tb_b2b_b2_l11_n,        -- : inout std_logic; 
        B2B_B2_L6_P           => tb_b2b_b2_l6_p,         -- : inout std_logic; 
        B2B_B2_L6_N           => tb_b2b_b2_l6_n,         -- : inout std_logic; 
        B2B_B2_L5_P           => tb_b2b_b2_l5_p,         -- : inout std_logic; 
        B2B_B2_L5_N           => tb_b2b_b2_l5_n,         -- : inout std_logic; 
        B2B_B2_L9_N           => tb_b2b_b2_l9_n,         -- : inout std_logic; 
        B2B_B2_L9_P           => tb_b2b_b2_l9_p,         -- : inout std_logic; 
        B2B_B2_L4_N           => tb_b2b_b2_l4_n,         -- : inout std_logic; 
        B2B_B2_L4_P           => tb_b2b_b2_l4_p,         -- : inout std_logic; 
        B2B_B2_L29_N          => tb_b2b_b2_l29_n,        -- : inout std_logic; -- single ended 
        B2B_B2_L10_N          => tb_b2b_b2_l10_n,        -- : inout std_logic; 
        B2B_B2_L10_P          => tb_b2b_b2_l10_p,        -- : inout std_logic; 
        B2B_B2_L2_N           => tb_b2b_b2_l2_n,         -- : inout std_logic; 
        B2B_B2_L2_P           => tb_b2b_b2_l2_p,         -- : inout std_logic; 
        --
        -- B2B J2 user IO
        B2B_B3_L60_N          => tb_b2b_b3_l60_n,        -- : inout std_logic; 
        B2B_B3_L60_P          => tb_b2b_b3_l60_p,        -- : inout std_logic; 
        B2B_B3_L9_N           => tb_b2b_b3_l9_n,         -- : inout std_logic; 
        B2B_B3_L9_P           => tb_b2b_b3_l9_p,         -- : inout std_logic; 
        B2B_B0_L3_P           => tb_b2b_b0_l3_p,         -- : inout std_logic; 
        B2B_B0_L3_N           => tb_b2b_b0_l3_n,         -- : inout std_logic; 
        B2B_B3_L59_P          => tb_b2b_b3_l59_p,        -- : inout std_logic; 
        B2B_B3_L59_N          => tb_b2b_b3_l59_n,        -- : inout std_logic; 
        B2B_B0_L32_P          => tb_b2b_b0_l32_p,        -- : inout std_logic; 
        B2B_B0_L32_N          => tb_b2b_b0_l32_n,        -- : inout std_logic; 
        B2B_B0_L7_N           => tb_b2b_b0_l7_n,         -- : inout std_logic; 
        B2B_B0_L7_P           => tb_b2b_b0_l7_p,         -- : inout std_logic; 
        B2B_B0_L33_N          => tb_b2b_b0_l33_n,        -- : inout std_logic; 
        B2B_B0_L33_P          => tb_b2b_b0_l33_p,        -- : inout std_logic; 
        B2B_B0_L36_P          => tb_b2b_b0_l36_p,        -- : inout std_logic; 
        B2B_B0_L36_N          => tb_b2b_b0_l36_n,        -- : inout std_logic; 
        B2B_B0_L49_P          => tb_b2b_b0_l49_p,        -- : inout std_logic; 
        B2B_B0_L49_N          => tb_b2b_b0_l49_n,        -- : inout std_logic; 
        B2B_B0_L62_P          => tb_b2b_b0_l62_p,        -- : inout std_logic; 
        B2B_B0_L62_N          => tb_b2b_b0_l62_n,        -- : inout std_logic; 
        B2B_B0_L66_P          => tb_b2b_b0_l66_p,        -- : inout std_logic; 
        B2B_B0_L66_N          => tb_b2b_b0_l66_n,        -- : inout std_logic; 
        B2B_B1_L10_P          => tb_b2b_b1_l10_p,        -- : inout std_logic; 
        B2B_B1_L10_N          => tb_b2b_b1_l10_n,        -- : inout std_logic; 
        B2B_B1_L9_P           => tb_b2b_b1_l9_p,         -- : inout std_logic; 
        B2B_B1_L9_N           => tb_b2b_b1_l9_n,         -- : inout std_logic; 
        B2B_B1_L21_N          => tb_b2b_b1_l21_n,        -- : inout std_logic; 
        B2B_B1_L21_P          => tb_b2b_b1_l21_p,        -- : inout std_logic; 
        B2B_B1_L61_P          => tb_b2b_b1_l61_p,        -- : inout std_logic; 
        B2B_B1_L61_N          => tb_b2b_b1_l61_n,        -- : inout std_logic; 
        --B2B_B0_L1           =>                         -- : inout std_logic;  -- used as reset_n
        B2B_B0_L2_P           => tb_b2b_b0_l2_p,         -- : inout std_logic; 
        B2B_B0_L2_N           => tb_b2b_b0_l2_n,         -- : inout std_logic; 
        B2B_B0_L4_N           => tb_b2b_b0_l4_n,         -- : inout std_logic; 
        B2B_B0_L4_P           => tb_b2b_b0_l4_p,         -- : inout std_logic; 
        B2B_B0_L5_N           => tb_b2b_b0_l5_n,         -- : inout std_logic; 
        B2B_B0_L5_P           => tb_b2b_b0_l5_p,         -- : inout std_logic; 
        B2B_B0_L6_N           => tb_b2b_b0_l6_n,         -- : inout std_logic; 
        B2B_B0_L6_P           => tb_b2b_b0_l6_p,         -- : inout std_logic; 
        B2B_B0_L8_N           => tb_b2b_b0_l8_n,         -- : inout std_logic; 
        B2B_B0_L8_P           => tb_b2b_b0_l8_p,         -- : inout std_logic; 
        B2B_B0_L34_N          => tb_b2b_b0_l34_n,        -- : inout std_logic; 
        B2B_B0_L34_P          => tb_b2b_b0_l34_p,        -- : inout std_logic; 
        B2B_B0_L35_N          => tb_b2b_b0_l35_n,        -- : inout std_logic; 
        B2B_B0_L35_P          => tb_b2b_b0_l35_p,        -- : inout std_logic; 
        B2B_B0_L37_N          => tb_b2b_b0_l37_n,        -- : inout std_logic; 
        B2B_B0_L37_P          => tb_b2b_b0_l37_p,        -- : inout std_logic; 
        B2B_B0_L38_N          => tb_b2b_b0_l38_n,        -- : inout std_logic; 
        B2B_B0_L38_P          => tb_b2b_b0_l38_p,        -- : inout std_logic; 
        B2B_B0_L50_N          => tb_b2b_b0_l50_n,        -- : inout std_logic; 
        B2B_B0_L50_P          => tb_b2b_b0_l50_p,        -- : inout std_logic; 
        B2B_B0_L51_N          => tb_b2b_b0_l51_n,        -- : inout std_logic; 
        B2B_B0_L51_P          => tb_b2b_b0_l51_p,        -- : inout std_logic; 
        B2B_B0_L63_N          => tb_b2b_b0_l63_n,        -- : inout std_logic; 
        B2B_B0_L63_P          => tb_b2b_b0_l63_p,        -- : inout std_logic; 
        B2B_B0_L64_N          => tb_b2b_b0_l64_n,        -- : inout std_logic; 
        B2B_B0_L64_P          => tb_b2b_b0_l64_p,        -- : inout std_logic; 
        B2B_B0_L65_N          => tb_b2b_b0_l65_n,        -- : inout std_logic; 
        B2B_B0_L65_P          => tb_b2b_b0_l65_p,        -- : inout std_logic; 
        B2B_B1_L20_P          => tb_b2b_b1_l20_p,        -- : inout std_logic; 
        B2B_B1_L20_N          => tb_b2b_b1_l20_n,        -- : inout std_logic; 
        B2B_B1_L19_P          => tb_b2b_b1_l19_p,        -- : inout std_logic; 
        B2B_B1_L19_N          => tb_b2b_b1_l19_n,        -- : inout std_logic; 
        B2B_B1_L59            => tb_b2b_b1_l59,          -- : inout std_logic; 
        --
        -- misc
        USER_LED_N            => tb_user_led_n,          -- : out   std_logic;
        AV                    => tb_av,                  -- : in    std_logic_vector(3 downto 0);
        BR                    => tb_br                   -- : in    std_logic_vector(3 downto 0)
    );

    main: process
    begin
        wait until rising_edge( tb_simulation_break);
        simulation_run <= false;
        wait; -- forever
    end process;

end architecture testbench;

