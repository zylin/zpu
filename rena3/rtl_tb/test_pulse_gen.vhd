
library ieee;
use ieee.std_logic_1164.all;


entity test_pulse_gen is
    port (
        trigger : in  std_ulogic;
        pulse   : out real
    );
end entity test_pulse_gen;


architecture behave of test_pulse_gen is

    constant pulse_height : real := 0.7;
    constant pulse_length : time := 10 us;

begin

    process
    begin
        pulse <= 0.0;
        wait until rising_edge(trigger);
        pulse <= pulse_height;
        wait for pulse_length;
        pulse <= 0.0;
    end process;

end architecture behave;
