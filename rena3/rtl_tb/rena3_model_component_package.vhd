--
-- this model describes the behaviour of the RENA3 ASIC
--



library ieee;
use ieee.std_logic_1164.all;

library rena3;
use rena3.rena3_model_types_package.all;


package rena3_model_component_package is


    component rena3_model is

        port (
            -- Pad Name                         Description
            -- VRI         : in  std_ulogic; -- 2V, Very low noise power supply
            -- VDDA        : in  std_ulogic; -- 5V, Analog power supply
            -- VDDA1       : in  std_ulogic; -- 5V, Low noise analog power supply #1
            -- VDDA2       : in  std_ulogic; -- 5V, Low noise analog power supply #2
            -- VDD         : in  std_ulogic; -- 5V, Digital power supply
            -- VSS         : in  std_ulogic; -- 0V, Digital ground
            -- VSSA1       : in  std_ulogic; -- 0V, Low noise analog ground
            -- VSSA        : in  std_ulogic; -- 0V, Analog ground
            TEST           : in  real;       -- +/-720mV step input to simulate signal. This signal is for testing
                                             -- channels.
            -- VGATE       : in  std_ulogic; -- 0V or ~1.5V for simple gate feedback operation. Must enable with
                                             -- FETSEL bit in channel to use this.
            -- DACREF      : in  std_ulogic; -- 2 to 3V, DAC reference level. Sets the MAX DAC output voltage to
                                             -- VREFLO + 1.5*13/16*DACREF
            VU             : in  real;       -- 2 - 3V sine wave, U timing signal for sampling by fast trigger
            VV             : in  real;       -- 2 - 3V sine wave, V timing signal for sampling by fast trigger
            -- ISET        : in  std_ulogic; -- 6.98Kohm to VDDA, Sets input FET bias current
            -- PBIAS       : in  std_ulogic; -- 33.2Kohm to ground. Sets bias current for most amplifiers
            -- FB_PBIAS    : in  std_ulogic; -- 47.5Kohm to ground, Sets feedback circuit bias current
            -- R_BIAS      : in  std_ulogic; -- 93.1Kohm to ground, Sets feedback R bias current
            -- VREFHI      : in  std_ulogic; -- 3.5V, High reference for negative going signals
            -- VREFLO      : in  std_ulogic; -- 1.5V, Low reference for positive going signals and reference for low rail
                                             -- of DAC
            DETECTOR_IN    : in  real_vector(0 to 35); -- Detector inputs pins
            -- AOUTP       : in  std_ulogic; -- ?, Positive differential output
            -- AOUTN       : in  std_ulogic; -- ?, Negative differential output
            CSHIFT         : in  std_ulogic; -- Shift one bit (from Cin) into the shift register on the rising edge
            CIN            : in  std_ulogic; -- Data input. Must be valid on the rising edge of CShift
            CS             : in  std_ulogic  -- Chip Select. After shifting 41 bits, pulse this signal high to load the
                                             -- shifted data in the proper registers
            -- TS_N        : in  std_ulogic; -- Differential out, Slow trigger output, Negative output
            -- TS_P        : in  std_ulogic; -- Differential out, Slow trigger output, positive output
            -- TF_N        : in  std_ulogic; -- Differential out, Fast trigger output, Negative Output
            -- TF_P        : in  std_ulogic; -- Differential out, Fast trigger output, positive output
            -- FOUT        : in  std_ulogic; -- Fast token output for fast token register
            -- SOUT        : in  std_ulogic; -- Slow token output for slow token register
            -- TOUT        : in  std_ulogic; -- Token output from token chain. Goes high when chip is finished to pass
                                             -- token to next chip.
            -- READ        : in  std_ulogic; -- Enables output of analog signals within a channel. Turns on the analog
                                             -- driver for a channel when token is present. Also enables output buffer.
            -- TIN         : in  std_ulogic; -- Token input, Always set a 1 for first channel, or receives TOUT from
                                             -- previous chip.
            -- SIN         : in  std_ulogic; -- Slow token input. Use with SHRCLK to load bits into slow token chain.
            -- FIN         : in  std_ulogic; -- Fast token input. Use with FHRCLK to load bits into slow token chain.
            -- SHRCLK      : in  std_ulogic; -- Slow hit register clock. Loads SIN bits on rising edge
            -- FHRCLK      : in  std_ulogic; -- Fast hit register clock. Loads FIN bits on rising edge
            -- ACQUIRE_P   : in  std_ulogic; -- Positive differential input, Peak detector is active when this signal is
                                             -- asserted (high).
            -- ACQUIRE_N   : in  std_ulogic; -- Negative differential input, Peak detector is active when this signal is
                                             -- asserted (low).
            -- CLS_P       : in  std_ulogic; -- Positive differential input, Peak detector reset signal. Resets the peak
                                             -- detector when asserted (high). Also clears the token register.
            -- CLS_N       : in  std_ulogic; -- Negative differential input, Peak detector reset signal. Resets the peak
                                             -- detector when asserted (low). Also clears the token register.
            -- CLF         : in  std_ulogic; -- This signal clears the fast latch (VU and VV sample circuit) when
                                             -- asserted, (high).
            -- TCLK        : in  std_ulogic; -- This signal shifts the token from one channel to the next on the rising
                                             -- edge
            -- TST         : in  std_ulogic_vector(3 to 22)  -- Pull to VDD with 44Kohm resistor. Test signal outputs. AKA T[3-22]
        );
    end component rena3_model;


    component rena3_channel_model is
        generic (
            channel_nr         : natural
        );
        port (
            inp                : in  rena3_channel_in_t;
            config             : in  channel_configuration_t;
            outp               : out rena3_channel_out_t
        );
    end component rena3_channel_model;


end package rena3_model_component_package;

