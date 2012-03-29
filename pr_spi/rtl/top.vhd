library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity top is
	port(
        reset_n       : in  std_logic;
        clk           : in  std_logic;
        dip_switch_n  : in  std_logic_vector(3 downto 0);
        button_n      : in  std_logic_vector(1 downto 0);		  
		led_n         : out std_logic_vector(7 downto 0);
        ssio_do       : in  std_logic;
        ssio_clk      : in  std_logic;
        ssio_lo       : in  std_logic
	);
end entity top;


architecture rtl of top is

    signal shift_reg : std_logic_vector(15 downto 0) := (others => '1');

begin

--  led_n <= (0 => '0', others => '1');

    process
    begin
        wait until rising_edge( ssio_clk);
        shift_reg <= shift_reg( shift_reg'high - 1 downto 0) & ssio_do;
    end process;


    process
    begin
        wait until rising_edge( ssio_lo);
        led_n <= not shift_reg(7 downto 0);
    end process;


end architecture rtl;

