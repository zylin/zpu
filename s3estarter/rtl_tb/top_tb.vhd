entity top_tb is
end entity top_tb;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library s3estarter;
use s3estarter.fpga_components.top;

library global;
use global.global_signals.all;


architecture testbench of top_tb is
    
    

    constant tb_clk_period     : time := (1 sec / 50_000_000);

    type     memory_model_t is (gaisler, micron);

    --constant memory_model      : memory_model_t := micron; -- isim
    constant memory_model      : memory_model_t := gaisler; -- modelsim

    signal   simulation_run    : boolean := true;

    signal   tb_RESET          : std_ulogic;
    signal   tb_RESET_n        : std_ulogic;

    -- ==== Analog-to-Digital Converter (ADC) ====
    -- some connections shared with SPI Flash, DAC, ADC, and AMP
    signal   tb_AD_CONV        : std_logic;

    -- ==== Programmable Gain Amplifier (AMP) ====
    -- some connections shared with SPI Flash, DAC, ADC, and AMP
    signal   tb_AMP_CS         : std_logic;
    signal   tb_AMP_DOUT       : std_logic;
    signal   tb_AMP_SHDN       : std_logic;

    -- ==== Pushbuttons (BTN) ====
    signal   tb_BTN_EAST       : std_logic;
    signal   tb_BTN_NORTH      : std_logic;
    signal   tb_BTN_SOUTH      : std_logic;
    signal   tb_BTN_WEST       : std_logic;

    -- ==== Clock inputs (CLK) ====
    signal   tb_CLK_50MHZ      : std_logic := '0';
                           
    signal   tb_CLK_AUX        : std_logic := '0';
    signal   tb_CLK_SMA        : std_logic := '0';

    -- ==== Digital-to-Analog Converter (DAC) ====
    -- some connections shared with SPI Flash, DAC, ADC, and AMP
    signal   tb_DAC_CLR        : std_logic;
    signal   tb_DAC_CS         : std_logic;

    -- ==== 1-Wire Secure EEPROM (DS)
    signal   tb_DS_WIRE        : std_logic;

    -- ==== Ethernet PHY (E) ====
    signal   tb_E_COL          : std_logic;
    signal   tb_E_CRS          : std_logic;
    signal   tb_E_MDC          : std_logic;
    signal   tb_E_MDIO         : std_logic;
    signal   tb_E_RX_CLK       : std_logic;
    signal   tb_E_RX_DV        : std_logic;
    signal   tb_E_RXD          : std_logic_vector(7 downto 0);
    signal   tb_E_RX_ER        : std_logic;
    signal   tb_E_TX_CLK       : std_logic;
    signal   tb_E_TX_EN        : std_logic;
    signal   tb_E_TXD          : std_logic_vector(7 downto 0) := (others => '0');
    signal   tb_E_TX_ER        : std_logic;

    -- ==== FPGA Configuration Mode, INIT_B Pins (FPGA) ====
    signal   tb_FPGA_M0        : std_logic;
    signal   tb_FPGA_M1        : std_logic;
    signal   tb_FPGA_M2        : std_logic;
    signal   tb_FPGA_INIT_B    : std_logic;
    signal   tb_FPGA_RDWR_B    : std_logic;
    signal   tb_FPGA_HSWAP     : std_logic;

    -- ==== FX2 Connector (FX2) ====
    signal   tb_FX2_CLKIN      : std_logic;
    signal   tb_FX2_CLKIO      : std_logic;
    signal   tb_FX2_CLKOUT     : std_logic;

    -- These four connections are shared with the J1 6-pin accessory header
    --FX2_IO          : inout std_logic_vector(4 downto 1);

    -- These four connections are shared with the J2 6-pin accessory header
    --FX2_IO          : inout std_logic_vector(8 downto 5);

    -- These four connections are shared with the J4 6-pin accessory header
    --FX2_IO          : inout std_logic_vector(12 downto 9);

    -- The discrete LEDs are shared with the following 8 FX2 connections
    --FX2_IO        : inout std_logic_vector(20 downto 13);
    --FX2_IO          : inout std_logic_vector(40 downto 21);
    signal  tb_FX2_IO          : std_logic_vector(40 downto 1);

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
    signal  tb_LCD_E           : std_logic;
    signal  tb_LCD_RS          : std_logic;
    signal  tb_LCD_RW          : std_logic;

    -- LCD data connections are shared with StrataFlash connections SF_D<11:8>
    --SF_D          : inout std_logic_vector(11 downto 8);

    -- ==== Discrete LEDs (LED) ====
    -- These are shared connections with the FX2 connector
    signal  tb_LED             : std_logic_vector(7 downto 0);

    -- ==== PS/2 Mouse/Keyboard Port (PS2) ====
    signal  tb_PS2_CLK         : std_logic;
    signal  tb_PS2_DATA        : std_logic;

    -- ==== Rotary Pushbutton Switch (ROT) ====
    signal  tb_ROT_A           : std_logic;
    signal  tb_ROT_B           : std_logic;
    signal  tb_ROT_CENTER      : std_logic;

    -- ==== RS-232 Serial Ports (RS232) ====
    signal  tb_RS232_DCE_RXD   : std_logic;
    signal  tb_RS232_DCE_TXD   : std_logic;
    signal  tb_RS232_DTE_RXD   : std_logic;
    signal  tb_RS232_DTE_TXD   : std_logic;

    -- ==== DDR SDRAM (SD) ==== (I/O Bank 3, VCCO=2.5V)
    signal  tb_SD_A            : std_logic_vector(12 downto 0);
    signal  tb_SD_BA           : std_logic_vector(1 downto 0);
    signal  tb_SD_CAS          : std_logic;
    signal  tb_SD_CK_N         : std_logic;
    signal  tb_SD_CK_P         : std_logic;
    signal  tb_SD_CKE          : std_logic;
    signal  tb_SD_CS           : std_logic;
    signal  tb_SD_DQ           : std_logic_vector(15 downto 0);
    signal  tb_SD_LDM          : std_logic;
    signal  tb_SD_LDQS         : std_logic;
    signal  tb_SD_RAS          : std_logic;
    signal  tb_SD_UDM          : std_logic;
    signal  tb_SD_UDQS         : std_logic;
    signal  tb_SD_WE           : std_logic;
    -- additional form combining signals
    signal tb_SD_DM            : std_logic_vector(1 downto 0);
    signal tb_SD_DQS           : std_logic_vector(1 downto 0);

    -- Path to allow connection to top DCM connection
    signal  tb_SD_CK_FB        : std_logic;

    -- ==== Intel StrataFlash Parallel NOR Flash (SF) ====
    signal  tb_SF_A            : std_logic_vector(24 downto 0);
    signal  tb_SF_BYTE         : std_logic;
    signal  tb_SF_CE0          : std_logic;
    signal  tb_SF_D            : std_logic_vector(15 downto 1);
    signal  tb_SF_OE           : std_logic;
    signal  tb_SF_STS          : std_logic;
    signal  tb_SF_WE           : std_logic;

    -- ==== STMicro SPI serial Flash (SPI) ====
    -- some connections shared with SPI Flash, DAC, ADC, and AMP
    signal  tb_SPI_MISO        : std_logic;
    signal  tb_SPI_MOSI        : std_logic;
    signal  tb_SPI_SCK         : std_logic;
    signal  tb_SPI_SS_B        : std_logic;
    signal  tb_SPI_ALT_CS_JP11 : std_logic;

    -- ==== Slide Switches (SW) ====
    signal  tb_SW              : std_logic_vector(3 downto 0);

    -- ==== VGA Port (VGA) ====
    signal  tb_VGA_BLUE        : std_logic;
    signal  tb_VGA_GREEN       : std_logic;
    signal  tb_VGA_HSYNC       : std_logic;
    signal  tb_VGA_RED         : std_logic;
    signal  tb_VGA_VSYNC       : std_logic;

    -- ==== Xilinx CPLD (XC) ====
    signal  tb_XC_CMD          : std_logic_vector(1 downto 0);
    signal  tb_XC_CPLD_EN      : std_logic;
    signal  tb_XC_D            : std_logic_vector(2 downto 0);
    signal  tb_XC_TRIG         : std_logic;
    signal  tb_XC_GCK0         : std_logic;
    signal  tb_GCLK10          : std_logic;


    -- extra phy signal
    signal  tb_GTX_CLK         : std_ulogic;


