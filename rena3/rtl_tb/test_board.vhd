

entity test_board is
end entity test_board;


library ieee;
use ieee.std_logic_1164.all;

library rena3;
--use rena3.component_package.controller_top;
use rena3.rena3_model_component_package.rena3_model;
use rena3.rena3_model_component_package.dds_model;
use rena3.test_pulse_gen_package.test_pulse_gen;


----------------------------------------
architecture board of test_board is
    
    constant clk_period                    : time       := ( 1 sec/ 50_000_000); -- 50 MHz
                                           
    signal simulation_run                  : boolean    := true;
    signal clk                             : std_ulogic := '1';
    signal reset                           : std_ulogic;
                                           
    signal testbench_trigger               : std_ulogic;
    signal test_pulse_gen_i0_pulse         : real;
                                           
    signal dds_model_i0_vu                 : real;
    signal dds_model_i0_vv                 : real;

    signal rena3_model_i0_ts               : std_ulogic;
    signal rena3_model_i0_tf               : std_ulogic;
    signal rena3_model_i0_fout             : std_ulogic;
    signal rena3_model_i0_sout             : std_ulogic;
    signal rena3_model_i0_tout             : std_ulogic;

    signal controller_top_i0_rena3_cshift  : std_ulogic;
    signal controller_top_i0_rena3_cin     : std_ulogic; 
    signal controller_top_i0_rena3_cs      : std_ulogic;    
    signal controller_top_i0_rena3_read    : std_ulogic;
    signal controller_top_i0_rena3_tin     : std_ulogic;
    signal controller_top_i0_rena3_sin     : std_ulogic;
    signal controller_top_i0_rena3_fin     : std_ulogic;
    signal controller_top_i0_rena3_shrclk  : std_ulogic;
    signal controller_top_i0_rena3_fhrclk  : std_ulogic;
    signal controller_top_i0_rena3_acquire : std_ulogic;
    signal controller_top_i0_rena3_cls     : std_ulogic;
    signal controller_top_i0_rena3_clf     : std_ulogic;
    signal controller_top_i0_rena3_tclk    : std_ulogic;
    signal controller_top_i0_break         : std_ulogic;





