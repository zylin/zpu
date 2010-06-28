
library ieee;
use ieee.std_logic_1164.all;


package test_pulse_gen_package is

    component test_pulse_gen is
        port (
            trigger : in  std_ulogic;
            pulse   : out real
        );
    end component test_pulse_gen;

end package test_pulse_gen_package;





library ieee;
use ieee.std_logic_1164.all;


entity test_pulse_gen is
    port (
        trigger : in  std_ulogic;
        pulse   : out real
    );
end entity test_pulse_gen;


----------------------------------------
architecture behave of test_pulse_gen is

    constant time_resolution : time := 100 ps;

    constant pulse_height    : real := 0.707;
    constant pulse_length    : time := 50 ns;
    constant rise_time       : time := 10 ns;
    constant fall_time       : time := 10 ns;

begin

    --------------------
    process
    --------------------
        variable rise : real;
        variable fall : real;
    begin
        pulse <= 0.0;
        rise  := 0.0;
        wait until rising_edge(trigger);

        -- rise
        while rise < pulse_height loop
            rise  := rise + pulse_height / real(rise_time / time_resolution);
            pulse <= rise;
            wait for time_resolution;
        end loop;

        pulse <= pulse_height;
        fall  := pulse_height;
        wait for pulse_length;

        -- fall
        while fall > 0.0 loop
            fall  := fall - pulse_height / real(fall_time / time_resolution);
            pulse <= fall;
            wait for time_resolution;
        end loop;

        pulse <= 0.0;
    end process;

end architecture behave;