begin

    tb_CLK_50MHZ  <= not tb_CLK_50MHZ after tb_clk_period/2 when simulation_run;
    tb_RESET      <= '1', '0' after 10 * tb_clk_period;
    tb_RESET_n    <= not tb_RESET;

    tb_ROT_CENTER <= tb_RESET;
    tb_ROT_A      <= '0';
    tb_ROT_B      <= '0';
    
    tb_BTN_EAST   <= '0';
    tb_BTN_NORTH  <= '0';
    tb_BTN_SOUTH  <= '0';
    tb_BTN_WEST   <= '0', '1' after 600 us, '0' after 650 us;


    tb_SD_CK_FB   <= transport tb_SD_CK_P after 3 ns; -- time is wild guess
        
    top_i0: top
        port map (
            AD_CONV         => tb_AD_CONV         , -- : inout std_ulogic;

            AMP_CS          => tb_AMP_CS          , -- : inout std_ulogic;
            AMP_DOUT        => tb_AMP_DOUT        , -- : inout std_ulogic;
            AMP_SHDN        => tb_AMP_SHDN        , -- : inout std_ulogic;

            BTN_EAST        => tb_BTN_EAST        , -- : inout std_ulogic;
            BTN_NORTH       => tb_BTN_NORTH       , -- : inout std_ulogic;
            BTN_SOUTH       => tb_BTN_SOUTH       , -- : inout std_ulogic;
            BTN_WEST        => tb_BTN_WEST        , -- : inout std_ulogic;

            CLK_50MHZ       => tb_CLK_50MHZ       , -- : in std_ulogic;

            CLK_AUX         => tb_CLK_AUX         , -- : in std_ulogic;
            CLK_SMA         => tb_CLK_SMA         , -- : in std_ulogic;

            DAC_CLR         => tb_DAC_CLR         , -- : inout std_ulogic;
            DAC_CS          => tb_DAC_CS          , -- : inout std_ulogic;

            DS_WIRE         => tb_DS_WIRE         , -- : inout std_ulogic;

            E_COL           => tb_E_COL           , -- : in    std_ulogic;
            E_CRS           => tb_E_CRS           , -- : in    std_ulogic;
            E_MDC           => tb_E_MDC           , -- : out   std_ulogic;
            E_MDIO          => tb_E_MDIO          , -- : inout std_ulogic;
            E_RX_CLK        => tb_E_RX_CLK        , -- : in    std_ulogic;
            E_RX_DV         => tb_E_RX_DV         , -- : in    std_ulogic;
            E_RXD           => tb_E_RXD(3 downto 0),
            E_RX_ER         => tb_E_RX_ER         , -- : in    std_ulogic_vector(3 downto 0);
            E_TX_CLK        => tb_E_TX_CLK        , -- : in    std_ulogic;
            E_TX_EN         => tb_E_TX_EN         , -- : out   std_ulogic;
            E_TXD           => tb_E_TXD(3 downto 0),-- : out   std_ulogic_vector(3 downto 0);
            E_TX_ER         => tb_E_TX_ER         ,

            FPGA_M0         => tb_FPGA_M0         , -- : inout std_ulogic;
            FPGA_M1         => tb_FPGA_M1         , -- : inout std_ulogic;
            FPGA_M2         => tb_FPGA_M2         , -- : inout std_ulogic;
            FPGA_INIT_B     => tb_FPGA_INIT_B     , -- : inout std_ulogic;
            FPGA_RDWR_B     => tb_FPGA_RDWR_B     , -- : inout std_ulogic;
            FPGA_HSWAP      => tb_FPGA_HSWAP      , -- : inout std_ulogic;

            FX2_CLKIN       => tb_FX2_CLKIN       , -- : inout std_ulogic;
            FX2_CLKIO       => tb_FX2_CLKIO       , -- : inout std_ulogic;
            FX2_CLKOUT      => tb_FX2_CLKOUT      , -- : inout std_ulogic;

            FX2_IO          => tb_FX2_IO          , -- : inout std_ulogic_vector(40 downto 1);

            LCD_E           => tb_LCD_E           , -- : inout std_ulogic;
            LCD_RS          => tb_LCD_RS          , -- : inout std_ulogic;
            LCD_RW          => tb_LCD_RW          , -- : inout std_ulogic;

            PS2_CLK         => tb_PS2_CLK         , -- : inout std_ulogic;
            PS2_DATA        => tb_PS2_DATA        , -- : inout std_ulogic;

            ROT_A           => tb_ROT_A           , -- : in    std_ulogic;
            ROT_B           => tb_ROT_B           , -- : in    std_ulogic;
            ROT_CENTER      => tb_ROT_CENTER      , -- : in    std_ulogic;

            RS232_DCE_RXD   => tb_RS232_DCE_RXD   , -- : inout std_ulogic;
            RS232_DCE_TXD   => tb_RS232_DCE_TXD   , -- : inout std_ulogic;
            RS232_DTE_RXD   => tb_RS232_DTE_RXD   , -- : inout std_ulogic;
            RS232_DTE_TXD   => tb_RS232_DTE_TXD   , -- : inout std_ulogic;

            SD_A            => tb_SD_A            , -- : inout std_ulogic_vector(12 downto 0);
            SD_BA           => tb_SD_BA           , -- : inout std_ulogic_vector(1 downto 0);
            SD_CAS          => tb_SD_CAS          , -- : inout std_ulogic;
            SD_CK_N         => tb_SD_CK_N         , -- : inout std_ulogic;
            SD_CK_P         => tb_SD_CK_P         , -- : inout std_ulogic;
            SD_CKE          => tb_SD_CKE          , -- : inout std_ulogic;
            SD_CS           => tb_SD_CS           , -- : inout std_ulogic;
            SD_DQ           => tb_SD_DQ           , -- : inout std_ulogic_vector(15 downto 0);
            SD_LDM          => tb_SD_LDM          , -- : inout std_ulogic;
            SD_LDQS         => tb_SD_LDQS         , -- : inout std_ulogic;
            SD_RAS          => tb_SD_RAS          , -- : inout std_ulogic;
            SD_UDM          => tb_SD_UDM          , -- : inout std_ulogic;
            SD_UDQS         => tb_SD_UDQS         , -- : inout std_ulogic;
            SD_WE           => tb_SD_WE           , -- : inout std_ulogic;

            SD_CK_FB        => tb_SD_CK_FB        , -- : in    std_ulogic;

            SF_A            => tb_SF_A(23 downto 0), -- : inout std_ulogic_vector(24 downto 0);
            SF_BYTE         => tb_SF_BYTE         , -- : inout std_ulogic;
            SF_CE0          => tb_SF_CE0          , -- : inout std_ulogic;
            SF_D            => tb_SF_D            , -- : inout std_ulogic_vector(15 downto 1);
            SF_OE           => tb_SF_OE           , -- : inout std_ulogic;
            SF_STS          => tb_SF_STS          , -- : inout std_ulogic;
            SF_WE           => tb_SF_WE           , -- : inout std_ulogic;

            SPI_MISO        => tb_SPI_MISO        , -- : inout std_ulogic;
            SPI_MOSI        => tb_SPI_MOSI        , -- : inout std_ulogic;
            SPI_SCK         => tb_SPI_SCK         , -- : inout std_ulogic;
            SPI_SS_B        => tb_SPI_SS_B        , -- : inout std_ulogic;
            SPI_ALT_CS_JP11 => tb_SPI_ALT_CS_JP11 , -- : inout std_ulogic;

            SW              => tb_SW              , -- : inout std_ulogic_vector(3 downto 0);

            VGA_BLUE        => tb_VGA_BLUE        , -- : inout std_ulogic;
            VGA_GREEN       => tb_VGA_GREEN       , -- : inout std_ulogic;
            VGA_HSYNC       => tb_VGA_HSYNC       , -- : inout std_ulogic;
            VGA_RED         => tb_VGA_RED         , -- : inout std_ulogic;
            VGA_VSYNC       => tb_VGA_VSYNC       , -- : inout std_ulogic;

            XC_CMD          => tb_XC_CMD          , -- : inout std_ulogic_vector(1 downto 0);
            XC_CPLD_EN      => tb_XC_CPLD_EN      , -- : inout std_ulogic;
            XC_D            => tb_XC_D            , -- : inout std_ulogic_vector(2 downto 0);
            XC_TRIG         => tb_XC_TRIG         , -- : inout std_ulogic;
            XC_GCK0         => tb_XC_GCK0         , -- : inout std_ulogic;
            GCLK10          => tb_GCLK10            -- : inout std_ulogic
        );
    tb_LED        <= tb_FX2_IO(20 downto 13);

    -- phy emulator model
    tb_E_MDIO     <= 'H'; -- pullup
    
    phy_i0: entity work.phy
        generic map (
            address        => 31, -- : integer range 0 to 31 := 0;
            base1000_t_fd  => 0,  -- : integer range 0 to 1  := 1;
            base1000_t_hd  => 0   -- : integer range 0 to 1  := 1;
        ) 
        port map (
            simulation_run => simulation_run,
            rstn           => tb_RESET_n,        -- : in std_logic;
            mdio           => tb_E_MDIO,         -- : inout std_logic;
            tx_clk         => tb_E_TX_CLK,       -- : out std_logic;
            rx_clk         => tb_E_RX_CLK,       -- : out std_logic; 
            rxd            => tb_E_RXD,          -- : out std_logic_vector(7 downto 0);   
            rx_dv          => tb_E_RX_DV,        -- : out std_logic; 
            rx_er          => tb_E_RX_ER,        -- : out std_logic; 
            rx_col         => tb_E_COL,          -- : out std_logic;
            rx_crs         => tb_E_CRS,          -- : out std_logic;
            txd            => tb_E_TXD,          -- : in std_logic_vector(7 downto 0);   
            tx_en          => tb_E_TX_EN,        -- : in std_logic; 
            tx_er          => tb_E_TX_ER,        -- : in std_logic; 
            mdc            => tb_E_MDC,          -- : in std_logic;
            gtx_clk        => tb_GTX_CLK         -- : in std_logic  
        );

    -- ddr ram model(s)
    model_vhdl: if memory_model = gaisler generate
      mt46v16m16_i0: entity work.mt46v16m16
        generic map (                                  -- Timing for -75Z CL2
--          tCK                 : time    :=  7.500 ns;
--          tCH                 : time    :=  3.375 ns;       -- 0.45*tCK
--          tCL                 : time    :=  3.375 ns;       -- 0.45*tCK
--          tDH                 : time    :=  0.500 ns;
--          tDS                 : time    :=  0.500 ns;
--          tIH                 : time    :=  0.900 ns;
--          tIS                 : time    :=  0.900 ns;
--          tMRD                : time    := 15.000 ns;
--          tRAS                : time    := 40.000 ns;
--          tRAP                : time    := 20.000 ns;
--          tRC                 : time    := 65.000 ns;
--          tRFC                : time    := 75.000 ns;
--          tRCD                : time    := 20.000 ns;
--          tRP                 : time    := 20.000 ns;
--          tRRD                : time    := 15.000 ns;
--          tWR                 : time    := 15.000 ns;
--          addr_bits           : integer := 13;
--          data_bits           : integer := 16;
            cols_bits => 10  -- : integer :=  9;
--          index               : integer :=  0;
--          fname               : string  := "sdram.srec";	-- File to read from
--          bbits               : integer :=  16
        )
      port map (
          Dq    => tb_SD_DQ,        -- : INOUT STD_LOGIC_VECTOR (data_bits - 1 DOWNTO 0)
          Dqs   => tb_SD_DQS,       -- : INOUT STD_LOGIC_VECTOR (1 DOWNTO 0)
          Addr  => tb_SD_A,         -- : IN    STD_LOGIC_VECTOR (addr_bits - 1 DOWNTO 0);
          Ba    => tb_SD_BA,        -- : IN    STD_LOGIC_VECTOR (1 DOWNTO 0);
          Clk   => tb_SD_CK_P,      -- : IN    STD_LOGIC;
          Clk_n => tb_SD_CK_N,      -- : IN    STD_LOGIC;
          Cke   => tb_SD_CKE,       -- : IN    STD_LOGIC;
          Cs_n  => tb_SD_CS,        -- : IN    STD_LOGIC;
          Ras_n => tb_SD_RAS,       -- : IN    STD_LOGIC;
          Cas_n => tb_SD_CAS,       -- : IN    STD_LOGIC;
          We_n  => tb_SD_WE,        -- : IN    STD_LOGIC;
          Dm    => tb_SD_DM         -- : IN    STD_LOGIC_VECTOR (1 DOWNTO 0)
      );
    end generate model_vhdl;


