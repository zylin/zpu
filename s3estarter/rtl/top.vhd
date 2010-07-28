-----------------------------------------------------
--- SPARTAN-3E STARTER KIT BOARD
--- top
-----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


entity top is
    port (
        -- ==== Analog-to-Digital Converter (ADC) ====
        -- some connections shared with SPI Flash, DAC, ADC, and AMP
        AD_CONV         : inout std_ulogic;

        -- ==== Programmable Gain Amplifier (AMP) ====
        -- some connections shared with SPI Flash, DAC, ADC, and AMP
        AMP_CS          : inout std_ulogic;
        AMP_DOUT        : inout std_ulogic;
        AMP_SHDN        : inout std_ulogic;

        -- ==== Pushbuttons (BTN) ====
        BTN_EAST        : inout std_ulogic;
        BTN_NORTH       : inout std_ulogic;
        BTN_SOUTH       : inout std_ulogic;
        BTN_WEST        : inout std_ulogic;

        -- ==== Clock inputs (CLK) ====
        CLK_50MHZ       : in std_ulogic;
                      
        CLK_AUX         : in std_ulogic;
        CLK_SMA         : in std_ulogic;

        -- ==== Digital-to-Analog Converter (DAC) ====
        -- some connections shared with SPI Flash, DAC, ADC, and AMP
        DAC_CLR         : inout std_ulogic;
        DAC_CS          : inout std_ulogic;

        -- ==== 1-Wire Secure EEPROM (DS)
        DS_WIRE         : inout std_ulogic;

        -- ==== Ethernet PHY (E) ====
        E_COL           : inout std_ulogic;
        E_CRS           : inout std_ulogic;
        E_MDC           : inout std_ulogic;
        E_MDIO          : inout std_ulogic;
        E_RX_CLK        : inout std_ulogic;
        E_RX_DV         : inout std_ulogic;
        E_RXD           : inout std_ulogic_vector(4 downto 0);
        E_TX_CLK        : inout std_ulogic;
        E_TX_EN         : inout std_ulogic;
        E_TXD           : inout std_ulogic_vector(4 downto 0);

        -- ==== FPGA Configuration Mode, INIT_B Pins (FPGA) ====
        FPGA_M0         : inout std_ulogic;
        FPGA_M1         : inout std_ulogic;
        FPGA_M2         : inout std_ulogic;
        FPGA_INIT_B     : inout std_ulogic;
        FPGA_RDWR_B     : inout std_ulogic;
        FPGA_HSWAP      : inout std_ulogic;

        -- ==== FX2 Connector (FX2) ====
        FX2_CLKIN       : inout std_ulogic;
        FX2_CLKIO       : inout std_ulogic;
        FX2_CLKOUT      : inout std_ulogic;

        -- These four connections are shared with the J1 6-pin accessory header
        --FX2_IO          : inout std_ulogic_vector(4 downto 1);

        -- These four connections are shared with the J2 6-pin accessory header
        --FX2_IO          : inout std_ulogic_vector(8 downto 5);

        -- These four connections are shared with the J4 6-pin accessory header
        --FX2_IO          : inout std_ulogic_vector(12 downto 9);

        -- The discrete LEDs are shared with the following 8 FX2 connections
        --FX2_IO        : inout std_ulogic_vector(20 downto 13);
        --FX2_IO          : inout std_ulogic_vector(40 downto 21);
        FX2_IO          : inout std_ulogic_vector(40 downto 0);

        -- ==== 6-pin header J1 ====
        -- These are shared connections with the FX2 connector
        --J1            : inout std_ulogic_vector(3 downto 0);

        -- ==== 6-pin header J2 ====
        -- These are shared connections with the FX2 connector
        --J2            : inout std_ulogic_vector(3 downto 0);

        -- ==== 6-pin header J4 ====
        -- These are shared connections with the FX2 connector
        --J4            : inout std_ulogic_vector(3 downto 0);

        -- ==== Character LCD (LCD) ====
        LCD_E           : inout std_ulogic;
        LCD_RS          : inout std_ulogic;
        LCD_RW          : inout std_ulogic;

        -- LCD data connections are shared with StrataFlash connections SF_D<11:8>
        --SF_D          : inout std_ulogic_vector(11 downto 8);

        -- ==== Discrete LEDs (LED) ====
        -- These are shared connections with the FX2 connector
        LED             : inout std_ulogic_vector(7 downto 0);

        -- ==== PS/2 Mouse/Keyboard Port (PS2) ====
        PS2_CLK         : inout std_ulogic;
        PS2_DATA        : inout std_ulogic;

        -- ==== Rotary Pushbutton Switch (ROT) ====
        ROT_A           : inout std_ulogic;
        ROT_B           : inout std_ulogic;
        ROT_CENTER      : inout std_ulogic;

        -- ==== RS-232 Serial Ports (RS232) ====
        RS232_DCE_RXD   : inout std_ulogic;
        RS232_DCE_TXD   : inout std_ulogic;
        RS232_DTE_RXD   : inout std_ulogic;
        RS232_DTE_TXD   : inout std_ulogic;

        -- ==== DDR SDRAM (SD) ==== (I/O Bank 3, VCCO=2.5V)
        SD_A            : inout std_ulogic_vector(12 downto 0);
        SD_BA           : inout std_ulogic_vector(1 downto 0);
        SD_CAS          : inout std_ulogic;
        SD_CK_N         : inout std_ulogic;
        SD_CK_P         : inout std_ulogic;
        SD_CKE          : inout std_ulogic;
        SD_CS           : inout std_ulogic;
        SD_DQ           : inout std_ulogic_vector(15 downto 0);
        SD_LDM          : inout std_ulogic;
        SD_LDQS         : inout std_ulogic;
        SD_RAS          : inout std_ulogic;
        SD_UDM          : inout std_ulogic;
        SD_UDQS         : inout std_ulogic;
        SD_WE           : inout std_ulogic;

        -- Path to allow connection to top DCM connection
        SD_CK_FB        : inout std_ulogic;

        -- ==== Intel StrataFlash Parallel NOR Flash (SF) ====
        SF_A            : inout std_ulogic_vector(24 downto 0);
        SF_BYTE         : inout std_ulogic;
        SF_CE0          : inout std_ulogic;
        SF_D            : inout std_ulogic_vector(15 downto 1);
        SF_OE           : inout std_ulogic;
        SF_STS          : inout std_ulogic;
        SF_WE           : inout std_ulogic;

        -- ==== STMicro SPI serial Flash (SPI) ====
        -- some connections shared with SPI Flash, DAC, ADC, and AMP
        SPI_MISO        : inout std_ulogic;
        SPI_MOSI        : inout std_ulogic;
        SPI_SCK         : inout std_ulogic;
        SPI_SS_B        : inout std_ulogic;
        SPI_ALT_CS_JP11 : inout std_ulogic;

        -- ==== Slide Switches (SW) ====
        SW              : inout std_ulogic_vector(3 downto 0);

        -- ==== VGA Port (VGA) ====
        VGA_BLUE        : inout std_ulogic;
        VGA_GREEN       : inout std_ulogic;
        VGA_HSYNC       : inout std_ulogic;
        VGA_RED         : inout std_ulogic;
        VGA_VSYNC       : inout std_ulogic;

        -- ==== Xilinx CPLD (XC) ====
        XC_CMD          : inout std_ulogic_vector(1 downto 0);
        XC_CPLD_EN      : inout std_ulogic;
        XC_D            : inout std_ulogic_vector(2 downto 0);
        XC_TRIG         : inout std_ulogic;
        XC_GCK0         : inout std_ulogic;
        GCLK10          : inout std_ulogic
    );
