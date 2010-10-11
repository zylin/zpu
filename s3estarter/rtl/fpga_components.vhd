
library ieee;
use ieee.std_logic_1164.all;

library s3estarter;
use s3estarter.types.all;

library global;
use global.global_signals.all;

library grlib;
use grlib.amba.all;

library gaisler;
use gaisler.misc.all; -- types
use gaisler.uart.all; -- types
use gaisler.net.all;  -- types

package fpga_components is

    
    component box is
        port (
            fpga_clk        : in    fpga_clk_in_t;
            fpga_rotary_sw  : in    fpga_rotary_sw_in_t;
            
            uarti           : in    uart_in_type;
            uarto           : out   uart_out_type;
    
            gpioi           : in    gpio_in_type;
            gpioo           : out   gpio_out_type;

            ethi            : in    eth_in_type;
            etho            : out   eth_out_type;

            vgao            : out   apbvga_out_type;

            ddr_clk         : out   std_logic_vector(2 downto 0);
            ddr_clkb        : out   std_logic_vector(2 downto 0);
            ddr_clk_fb      : in    std_logic;
            ddr_clk_fb_out  : out   std_logic;
            ddr_cke         : out   std_logic_vector(1 downto 0);
            ddr_csb         : out   std_logic_vector(1 downto 0);
            ddr_web         : out   std_ulogic;                     -- ddr write enable
            ddr_rasb        : out   std_ulogic;                     -- ddr ras
            ddr_casb        : out   std_ulogic;                     -- ddr cas
            ddr_dm          : out   std_logic_vector (1 downto 0);  -- ddr dm
            ddr_dqs         : inout std_logic_vector (1 downto 0);  -- ddr dqs
            ddr_ad          : out   std_logic_vector (13 downto 0); -- ddr address
            ddr_ba          : out   std_logic_vector (1 downto 0);  -- ddr bank address
            ddr_dq          : inout std_logic_vector (15 downto 0); -- ddr data

            debug_trace     : out   debug_signals_t;
            debug_trace_box : out   debug_signals_t;
            debug_trace_dcm : out   debug_signals_t;
            -- to stop simulation
            break           : out   std_ulogic
        );
    end component box;



    component clk_gen is
        port (
            clk        : in  std_ulogic;
            arst       : in  std_ulogic;
            --
            clk_100MHz : out std_ulogic;
            clk_50MHz  : out std_ulogic;
            clk_25MHz  : out std_ulogic;
            clk_ready  : out std_ulogic;
            --
            psdone     : out std_ulogic;
            psovfl     : out std_ulogic;
            psen       : in  std_ulogic;
            psincdec   : in  std_ulogic
        );
    end component clk_gen;



    
    component top is
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
            E_RXD           : in    std_logic_vector(3 downto 0);
            E_RX_ER         : in    std_logic;
            E_TX_CLK        : in    std_logic; -- transmit clock 25MHz@100BaseTx or 2.5MHz@10Base-T
            E_TX_EN         : out   std_logic; -- transmit enable
            E_TXD           : out   std_logic_vector(3 downto 0);
            E_TX_ER         : out   std_logic;

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
            FX2_IO          : inout std_ulogic_vector(40 downto 1);

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
            --J1              : inout std_logic_vector(3 downto 0);

            -- ==== 6-pin header J2 ====
            -- These are shared connections with the FX2 connector
            --J2              : inout std_logic_vector(3 downto 0);

            -- ==== 6-pin header J4 ====
            -- These are shared connections with the FX2 connector
            --J4              : inout std_logic_vector(3 downto 0);

            -- ==== Character LCD (LCD) ====
            LCD_E           : out   std_logic;
            LCD_RS          : out   std_logic;
            LCD_RW          : out   std_logic;

            -- LCD data connections are shared with StrataFlash connections SF_D<11:8>
            --SF_D          : inout std_ulogic_vector(11 downto 8);

            -- ==== Discrete LEDs (LED) ====
            -- These are shared connections with the FX2 connector
            --LED             : out   std_logic_vector(7 downto 0);

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
            SD_A            : out   std_logic_vector(12 downto 0); -- address inputs
            SD_DQ           : inout std_logic_vector(15 downto 0); -- data IO
            SD_BA           : out   std_logic_vector(1 downto 0);  -- bank address inputs
            SD_RAS          : out   std_logic;                     -- command output
            SD_CAS          : out   std_logic;                     -- command output
            SD_WE           : out   std_logic;                     -- command output 
            SD_UDM          : out   std_logic;                     -- data mask
            SD_LDM          : out   std_logic;                     -- data mask
            SD_UDQS         : inout std_logic;                     -- data strobe
            SD_LDQS         : inout std_logic;                     -- data strobe
            SD_CS           : out   std_logic;                     -- active low chip select
            SD_CKE          : out   std_logic;                     -- active high clock enable
            SD_CK_N         : out   std_logic;                     -- differential clock
            SD_CK_P         : out   std_logic;                     -- differential clock

            -- Path to allow connection to top DCM connection
            SD_CK_FB        : in    std_logic;

            -- ==== Intel StrataFlash Parallel NOR Flash (SF) ====
            SF_A            : out   std_logic_vector(23 downto 0);
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
    end component top;


    component dcm_ctrl_apb is
      generic (
        pindex   : integer := 0;
        paddr    : integer := 0;
        pmask    : integer := 16#fff#
      );
      port (
        rst_n           : in  std_ulogic;
        clk             : in  std_ulogic;
        apbi            : in  apb_slv_in_type;
        apbo            : out apb_slv_out_type;
                        
        psdone          : in  std_ulogic;
        psovfl          : in  std_ulogic;
        psen            : out std_ulogic;
        psincdec        : out std_ulogic;
            
        debug_trace     : out   debug_signals_t
      );
    end component dcm_ctrl_apb;


end package fpga_components;
