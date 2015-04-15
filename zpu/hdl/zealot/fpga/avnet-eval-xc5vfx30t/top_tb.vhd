-- testbench for
-- Avnet Virtex 5 FX Evaluation Board
--
-- includes "model" for clock generation
-- simulate press on gpio_button(0) (=PB1) as reset
--
-- place models for external components (PHY, DDR2-RAM) in this file
--


library ieee;
use ieee.std_logic_1164.all;


entity top_tb is
end entity top_tb;

architecture testbench of top_tb is

    ---------------------------
    -- constant declarations
    constant clk_100MHz_period  : time := 1 sec / 100_000_000;  -- 100 MHz


    ---------------------------
    -- signal declarations
    signal simulation_run         : boolean   := true;
    signal tb_stop_simulation     : std_logic;
    --
    signal tb_clk_100MHz          : std_logic := '0';  -- 100 MHz clock
    signal tb_clk_socket          : std_logic := '0';  -- user clock
    signal tb_user_clk_p          : std_logic := '0';  -- diff user clock
    signal tb_user_clk_n          : std_logic := '0';  -- diff user clock
    --                                         
    --  RS232                                  
    signal tb_rs232_rx            : std_logic := '0';
    signal tb_rs232_tx            : std_logic;
    signal tb_rs232_rts           : std_logic := '0';
    signal tb_rs232_cts           : std_logic;
    --  RS232 USB                              
    signal tb_rs232_usb_rx        : std_logic := '0';
    signal tb_rs232_usb_tx        : std_logic;
    signal tb_rs232_usb_reset_n   : std_logic;
    --
    signal tb_gpio_led_n          : std_logic_vector(7 downto 0);
    signal tb_gpio_dipswitch      : std_logic_vector(7 downto 0) := (others => '0');
    signal tb_gpio_button         : std_logic_vector(3 downto 0) := (others => '0');
    --
    --  FLASH 8Mx16 
    signal tb_flash_a             : std_logic_vector(31 downto 7);
    signal tb_flash_dq            : std_logic_vector(15 downto 0);
    signal tb_flash_wen           : std_logic;
    signal tb_flash_oen           : std_logic_vector(0 downto 0);
    signal tb_flash_cen           : std_logic_vector(0 downto 0);
    signal tb_flash_rp_n          : std_logic;
    signal tb_flash_byte_n        : std_logic;
    signal tb_flash_adv_n         : std_logic;
    signal tb_flash_clk           : std_logic;
    signal tb_flash_wait          : std_logic := '0';
    --
    --  DDR2 SDRAM 16Mx32 
    signal tb_ddr2_odt            : std_logic_vector(0 downto 0) := (others => '0');
    signal tb_ddr2_a              : std_logic_vector(12 downto 0);
    signal tb_ddr2_ba             : std_logic_vector(1 downto 0);
    signal tb_ddr2_cas_n          : std_logic;
    signal tb_ddr2_cke            : std_logic;
    signal tb_ddr2_cs_n           : std_logic;
    signal tb_ddr2_ras_n          : std_logic;
    signal tb_ddr2_we_n           : std_logic;
    signal tb_ddr2_dm             : std_logic_vector(3 downto 0);
    signal tb_ddr2_dqs_p          : std_logic_vector(3 downto 0);
    signal tb_ddr2_dqs_n          : std_logic_vector(3 downto 0);
    signal tb_ddr2_dq             : std_logic_vector(31 downto 0);
    signal tb_ddr2_ck_p           : std_logic_vector(1 downto 0) := (others => '0');
    signal tb_ddr2_ck_n           : std_logic_vector(1 downto 0) := (others => '0');
    --
    --  Ethernet MAC 
    signal tb_gmii_txer           : std_logic;
    signal tb_gmii_tx_clk         : std_logic := '0';  -- 25 MHz
    signal tb_gmii_rx_clk         : std_logic := '0';  -- 25 MHz
    signal tb_gmii_gtc_clk        : std_logic;
    signal tb_gmii_crs            : std_logic := '0';
    signal tb_gmii_dv             : std_logic := '0';
    signal tb_gmii_rx_data        : std_logic_vector(7 downto 0);
    signal tb_gmii_col            : std_logic := '0';
    signal tb_gmii_rx_er          : std_logic := '0';
    signal tb_gmii_tx_en          : std_logic;
    signal tb_gmii_tx_data        : std_logic_vector(7 downto 0);
    signal tb_gbe_rst_n           : std_logic;
    signal tb_gbe_mdc             : std_logic;
    signal tb_gbe_mdio            : std_logic;
    signal tb_gbe_int_n           : std_logic;
    signal tb_gbe_mclk            : std_logic := '0';
    --
    --  SysACE CompactFlash 
    signal tb_sam_clk             : std_logic := '0';
    signal tb_sam_a               : std_logic_vector(6 downto 0);
    signal tb_sam_d               : std_logic_vector(15 downto 0);
    signal tb_sam_cen             : std_logic;
    signal tb_sam_oen             : std_logic;
    signal tb_sam_wen             : std_logic;
    signal tb_sam_mpirq           : std_logic := '0';
    signal tb_sam_brdy            : std_logic := '0';
    signal tb_sam_reset_n         : std_logic;
    --
    --  Expansion Header
    signal tb_exp1_se_io          : std_logic_vector(33 downto 0);
    signal tb_exp1_diff_p         : std_logic_vector(21 downto 0);
    signal tb_exp1_diff_n         : std_logic_vector(21 downto 0);
    signal tb_exp1_se_clk_out     : std_logic;
    signal tb_exp1_se_clk_in      : std_logic := '0';
    signal tb_exp1_diff_clk_out_p : std_logic;
    signal tb_exp1_diff_clk_out_n : std_logic;
    signal tb_exp1_diff_clk_in_p  : std_logic := '0';
    signal tb_exp1_diff_clk_in_n  : std_logic := '0';
    --
    -- Debug/Trace
    signal tb_atdd                : std_logic_vector(19 downto 8);
    signal tb_trace_ts10          : std_logic;
    signal tb_trace_ts20          : std_logic;
    signal tb_trace_ts1e          : std_logic;
    signal tb_trace_ts2e          : std_logic;
    signal tb_trace_ts3           : std_logic;
    signal tb_trace_ts4           : std_logic;
    signal tb_trace_ts5           : std_logic;
    signal tb_trace_ts6           : std_logic;
    signal tb_trace_clk           : std_logic := '0';
    signal tb_cpu_hreset          : std_logic := '0';
    signal tb_cpu_tdo             : std_logic;
    signal tb_cpu_tms             : std_logic := '0';
    signal tb_cpu_tdi             : std_logic := '0';
    signal tb_cpu_trst            : std_logic := '0';
    signal tb_cpu_tck             : std_logic := '0';
    signal tb_cpu_halt_n          : std_logic := '0';


