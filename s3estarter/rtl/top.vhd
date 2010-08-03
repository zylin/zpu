-----------------------------------------------------
-- SPARTAN-3E STARTER KIT BOARD
-- top
-- contains buffers (iobuf, bufg, iobufds etc.)
-----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


entity top is
    port (
        -- ==== Analog-to-Digital Converter (ADC) ====
        -- some connections shared with SPI Flash, DAC, ADC, and AMP
        AD_CONV         : out   std_logic;

        -- ==== Programmable Gain Amplifier (AMP) ====
        -- some connections shared with SPI Flash, DAC, ADC, and AMP
        AMP_CS          : out   std_logic; -- active low chip select
        AMP_DOUT        : in    std_logic;
        AMP_SHDN        : out   std_logic; -- active high shutdown, reset

        -- ==== Pushbuttons (BTN) ====
        BTN_EAST        : in    std_logic;
        BTN_NORTH       : in    std_logic;
        BTN_SOUTH       : in    std_logic;
        BTN_WEST        : in    std_logic;

        -- ==== Clock inputs (CLK) ====
        CLK_50MHZ       : in    std_logic;
                                
        CLK_AUX         : in    std_logic;
        CLK_SMA         : in    std_logic;

        -- ==== Digital-to-Analog Converter (DAC) ====
        -- some connections shared with SPI Flash, DAC, ADC, and AMP
        DAC_CLR         : out   std_logic; -- async, active low reset input
        DAC_CS          : out   std_logic; -- active low chip select, conv start with rising edge

        -- ==== 1-Wire Secure EEPROM (DS)
        DS_WIRE         : inout std_logic;

        -- ==== Ethernet PHY (E) ====
        E_COL           : in    std_logic; -- MII collision detect
        E_CRS           : in    std_logic; -- carrier sense
        E_MDC           : out   std_logic; -- management clock
        E_MDIO          : inout std_logic; -- management data IO
        E_RX_CLK        : in    std_logic; -- receive clock 25MHz@100BaseTx or 2.5MHz@10Base-T
        E_RX_DV         : in    std_logic; -- receive data valid
        E_RXD           : in    std_logic_vector(4 downto 0);
        E_TX_CLK        : in    std_logic; -- transmit clock 25MHz@100BaseTx or 2.5MHz@10Base-T
        E_TX_EN         : out   std_logic; -- transmit enable
        E_TXD           : out   std_logic_vector(4 downto 0);

        -- ==== FPGA Configuration Mode, INIT_B Pins (FPGA) ====
        FPGA_M0         : inout std_logic;
        FPGA_M1         : inout std_logic;
        FPGA_M2         : inout std_logic;
        FPGA_INIT_B     : inout std_logic;
        FPGA_RDWR_B     : inout std_logic;
        FPGA_HSWAP      : inout std_logic;

        -- ==== FX2 Connector (FX2) ====
        FX2_CLKIN       : inout std_logic;
        FX2_CLKIO       : inout std_logic;
        FX2_CLKOUT      : inout std_logic;

        -- These four connections are shared with the J1 6-pin accessory header
        --FX2_IO          : inout std_ulogic_vector(4 downto 1);

        -- These four connections are shared with the J2 6-pin accessory header
        --FX2_IO          : inout std_ulogic_vector(8 downto 5);

        -- These four connections are shared with the J4 6-pin accessory header
        --FX2_IO          : inout std_ulogic_vector(12 downto 9);

        -- The discrete LEDs are shared with the following 8 FX2 connections
        --FX2_IO          : inout std_ulogic_vector(20 downto 13);

        --FX2_IO            : inout std_ulogic_vector(34 downto 21);
        --FX2_IO            : in    std_ulogic_vector(38 downto 35);
        --FX2_IO            : inout std_ulogic_vector(39 downto 39);
        --FX2_IO            : in    std_ulogic_vector(40 downto 40);

        -- ==== 6-pin header J1 ====
        -- These are shared connections with the FX2 connector
        J1              : inout std_logic_vector(3 downto 0);

        -- ==== 6-pin header J2 ====
        -- These are shared connections with the FX2 connector
        J2              : inout std_logic_vector(3 downto 0);

        -- ==== 6-pin header J4 ====
        -- These are shared connections with the FX2 connector
        J4              : inout std_logic_vector(3 downto 0);

        -- ==== Character LCD (LCD) ====
        LCD_E           : out   std_logic;
        LCD_RS          : out   std_logic;
        LCD_RW          : out   std_logic;

        -- LCD data connections are shared with StrataFlash connections SF_D<11:8>
        --SF_D          : inout std_ulogic_vector(11 downto 8);

        -- ==== Discrete LEDs (LED) ====
        -- These are shared connections with the FX2 connector
        LED             : out   std_logic_vector(7 downto 0);

        -- ==== PS/2 Mouse/Keyboard Port (PS2) ====
        PS2_CLK         : inout std_logic;
        PS2_DATA        : inout std_logic;

        -- ==== Rotary Pushbutton Switch (ROT) ====
        ROT_A           : in    std_logic;
        ROT_B           : in    std_logic;
        ROT_CENTER      : in    std_logic;

        -- ==== RS-232 Serial Ports (RS232) ====
        RS232_DCE_RXD   : in    std_logic;
        RS232_DCE_TXD   : out   std_logic;
        RS232_DTE_RXD   : in    std_logic;
        RS232_DTE_TXD   : out   std_logic;

        -- ==== DDR SDRAM (SD) ==== (I/O Bank 3, VCCO=2.5V)
        SD_A            : inout std_logic_vector(12 downto 0); -- address inputs
        SD_DQ           : inout std_logic_vector(15 downto 0); -- data IO
        SD_BA           : out   std_logic_vector(1 downto 0);  -- bank address inputs
        SD_RAS          : out   std_logic;                     -- command output
        SD_CAS          : out   std_logic;                     -- command output
        SD_WE           : out   std_logic;                     -- command output 
        SD_UDM          : out   std_logic;                     -- data mask
        SD_LDM          : out   std_logic;                     -- data mask
        SD_UDQS         : in    std_logic;                     -- data strobe
        SD_LDQS         : in    std_logic;                     -- data strobe
        SD_CS           : out   std_logic;                     -- active low chip select
        SD_CKE          : out   std_logic;                     -- active high clock enable
        SD_CK_N         : out   std_logic;                     -- differential clock
        SD_CK_P         : out   std_logic;                     -- differential clock

        -- Path to allow connection to top DCM connection
        SD_CK_FB        : in    std_logic;

        -- ==== Intel StrataFlash Parallel NOR Flash (SF) ====
        SF_A            : out   std_logic_vector(24 downto 0);
        SF_BYTE         : out   std_logic;
        SF_CE0          : out   std_logic;
        SF_D            : inout std_logic_vector(15 downto 1);
        SF_OE           : out   std_logic;
        SF_STS          : in    std_logic;
        SF_WE           : out   std_logic;

        -- ==== STMicro SPI serial Flash (SPI) ====
        -- some connections shared with SPI Flash, DAC, ADC, and AMP
        SPI_MOSI        : out   std_logic; -- master out slave in
        SPI_MISO        : in    std_logic; -- master in  slave out
        SPI_SCK         : out   std_logic; -- clock
        SPI_SS_B        : out   std_logic; -- active low slave select

        SPI_ALT_CS_JP11 : out   std_logic;

        -- ==== Slide Switches (SW) ====
        SW              : in    std_logic_vector(3 downto 0);

        -- ==== VGA Port (VGA) ====
        VGA_BLUE        : out   std_logic;
        VGA_GREEN       : out   std_logic;
        VGA_HSYNC       : out   std_logic;
        VGA_RED         : out   std_logic;
        VGA_VSYNC       : out   std_logic;

        -- ==== Xilinx CPLD (XC) ====
        XC_CMD          : out   std_logic_vector(1 downto 0);
        XC_CPLD_EN      : out   std_logic;
        XC_D            : inout std_logic_vector(2 downto 0);
        XC_TRIG         : in    std_logic;
        XC_GCK0         : inout std_logic;
        GCLK10          : inout std_logic
    );
