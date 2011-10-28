-- top module of
-- Avnet Virtex 5 FX Evaluation Board
--
-- using following external connections:
-- pushbutton PB1 as reset
-- LEDs   for output
-- RS232 (non USB)
--


library ieee;
use ieee.std_logic_1164.all;

library zpu;
use zpu.zpupkg.all;                     -- zpu_dbgo_t

library unisim;
use unisim.vcomponents.ibufds;
use unisim.vcomponents.dcm_base;


entity top is
    port (
        -- pragma translate_off 
        stop_simulation     : out   std_logic;
        -- pragma translate_on 
        clk_100MHz          : in    std_logic;  -- 100 MHz clock
        clk_socket          : in    std_logic;  -- user clock
        user_clk_p          : in    std_logic;  -- differential user clock
        user_clk_n          : in    std_logic;  -- differential user clock
        --                                         
        --  RS232                                  
        rs232_rx            : in    std_logic;
        rs232_tx            : out   std_logic;
        rs232_rts           : in    std_logic;
        rs232_cts           : out   std_logic;
        --  RS232 USB                              
        rs232_usb_rx        : in    std_logic;
        rs232_usb_tx        : out   std_logic;
        rs232_usb_reset_n   : out   std_logic;
        --
        gpio_led_n          : out   std_logic_vector(7 downto 0);
        gpio_dipswitch      : in    std_logic_vector(7 downto 0);
        gpio_button         : in    std_logic_vector(3 downto 0);
        --
        --  FLASH 8Mx16 
        flash_a             : out   std_logic_vector(31 downto 7);
        flash_dq            : inout std_logic_vector(15 downto 0);
        flash_wen           : out   std_logic;
        flash_oen           : out   std_logic_vector(0 downto 0);
        flash_cen           : out   std_logic_vector(0 downto 0);
        flash_rp_n          : out   std_logic;
        flash_byte_n        : out   std_logic;
        flash_adv_n         : out   std_logic;
        flash_clk           : out   std_logic;
        flash_wait          : in    std_logic;
        --
        --  DDR2 SDRAM 16Mx32 
        ddr2_odt            : in    std_logic_vector(0 downto 0);
        ddr2_a              : out   std_logic_vector(12 downto 0);
        ddr2_ba             : out   std_logic_vector(1 downto 0);
        ddr2_cas_n          : out   std_logic;
        ddr2_cke            : out   std_logic;
        ddr2_cs_n           : out   std_logic;
        ddr2_ras_n          : out   std_logic;
        ddr2_we_n           : out   std_logic;
        ddr2_dm             : out   std_logic_vector(3 downto 0);
        ddr2_dqs_p          : inout std_logic_vector(3 downto 0);
        ddr2_dqs_n          : inout std_logic_vector(3 downto 0);
        ddr2_dq             : inout std_logic_vector(31 downto 0);
        ddr2_ck_p           : in    std_logic_vector(1 downto 0);
        ddr2_ck_n           : in    std_logic_vector(1 downto 0);
        --
        --  Ethernet MAC 
        gmii_txer           : out   std_logic;
        gmii_tx_clk         : in    std_logic;  -- 25 MHz
        gmii_rx_clk         : in    std_logic;  -- 25 MHz
        gmii_gtc_clk        : out   std_logic;
        gmii_crs            : in    std_logic;
        gmii_dv             : in    std_logic;
        gmii_rx_data        : in    std_logic_vector(7 downto 0);
        gmii_col            : in    std_logic;
        gmii_rx_er          : in    std_logic;
        gmii_tx_en          : out   std_logic;
        gmii_tx_data        : out   std_logic_vector(7 downto 0);
        gbe_rst_n           : out   std_logic;
        gbe_mdc             : out   std_logic;
        gbe_mdio            : inout std_logic;
        gbe_int_n           : inout std_logic;
        gbe_mclk            : in    std_logic;
        --
        --  SysACE CompactFlash 
        sam_clk             : in    std_logic;
        sam_a               : out   std_logic_vector(6 downto 0);
        sam_d               : inout std_logic_vector(15 downto 0);
        sam_cen             : out   std_logic;
        sam_oen             : out   std_logic;
        sam_wen             : out   std_logic;
        sam_mpirq           : in    std_logic;
        sam_brdy            : in    std_logic;
        sam_reset_n         : out   std_logic;
        --
        --  Expansion Header
        exp1_se_io          : inout std_logic_vector(33 downto 0);
        exp1_diff_p         : inout std_logic_vector(21 downto 0);
        exp1_diff_n         : inout std_logic_vector(21 downto 0);
        exp1_se_clk_out     : out   std_logic;
        exp1_se_clk_in      : in    std_logic;
        exp1_diff_clk_out_p : out   std_logic;
        exp1_diff_clk_out_n : out   std_logic;
        exp1_diff_clk_in_p  : in    std_logic;
        exp1_diff_clk_in_n  : in    std_logic;
        --
        -- Debug/Trace
        atdd                : inout std_logic_vector(19 downto 8);
        trace_ts10          : inout std_logic;
        trace_ts20          : inout std_logic;
        trace_ts1e          : inout std_logic;
        trace_ts2e          : inout std_logic;
        trace_ts3           : inout std_logic;
        trace_ts4           : inout std_logic;
        trace_ts5           : inout std_logic;
        trace_ts6           : inout std_logic;
        trace_clk           : in    std_logic;
        cpu_hreset          : in    std_logic;
        cpu_tdo             : out   std_logic;
        cpu_tms             : in    std_logic;
        cpu_tdi             : in    std_logic;
        cpu_trst            : in    std_logic;
        cpu_tck             : in    std_logic;
        cpu_halt_n          : in    std_logic
    );
