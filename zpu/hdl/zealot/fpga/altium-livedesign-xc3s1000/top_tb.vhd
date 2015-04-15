-- testbench for
-- Altium LiveDesign Board
--
-- includes "model" for clock generation
-- simulate press on test/reset as reset
--
-- place models for external components (SRAM, PS2) in this file
--


library ieee;
use ieee.std_logic_1164.all;


entity top_tb is
end entity top_tb;

architecture testbench of top_tb is

    ---------------------------
    -- constant declarations
    constant clk_period : time := 1 sec / 50_000_000;  -- 50 MHz


    ---------------------------
    -- signal declarations
    signal simulation_run     : boolean := true;
    signal tb_stop_simulation : std_logic;
    --
    signal tb_clk             : std_logic                     := '0';
    signal tb_reset_n         : std_logic;
    --
    -- soft JTAG
    signal tb_soft_tdo        : std_logic;
    signal tb_soft_tms        : std_logic                     := '1';
    signal tb_soft_tdi        : std_logic                     := '1';
    signal tb_soft_tck        : std_logic                     := '1';
    --
    -- SRAM 0 (256k x 16) pin connections
    signal tb_sram0_a         : std_logic_vector(18 downto 0);
    signal tb_sram0_d         : std_logic_vector(15 downto 0) := (others => 'Z');
    signal tb_sram0_lb_n      : std_logic;
    signal tb_sram0_ub_n      : std_logic;
    signal tb_sram0_cs_n      : std_logic;     -- chip select
    signal tb_sram0_we_n      : std_logic;     -- write-enable
    signal tb_sram0_oe_n      : std_logic;     -- output enable
    --
    -- SRAM 1 (256k x 16) pin connections
    signal tb_sram1_a         : std_logic_vector(18 downto 0);
    signal tb_sram1_d         : std_logic_vector(15 downto 0) := (others => 'Z');
    signal tb_sram1_lb_n      : std_logic;
    signal tb_sram1_ub_n      : std_logic;
    signal tb_sram1_cs_n      : std_logic;     -- chip select
    signal tb_sram1_we_n      : std_logic;     -- write-enable
    signal tb_sram1_oe_n      : std_logic;     -- output enable
    --
    -- RS232
    signal tb_rs232_rx        : std_logic                     := '1';
    signal tb_rs232_tx        : std_logic;
    signal tb_rs232_cts       : std_logic                     := '1';
    signal tb_rs232_rts       : std_logic;
    --
    -- PS2 connectors
    signal tb_mouse_clk       : std_logic                     := 'Z';
    signal tb_mouse_data      : std_logic                     := 'Z';
    signal tb_kbd_clk         : std_logic                     := 'Z';
    signal tb_kbd_data        : std_logic                     := 'Z';
    --
    -- vga output
    signal tb_vga_red         : std_logic_vector(7 downto 5);
    signal tb_vga_green       : std_logic_vector(7 downto 5);
    signal tb_vga_blue        : std_logic_vector(7 downto 5);
    signal tb_vga_hsync       : std_logic;
    signal tb_vga_vsync       : std_logic;
    --
    -- Audio out
    signal tb_audio_r         : std_logic;
    signal tb_audio_l         : std_logic;
    --
    -- GPIOs
    signal tb_switch_n        : std_logic_vector(7 downto 0)  := (others => '1');
    signal tb_button_n        : std_logic_vector(5 downto 0)  := (others => '1');
    signal tb_led             : std_logic_vector(7 downto 0);
    --
    -- seven segment display
    signal tb_dig0_seg        : std_logic_vector(7 downto 0);
    signal tb_dig1_seg        : std_logic_vector(7 downto 0);
    signal tb_dig2_seg        : std_logic_vector(7 downto 0);
    signal tb_dig3_seg        : std_logic_vector(7 downto 0);
    signal tb_dig4_seg        : std_logic_vector(7 downto 0);
    signal tb_dig5_seg        : std_logic_vector(7 downto 0);
    --
    -- User Header A
    signal tb_header_a        : std_logic_vector(19 downto 2) := (others => 'Z');
    signal tb_header_b        : std_logic_vector(19 downto 2) := (others => 'Z');

