

entity test_board is
end entity test_board;


library ieee;
use ieee.std_logic_1164.all;

library rena3;
use rena3.rena3_model_component_package.rena3_model;
use rena3.rena3_model_component_package.dds_model;
use rena3.test_pulse_gen_package.test_pulse_gen;


architecture board of test_board is

    signal testbench_trigger       : std_ulogic;
    signal test_pulse_gen_i0_pulse : real;

    signal dds_model_i0_vu         : real;
    signal dds_model_i0_vv         : real;

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

    dds_model_i0: dds_model
        port map(
            vu      => dds_model_i0_vu,
            vv      => dds_model_i0_vv
        );
   
    -- TODO generate C* stimuli from FPGA
    -- TODO generate CLF stimuli from FPGA
    -- TODO generate slow token register stimuli from FPGA
    -- TODO generate fast token register stimuli from FPGA
    -- TODO generate token stuff stimuli from FPGA
    rena3_model_i0: rena3_model
        port map(
            TEST        => test_pulse_gen_i0_pulse, --   : in  real;       -- +/-720mV step input to simulate signal. This signal is for testing
            VU          => dds_model_i0_vu,         --   : in  real;       -- 2 - 3V sine wave, U timing signal for sampling by fast trigger
            VV          => dds_model_i0_vv,         --   : in  real;       -- 2 - 3V sine wave, V timing signal for sampling by fast trigger
            DETECTOR_IN => (others => 0.0),         --   : in  real_array(0 to 35); -- Detector inputs pins
            AOUTP       => open,                    --   : out real;       -- ?, Positive differential output
            AOUTN       => open,                    --   : out real;       -- ?, Negative differential output
            CSHIFT      => '0',                     --   : in  std_ulogic; -- Shift one bit (from Cin) into the shift register on the rising edge
            CIN         => '0',                     --   : in  std_ulogic; -- Data input. Must be valid on the rising edge of CShift
            CS          => '0',                     --   : in  std_ulogic  -- Chip Select. After shifting 41 bits, pulse this signal high to load the
            FOUT        => open,                    --   : out std_ulogic; -- Fast token output for fast token register
            SOUT        => open,                    --   : out std_ulogic; -- Slow token output for slow token register
            TOUT        => open,                    --   : out std_ulogic; -- Token output from token chain. Goes high when chip is finished to pass
            TIN         => '1',                     --   : in  std_ulogic; -- Token input, Always set a 1 for first channel, or receives TOUT from
            SIN         => '1',                     --   : in  std_ulogic; -- Slow token input. Use with SHRCLK to load bits into slow token chain.
            FIN         => '1',                     --   : in  std_ulogic; -- Fast token input. Use with FHRCLK to load bits into slow token chain.
            SHRCLK      => '1',                     --   : in  std_ulogic; -- Slow hit register clock. Loads SIN bits on rising edge
            FHRCLK      => '1',                     --   : in  std_ulogic; -- Fast hit register clock. Loads FIN bits on rising edge
            CLF         => '0',                     --   : in  std_ulogic  -- This signal clears the fast latch (VU and VV sample circuit) when
            TCLK        => '1'                      --   : in  std_ulogic  -- This signal shifts the token from one channel to the next on the rising
        );

end architecture board;
