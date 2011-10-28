-- top module of
-- Spartan-3E Starter Kit Board
--
-- using following external connections:
-- rotary pushbutton as reset
-- LEDs   for output
-- RS232 (DCE, the left one)
--


library ieee;
use ieee.std_logic_1164.all;

library zpu;
use zpu.zpupkg.all;                     -- zpu_dbgo_t

library unisim;
use unisim.vcomponents.dcm_sp;


entity top is
    port (
        -- pragma translate_off 
        stop_simulation : out   std_logic;
        -- pragma translate_on 
        --
        -- Analog-to-Digital Converter (ADC)
        ad_conv         : out   std_logic;
        -- Programmable Gain Amplifier (AMP)
        amp_cs          : out   std_logic;  -- active low chip select
        amp_dout        : in    std_logic;
        amp_shdn        : out   std_logic;  -- active high shutdown, reset
        -- Pushbuttons (BTN)
        btn_east        : in    std_logic;
        btn_north       : in    std_logic;
        btn_south       : in    std_logic;
        btn_west        : in    std_logic;
        -- Clock inputs (CLK)
        clk_50mhz       : in    std_logic;
        clk_aux         : in    std_logic;
        clk_sma         : in    std_logic;
        -- Digital-to-Analog Converter (DAC)
        dac_clr         : out   std_logic;  -- async, active low reset input
        dac_cs          : out   std_logic;  -- active low chip select, conv start with rising edge
        -- 1-Wire Secure EEPROM (DS)
        ds_wire         : inout std_logic;
        -- Ethernet PHY (E)
        e_col           : in    std_logic;  -- MII collision detect
        e_crs           : in    std_logic;  -- carrier sense
        e_mdc           : out   std_logic;  -- management clock
        e_mdio          : inout std_logic;  -- management data io
        e_rx_clk        : in    std_logic;  -- receive clock 25MHz@100BaseTx or 2.5MHz@10Base-T
        e_rx_dv         : in    std_logic;  -- receive data valid
        e_rxd           : in    std_logic_vector(3 downto 0);
        e_rx_er         : in    std_logic;
        e_tx_clk        : in    std_logic;  -- transmit clock 25MHz@100BaseTx or 2.5MHz@10Base-T
        e_tx_en         : out   std_logic;  -- transmit enable
        e_txd           : out   std_logic_vector(3 downto 0);
        e_tx_er         : out   std_logic;
        -- FPGA Configuration Mode, INIT_B Pins (FPGA)
        fpga_m0         : inout std_logic;
        fpga_m1         : inout std_logic;
        fpga_m2         : inout std_logic;
        fpga_init_b     : inout std_logic;
        fpga_rdwr_b     : in    std_logic;
        fpga_hswap      : in    std_logic;
        -- FX2 Connector (FX2)
        fx2_clkin       : inout std_logic;
        fx2_clkio       : inout std_logic;
        fx2_clkout      : inout std_logic;
        fx2_io          : inout std_logic_vector(40 downto 1);
        -- These are shared connections with the FX2 connector
        --j1              : inout std_logic_vector(3 downto 0);
        --j2              : inout std_logic_vector(3 downto 0);
        --j4              : inout std_logic_vector(3 downto 0);
        --led             : out   std_logic_vector(7 downto 0);
        -- Character LCD (LCD)
        lcd_e           : out   std_logic;
        lcd_rs          : out   std_logic;
        lcd_rw          : out   std_logic;
        -- LCD data connections are shared with StrataFlash connections SF_D<11:8>
        --sf_d          : inout std_ulogic_vector(11 downto 8);
        -- PS/2 Mouse/Keyboard Port (PS2)
        ps2_clk         : inout std_logic;
        ps2_data        : inout std_logic;
        -- Rotary Pushbutton Switch (ROT)
        rot_a           : in    std_logic;
        rot_b           : in    std_logic;
        rot_center      : in    std_logic;
        -- RS-232 Serial Ports (RS232)
        rs232_dce_rxd   : in    std_logic;
        rs232_dce_txd   : out   std_logic;
        rs232_dte_rxd   : in    std_logic;
        rs232_dte_txd   : out   std_logic;
        -- DDR SDRAM (SD) (I/O Bank 3, VCCO=2.5V)
        sd_a            : out   std_logic_vector(12 downto 0);  -- address inputs
        sd_dq           : inout std_logic_vector(15 downto 0);  -- data io
        sd_ba           : out   std_logic_vector(1 downto 0);   -- bank address inputs
        sd_ras          : out   std_logic;                      -- command output
        sd_cas          : out   std_logic;                      -- command output
        sd_we           : out   std_logic;                      -- command output 
        sd_udm          : out   std_logic;                      -- data mask
        sd_ldm          : out   std_logic;                      -- data mask
        sd_udqs         : inout std_logic;                      -- data strobe
        sd_ldqs         : inout std_logic;                      -- data strobe
        sd_cs           : out   std_logic;                      -- active low chip select
        sd_cke          : out   std_logic;                      -- active high clock enable
        sd_ck_n         : out   std_logic;                      -- differential clock
        sd_ck_p         : out   std_logic;                      -- differential clock
        -- Path to allow connection to top DCM connection
        sd_ck_fb        : in    std_logic;
        -- Intel StrataFlash Parallel NOR Flash (SF)
        sf_a            : out   std_logic_vector(23 downto 0);  -- sf_a<24> = fx_io32
        sf_byte         : out   std_logic;
        sf_ce0          : out   std_logic;
        sf_d            : inout std_logic_vector(15 downto 1);
        sf_oe           : out   std_logic;
        sf_sts          : in    std_logic;
        sf_we           : out   std_logic;
        -- STMicro SPI serial Flash (SPI)
        spi_mosi        : out   std_logic;  -- master out slave in
        spi_miso        : in    std_logic;  -- master in  slave out
        spi_sck         : out   std_logic;  -- clock
        spi_ss_b        : out   std_logic;  -- active low slave select
        spi_alt_cs_jp11 : out   std_logic;
        -- Slide Switches (SW)
        sw              : in    std_logic_vector(3 downto 0);
        -- VGA Port (VGA)
        vga_blue        : out   std_logic;
        vga_green       : out   std_logic;
        vga_hsync       : out   std_logic;
        vga_red         : out   std_logic;
        vga_vsync       : out   std_logic;
        -- Xilinx CPLD (XC)
        xc_cmd          : out   std_logic_vector(1 downto 0);
        xc_cpld_en      : out   std_logic;
        xc_d            : inout std_logic_vector(2 downto 0);
        xc_trig         : in    std_logic;
        xc_gck0         : inout std_logic;
        gclk10          : inout std_logic
        );
