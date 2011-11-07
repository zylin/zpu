library ieee;
use ieee.std_logic_1164.all;


entity top is
  port (
    clk        : in    std_logic;
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
    -- User Header A
    header_a   : inout std_logic_vector(19 downto 2);
    header_b   : inout std_logic_vector(19 downto 2)
    );
end entity top;

architecture rtl of top is


begin

  -- default output drivers
  -- to pass bitgen DRC 
  soft_tdo   <= '1';
  --
  sram0_a    <= (others => '1');
  sram0_lb_n <= '1';
  sram0_ub_n <= '1';
  sram0_cs_n <= '1';
  sram0_we_n <= '1';
  sram0_oe_n <= '1';
  --
  sram1_a    <= (others => '1');
  sram1_lb_n <= '1';
  sram1_ub_n <= '1';
  sram1_cs_n <= '1';
  sram1_we_n <= '1';
  sram1_oe_n <= '1';
  --
  rs232_tx   <= '1';
  rs232_rts  <= '1';
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
  led        <= (others => '0');
  --
  dig0_seg   <= (others => '0');
  dig1_seg   <= (others => '0');
  dig2_seg   <= (others => '0');
  dig3_seg   <= (others => '0');
  dig4_seg   <= (others => '0');
  dig5_seg   <= (others => '0');


end architecture rtl;

