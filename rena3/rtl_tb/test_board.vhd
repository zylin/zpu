

entity test_board is
end entity test_board;


library ieee;
use ieee.std_logic_1164.all;

library rena3;
use rena3.rena3_model_component_package.rena3_model;
use rena3.test_pulse_gen_package.test_pulse_gen;


architecture board of test_board is

    signal testbench_trigger       : std_ulogic;
    signal test_pulse_gen_i0_pulse : real;

begin
    
    -- stimuli

    -- TODO generate testpulses from FPGA
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
   
    -- TODO generate C* stimuli from FPGA
    rena3_model_i0: rena3_model
        port map(
            TEST        => test_pulse_gen_i0_pulse, --   : in  real;       -- +/-720mV step input to simulate signal. This signal is for testing
            VU          => 0.0,                     --   : in  real;       -- 2 - 3V sine wave, U timing signal for sampling by fast trigger
            VV          => 1.0,                     --   : in  real;       -- 2 - 3V sine wave, V timing signal for sampling by fast trigger
            DETECTOR_IN => (others => 0.0),         --   : in  real_array(0 to 35); -- Detector inputs pins
            CSHIFT      => '0',                     --   : in  std_ulogic; -- Shift one bit (from Cin) into the shift register on the rising edge
            CIN         => '0',                     --   : in  std_ulogic; -- Data input. Must be valid on the rising edge of CShift
            CS          => '0'                      --   : in  std_ulogic  -- Chip Select. After shifting 41 bits, pulse this signal high to load the
        );

end architecture board;
