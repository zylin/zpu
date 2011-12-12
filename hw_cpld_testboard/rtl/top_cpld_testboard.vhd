library ieee;
use ieee.std_logic_1164.all;

entity top_cpld_testboard is
	port(
        reset         : in  std_logic;
        clk           : in  std_logic;
        bcd_switch    : in  std_logic_vector(3 downto 0);
		led_n         : out std_logic_vector(7 downto 0)
	);
end top_cpld_testboard;

architecture rtl of top_cpld_testboard is

begin

    led_n <= (0 => '0', others => '1');

end architecture rtl;