end entity top;


architecture rtl of top is

    ---------------------------
    -- type declarations
    type zpu_type is (zpu_small, zpu_medium);

    ---------------------------
    -- constant declarations
    constant zpu_flavour : zpu_type := zpu_medium;  -- choose your flavour HERE
    --  modify frequency here
    constant clk_multiply : positive := 3;  -- 2 for small, 3 for medium
    constant clk_divide   : positive := 2;  -- 1 for small, 2 for medium
    --
    constant word_size_c  : natural  := 32; -- 32 bits data path
    constant addr_w_c     : natural  := 18; -- 18 bits address space=256 kB, 128 kB I/O


    constant spi_ss_b_disable    : std_ulogic := '1';  -- 1 = disable SPI serial flash
    constant dac_cs_disable      : std_ulogic := '1';  -- 1 = disable DAC 
    constant amp_cs_disable      : std_ulogic := '1';  -- 1 = disable programmable pre-amplifier
    constant ad_conv_disable     : std_ulogic := '0';  -- 0 = disable ADC
    constant sf_ce0_disable      : std_ulogic := '1';
    constant fpga_init_b_disable : std_ulogic := '1';  -- 1 = disable pflatform flash PROM
    --
    -- connect ldc to fpga
    constant sf_ce0_lcd_to_fpga  : std_ulogic := '1';
    --
    constant clk_frequency       : positive   := 50;   -- input frequency for correct calculation


    ---------------------------
    -- component declarations
    component zpu_small1 is
        generic (
            word_size  : natural   := 32;      -- 32 bits data path
            d_care_val : std_logic := '0';     -- Fill value
            clk_freq   : positive  := 50;      -- 50 MHz clock
            brate      : positive  := 115200;  -- RS232 baudrate
            addr_w     : natural   := 16;      -- 16 bits address space=64 kB, 32 kB I/O
            bram_w     : natural   := 15       -- 15 bits RAM space=32 kB
            );
        port (
            clk_i      : in  std_logic;        -- CPU clock
            rst_i      : in  std_logic;        -- Reset
            break_o    : out std_logic;        -- Break executed
            dbg_o      : out zpu_dbgo_t;       -- Debug info
            rs232_tx_o : out std_logic;        -- UART Tx
            rs232_rx_i : in  std_logic;        -- UART Rx
            gpio_in    : in  std_logic_vector(31 downto 0);
            gpio_out   : out std_logic_vector(31 downto 0);
            gpio_dir   : out std_logic_vector(31 downto 0)  -- 1 = in, 0 = out
            );
    end component zpu_small1;

    component zpu_med1 is
        generic(
            word_size  : natural   := 32;      -- 32 bits data path
            d_care_val : std_logic := '0';     -- Fill value
            clk_freq   : positive  := 50;      -- 50 MHz clock
            brate      : positive  := 115200;  -- RS232 baudrate
            addr_w     : natural   := 18;      -- 18 bits address space=256 kB, 128 kB I/O
            bram_w     : natural   := 15       -- 15 bits RAM space=32 kB
            );
        port(
            clk_i      : in  std_logic;        -- CPU clock
            rst_i      : in  std_logic;        -- Reset
            break_o    : out std_logic;        -- Break executed
            dbg_o      : out zpu_dbgo_t;       -- Debug info
            rs232_tx_o : out std_logic;        -- UART Tx
            rs232_rx_i : in  std_logic;        -- UART Rx
            gpio_in    : in  std_logic_vector(31 downto 0);
            gpio_out   : out std_logic_vector(31 downto 0);
            gpio_dir   : out std_logic_vector(31 downto 0)  -- 1 = in, 0 = out
            );
    end component zpu_med1;


    ---------------------------
    -- signal declarations
    signal dcm_sp_i0_clk0  : std_ulogic;
    signal dcm_sp_i0_clkfx : std_ulogic;
    signal clk_fb          : std_ulogic;
    signal clk             : std_ulogic;
    --
    signal reset_shift_reg : std_ulogic_vector(3 downto 0);
    signal reset_sync      : std_ulogic;
    --
    signal zpu_i0_dbg      : zpu_dbgo_t;  -- Debug info
    signal zpu_i0_break    : std_logic;
    --
    signal gpio_in         : std_logic_vector(31 downto 0);
    signal zpu_i0_gpio_out : std_logic_vector(31 downto 0);
    signal zpu_i0_gpio_dir : std_logic_vector(31 downto 0);
    
    ---------------------------
    -- alias declarations
    alias led : std_logic_vector(7 downto 0) is fx2_io(20 downto 13);