--  model_verilog: if memory_model = micron generate
--    -- timing -6f
--    mt46v32m16_i0: entity work.ddr
--      port map (
--          Clk   => tb_SD_CK_P,
--          Clk_n => tb_SD_CK_N,
--          Cke   => tb_SD_CKE,
--          Cs_n  => tb_SD_CS,
--          Ras_n => tb_SD_RAS,
--          Cas_n => tb_SD_CAS,
--          We_n  => tb_SD_WE,
--          Ba    => tb_SD_BA,
--          Addr  => tb_SD_A,
--          Dm    => tb_SD_DM,
--          Dq    => tb_SD_DQ,
--          Dqs   => tb_SD_DQS
--      );
--  end generate model_verilog;

    tb_SD_DM  <= tb_SD_UDM  & tb_SD_LDM;
    tb_SD_DQS <= tb_SD_UDQS & tb_SD_LDQS;


    -------------------- 
    main: process
    begin
        -- report "bitwidth for counter to 15 : " & integer'image( integer( ieee.math_real.ceil( ieee.math_real.log2( real( 15 +1)))));
        -- report "bitwidth for counter to 16 : " & integer'image( integer( ieee.math_real.ceil( ieee.math_real.log2( real( 16 +1)))));

        -- wait for 50 ms;
        wait until rising_edge( global_break);
        simulation_run <= false;
        wait;
    end process;

--  gen_sw_pattern: process
--      variable count : unsigned( tb_SW'range) := (others => '0');
--  begin
--      wait until rising_edge( tb_CLK_50MHZ);
--      tb_SW <= std_logic_vector( count);
--      count := count + 1;
--  end process;
    tb_SW <= (others => '0');

end architecture testbench;
