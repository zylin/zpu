-- top module of
-- SP601 evaluation board
--
-- using following external connections:
--
-- cpu_reset (SW9)      reset
-- LEDs                 output
-- USB_UART             communication 
--


library ieee;
use ieee.std_logic_1164.all;

library zpu;
use zpu.zpupkg.all;                     -- zpu_dbgo_t

library unisim;
use unisim.vcomponents.ibufgds;
use unisim.vcomponents.dcm_sp;


entity top is
    port (
        -- pragma translate_off 
        stop_simulation          : out   std_logic;
        -- pragma translate_on 
        --
        cpu_reset                : in    std_logic;  -- SW9 pushbutton (active-high)
        --
        -- DDR2 memory 128 MB
        ddr2_a                   : out   std_logic_vector(12 downto 0);
        ddr2_ba                  : out   std_logic_vector(2 downto 0);
        ddr2_cas_b               : out   std_logic;
        ddr2_ras_b               : out   std_logic;
        ddr2_we_b                : out   std_logic;
        ddr2_cke                 : out   std_logic;
        ddr2_clk_n               : out   std_logic;
        ddr2_clk_p               : out   std_logic;
        ddr2_dq                  : inout std_logic_vector(15 downto 0);
        ddr2_ldm                 : out   std_logic;
        ddr2_udm                 : out   std_logic;
        ddr2_ldqs_n              : inout std_logic;
        ddr2_ldqs_p              : inout std_logic;
        ddr2_udqs_n              : inout std_logic;
        ddr2_udqs_p              : inout std_logic;
        ddr2_odt                 : out   std_logic;
        --                                
        -- flash memory                        
        flash_a                  : out   std_logic_vector(24 downto 0);
        flash_d                  : inout std_logic_vector(7 downto 3);
        --
        fpga_d0_din_miso_miso1   : inout std_logic;  -- dual use
        fpga_d1_miso2            : inout std_logic;  -- dual use
        fpga_d2_miso3            : inout std_logic;  -- dual use
        flash_we_b               : out   std_logic;
        flash_oe_b               : out   std_logic;
        flash_ce_b               : out   std_logic;
        --
        -- FMC connector
        -- M2C   Mezzanine to Carrier
        -- C2M   Carrier to Mezzanine
        fmc_clk0_m2c_n           : in    std_logic;
        fmc_clk0_m2c_p           : in    std_logic;
        fmc_clk1_m2c_n           : in    std_logic;
        fmc_clk1_m2c_p           : in    std_logic;
        -- IIC addresses:
        -- M24C08:                 1010100..1010111
        -- 2kb EEPROM on FMC card: 1010010
        iic_scl_main             : inout std_logic;
        iic_sda_main             : inout std_logic;
        fmc_la00_cc_n            : inout std_logic;
        fmc_la00_cc_p            : inout std_logic;
        fmc_la01_cc_n            : inout std_logic;
        fmc_la01_cc_p            : inout std_logic;
        fmc_la02_n               : inout std_logic;
        fmc_la02_p               : inout std_logic;
        fmc_la03_n               : inout std_logic;
        fmc_la03_p               : inout std_logic;
        fmc_la04_n               : inout std_logic;
        fmc_la04_p               : inout std_logic;
        fmc_la05_n               : inout std_logic;
        fmc_la05_p               : inout std_logic;
        fmc_la06_n               : inout std_logic;
        fmc_la06_p               : inout std_logic;
        fmc_la07_n               : inout std_logic;
        fmc_la07_p               : inout std_logic;
        fmc_la08_n               : inout std_logic;
        fmc_la08_p               : inout std_logic;
        fmc_la09_n               : inout std_logic;
        fmc_la09_p               : inout std_logic;
        fmc_la10_n               : inout std_logic;
        fmc_la10_p               : inout std_logic;
        fmc_la11_n               : inout std_logic;
        fmc_la11_p               : inout std_logic;
        fmc_la12_n               : inout std_logic;
        fmc_la12_p               : inout std_logic;
        fmc_la13_n               : inout std_logic;
        fmc_la13_p               : inout std_logic;
        fmc_la14_n               : inout std_logic;
        fmc_la14_p               : inout std_logic;
        fmc_la15_n               : inout std_logic;
        fmc_la15_p               : inout std_logic;
        fmc_la16_n               : inout std_logic;
        fmc_la16_p               : inout std_logic;
        fmc_la17_cc_n            : inout std_logic;
        fmc_la17_cc_p            : inout std_logic;
        fmc_la18_cc_n            : inout std_logic;
        fmc_la18_cc_p            : inout std_logic;
        fmc_la19_n               : inout std_logic;
        fmc_la19_p               : inout std_logic;
        fmc_la20_n               : inout std_logic;
        fmc_la20_p               : inout std_logic;
        fmc_la21_n               : inout std_logic;
        fmc_la21_p               : inout std_logic;
        fmc_la22_n               : inout std_logic;
        fmc_la22_p               : inout std_logic;
        fmc_la23_n               : inout std_logic;
        fmc_la23_p               : inout std_logic;
        fmc_la24_n               : inout std_logic;
        fmc_la24_p               : inout std_logic;
        fmc_la25_n               : inout std_logic;
        fmc_la25_p               : inout std_logic;
        fmc_la26_n               : inout std_logic;
        fmc_la26_p               : inout std_logic;
        fmc_la27_n               : inout std_logic;
        fmc_la27_p               : inout std_logic;
        fmc_la28_n               : inout std_logic;
        fmc_la28_p               : inout std_logic;
        fmc_la29_n               : inout std_logic;
        fmc_la29_p               : inout std_logic;
        fmc_la30_n               : inout std_logic;
        fmc_la30_p               : inout std_logic;
        fmc_la31_n               : inout std_logic;
        fmc_la31_p               : inout std_logic;
        fmc_la32_n               : inout std_logic;
        fmc_la32_p               : inout std_logic;
        fmc_la33_n               : inout std_logic;
        fmc_la33_p               : inout std_logic;
        fmc_prsnt_m2c_l          : in    std_logic;
        fmc_pwr_good_flash_rst_b : out   std_logic;  -- multiple destinations: 1 of Q2 (LED DS1 driver), U1 AB2 FPGA_PROG (through series R260 DNP), 44 of U25
        --
        fpga_awake               : out   std_logic;
        fpga_cclk                : out   std_logic;
        fpga_cmp_clk             : in    std_logic;
        fpga_cmp_mosi            : in    std_logic;
        --
        fpga_hswapen             : in    std_logic;
        fpga_init_b              : out   std_logic;  -- low active
        fpga_m0_cmp_miso         : in    std_logic;  -- mode DIP switch SW1 active high
        fpga_m1                  : in    std_logic;  -- mode DIP switch SW1 active high
        fpga_mosi_csi_b_miso0    : inout std_logic;
        fpga_onchip_term1        : inout std_logic;
        fpga_onchip_term2        : inout std_logic;
        fpga_vtemp               : in    std_logic;
        --
        -- GPIOs
        gpio_button              : in    std_logic_vector(3 downto 0);  -- active high
        gpio_header_ls           : inout std_logic_vector(7 downto 0);
        gpio_led                 : out   std_logic_vector(3 downto 0);
        gpio_switch              : in    std_logic_vector(3 downto 0);  -- active high
        --
        -- Ethernet Gigabit PHY, 
        -- default settings:
        -- phy address    = 0b00111
        -- ANEG[3..0]     = "1111"
        -- ENA_XC         = 1
        -- DIS_125        = 1
        -- HWCFG_MD[3..0] = "1111"
        -- DIS_FC         = 1
        -- DIS_SLEEP      = 1
        -- SEL_BDT        = 0
        -- INT_POL        = 1
        -- 75/50Ohm       = 0
        phy_col                  : in    std_logic;
        phy_crs                  : in    std_logic;
        phy_int                  : in    std_logic;
        phy_mdc                  : out   std_logic;
        phy_mdio                 : inout std_logic;
        phy_reset                : out   std_logic;
        phy_rxclk                : in    std_logic;
        phy_rxctl_rxdv           : in    std_logic;
        phy_rxd                  : in    std_logic_vector(7 downto 0);
        phy_rxer                 : in    std_logic;
        phy_txclk                : in    std_logic;
        phy_txctl_txen           : out   std_logic;
        phy_txc_gtxclk           : out   std_logic;
        phy_txd                  : out   std_logic_vector(7 downto 0);
        phy_txer                 : out   std_logic;
        --
        --
        spi_cs_b                 : out   std_logic;
        --
        -- 200 MHz oscillator, jitter 50 ppm
        sysclk_n                 : in    std_logic;
        sysclk_p                 : in    std_logic;
        --
        -- RS232 via USB
        usb_1_cts                : out   std_logic;  -- function: RTS output
        usb_1_rts                : in    std_logic;  -- function: CTS input
        usb_1_rx                 : out   std_logic;  -- function: TX data out
        usb_1_tx                 : in    std_logic;  -- function: RX data in
        --
        --  27 MHz, oscillator socket
        user_clock               : in    std_logic;
        --
        -- user clock provided per SMA
        user_sma_clock_p         : in    std_logic;
        user_sma_clock_n         : in    std_logic
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
    constant clk_multiply  : positive := 2;  -- 2 for small, 2 for medium
    constant clk_divide    : positive := 5;  -- 4 for small, 5 for medium
    --
    --
    constant word_size_c   : natural  := 32;  -- 32 bits data path
    constant addr_w_c      : natural  := 18;  -- 18 bits address space=256 kB, 128 kB I/O
    --
    constant clk_frequency : positive := 200; -- input frequency for correct calculation


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
    signal dcm_sp_i0_clk0    : std_ulogic;
    signal dcm_sp_i0_clkfx   : std_ulogic;
    signal clk_fb            : std_ulogic;
    signal clk               : std_ulogic;
    --
    signal reset_shift_reg   : std_ulogic_vector(3 downto 0);
    signal reset_sync        : std_ulogic;
    --
    signal zpu_i0_dbg        : zpu_dbgo_t;  -- Debug info
    signal zpu_i0_break      : std_logic;
    --
    signal gpio_in           : std_logic_vector(31 downto 0) := (others => '0');
    signal zpu_i0_gpio_out   : std_logic_vector(31 downto 0);
    signal zpu_i0_gpio_dir   : std_logic_vector(31 downto 0);


begin

    -- default output drivers
    -- to pass bitgen DRC 
    -- outputs used by design are commented
    --
    ddr2_a                   <= (others => '1');
    ddr2_ba                  <= (others => '1');
    ddr2_cas_b               <= '1';
    ddr2_ras_b               <= '1';
    ddr2_we_b                <= '1';
    ddr2_cke                 <= '0';
    ddr2_clk_n               <= '0';
    ddr2_clk_p               <= '1';
    ddr2_dq                  <= (others => 'Z');
    ddr2_ldm                 <= '0';
    ddr2_udm                 <= '0';
    ddr2_ldqs_n              <= 'Z';
    ddr2_ldqs_p              <= 'Z';
    ddr2_udqs_n              <= 'Z';
    ddr2_udqs_p              <= 'Z';
    ddr2_odt                 <= '1';
    --
    flash_a                  <= (others => '1');
    flash_d                  <= (others => 'Z');
    flash_we_b               <= '1';
    flash_oe_b               <= '1';
    flash_ce_b               <= '1';
    --
    fpga_d0_din_miso_miso1   <= 'Z';
    fpga_d1_miso2            <= 'Z';
    fpga_d2_miso3            <= 'Z';
    --
    iic_scl_main             <= 'Z';
    iic_sda_main             <= 'Z';
    fmc_la00_cc_n            <= 'Z';
    fmc_la00_cc_p            <= 'Z';
    fmc_la01_cc_n            <= 'Z';
    fmc_la01_cc_p            <= 'Z';
    fmc_la02_n               <= 'Z';
    fmc_la02_p               <= 'Z';
    fmc_la03_n               <= 'Z';
    fmc_la03_p               <= 'Z';
    fmc_la04_n               <= 'Z';
    fmc_la04_p               <= 'Z';
    fmc_la05_n               <= 'Z';
    fmc_la05_p               <= 'Z';
    fmc_la06_n               <= 'Z';
    fmc_la06_p               <= 'Z';
    fmc_la07_n               <= 'Z';
    fmc_la07_p               <= 'Z';
    fmc_la08_n               <= 'Z';
    fmc_la08_p               <= 'Z';
    fmc_la09_n               <= 'Z';
    fmc_la09_p               <= 'Z';
    fmc_la10_n               <= 'Z';
    fmc_la10_p               <= 'Z';
    fmc_la11_n               <= 'Z';
    fmc_la11_p               <= 'Z';
    fmc_la12_n               <= 'Z';
    fmc_la12_p               <= 'Z';
    fmc_la13_n               <= 'Z';
    fmc_la13_p               <= 'Z';
    fmc_la14_n               <= 'Z';
    fmc_la14_p               <= 'Z';
    fmc_la15_n               <= 'Z';
    fmc_la15_p               <= 'Z';
    fmc_la16_n               <= 'Z';
    fmc_la16_p               <= 'Z';
    fmc_la17_cc_n            <= 'Z';
    fmc_la17_cc_p            <= 'Z';
    fmc_la18_cc_n            <= 'Z';
    fmc_la18_cc_p            <= 'Z';
    fmc_la19_n               <= 'Z';
    fmc_la19_p               <= 'Z';
    fmc_la20_n               <= 'Z';
    fmc_la20_p               <= 'Z';
    fmc_la21_n               <= 'Z';
    fmc_la21_p               <= 'Z';
    fmc_la22_n               <= 'Z';
    fmc_la22_p               <= 'Z';
    fmc_la23_n               <= 'Z';
    fmc_la23_p               <= 'Z';
    fmc_la24_n               <= 'Z';
    fmc_la24_p               <= 'Z';
    fmc_la25_n               <= 'Z';
    fmc_la25_p               <= 'Z';
    fmc_la26_n               <= 'Z';
    fmc_la26_p               <= 'Z';
    fmc_la27_n               <= 'Z';
    fmc_la27_p               <= 'Z';
    fmc_la28_n               <= 'Z';
    fmc_la28_p               <= 'Z';
    fmc_la29_n               <= 'Z';
    fmc_la29_p               <= 'Z';
    fmc_la30_n               <= 'Z';
    fmc_la30_p               <= 'Z';
    fmc_la31_n               <= 'Z';
    fmc_la31_p               <= 'Z';
    fmc_la32_n               <= 'Z';
    fmc_la32_p               <= 'Z';
    fmc_la33_n               <= 'Z';
    fmc_la33_p               <= 'Z';
    fmc_pwr_good_flash_rst_b <= '1';
    --
    fpga_awake               <= '1';
    fpga_cclk                <= '1';    -- SPI clk
    fpga_init_b              <= '1';
    fpga_mosi_csi_b_miso0    <= 'Z';
    fpga_onchip_term1        <= 'Z';
    fpga_onchip_term2        <= 'Z';
    --
    --gpio_led               <= (others => '0'); 
    --gpio_header_ls         <= (others => 'Z');
    --
    phy_mdc                  <= '0';
    phy_mdio                 <= 'Z';
    phy_reset                <= '0';
    phy_txc_gtxclk           <= '0';
    phy_txctl_txen           <= '0';
    phy_txd                  <= (others => '1');
    phy_txer                 <= '0';
    --
    spi_cs_b                 <= '1';
    --
    --usb_1_rx               <= '1';    -- function: TX data out
    usb_1_cts                <= '1';    -- function: RTS


    -- global differential input buffer 
    ibufgds_i0 : ibufgds
        generic map (
            diff_term => true
            )
        port map (
            i  => sysclk_p,
            ib => sysclk_n,
            o  => sys_clk
            );

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
            clkin => sys_clk,
            clk0  => dcm_sp_i0_clk0,
            clkfx => dcm_sp_i0_clkfx,
            clkfb => clk_fb
            );

    clk_fb <= dcm_sp_i0_clk0;
    clk    <= dcm_sp_i0_clkfx;


    -- reset synchronizer
    -- generate synchronous reset
    reset_synchronizer : process(clk, cpu_reset)
    begin
        if cpu_reset = '1' then
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
                clk_i      => clk,             -- : in  std_logic;   -- CPU clock
                rst_i      => reset_sync,      -- : in  std_logic;   -- Reset
                break_o    => zpu_i0_break,    -- : out std_logic;   -- Break executed
                dbg_o      => zpu_i0_dbg,      -- : out zpu_dbgo_t;  -- Debug info
                rs232_tx_o => usb_1_rx,        -- : out std_logic;   -- UART Tx
                rs232_rx_i => usb_1_tx,        -- : in  std_logic    -- UART Rx
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
                clk_i      => clk,             -- : in  std_logic;   -- CPU clock
                rst_i      => reset_sync,      -- : in  std_logic;   -- Reset
                break_o    => zpu_i0_break,    -- : out std_logic;   -- Break executed
                dbg_o      => zpu_i0_dbg,      -- : out zpu_dbgo_t;  -- Debug info
                rs232_tx_o => usb_1_rx,        -- : out std_logic;   -- UART Tx
                rs232_rx_i => usb_1_tx,        -- : in  std_logic    -- UART Rx
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
    gpio_in(23 downto 16) <= gpio_header_ls;
    gpio_in(11 downto  8) <= gpio_switch;
    gpio_in( 3 downto  0) <= gpio_button;

    -- 3-state buffers for header_ls
    gpio_header_ls(7) <= zpu_i0_gpio_out(23) when zpu_i0_gpio_dir(23) = '0' else 'Z';
    gpio_header_ls(6) <= zpu_i0_gpio_out(22) when zpu_i0_gpio_dir(22) = '0' else 'Z';
    gpio_header_ls(5) <= zpu_i0_gpio_out(21) when zpu_i0_gpio_dir(21) = '0' else 'Z';
    gpio_header_ls(4) <= zpu_i0_gpio_out(20) when zpu_i0_gpio_dir(20) = '0' else 'Z';
    gpio_header_ls(3) <= zpu_i0_gpio_out(19) when zpu_i0_gpio_dir(19) = '0' else 'Z';
    gpio_header_ls(2) <= zpu_i0_gpio_out(18) when zpu_i0_gpio_dir(18) = '0' else 'Z';
    gpio_header_ls(1) <= zpu_i0_gpio_out(17) when zpu_i0_gpio_dir(17) = '0' else 'Z';
    gpio_header_ls(0) <= zpu_i0_gpio_out(16) when zpu_i0_gpio_dir(16) = '0' else 'Z';

    -- switch on all LEDs in case of break
    process
    begin
        wait until rising_edge(clk);
        gpio_led <= zpu_i0_gpio_out(3 downto 0); 
        if zpu_i0_break = '1' then
            gpio_led <= (others => '1');
        end if;
    end process;



end architecture rtl;