begin

    -- default output drivers
    -- to pass bitgen DRC 
    -- outputs used by design are commented
    --
    ad_conv           <= ad_conv_disable;
    amp_cs            <= amp_cs_disable;
    amp_shdn          <= '1';
    --
    dac_clr           <= '0';
    dac_cs            <= dac_cs_disable;
    --
    ds_wire           <= 'Z';
    --
    e_txd(3 downto 0) <= (others => '1');
    e_tx_en           <= '0';
    e_tx_er           <= '0';
    e_mdc             <= '1';
    e_mdio            <= 'Z';
    --
    fpga_m0           <= 'Z';
    fpga_m1           <= 'Z';
    fpga_m2           <= 'Z';
    fpga_init_b       <= fpga_init_b_disable;
    --
    fx2_clkin         <= 'Z';
    fx2_clkio         <= 'Z';
    fx2_clkout        <= 'Z';
    fx2_io            <= (others => 'Z');
    --
    lcd_e             <= '0';
    lcd_rs            <= '0';
    lcd_rw            <= '0';
    --
    ps2_clk           <= 'Z';
    ps2_data          <= 'Z';
    --
    --rs232_dce_txd     <= '1';
    rs232_dte_txd     <= '1';
    --
    sd_a              <= (others => '1');
    sd_dq             <= (others => 'Z');
    sd_ba             <= (others => '1');
    sd_ras            <= '0';
    sd_cas            <= '0';
    sd_we             <= '0';
    sd_udm            <= '1';
    sd_ldm            <= '1';
    sd_udqs           <= '1';
    sd_ldqs           <= '1';
    sd_cs             <= '1';
    sd_cke            <= '1';
    sd_ck_n           <= '0';
    sd_ck_p           <= '1';
    --
    sf_a              <= (others => '0');
    sf_byte           <= '0';
    sf_ce0            <= sf_ce0_lcd_to_fpga;
    sf_d              <= (others => 'Z');
    sf_oe             <= '1';
    sf_we             <= '0';
    --
    spi_mosi          <= '0';
    spi_sck           <= '0';
    spi_ss_b          <= spi_ss_b_disable;
    spi_alt_cs_jp11   <= spi_ss_b_disable;
    --
    vga_red           <= '0';
    vga_green         <= '0';
    vga_blue          <= '0';
    vga_hsync         <= '0';
    vga_vsync         <= '0';
    --
    xc_cmd            <= "00";
    xc_d              <= (others => 'Z');
    xc_cpld_en        <= '0';
    xc_gck0           <= 'Z';
    gclk10            <= 'Z';
    -- led out
    --fx2_io(20 downto 13) <= (others => '0');


    -- digital clock manager (DCM)
    -- to generate higher/other system clock frequencys
    dcm_sp_i0 : dcm_sp
        generic map (
            startup_wait   => true,     -- wait with DONE till locked
            clkfx_multiply => clk_multiply,
            clkfx_divide   => clk_divide, 
            clk_feedback   => "1X"
            )
        port map (
            clkin => clk_50mhz,
            clk0  => dcm_sp_i0_clk0,
            clkfx => dcm_sp_i0_clkfx,
            clkfb => clk_fb
            );

    clk_fb <= dcm_sp_i0_clk0;
    clk    <= dcm_sp_i0_clkfx;


    -- reset synchronizer
    -- generate synchronous reset
    reset_synchronizer : process(clk, rot_center)
    begin
        if rot_center = '1' then
            reset_shift_reg <= (others => '1');
        elsif rising_edge(clk) then
            reset_shift_reg <= reset_shift_reg(reset_shift_reg'high-1 downto 0) & '0';
        end if;
    end process;
    reset_sync <= reset_shift_reg(reset_shift_reg'high);


    -- select instance of zpu
    zpu_i0_small : if zpu_flavour = zpu_small generate
        zpu_i0 : zpu_small1
            generic map (
                addr_w    => addr_w_c,
                word_size => word_size_c,
                clk_freq  => clk_frequency * clk_multiply / clk_divide
                )
            port map (
                clk_i      => clk,             -- : in  std_logic;   -- CPU clock
                rst_i      => reset_sync,      -- : in  std_logic;   -- Reset
                break_o    => zpu_i0_break,    -- : out std_logic;   -- Break executed
                dbg_o      => zpu_i0_dbg,      -- : out zpu_dbgo_t;  -- Debug info
                rs232_tx_o => rs232_dce_txd,   -- : out std_logic;   -- UART Tx
                rs232_rx_i => rs232_dce_rxd,   -- : in  std_logic    -- UART Rx
                gpio_in    => gpio_in,         -- : in  std_logic_vector(31 downto 0);
                gpio_out   => zpu_i0_gpio_out, -- : out std_logic_vector(31 downto 0);
                gpio_dir   => zpu_i0_gpio_dir  -- : out std_logic_vector(31 downto 0)  -- 1 = in, 0 = out
                );
    end generate zpu_i0_small;

    zpu_i0_medium : if zpu_flavour = zpu_medium generate
        zpu_i0 : zpu_med1
            generic map (
                addr_w    => addr_w_c,
                word_size => word_size_c,
                clk_freq  => clk_frequency * clk_multiply / clk_divide
                )
            port map (
                clk_i      => clk,             -- : in  std_logic;   -- CPU clock
                rst_i      => reset_sync,      -- : in  std_logic;   -- Reset
                break_o    => zpu_i0_break,    -- : out std_logic;   -- Break executed
                dbg_o      => zpu_i0_dbg,      -- : out zpu_dbgo_t;  -- Debug info
                rs232_tx_o => rs232_dce_txd,   -- : out std_logic;   -- UART Tx
                rs232_rx_i => rs232_dce_rxd,   -- : in  std_logic    -- UART Rx
                gpio_in    => gpio_in,         -- : in  std_logic_vector(31 downto 0);
                gpio_out   => zpu_i0_gpio_out, -- : out std_logic_vector(31 downto 0);
                gpio_dir   => zpu_i0_gpio_dir  -- : out std_logic_vector(31 downto 0)  -- 1 = in, 0 = out
                );
    end generate zpu_i0_medium;


    -- pragma translate_off 
    stop_simulation <= zpu_i0_break;


    trace_mod : trace
        generic map (
            addr_w    => addr_w_c,
            word_size => word_size_c,
            log_file  => "zpu_trace.log"
            )
        port map (
            clk_i  => clk,
            dbg_i  => zpu_i0_dbg,
            stop_i => zpu_i0_break,
            busy_i => '0'
            );
    -- pragma translate_on


    -- assign GPIOs
    -- no bidirectional pins (e.g. headers), so
    -- gpio_dir is unused
    --
    -- bit   31 30 29 28 27 26 25 24  23 22 21 20 19 18 17 16
    --
    --  in   -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- --
    -- out   -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- --
    --
    --
    -- bit   15 14 13 12 11 10  9  8   7  6  5  4  3  2  1  0
    --                                                       
    --  in   -- -- -- -- sw(3.....0)  -- ra rb rc be bn bs bw
    -- out   -- -- -- -- -- -- -- --  led(7................0)

    gpio_in <= ((11) => sw(3),
                (10) => sw(2),
                ( 9) => sw(1),
                ( 8) => sw(0),
                --
                ( 6) => rot_a,
                ( 5) => rot_b,
                ( 4) => rot_center,
                --
                ( 3) => btn_east,
                ( 2) => btn_north,
                ( 1) => btn_south,
                ( 0) => btn_west,
                others => '0');


    -- switch on all LEDs in case of break
    process
    begin
        wait until rising_edge(clk);
        led <= zpu_i0_gpio_out(7 downto 0);
        if zpu_i0_break = '1' then
            led <= (others => '1');
        end if;
    end process;

    

end architecture rtl;
