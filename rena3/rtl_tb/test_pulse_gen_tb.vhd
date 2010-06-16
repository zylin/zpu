
entity test_pulse_gen_tb is
end entity test_pulse_gen_tb;


library ieee;
use ieee.std_logic_1164.all;

architecture testbench of test_pulse_gen_tb is
    
    component test_pulse_gen is
        port (
            trigger : in  std_ulogic;
            pulse   : out real
        );
    end component test_pulse_gen;

    signal testbench_trigger       : std_ulogic;
    signal test_pulse_gen_i0_pulse : real;

begin

    gen_trigger_events: process
    begin

        testbench_trigger <= '0';
    
        for i in 1 to 3 loop
            wait for 999 us;
            testbench_trigger <= '1';
            wait for   1 us;
            testbench_trigger <= '0';
        end loop;

        wait for 500 us;
        report "End simulation." severity note;
        wait;

    end process gen_trigger_events;


    test_pulse_gen_i0: test_pulse_gen
        port map(
            trigger => testbench_trigger,
            pulse   => test_pulse_gen_i0_pulse 
        );
end;