end entity top;


architecture rtl of top is

    ---------------------------
    -- type declarations
    type zpu_type is (zpu_small, zpu_medium);

    ---------------------------
    -- constant declarations
    constant zpu_flavour   : zpu_type := zpu_medium;  -- choose your flavour HERE
    --  modify frequency here
    constant clk_multiply  : positive := 5;   -- 7 for small, 5 for medium
    constant clk_divide    : positive := 4;   -- 4 for small, 4 for medium
    --
    --
    constant word_size_c   : natural  := 32;  -- 32 bits data path
    constant addr_w_c      : natural  := 18;  -- 18 bits address space=256 kB, 128 kB I/O
    --
    constant clk_frequency : positive := 100; -- input frequency for correct calculation

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
    signal sys_clk           : std_ulogic;
    signal dcm_base_i0_clk0  : std_ulogic;
    signal dcm_base_i0_clkfx : std_ulogic;
    signal clk_fb            : std_ulogic;
    signal clk               : std_ulogic;
    --
    signal reset_shift_reg   : std_ulogic_vector(3 downto 0);
    signal reset_sync        : std_ulogic;
    --
    signal zpu_i0_dbg        : zpu_dbgo_t;  -- Debug info
    signal zpu_i0_break      : std_logic;
    --
    signal ibufds_i0_o       : std_ulogic;
    signal ibufds_i1_o       : std_ulogic;
    --
    signal gpio_in           : std_logic_vector(31 downto 0) := (others => '0');
    signal zpu_i0_gpio_out   : std_logic_vector(31 downto 0);
    signal zpu_i0_gpio_dir   : std_logic_vector(31 downto 0);
    