end entity top;



library s3estarter;
use s3estarter.types.all;


architecture rtl of top is

    component obox is
        port (
            fpga_button     : in    fpga_button_in_t;
            fpga_clk        : in    fpga_clk_in_t;
            fpga_led        : out   fpga_led_out_t 
        );
    end component obox;

    signal top_fpga_button     : fpga_button_in_t;
    signal top_fpga_clk        : fpga_clk_in_t;
    
    signal obox_i0_fpga_led    : fpga_led_out_t;

begin

    top_fpga_button.east  <= BTN_EAST;
    top_fpga_button.north <= BTN_NORTH;
    top_fpga_button.south <= BTN_SOUTH;
    top_fpga_button.west  <= BTN_WEST;

    top_fpga_clk.clk50    <= CLK_50MHZ;
    top_fpga_clk.aux      <= CLK_AUX;
    top_fpga_clk.sma      <= CLK_SMA;

    obox_i0: obox
        port map (
            fpga_button => top_fpga_button,         -- : in    fpga_button_in_t;
            fpga_clk    => top_fpga_clk,            -- : in    fpga_clk_in_t;
            fpga_led    => obox_i0_fpga_led         -- : out   fpga_led_out_t 
        );

    LED                   <= obox_i0_fpga_led.data;

end architecture rtl;
