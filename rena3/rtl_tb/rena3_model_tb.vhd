--
-- testbench for the rena3_model
--
-- 1. test the timing for the SPI configuration
-- 2. test response to pulsed inputs (on TEST pin)

entity rena3_model_tb is
end entity rena3_model_tb;




library ieee;
use ieee.std_logic_1164.all;


library tools;
use tools.image_pkg.all;


library rena3;
use rena3.rena3_model_component_package.rena3_model;
use rena3.test_pulse_gen_package.test_pulse_gen;



architecture testbench of rena3_model_tb is

    constant clock_period   : time       := (1 sec)/(50_000_000); -- 50 MHz

    -- 1_1_0_1_00_0_1_1_0_0000_1_11111111_1_11111111_1_1_0
    constant test_config_power_on_others_1_c : std_ulogic_vector := "11010001100000111111111111111111110";  

    -- 0_0_0_0_00_0_0_0_0_0000_0_00000000_0_00000000_0_0_0
    constant test_config_power_on_others_0_c : std_ulogic_vector := "00000000000000000000000000000000000";     


    constant test_config_channel0_c : std_ulogic_vector := "000000" & test_config_power_on_others_1_c;
    constant test_config_channel1_c : std_ulogic_vector := "000001" & test_config_power_on_others_0_c;
    constant test_config_channel2_c : std_ulogic_vector := "100000" & test_config_power_on_others_0_c;

    -- 36 bits ( one for each channel, from low to high)
    constant test_slow_token_c      : std_ulogic_vector := "110010101111111100000000100000010101";

    type state_t is (IDLE, CONFIG0, WAIT1, CONFIG1, CONFIG2, WAIT2, PULSE, WAIT3, SLOW_TOKEN, WAIT4, READY);
    type configuration_state_t is (IDLE, SHIFT, RAISE_CS);

    type configuration_t is record
        state           : configuration_state_t;
        start           : boolean;
        index           : natural range 0 to test_config_channel0_c'length;
        vector          : std_ulogic_vector( test_config_channel0_c'range);
        ready           : boolean;
    end record configuration_t;
    constant default_configuration_c : configuration_t := (
        state           => IDLE,
        start           => false,
        index           => 0,
        vector          => (others => '0'),
        ready           => false
    );


    type reg_t is record
        state              : state_t;
        detector_in        : real_vector(0 to 35);
        cshift             : std_ulogic;
        cin                : std_ulogic;
        cs                 : std_ulogic;
        sin                : std_ulogic;
        shrclk             : std_ulogic;
        clf                : std_ulogic;
        config             : configuration_t;
        waitcounter        : natural;
        trigger            : std_ulogic;
        pulsecounter       : natural;
        slow_token_counter : integer;
    end record reg_t;
    constant default_reg_c : reg_t := (
        state              => IDLE,
        detector_in        => (others => 0.0),
        cshift             => '1',
        cin                => '0',
        cs                 => '0',
        sin                => test_slow_token_c(35),
        shrclk             => '0',
        clf                => '0',
        config             => default_configuration_c,
        waitcounter        =>  10,
        trigger            => '0',
        pulsecounter       =>   3,
        slow_token_counter =>   0
    );


    type src_t is record
        test_pulse_gen_i0_pulse : real;
        rena3_model_i0_sout     : std_ulogic;
    end record src_t;


    signal simulation_run          : boolean    := true;
    signal clock                   : std_ulogic := '0';
    signal reset                   : std_ulogic;
                                   
    signal r, r_in                 : reg_t;
    signal src                     : src_t;



    procedure configure_rena( x: inout reg_t) is
    begin
        x.config.ready                 := false;
        x.cs                           := '0';

        case x.config.state is

             when IDLE =>
                if x.config.start then
                    x.config.index     := 0;
                    x.config.start     := false;
                    x.config.state     := SHIFT;
                end if;

            when SHIFT =>
                if x.cshift = '1' then
                    x.cshift           := '0';
                    x.cin              := x.config.vector( x.config.index);
                else
                    x.cshift           := '1';
                    if x.config.index < x.config.vector'high then
                        x.config.index := x.config.index + 1;
                    else
                        x.config.state := RAISE_CS;
                    end if;
                end if;

            when RAISE_CS =>
                x.cs                   := '1';
                x.config.state := IDLE;
                x.config.ready := true;

        end case;

    end procedure configure_rena;




    procedure rotate_slow_token_register( x: inout reg_t) is
    begin
        if x.shrclk = '0' then
            -- rise
            x.shrclk             := '1';
            x.slow_token_counter := x.slow_token_counter - 1;
        else                     
            -- fall              
            x.shrclk             := '0';
            x.sin                := test_slow_token_c( x.slow_token_counter );
        end if;
    end procedure rotate_slow_token_register;


begin

    -- clock and reset
    clock <= not clock after clock_period/2 when simulation_run;
    reset <= '1', '0'  after  10 * clock_period;
    
    -- stimuli generator
    test_pulse_gen_i0: test_pulse_gen
        port map(
            trigger => r.trigger,
            pulse   => src.test_pulse_gen_i0_pulse 
        );


    -- dut
    -- TODO look for open ports
    rena3_model_i0: rena3_model
        port map(
            TEST        => src.test_pulse_gen_i0_pulse, --   : in  real;       -- +/-720mV step input to simulate signal. This signal is for testing
            VU          => 0.0,                         --   : in  real;       -- 2 - 3V sine wave, U timing signal for sampling by fast trigger
            VV          => 1.0,                         --   : in  real;       -- 2 - 3V sine wave, V timing signal for sampling by fast trigger
            DETECTOR_IN => r.detector_in,               --   : in  real_array(0 to 35); -- Detector inputs pins
            CSHIFT      => r.cshift,                    --   : in  std_ulogic; -- Shift one bit (from Cin) into the shift register on the rising edge
            CIN         => r.cin,                       --   : in  std_ulogic; -- Data input. Must be valid on the rising edge of CShift
            CS          => r.cs,                        --   : in  std_ulogic  -- Chip Select. After shifting 41 bits, pulse this signal high to load the
            SOUT        => src.rena3_model_i0_sout,     --   : out std_ulogic; -- Slow token output for slow token register
            SIN         => r.sin,                       --   : in  std_ulogic; -- Slow token input. Use with SHRCLK to load bits into slow token chain.
            SHRCLK      => r.shrclk,                    --   : in  std_ulogic; -- Slow hit register clock. Loads SIN bits on rising edge
            CLF         => r.clf                        --   : in  std_ulogic  -- This signal clears the fast latch (VU and VV sample circuit) when
        );


    -- main
    comb: process(r)
        variable v : reg_t;
    begin
        v   := r;
                    
        configure_rena( v);

        case v.state is

            when IDLE    =>
                v.state                  := CONFIG0;
                v.config.vector          := test_config_channel0_c;
                v.config.start           := true;
                                         
            when CONFIG0 =>              
                if v.config.ready then   
                    v.state              := WAIT1;
                end if;

            when WAIT1 =>
                if v.waitcounter = 0 then
                    v.state              := CONFIG1;
                    v.config.vector      := test_config_channel1_c;
                    v.config.start       := true;
                else                    
                    v.waitcounter        := v.waitcounter - 1;
                end if;

            when CONFIG1 =>
                if v.config.ready then
                    v.state              := CONFIG2;
                    v.config.vector      := test_config_channel2_c;
                    v.config.start       := true;
                end if;

            when CONFIG2 =>
                if v.config.ready then
                    v.state              := WAIT2;
                    v.waitcounter        := 10;
                end if;

            when WAIT2 =>
                if v.waitcounter = 0 then
                    v.state              := PULSE;
                    v.pulsecounter       := 3;
                    v.waitcounter        := 100;
                    v.trigger            := '1';
                else
                    v.waitcounter        := v.waitcounter - 1;
                end if;
    
            when PULSE =>
                if v.waitcounter = 0 then
                    v.pulsecounter       := v.pulsecounter - 1;
                    if v.pulsecounter = 0 then
                        v.state          := WAIT3;
                    else
                        v.waitcounter    := 100;
                        v.trigger        := '1';
                    end if;
                else
                    if v.trigger = '1' then
                        v.trigger        := '0';
                    end if;
                    v.waitcounter        := v.waitcounter - 1;
                end if;
                -- clear fast section
                if (v.waitcounter = 50) and (v.pulsecounter = 2) then
                    v.clf                := '1';
                else
                    v.clf                := '0';
                end if;
                    
            
            when WAIT3 =>
                if v.waitcounter = 0 then
                    v.slow_token_counter := test_slow_token_c'high;
                    v.state              := SLOW_TOKEN;
                else                  
                    v.waitcounter        := v.waitcounter - 1;
                end if;

            when SLOW_TOKEN =>
                if v.slow_token_counter >= 0 then
                    rotate_slow_token_register( v);
                else                    
                    v.shrclk             := '0';
                    v.waitcounter        := 20;
                    v.state              := WAIT4;
                end if;

            when WAIT4 =>
                if v.waitcounter = 0 then
                    v.state              := READY;
                else
                    v.waitcounter        := v.waitcounter - 1;
                end if;
            
            when READY =>
                simulation_run           <= false;

        end case;
        
        r_in <= v;
    end process comb;

    seq: process
    begin
        wait until rising_edge(clock);
        r <= r_in;
        if reset = '1' then
            r <= default_reg_c;
        end if;
    end process seq;



end architecture testbench;
