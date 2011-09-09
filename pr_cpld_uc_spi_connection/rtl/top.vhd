------------------------------------------------------------
-- test for spi slave on cpld
--

library ieee;
use ieee.std_logic_1164.all;


entity top is
    port (
        f1_07_gck3    : in  std_logic;
        f1_06         : in  std_logic;
        f1_08         : in  std_logic;
        f1_09         : in  std_logic;
        f1_10         : in  std_logic;
        f1_11         : in  std_logic;
        f1_12         : in  std_logic;
        f1_13         : in  std_logic;
        f1_14         : out std_logic;
        f1_15         : out std_logic;
        f1_16         : out std_logic;
        f1_17         : out std_logic;
        f2_17         : out std_logic;
        f2_16         : out std_logic;
        f2_15         : out std_logic;
        f2_14         : out std_logic;
        f2_13         : in  std_logic;
        f2_12         : in  std_logic;
        f2_11         : in  std_logic;
        f2_10         : in  std_logic;
        f2_09         : in  std_logic;
        f2_08         : in  std_logic;
        f2_07         : in  std_logic;
        f2_06_gsr     : in  std_logic;
        f2_05_gts2    : in  std_logic;
        f2_03_io_gts1 : in  std_logic; 
        f2_04         : in  std_logic;
        f2_02         : in  std_logic;
        f2_01         : in  std_logic;
        f1_01         : in  std_logic;
        f1_02         : out std_logic;
        f1_04         : in  std_logic;
        f1_03_gck1    : in  std_logic;
        f1_05_gck2    : in  std_logic
    );
end entity top;

architecture rtl of top is

    signal  top_sdi            : std_logic;
    signal  sr_i0_sdo          : std_logic;
    signal  top_clk            : std_logic;
    signal  top_cs_n : std_logic; -- 1=latch, 0=shift
    signal  top_port_in        : std_ulogic_vector(7 downto 0);
    signal  sr_i0_port_out     : std_ulogic_vector(7 downto 0);

begin

    -- spi
    top_clk   <= f1_05_gck2; -- SCLK
    top_cs_n  <= f1_07_gck3; -- /CS 
    top_sdi   <= f1_04;      -- SDI
    f1_02     <= sr_i0_sdo;  -- SDO 

    -- button
    top_port_in <= (others => f2_06_gsr);

    sr_cpld_i0: entity work.sr_cpld
        port map ( 
            sdi      => top_sdi,       -- : in  std_logic;
            sdo      => sr_i0_sdo,     -- : out std_logic;
            clk      => top_clk,       -- : in  std_logic;
            cs_n     => top_cs_n,      -- : in  std_logic; --edge sensitive chip select 
            port_in  => top_port_in,   -- : in  std_ulogic_vector( port_count_in -1 downto 0);
            port_out => sr_i0_port_out -- : out std_ulogic_vector( port_count_out-1 downto 0)
        );

    -- leds
    f1_14 <= not sr_i0_port_out(0);
    f1_15 <= not sr_i0_port_out(1);
    f1_16 <= not sr_i0_port_out(2);
    f1_17 <= not sr_i0_port_out(3);
    f2_17 <= not sr_i0_port_out(4);
    f2_16 <= not sr_i0_port_out(5);
    f2_15 <= not sr_i0_port_out(6);
    f2_14 <= not sr_i0_port_out(7);




end architecture rtl;
