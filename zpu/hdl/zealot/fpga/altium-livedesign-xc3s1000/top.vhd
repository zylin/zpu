-- top module of
-- Altium LiveDesign Board
--
-- using following external connections:
-- test button as reset
-- LEDs and 7 segment for output
-- RS232
--


library ieee;
use ieee.std_logic_1164.all;

library zpu;
use zpu.zpupkg.all;   -- zpu_dbgo_t

library unisim;
use unisim.vcomponents.dcm;


entity top is
    port (
        -- pragma translate_off 
        stop_simulation : out   std_logic;
        -- pragma translate_on 
        clk_50     : in    std_logic;
        reset_n    : in    std_logic;
        --
        -- soft JTAG
        soft_tdo   : out   std_logic;
        soft_tms   : in    std_logic;
        soft_tdi   : in    std_logic;
        soft_tck   : in    std_logic;
        --
        -- SRAM 0 (256k x 16) pin connections
        sram0_a    : out   std_logic_vector(18 downto 0);
        sram0_d    : inout std_logic_vector(15 downto 0);
        sram0_lb_n : out   std_logic;
        sram0_ub_n : out   std_logic;
        sram0_cs_n : out   std_logic;       -- chip select
        sram0_we_n : out   std_logic;       -- write-enable
        sram0_oe_n : out   std_logic;       -- output enable
        --
        -- SRAM 1 (256k x 16) pin connections
        sram1_a    : out   std_logic_vector(18 downto 0);
        sram1_d    : inout std_logic_vector(15 downto 0);
        sram1_lb_n : out   std_logic;
        sram1_ub_n : out   std_logic;
        sram1_cs_n : out   std_logic;       -- chip select
        sram1_we_n : out   std_logic;       -- write-enable
        sram1_oe_n : out   std_logic;       -- output enable
        --
        -- RS232
        rs232_rx   : in    std_logic;
        rs232_tx   : out   std_logic;
        rs232_cts  : in    std_logic;
        rs232_rts  : out   std_logic;
        --
        -- PS2 connectors
        mouse_clk  : inout std_logic;
        mouse_data : inout std_logic;
        kbd_clk    : inout std_logic;
        kbd_data   : inout std_logic;
        --
        -- vga output
        vga_red    : out   std_logic_vector(7 downto 5);
        vga_green  : out   std_logic_vector(7 downto 5);
        vga_blue   : out   std_logic_vector(7 downto 5);
        vga_hsync  : out   std_logic;
        vga_vsync  : out   std_logic;
        --
        -- Audio out
        audio_r    : out   std_logic;
        audio_l    : out   std_logic;
        --
        -- GPIOs
        switch_n   : in    std_logic_vector(7 downto 0);
        button_n   : in    std_logic_vector(5 downto 0);
        led        : out   std_logic_vector(7 downto 0);
        --
        -- seven segment display
        dig0_seg   : out   std_logic_vector(7 downto 0);
        dig1_seg   : out   std_logic_vector(7 downto 0);
        dig2_seg   : out   std_logic_vector(7 downto 0);
        dig3_seg   : out   std_logic_vector(7 downto 0);
        dig4_seg   : out   std_logic_vector(7 downto 0);
        dig5_seg   : out   std_logic_vector(7 downto 0);
        --
        -- User Header
        header_a   : inout std_logic_vector(19 downto 2);
        header_b   : inout std_logic_vector(19 downto 2)
    );
end entity top;


architecture rtl of top is


    ---------------------------
    -- type declarations
    type zpu_type is (zpu_small, zpu_medium);

    ---------------------------
    -- constant declarations
    constant zpu_flavour   : zpu_type := zpu_small;  -- choose your flavour HERE
    --  modify frequency here
    constant clk_multiply  : positive := 3; -- 9 for small, 3 for medium
    constant clk_divide    : positive := 2; -- 5 for small, 2 for medium
    --
    constant word_size_c   : natural  := 32; -- 32 bits data path
    constant addr_w_c      : natural  := 18; -- 18 bits address space=256 kB, 128 kB I/O

    constant clk_frequency : positive := 50; -- input frequency for correct calculation


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
    signal dcm_i0_clk0     : std_ulogic;
    signal dcm_i0_clkfx    : std_ulogic;
    signal clk_fb          : std_ulogic;
    signal clk             : std_ulogic;
    --
    signal reset_shift_reg : std_ulogic_vector(3 downto 0);
    signal reset_sync      : std_ulogic;
    --
    signal zpu_i0_dbg      : zpu_dbgo_t;  -- Debug info
    signal zpu_i0_break    : std_logic;
    --
    signal gpio_in         : std_logic_vector(31 downto 0) := (others => '0');
    signal zpu_i0_gpio_out : std_logic_vector(31 downto 0);
    signal zpu_i0_gpio_dir : std_logic_vector(31 downto 0);