begin
   
    -- clock and reset generator 
    clk   <= not clk after clk_period/2 when simulation_run;
    reset <= '1', '0' after 10 * clk_period;

    -- TODO generate testpulses from FPGA
    --------------------
    gen_trigger_events: process
    --------------------
    begin

        testbench_trigger <= '0';
        wait until reset = '0';
    
        while controller_top_i0_break = '0' loop
            wait for  99 us;
            testbench_trigger <= '1';
            wait for   1 us;
            testbench_trigger <= '0';
        end loop;

        report "---" & LF & "ZPU sends break" & LF & "End simulation." severity note;
        simulation_run        <= false;
        wait;

    end process gen_trigger_events;
    
    --------------------
    test_pulse_gen_i0: test_pulse_gen
        port map(
            trigger => testbench_trigger,
            pulse   => test_pulse_gen_i0_pulse 
        );

    --------------------
    dds_model_i0: dds_model
        port map(
            run     => simulation_run,
            vu      => dds_model_i0_vu,
            vv      => dds_model_i0_vv
        );
   
    --------------------
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
            CSHIFT      => controller_top_i0_rena3_cshift,  --   : in  std_ulogic; -- Shift one bit (from Cin) into the shift register on the rising edge
            CIN         => controller_top_i0_rena3_cin,     --   : in  std_ulogic; -- Data input. Must be valid on the rising edge of CShift
            CS          => controller_top_i0_rena3_cs,      --   : in  std_ulogic  -- Chip Select. After shifting 41 bits, pulse this signal high to load the
            TS_N        => open,                            --   : out std_ulogic; -- Differential out, Slow trigger output, Negative output
            TS_P        => rena3_model_i0_ts,               --   : out std_ulogic; -- Differential out, Slow trigger output, positive output
            TF_N        => open,                            --   : out std_ulogic; -- Differential out, Fast trigger output, Negative Output
            TF_P        => rena3_model_i0_tf,               --   : out std_ulogic; -- Differential out, Fast trigger output, positive output
            FOUT        => rena3_model_i0_fout,             --   : out std_ulogic; -- Fast token output for fast token register
            SOUT        => rena3_model_i0_sout,             --   : out std_ulogic; -- Slow token output for slow token register
            TOUT        => rena3_model_i0_tout,             --   : out std_ulogic; -- Token output from token chain. Goes high when chip is finished to pass
            READ        => controller_top_i0_rena3_read,    --   : in  std_ulogic; -- Enables output of analog signals within a channel. Turns on the analog
            TIN         => controller_top_i0_rena3_tin,     --   : in  std_ulogic; -- Token input, Always set a 1 for first channel, or receives TOUT from
            SIN         => controller_top_i0_rena3_sin,     --   : in  std_ulogic; -- Slow token input. Use with SHRCLK to load bits into slow token chain.
            FIN         => controller_top_i0_rena3_fin,     --   : in  std_ulogic; -- Fast token input. Use with FHRCLK to load bits into slow token chain.
            SHRCLK      => controller_top_i0_rena3_shrclk,  --   : in  std_ulogic; -- Slow hit register clock. Loads SIN bits on rising edge
            FHRCLK      => controller_top_i0_rena3_fhrclk,  --   : in  std_ulogic; -- Fast hit register clock. Loads FIN bits on rising edge
            ACQUIRE_P   => controller_top_i0_rena3_acquire, --   : in  std_ulogic; -- Positive differential input, Peak detector is active when this signal is asserted (high).
            ACQUIRE_N   => '0', --not(controller_top_i0_rena3_acquire), --   : in  std_ulogic; -- Negative differential input, Peak detector is active when this signal is asserted (low)
            CLS_P       => controller_top_i0_rena3_cls,     --   : in  std_ulogic; -- Positive differential input, Peak detector reset signal. Resets the peak
                                                    -- detector when asserted (high). Also clears the token register.
            CLS_N       => '0',--not(controller_top_i0_rena3_cls),--   : in  std_ulogic; -- Negative differential input, Peak detector reset signal. Resets the peak
            CLF         => controller_top_i0_rena3_clf,     --   : in  std_ulogic  -- This signal clears the fast latch (VU and VV sample circuit) when
            TCLK        => controller_top_i0_rena3_tclk     --   : in  std_ulogic  -- This signal shifts the token from one channel to the next on the rising
        );


--  controller_top_i0: controller_top
--      port map (
--      clk            => clk,                             --   : in  std_ulogic;
--      reset          => reset,                           --   : in  std_ulogic;
--      -- rena 3                                          
--      rena3_ts       => rena3_model_i0_ts,               --   : in  std_ulogic;
--      rena3_tf       => rena3_model_i0_tf,               --   : in  std_ulogic;
--      rena3_fout     => rena3_model_i0_fout,             --   : in  std_ulogic;
--      rena3_sout     => rena3_model_i0_sout,             --   : in  std_ulogic;
--      rena3_tout     => rena3_model_i0_tout,             --   : in  std_ulogic;
--      --                                                 
--      rena3_chsift   => controller_top_i0_rena3_cshift,  --   : out std_ulogic;
--      rena3_cin      => controller_top_i0_rena3_cin,     --   : out std_ulogic;
--      rena3_cs       => controller_top_i0_rena3_cs,      --   : out std_ulogic;
--      rena3_read     => controller_top_i0_rena3_read,    --   : out std_ulogic;
--      rena3_tin      => controller_top_i0_rena3_tin,     --   : out std_ulogic;
--      rena3_sin      => controller_top_i0_rena3_sin,     --   : out std_ulogic;
--      rena3_fin      => controller_top_i0_rena3_fin,     --   : out std_ulogic;
--      rena3_shrclk   => controller_top_i0_rena3_shrclk,  --   : out std_ulogic;
--      rena3_fhrclk   => controller_top_i0_rena3_fhrclk,  --   : out std_ulogic;
--      rena3_acquire  => controller_top_i0_rena3_acquire, --   : out std_ulogic;
--      rena3_cls      => controller_top_i0_rena3_cls,     --   : out std_ulogic;
--      rena3_clf      => controller_top_i0_rena3_clf,     --   : out std_ulogic;
--      rena3_tclk     => controller_top_i0_rena3_tclk,    --   : out std_ulogic;
--      --
--      break          => controller_top_i0_break          --   : out std_ulogic
--  );

end architecture board;
