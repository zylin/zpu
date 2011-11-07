
library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.ibufds;



entity top is
    port 
    (
        sys_clk                            : in    std_logic; -- 100 MHz clock
        clk_socket                         : in    std_logic; -- user clock
        --sys_rst                            : in    std_logic; 
        --                                         
        --  RS232                                  
        RS232_RX                           : in    std_logic;
        RS232_TX                           : out   std_logic;
        --  RS232_USB                              
        RS232_USB_RX                       : in    std_logic;
        RS232_USB_TX                       : out   std_logic;
        RS232_USB_reset_dummy              : out   std_logic;
        --
        GPIO_LED_out                       : out   std_logic_vector(7 downto 0);
        GPIO_DIPswitch_in                  : in    std_logic_vector(7 downto 0);
        GPIO_button_in                     : in    std_logic_vector(3 downto 0);
        --
        --  FLASH_8Mx16 
        FLASH_8Mx16_Mem_A                  : out   std_logic_vector(31 downto 7);
        FLASH_8Mx16_Mem_DQ                 : inout std_logic_vector(15 downto 0);
        FLASH_8Mx16_Mem_WEN                : out   std_logic;
        FLASH_8Mx16_Mem_OEN                : out   std_logic_vector(0 downto 0);
        FLASH_8Mx16_Mem_CEN                : out   std_logic_vector(0 downto 0);
        FLASH_8Mx16_rpn_dummy              : out   std_logic;
        --FLASH_8Mx16_byte_dummy           : std_logic;
        --FLASH_8Mx16_adv_dummy            : std_logic;
        --FLASH_8Mx16_clk_dummy            : std_logic;
        --FLASH_8Mx16_wait_dummy           : std_logic;
        --
        --  DDR2_SDRAM_16Mx32 
        DDR2_SDRAM_16Mx32_DDR2_ODT         : in    std_logic_vector( 0 downto 0);
        DDR2_SDRAM_16Mx32_DDR2_A           : out   std_logic_vector(12 downto 0);
        DDR2_SDRAM_16Mx32_DDR2_BA          : out   std_logic_vector( 1 downto 0);
        DDR2_SDRAM_16Mx32_DDR2_CAS_N       : out   std_logic;
        DDR2_SDRAM_16Mx32_DDR2_CKE         : out   std_logic;
        DDR2_SDRAM_16Mx32_DDR2_CS_N        : out   std_logic;
        DDR2_SDRAM_16Mx32_DDR2_RAS_N       : out   std_logic;
        DDR2_SDRAM_16Mx32_DDR2_WE_N        : out   std_logic;
        DDR2_SDRAM_16Mx32_DDR2_DM          : out   std_logic_vector( 3 downto 0);
        DDR2_SDRAM_16Mx32_DDR2_DQS         : inout std_logic_vector( 3 downto 0);
        DDR2_SDRAM_16Mx32_DDR2_DQS_N       : inout std_logic_vector( 3 downto 0);
        DDR2_SDRAM_16Mx32_DDR2_DQ          : inout std_logic_vector(31 downto 0);
        DDR2_SDRAM_16Mx32_DDR2_CK          : in    std_logic_vector( 1 downto 0);
        DDR2_SDRAM_16Mx32_DDR2_CK_N        : in    std_logic_vector( 1 downto 0);
        --
        --  Ethernet_MAC 
        Ethernet_MAC_DUMMY_ETH_TXER        : out   std_logic;
        Ethernet_MAC_PHY_tx_clk            : in    std_logic; -- 25 MHz
        Ethernet_MAC_PHY_rx_clk            : in    std_logic; -- 25 MHz
        Ethernet_MAC_PHY_crs               : in    std_logic;
        Ethernet_MAC_PHY_dv                : in    std_logic;
        Ethernet_MAC_PHY_rx_data           : in    std_logic_vector(3 downto 0);
        Ethernet_MAC_PHY_col               : in    std_logic;
        Ethernet_MAC_PHY_rx_er             : in    std_logic;
        Ethernet_MAC_PHY_tx_en             : out   std_logic;
        Ethernet_MAC_PHY_tx_data           : out   std_logic_vector(3 downto 0);
        Ethernet_MAC_PHY_rst_n             : out   std_logic;
        Ethernet_MAC_PHY_Mii_clk           : out   std_logic;
        Ethernet_MAC_PHY_Mii_data          : inout std_logic;
        --
        --  SysACE_CompactFlash 
        SysACE_CompactFlash_SysACE_CLK     : in    std_logic;
        SysACE_CompactFlash_SysACE_MPA     : out   std_logic_vector( 6 downto 0);
        SysACE_CompactFlash_SysACE_MPD     : inout std_logic_vector(15 downto 0);
        SysACE_CompactFlash_SysACE_CEN     : out   std_logic;
        SysACE_CompactFlash_SysACE_OEN     : out   std_logic;
        SysACE_CompactFlash_SysACE_WEN     : out   std_logic;
        SysACE_CompactFlash_SysACE_MPIRQ   : in    std_logic
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
        i  => DDR2_SDRAM_16Mx32_DDR2_CK(0),
        ib => DDR2_SDRAM_16Mx32_DDR2_CK_N(0)
    );
    
    ibufds_i1 : ibufds
    generic map (
        diff_term => true
    )
    port map (
        o  => ibufds_i1_o,
        i  => DDR2_SDRAM_16Mx32_DDR2_CK(1),
        ib => DDR2_SDRAM_16Mx32_DDR2_CK_N(1)
    );

    -- some default assignments 
    -- to pass bitgen DRC 
    RS232_TX                       <= '1';
    RS232_USB_TX                   <= '1';
    RS232_USB_reset_dummy          <= '0';
    FLASH_8Mx16_Mem_CEN            <= "1";
    FLASH_8Mx16_Mem_OEN            <= "1";
    FLASH_8Mx16_Mem_WEN            <= '1';
    FLASH_8Mx16_rpn_dummy          <= '1';
    FLASH_8Mx16_Mem_A              <= (others => '0');
    DDR2_SDRAM_16Mx32_DDR2_A       <= (others => '0');
    DDR2_SDRAM_16Mx32_DDR2_BA      <= (others => '0');
    DDR2_SDRAM_16Mx32_DDR2_DM      <= (others => '0');
    DDR2_SDRAM_16Mx32_DDR2_CS_N    <= '1';
    DDR2_SDRAM_16Mx32_DDR2_WE_N    <= '1';
    DDR2_SDRAM_16Mx32_DDR2_CKE     <= '1';
    DDR2_SDRAM_16Mx32_DDR2_CAS_N   <= '1';
    DDR2_SDRAM_16Mx32_DDR2_RAS_N   <= '1';
    Ethernet_MAC_PHY_rst_n         <= '1';
    Ethernet_MAC_PHY_tx_data       <= (others => '0');
    Ethernet_MAC_PHY_tx_en         <= '0';
    Ethernet_MAC_DUMMY_ETH_TXER    <= '0';
    Ethernet_MAC_PHY_Mii_clk       <= '1';
    SysACE_CompactFlash_SysACE_CEN <= '1';
    SysACE_CompactFlash_SysACE_OEN <= '1';
    SysACE_CompactFlash_SysACE_WEN <= '1';
    SysACE_CompactFlash_SysACE_MPA <= (others => '0');


    -- small function:
    GPIO_LED_out <= GPIO_DIPswitch_in when GPIO_button_in(0) = '0' else not GPIO_DIPswitch_in;

end architecture rtl;