begin

    -- generate clock
    tb_clk <= not tb_clk after clk_period / 2 when simulation_run;

    -- generate reset
    tb_reset_n <= '0', '1' after 6.66 * clk_period;


    -- simulate keypress
    tb_button_n(2) <= '1', '0' after 50 us, '1' after 52 us;

    -- dut
    top_i0 : entity work.top
        port map (
            stop_simulation => tb_stop_simulation, -- : out   std_logic;
            --
            clk_50     => tb_clk,        -- : in    std_logic;
            reset_n    => tb_reset_n,    -- : in    std_logic;
            --
            -- soft JTAG
            soft_tdo   => tb_soft_tdo,   -- : out   std_logic;
            soft_tms   => tb_soft_tms,   -- : in    std_logic;
            soft_tdi   => tb_soft_tdi,   -- : in    std_logic;
            soft_tck   => tb_soft_tck,   -- : in    std_logic;
            --
            -- SRAM 0 (256k x 16) pin connections
            sram0_a    => tb_sram0_a,    -- : out   std_logic_vector(18 downto 0);
            sram0_d    => tb_sram0_d,    -- : inout std_logic_vector(15 downto 0);
            sram0_lb_n => tb_sram0_lb_n, -- : out   std_logic;
            sram0_ub_n => tb_sram0_ub_n, -- : out   std_logic;
            sram0_cs_n => tb_sram0_cs_n, -- : out   std_logic;       -- chip select
            sram0_we_n => tb_sram0_we_n, -- : out   std_logic;       -- write-enable
            sram0_oe_n => tb_sram0_oe_n, -- : out   std_logic;       -- output enable
            --
            -- SRAM 1 (256k x 16) pin connections
            sram1_a    => tb_sram1_a,    -- : out   std_logic_vector(18 downto 0);
            sram1_d    => tb_sram1_d,    -- : inout std_logic_vector(15 downto 0);
            sram1_lb_n => tb_sram1_lb_n, -- : out   std_logic;
            sram1_ub_n => tb_sram1_ub_n, -- : out   std_logic;
            sram1_cs_n => tb_sram1_cs_n, -- : out   std_logic;       -- chip select
            sram1_we_n => tb_sram1_we_n, -- : out   std_logic;       -- write-enable
            sram1_oe_n => tb_sram1_oe_n, -- : out   std_logic;       -- output enable
            --
            -- RS232
            rs232_rx   => tb_rs232_rx,   -- : in    std_logic;
            rs232_tx   => tb_rs232_tx,   -- : out   std_logic;
            rs232_cts  => tb_rs232_cts,  -- : in    std_logic;
            rs232_rts  => tb_rs232_rts,  -- : out   std_logic;
            --
            -- PS2 connectors
            mouse_clk  => tb_mouse_clk,  -- : inout std_logic;
            mouse_data => tb_mouse_data, -- : inout std_logic;
            kbd_clk    => tb_kbd_clk,    -- : inout std_logic;
            kbd_data   => tb_kbd_data,   -- : inout std_logic;
            --
            -- vga output
            vga_red    => tb_vga_red,    -- : out   std_logic_vector(7 downto 5);
            vga_green  => tb_vga_green,  -- : out   std_logic_vector(7 downto 5);
            vga_blue   => tb_vga_blue,   -- : out   std_logic_vector(7 downto 5);
            vga_hsync  => tb_vga_hsync,  -- : out   std_logic;
            vga_vsync  => tb_vga_vsync,  -- : out   std_logic;
            --
            -- Audio out
            audio_r    => tb_audio_r,    -- : out   std_logic;
            audio_l    => tb_audio_l,    -- : out   std_logic;
            --
            -- GPIOs
            switch_n   => tb_switch_n,   -- : in    std_logic_vector(7 downto 0);
            button_n   => tb_button_n,   -- : in    std_logic_vector(5 downto 0);
            led        => tb_led,        -- : out   std_logic_vector(7 downto 0);
            --
            -- seven segment display
            dig0_seg   => tb_dig0_seg,   -- : out   std_logic_vector(7 downto 0);
            dig1_seg   => tb_dig1_seg,   -- : out   std_logic_vector(7 downto 0);
            dig2_seg   => tb_dig2_seg,   -- : out   std_logic_vector(7 downto 0);
            dig3_seg   => tb_dig3_seg,   -- : out   std_logic_vector(7 downto 0);
            dig4_seg   => tb_dig4_seg,   -- : out   std_logic_vector(7 downto 0);
            dig5_seg   => tb_dig5_seg,   -- : out   std_logic_vector(7 downto 0);
            --
            -- User Header
            header_a   => tb_header_a,   -- : inout std_logic_vector(19 downto 2);
            header_b   => tb_header_b    -- : inout std_logic_vector(19 downto 2)
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