begin

    -- default output drivers
    -- to pass bitgen DRC 
    -- outputs used by design are commented
    soft_tdo   <= '1';
    --
    sram0_a    <= (others => '1');
    sram0_d    <= (others => 'Z');
    sram0_lb_n <= '1';
    sram0_ub_n <= '1';
    sram0_cs_n <= '1';
    sram0_we_n <= '1';
    sram0_oe_n <= '1';
    --
    sram1_a    <= (others => '1');
    sram1_d    <= (others => 'Z');
    sram1_lb_n <= '1';
    sram1_ub_n <= '1';
    sram1_cs_n <= '1';
    sram1_we_n <= '1';
    sram1_oe_n <= '1';
    --
    --rs232_tx   <= '1';
    rs232_rts  <= '1';
    --
    mouse_clk  <= 'Z'; 
    mouse_data <= 'Z'; 
    kbd_clk    <= 'Z'; 
    kbd_data   <= 'Z'; 
    --
    vga_red    <= (others => '1');
    vga_green  <= (others => '1');
    vga_blue   <= (others => '1');
    vga_hsync  <= '1';
    vga_vsync  <= '1';
    --
    audio_r    <= '0';
    audio_l    <= '0';
    --
    --led        <= (others => '0');
    --
    --dig0_seg   <= (others => '0');
    --dig1_seg   <= (others => '0');
    dig2_seg   <= (others => '0');
    dig3_seg   <= (others => '0');
    dig4_seg   <= (others => '0');
    dig5_seg   <= (others => '0');
    --
    header_a   <= (others => 'Z');
    header_b   <= (others => 'Z');


    -- digital clock manager (DCM)
    -- to generate higher/other system clock frequencys
    dcm_i0 : dcm
        generic map (
            startup_wait   => true,     -- wait with DONE till locked
            clkfx_multiply => clk_multiply,
            clkfx_divide   => clk_divide, 
            clk_feedback   => "1X"
            )
        port map (
            clkin => clk_50,
            clk0  => dcm_i0_clk0,
            clkfx => dcm_i0_clkfx,
            clkfb => clk_fb
            );

    clk_fb <= dcm_i0_clk0;
    clk    <= dcm_i0_clkfx;


    -- reset synchronizer
    -- generate synchronous reset
    reset_synchronizer : process(clk, reset_n)
    begin
        if reset_n = '0' then
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
                rs232_tx_o => rs232_tx,        -- : out std_logic;   -- UART Tx
                rs232_rx_i => rs232_rx,        -- : in  std_logic    -- UART Rx
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
                rs232_tx_o => rs232_tx,        -- : out std_logic;   -- UART Tx
                rs232_rx_i => rs232_rx,        -- : in  std_logic    -- UART Rx
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
    --
    -- bit   31 30 29 28 27 26 25 24  23 22 21 20 19 18 17 16  
    --
    --  in   header_a(19.........12)  -- -- -- -- -- -- -- --  
    -- out   header_a(19.........12)  dig1_seg(7...........0)  
    --
    --
    -- bit   15 14 13 12 11 10  9  8   7  6  5  4  3  2  1  0
    --                                                       
    --  in   switch_n(7...........0)  -- --  button_n(5....0)
    -- out   dig0_seg(7...........0)  led(7................0)
    --

    gpio_in(31 downto 24) <= header_a(19 downto 12);
    gpio_in(15 downto 8)  <= switch_n;
    gpio_in( 5 downto 0)  <= button_n;

    -- 3-state buffers for some headers
    header_a(19) <= zpu_i0_gpio_out(31) when zpu_i0_gpio_dir(31) = '0' else 'Z';
    header_a(18) <= zpu_i0_gpio_out(30) when zpu_i0_gpio_dir(30) = '0' else 'Z';
    header_a(17) <= zpu_i0_gpio_out(29) when zpu_i0_gpio_dir(29) = '0' else 'Z';
    header_a(16) <= zpu_i0_gpio_out(28) when zpu_i0_gpio_dir(28) = '0' else 'Z';
    header_a(15) <= zpu_i0_gpio_out(27) when zpu_i0_gpio_dir(27) = '0' else 'Z';
    header_a(14) <= zpu_i0_gpio_out(26) when zpu_i0_gpio_dir(26) = '0' else 'Z';
    header_a(13) <= zpu_i0_gpio_out(25) when zpu_i0_gpio_dir(25) = '0' else 'Z';
    header_a(12) <= zpu_i0_gpio_out(24) when zpu_i0_gpio_dir(24) = '0' else 'Z';

    -- outputs    
    dig1_seg <= zpu_i0_gpio_out(23 downto 16);
    dig0_seg <= zpu_i0_gpio_out(15 downto  8);

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

