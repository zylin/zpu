library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity adc_model is
    port (
        clk      : in std_logic;
        analog_p : in real;
        analog_n : in real;
        digital  : out std_logic_vector(13 downto 0);
        otr      : out std_logic
    );
end entity adc_model;


architecture model of adc_model is

    constant t_od : time := 19 ns; -- max output delay

    signal adc_value_0 : std_logic_vector( digital'range);
    signal adc_value_1 : std_logic_vector( digital'range);
    signal adc_value_2 : std_logic_vector( digital'range);

begin
    
    process
    begin
        wait until rising_edge( clk);
        adc_value_0 <= std_logic_vector( to_signed( integer( 1000.0 * (analog_p - analog_n)), digital'length));
        -- emulate 3 clock cycle pipeline delay
        adc_value_1 <= adc_value_0;
        adc_value_2 <= adc_value_1;
        digital     <= adc_value_2 after t_od;
    end process;

    otr <= '0';

end architecture model;