begin


    -- generate clocks
    tb_clk_100MHz <= not tb_clk_100MHz after clk_100MHz_period / 2 when simulation_run;

    -- generate reset
    tb_gpio_button(0) <= '1', '0' after 6.66 * clk_100MHz_period;


    -- simulate keypress
    tb_gpio_button(2) <= '0', '1' after 55 us, '0' after 56 us;

    -- dut
    top_i0 : entity work.top
        port map (
            stop_simulation => tb_stop_simulation,  -- : out   std_logic;
            clk_100MHz          => tb_clk_100MHz,           -- : in    std_logic;
            clk_socket          => tb_clk_socket,           -- : in    std_logic;
            user_clk_p          => tb_user_clk_p,           -- : in    std_logic;
            user_clk_n          => tb_user_clk_n,           -- : in    std_logic;
            --                                         
            --  RS232                                  
            rs232_rx            => tb_rs232_rx,             -- : in    std_logic;
            rs232_tx            => tb_rs232_tx,             -- : out   std_logic;
            rs232_rts           => tb_rs232_rts,            -- : in    std_logic;
            rs232_cts           => tb_rs232_cts,            -- : out   std_logic;
            --  RS232 USB                              
            rs232_usb_rx        => tb_rs232_usb_rx,         -- : in    std_logic;
            rs232_usb_tx        => tb_rs232_usb_tx,         -- : out   std_logic;
            rs232_usb_reset_n   => tb_rs232_usb_reset_n,    -- : out   std_logic;
            --                                              
            gpio_led_n          => tb_gpio_led_n,           -- : out   std_logic_vector(7 downto 0);
            gpio_dipswitch      => tb_gpio_dipswitch,       -- : in    std_logic_vector(7 downto 0);
            gpio_button         => tb_gpio_button,          -- : in    std_logic_vector(3 downto 0);
            --
            --  FLASH 8Mx16 
            flash_a             => tb_flash_a,              -- : out   std_logic_vector(31 downto 7);
            flash_dq            => tb_flash_dq,             -- : inout std_logic_vector(15 downto 0);
            flash_wen           => tb_flash_wen,            -- : out   std_logic;
            flash_oen           => tb_flash_oen,            -- : out   std_logic_vector(0 downto 0);
            flash_cen           => tb_flash_cen,            -- : out   std_logic_vector(0 downto 0);
            flash_rp_n          => tb_flash_rp_n,           -- : out   std_logic;
            flash_byte_n        => tb_flash_byte_n,         -- : out   std_logic;
            flash_adv_n         => tb_flash_adv_n,          -- : out   std_logic;
            flash_clk           => tb_flash_clk,            -- : out   std_logic;
            flash_wait          => tb_flash_wait,           -- : in    std_logic;
            --
            --  DDR2 SDRAM 16Mx32 
            ddr2_odt            => tb_ddr2_odt,             -- : in    std_logic_vector(0 downto 0);
            ddr2_a              => tb_ddr2_a,               -- : out   std_logic_vector(12 downto 0);
            ddr2_ba             => tb_ddr2_ba,              -- : out   std_logic_vector(1 downto 0);
            ddr2_cas_n          => tb_ddr2_cas_n,           -- : out   std_logic;
            ddr2_cke            => tb_ddr2_cke,             -- : out   std_logic;
            ddr2_cs_n           => tb_ddr2_cs_n,            -- : out   std_logic;
            ddr2_ras_n          => tb_ddr2_ras_n,           -- : out   std_logic;
            ddr2_we_n           => tb_ddr2_we_n,            -- : out   std_logic;
            ddr2_dm             => tb_ddr2_dm,              -- : out   std_logic_vector(3 downto 0);
            ddr2_dqs_p          => tb_ddr2_dqs_p,           -- : inout std_logic_vector(3 downto 0);
            ddr2_dqs_n          => tb_ddr2_dqs_n,           -- : inout std_logic_vector(3 downto 0);
            ddr2_dq             => tb_ddr2_dq,              -- : inout std_logic_vector(31 downto 0);
            ddr2_ck_p           => tb_ddr2_ck_p,            -- : in    std_logic_vector(1 downto 0);
            ddr2_ck_n           => tb_ddr2_ck_n,            -- : in    std_logic_vector(1 downto 0);
            --
            --  Ethernet MAC 
            gmii_txer           => tb_gmii_txer,            -- : out   std_logic;
            gmii_tx_clk         => tb_gmii_tx_clk,          -- : in    std_logic;
            gmii_rx_clk         => tb_gmii_rx_clk,          -- : in    std_logic;
            gmii_gtc_clk        => tb_gmii_gtc_clk,         -- : out   std_logic;
            gmii_crs            => tb_gmii_crs,             -- : in    std_logic;
            gmii_dv             => tb_gmii_dv,              -- : in    std_logic;
            gmii_rx_data        => tb_gmii_rx_data,         -- : in    std_logic_vector(7 downto 0);
            gmii_col            => tb_gmii_col,             -- : in    std_logic;
            gmii_rx_er          => tb_gmii_rx_er,           -- : in    std_logic;
            gmii_tx_en          => tb_gmii_tx_en,           -- : out   std_logic;
            gmii_tx_data        => tb_gmii_tx_data,         -- : out   std_logic_vector(7 downto 0);
            gbe_rst_n           => tb_gbe_rst_n,            -- : out   std_logic;
            gbe_mdc             => tb_gbe_mdc,              -- : out   std_logic;
            gbe_mdio            => tb_gbe_mdio,             -- : inout std_logic;
            gbe_int_n           => tb_gbe_int_n,            -- : inout std_logic;
            gbe_mclk            => tb_gbe_mclk,             -- : in    std_logic;
            --
            --  SysACE CompactFlash 
            sam_clk             => tb_sam_clk,              -- : in    std_logic;
            sam_a               => tb_sam_a,                -- : out   std_logic_vector(6 downto 0);
            sam_d               => tb_sam_d,                -- : inout std_logic_vector(15 downto 0);
            sam_cen             => tb_sam_cen,              -- : out   std_logic;
            sam_oen             => tb_sam_oen,              -- : out   std_logic;
            sam_wen             => tb_sam_wen,              -- : out   std_logic;
            sam_mpirq           => tb_sam_mpirq,            -- : in    std_logic;
            sam_brdy            => tb_sam_brdy,             -- : in    std_logic;
            sam_reset_n         => tb_sam_reset_n,          -- : out   std_logic;
            --
            --  Expansion Header
            exp1_se_io          => tb_exp1_se_io,           -- : inout std_logic_vector(33 downto 0);
            exp1_diff_p         => tb_exp1_diff_p,          -- : inout std_logic_vector(21 downto 0);
            exp1_diff_n         => tb_exp1_diff_n,          -- : inout std_logic_vector(21 downto 0);
            exp1_se_clk_out     => tb_exp1_se_clk_out,      -- : out   std_logic;
            exp1_se_clk_in      => tb_exp1_se_clk_in,       -- : in    std_logic;
            exp1_diff_clk_out_p => tb_exp1_diff_clk_out_p,  -- : out   std_logic;
            exp1_diff_clk_out_n => tb_exp1_diff_clk_out_n,  -- : out   std_logic;
            exp1_diff_clk_in_p  => tb_exp1_diff_clk_in_p,   -- : in    std_logic;
            exp1_diff_clk_in_n  => tb_exp1_diff_clk_in_n,   -- : in    std_logic;
            --
            -- Debug/Trace
            atdd                => tb_atdd,                 -- : inout std_logic_vector(19 downto 8);
            trace_ts10          => tb_trace_ts10,           -- : inout std_logic;
            trace_ts20          => tb_trace_ts20,           -- : inout std_logic;
            trace_ts1e          => tb_trace_ts1e,           -- : inout std_logic;
            trace_ts2e          => tb_trace_ts2e,           -- : inout std_logic;
            trace_ts3           => tb_trace_ts3,            -- : inout std_logic;
            trace_ts4           => tb_trace_ts4,            -- : inout std_logic;
            trace_ts5           => tb_trace_ts5,            -- : inout std_logic;
            trace_ts6           => tb_trace_ts6,            -- : inout std_logic;
            trace_clk           => tb_trace_clk,            -- : in    std_logic;
            cpu_hreset          => tb_cpu_hreset,           -- : in    std_logic;
            cpu_tdo             => tb_cpu_tdo,              -- : out   std_logic;
            cpu_tms             => tb_cpu_tms,              -- : in    std_logic;
            cpu_tdi             => tb_cpu_tdi,              -- : in    std_logic;
            cpu_trst            => tb_cpu_trst,             -- : in    std_logic;
            cpu_tck             => tb_cpu_tck,              -- : in    std_logic;
            cpu_halt_n          => tb_cpu_halt_n            -- : in    std_logic
    );


    -- check for simulation stopping
    process (tb_stop_simulation)
    begin
        if tb_stop_simulation = '1' then
            report "Simulation end." severity note;
            simulation_run <= false;
        end if;
    end process;

end architecture testbench;