end entity top;


library s3estarter;
use s3estarter.types.all;
use s3estarter.fpga_components.box;

library gaisler;
use gaisler.misc.all; -- types
use gaisler.uart.all; -- types


architecture rtl of top is

    constant spi_ss_b_disable    : std_ulogic := '1';
    constant dac_cs_disable      : std_ulogic := '1';
    constant amp_cs_disable      : std_ulogic := '1';
    constant ad_conv_disable     : std_ulogic := '0';
    constant sf_ce0_disable      : std_ulogic := '1';
    constant fpga_init_b_disable : std_ulogic := '1';

    -- connect ldc to fpga
    constant sf_ce0_lcd_to_fpga  : std_ulogic := '1';
    constant lcd_rw_lcd_to_fpga  : std_ulogic := '1';


    signal top_fpga_clk        : fpga_clk_in_t;
    signal top_fpga_rotary_sw  : fpga_rotary_sw_in_t;
    
    signal box_i0_fpga_led     : fpga_led_out_t;
            
    signal top_fpga_uarti      : uart_in_type;
    signal box_i0_uarto        : uart_out_type;
    
    signal top_fpga_gpioi      : gpio_in_type;
    signal box_i0_gpioo        : gpio_out_type;

    signal break               : std_ulogic;

begin
    
    -- drive unused outputs
    AD_CONV         <= ad_conv_disable;
    AMP_CS          <= amp_cs_disable;
    AMP_SHDN        <= '1'; 
                    
    DAC_CLR         <= '0';
    DAC_CS          <= dac_cs_disable;
                    
    DS_WIRE         <= 'Z';
                    
    E_MDC           <= '0';
    E_MDIO          <= 'Z';
    E_TX_EN         <= '0';
    E_TXD           <= (others => '0');
                    
    LCD_E           <= '0';
    LCD_RS          <= '0';
    LCD_RW          <= '0';
                    
    RS232_DTE_TXD   <= '0';
                    
    SD_BA           <= "00";
    SD_RAS          <= '0';
    SD_CAS          <= '0';
    SD_WE           <= '1';
    SD_UDM          <= '0';
    SD_LDM          <= '0';
    SD_CS           <= '1'; 
    SD_CKE          <= '0';
    SD_CK_N         <= '0';
    SD_CK_P         <= '1';
                    
    SF_A            <= (others => '0');
    SF_BYTE         <= '0';
    SF_CE0          <= sf_ce0_lcd_to_fpga;
    SF_OE           <= '1';
    SF_WE           <= '0';
                    
    SPI_MOSI        <= '0';
    SPI_SCK         <= '0';
    SPI_SS_B        <= spi_ss_b_disable;
    SPI_ALT_CS_JP11 <= spi_ss_b_disable;
    
    VGA_RED         <= '0';
    VGA_GREEN       <= '0';
    VGA_BLUE        <= '0';
    VGA_HSYNC       <= '0';
    VGA_VSYNC       <= '0';

    XC_CMD          <= "00";
    XC_CPLD_EN      <= '0';

    top_fpga_clk.clk50        <= CLK_50MHZ;
    top_fpga_clk.aux          <= CLK_AUX;
    top_fpga_clk.sma          <= CLK_SMA;

    top_fpga_rotary_sw.a      <= ROT_A; 
    top_fpga_rotary_sw.b      <= ROT_B;
    top_fpga_rotary_sw.center <= ROT_CENTER;

    -- connetions for uart
    top_fpga_uarti.rxd        <= RS232_DCE_RXD; 
    top_fpga_uarti.ctsn       <= '0';
    top_fpga_uarti.extclk     <= '0';
    RS232_DCE_TXD             <= box_i0_uarto.txd;
    
    
    -- pads for gpio (buttons i)
    top_fpga_gpioi.sig_in           <= (others => '0');
    top_fpga_gpioi.sig_en           <= (others => '0');
    top_fpga_gpioi.din( 3 downto 0) <= SW;
    top_fpga_gpioi.din( 7 downto 4) <= BTN_WEST & BTN_NORTH & BTN_SOUTH & BTN_EAST;
    top_fpga_gpioi.din(31 downto 8) <= (others => '0');

    box_i0: box
        port map (
            fpga_clk        => top_fpga_clk,        -- : in    fpga_clk_in_t;
            fpga_rotary_sw  => top_fpga_rotary_sw,  -- : in    fpga_rotary_sw_in_t;

            uarti           => top_fpga_uarti,      -- : in    uart_in_type
            uarto           => box_i0_uarto,       -- : out   uart_out_type

            gpioi           => top_fpga_gpioi,      -- : in    gpio_in_type;
            gpioo           => box_i0_gpioo,       -- : out   gpio_out_type;

            break           => break                -- : out   cpu break command
        );

    -- pads for gpio (led out)
    LED                   <= std_logic_vector( box_i0_gpioo.dout( 7 downto 0) );

    -- connections to logic analyzer pods
    J4                    <= std_logic_vector( box_i0_gpioo.dout( 3 downto 0) );
    J1                    <= std_logic_vector( box_i0_gpioo.dout( 7 downto 4) );
    J2                    <= top_fpga_clk.clk50 & (break) & "00";

      
    -- port map (gpio(i), gpioo.dout(i), gpioo.oen(i), gpioi.din(i))
    -- port (pad : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic)

    -- pad <= i when en = '0' else 'Z' after 2 ns;
    -- o   <= to_X01(pad) after 1 ns;

end architecture rtl;