begin
  
    -- default output drivers
    -- to pass bitgen DRC 
      -- other used outputs are only commented
    --rs232_tx            <= '1';
    rs232_cts           <= '1';
    rs232_usb_tx        <= '1';
    rs232_usb_reset_n   <= '1';
    --
    --gpio_led_n        <= (others => '1');
    --
    flash_cen           <= "1";
    flash_oen           <= "1";
    flash_wen           <= '1';
    flash_rp_n          <= '1';
    flash_byte_n        <= '1';
    flash_adv_n         <= '1';
    flash_clk           <= '0';
    flash_a             <= (others => '0');
    flash_dq            <= (others => 'Z');
    --
    ddr2_a              <= (others => '0');
    ddr2_ba             <= (others => '0');
    ddr2_dm             <= (others => '0');
    ddr2_cs_n           <= '1';
    ddr2_we_n           <= '1';
    ddr2_cke            <= '1';
    ddr2_cas_n          <= '1';
    ddr2_ras_n          <= '1';
    ddr2_dqs_p          <= (others => 'Z');
    ddr2_dqs_n          <= (others => 'Z');
    ddr2_dq             <= (others => 'Z');
    --
    gmii_gtc_clk        <= '0';
    gmii_tx_data        <= (others => '0');
    gmii_tx_en          <= '0';
    gmii_txer           <= '0';
    gbe_rst_n           <= '1';
    gbe_mdc             <= '1';
    gbe_mdio            <= 'Z';
    gbe_int_n           <= 'Z';
    --
    sam_cen             <= '1';
    sam_oen             <= '1';
    sam_wen             <= '1';
    sam_a               <= (others => '0');
    sam_d               <= (others => 'Z');
    sam_reset_n         <= '1';
    --
    exp1_se_io          <= (others => 'Z');
    exp1_diff_p         <= (others => 'Z');
    exp1_diff_n         <= (others => 'Z');
    exp1_se_clk_out     <= '0';
    exp1_diff_clk_out_p <= '0';
    exp1_diff_clk_out_n <= '1';
    --
    atdd                <= (others => 'Z');
    trace_ts10          <= 'Z';
    trace_ts20          <= 'Z';
    trace_ts1e          <= 'Z';
    trace_ts2e          <= 'Z';
    trace_ts3           <= 'Z';
    trace_ts4           <= 'Z';
    trace_ts5           <= 'Z';
    trace_ts6           <= 'Z';
    cpu_tdo             <= '1';


    -- global differential input buffer 
  ibufds_i0 : ibufds
    generic map (
      diff_term => true
      )
    port map (
      o  => ibufds_i0_o,
      i  => ddr2_ck_p(0),
      ib => ddr2_ck_n(0)
      );

    -- global differential input buffer 
  ibufds_i1 : ibufds
    generic map (
      diff_term => true
      )
    port map (
      o  => ibufds_i1_o,
      i  => ddr2_ck_p(1),
      ib => ddr2_ck_n(1)
      );
  
    -- digital clock manager (DCM)
    -- to generate higher/other system clock frequencys
    dcm_base_i0: dcm_base
    generic map (
        startup_wait       => true, -- wait with DONE till locked
        --dfs_frequency_mode => "HIGH", -- use this with zpu_small for 175 MHz
        clkfx_multiply     => clk_multiply,
        clkfx_divide       => clk_divide,
        clk_feedback       => "1X"
    )
    port map (
        rst   => '0',
        clkin => clk_100MHz,
        clk0  => dcm_base_i0_clk0,
        clkfx => dcm_base_i0_clkfx,
        clkfb => clk_fb
    );
          
    -- speaking names for dcm output
    clk_fb    <= dcm_base_i0_clk0;
    clk       <= dcm_base_i0_clkfx;


    -- reset synchronizer
    -- generate synchronous reset
    reset_synchronizer : process(clk, gpio_button)
    begin
        if (gpio_button(0) = '1') then
            reset_shift_reg <= (others => '1');
        elsif rising_edge(clk) then
            reset_shift_reg <= reset_shift_reg(reset_shift_reg'high-1 downto 0) & '0';
        end if;
    end process;
    reset_sync <= reset_shift_reg(reset_shift_reg'high);



    -- select instance of zpu
    zpu_i0_small: if zpu_flavour = zpu_small generate
        zpu_i0 : zpu_small1
            generic map (
                addr_w    => addr_w_c,
                word_size => word_size_c,
                clk_freq  => clk_frequency * clk_multiply / clk_divide
                )
            port map (
                clk_i      => clk,             -- : in  std_logic;   - CPU clock
                rst_i      => reset_sync,      -- : in  std_logic;   - Reset
                break_o    => zpu_i0_break,    -- : out std_logic;   - Break executed
                dbg_o      => zpu_i0_dbg,      -- : out zpu_dbgo_t;  - Debug info
                rs232_tx_o => rs232_tx,        -- : out std_logic;   - UART Tx
                rs232_rx_i => rs232_rx,        -- : in  std_logic    - UART Rx
                gpio_in    => gpio_in,         -- : in  std_logic_vector(31 downto 0);
                gpio_out   => zpu_i0_gpio_out, -- : out std_logic_vector(31 downto 0);
                gpio_dir   => zpu_i0_gpio_dir  -- : out std_logic_vector(31 downto 0)  -- 1 = in, 0 = out
                );
    end generate zpu_i0_small;

    zpu_i0_medium: if zpu_flavour = zpu_medium generate
        zpu_i0 : zpu_med1
            generic map (
                addr_w    => addr_w_c,
                word_size => word_size_c,
                clk_freq  => clk_frequency * clk_multiply / clk_divide
                )
            port map (
                clk_i      => clk,             -- : in  std_logic;   - CPU clock
                rst_i      => reset_sync,      -- : in  std_logic;   - Reset
                break_o    => zpu_i0_break,    -- : out std_logic;   - Break executed
                dbg_o      => zpu_i0_dbg,      -- : out zpu_dbgo_t;  - Debug info
                rs232_tx_o => rs232_tx,        -- : out std_logic;   - UART Tx
                rs232_rx_i => rs232_rx,        -- : in  std_logic    - UART Rx
                gpio_in    => gpio_in,         -- : in  std_logic_vector(31 downto 0);
                gpio_out   => zpu_i0_gpio_out, -- : out std_logic_vector(31 downto 0);
                gpio_dir   => zpu_i0_gpio_dir  -- : out std_logic_vector(31 downto 0)  -- 1 = in, 0 = out
                );
    end generate zpu_i0_medium;

    -- pragma translate_off 
    stop_simulation <= zpu_i0_break; -- abort() causes to stop the simulation


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
    --  in   gpio_dipswitch(7.....0)  -- -- -- --  buttons3.0
    -- out   -- -- -- -- -- -- -- --  led(7................0)
    --

    gpio_in(15 downto 8) <= gpio_dipswitch;
    gpio_in( 3 downto 0) <= gpio_button;


    -- switch on all LEDs in case of break
    process
    begin
        wait until rising_edge(clk);
        gpio_led_n <= not zpu_i0_gpio_out(7 downto 0);
        if zpu_i0_break = '1' then
            gpio_led_n <= (others => '0');
        end if;
    end process;



end architecture rtl;

