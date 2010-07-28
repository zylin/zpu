
library ieee;
use ieee.std_logic_1164.all;

library s3estarter;
use s3estarter.types.all;


package fpga_components is

    
    component ibox is
        port (
            clk             : in    std_ulogic;
            reset           : in    std_ulogic;

            fpga_button     : in    fpga_button_in_t;
            fpga_led        : out   fpga_led_out_t;
            fpga_rotary_sw  : in    fpga_rotary_sw_in_t
        );
    end component ibox;

    component obox is
        port (
            fpga_button     : in    fpga_button_in_t;
            fpga_clk        : in    fpga_clk_in_t;
            fpga_led        : out   fpga_led_out_t;
            fpga_rotary_sw  : in    fpga_rotary_sw_in_t
        );
    end component obox;

    
    component top is
        port (
            -- ==== Analog-to-Digital Converter (ADC) ====
            -- some connections shared with SPI Flash, DAC, ADC, and AMP
            AD_CONV         : inout std_logic;

            -- ==== Programmable Gain Amplifier (AMP) ====
            -- some connections shared with SPI Flash, DAC, ADC, and AMP
            AMP_CS          : inout std_logic;
            AMP_DOUT        : inout std_logic;
            AMP_SHDN        : inout std_logic;

            -- ==== Pushbuttons (BTN) ====
            BTN_EAST        : inout std_logic;
            BTN_NORTH       : inout std_logic;
            BTN_SOUTH       : inout std_logic;
            BTN_WEST        : inout std_logic;

            -- ==== Clock inputs (CLK) ====
            CLK_50MHZ       : in std_logic;
                          
            CLK_AUX         : in std_logic;
            CLK_SMA         : in std_logic;

            -- ==== Digital-to-Analog Converter (DAC) ====
            -- some connections shared with SPI Flash, DAC, ADC, and AMP
            DAC_CLR         : inout std_logic;
            DAC_CS          : inout std_logic;

            -- ==== 1-Wire Secure EEPROM (DS)
            DS_WIRE         : inout std_logic;

            -- ==== Ethernet PHY (E) ====
            E_COL           : inout std_logic;
            E_CRS           : inout std_logic;
            E_MDC           : inout std_logic;
            E_MDIO          : inout std_logic;
            E_RX_CLK        : inout std_logic;
            E_RX_DV         : inout std_logic;
            E_RXD           : inout std_logic_vector(4 downto 0);
            E_TX_CLK        : inout std_logic;
            E_TX_EN         : inout std_logic;
            E_TXD           : inout std_logic_vector(4 downto 0);

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
            --FX2_IO          : inout std_logic_vector(4 downto 1);

            -- These four connections are shared with the J2 6-pin accessory header
            --FX2_IO          : inout std_logic_vector(8 downto 5);

            -- These four connections are shared with the J4 6-pin accessory header
            --FX2_IO          : inout std_logic_vector(12 downto 9);

            -- The discrete LEDs are shared with the following 8 FX2 connections
            --FX2_IO        : inout std_logic_vector(20 downto 13);
            --FX2_IO          : inout std_logic_vector(40 downto 21);
            FX2_IO          : inout std_logic_vector(40 downto 0);

            -- ==== 6-pin header J1 ====
            -- These are shared connections with the FX2 connector
            --J1            : inout std_logic_vector(3 downto 0);

            -- ==== 6-pin header J2 ====
            -- These are shared connections with the FX2 connector
            --J2            : inout std_logic_vector(3 downto 0);

            -- ==== 6-pin header J4 ====
            -- These are shared connections with the FX2 connector
            --J4            : inout std_logic_vector(3 downto 0);

            -- ==== Character LCD (LCD) ====
            LCD_E           : inout std_logic;
            LCD_RS          : inout std_logic;
            LCD_RW          : inout std_logic;

            -- LCD data connections are shared with StrataFlash connections SF_D<11:8>
            --SF_D          : inout std_logic_vector(11 downto 8);

            -- ==== Discrete LEDs (LED) ====
            -- These are shared connections with the FX2 connector
            LED             : inout std_logic_vector(7 downto 0);

            -- ==== PS/2 Mouse/Keyboard Port (PS2) ====
            PS2_CLK         : inout std_logic;
            PS2_DATA        : inout std_logic;

            -- ==== Rotary Pushbutton Switch (ROT) ====
            ROT_A           : in    std_logic;
            ROT_B           : in    std_logic;
            ROT_CENTER      : in    std_logic;

            -- ==== RS-232 Serial Ports (RS232) ====
            RS232_DCE_RXD   : inout std_logic;
            RS232_DCE_TXD   : inout std_logic;
            RS232_DTE_RXD   : inout std_logic;
            RS232_DTE_TXD   : inout std_logic;

            -- ==== DDR SDRAM (SD) ==== (I/O Bank 3, VCCO=2.5V)
            SD_A            : inout std_logic_vector(12 downto 0);
            SD_BA           : inout std_logic_vector(1 downto 0);
            SD_CAS          : inout std_logic;
            SD_CK_N         : inout std_logic;
            SD_CK_P         : inout std_logic;
            SD_CKE          : inout std_logic;
            SD_CS           : inout std_logic;
            SD_DQ           : inout std_logic_vector(15 downto 0);
            SD_LDM          : inout std_logic;
            SD_LDQS         : inout std_logic;
            SD_RAS          : inout std_logic;
            SD_UDM          : inout std_logic;
            SD_UDQS         : inout std_logic;
            SD_WE           : inout std_logic;

            -- Path to allow connection to top DCM connection
            SD_CK_FB        : inout std_logic;

            -- ==== Intel StrataFlash Parallel NOR Flash (SF) ====
            SF_A            : inout std_logic_vector(24 downto 0);
            SF_BYTE         : inout std_logic;
            SF_CE0          : inout std_logic;
            SF_D            : inout std_logic_vector(15 downto 1);
            SF_OE           : inout std_logic;
            SF_STS          : inout std_logic;
            SF_WE           : inout std_logic;

            -- ==== STMicro SPI serial Flash (SPI) ====
            -- some connections shared with SPI Flash, DAC, ADC, and AMP
            SPI_MISO        : inout std_logic;
            SPI_MOSI        : inout std_logic;
            SPI_SCK         : inout std_logic;
            SPI_SS_B        : inout std_logic;
            SPI_ALT_CS_JP11 : inout std_logic;

            -- ==== Slide Switches (SW) ====
            SW              : inout std_logic_vector(3 downto 0);

            -- ==== VGA Port (VGA) ====
            VGA_BLUE        : inout std_logic;
            VGA_GREEN       : inout std_logic;
            VGA_HSYNC       : inout std_logic;
            VGA_RED         : inout std_logic;
            VGA_VSYNC       : inout std_logic;

            -- ==== Xilinx CPLD (XC) ====
            XC_CMD          : inout std_logic_vector(1 downto 0);
            XC_CPLD_EN      : inout std_logic;
            XC_D            : inout std_logic_vector(2 downto 0);
            XC_TRIG         : inout std_logic;
            XC_GCK0         : inout std_logic;
            GCLK10          : inout std_logic
        );
    end component top;

end package fpga_components;
