--
-- testbench for the rena3_model
--
-- 1. test the timing for the SPI configuration
--

entity rena3_model_tb is
end entity rena3_model_tb;




library ieee;
use ieee.std_logic_1164.all;


library tools;
use tools.image_pkg.all;


library rena3;
use rena3.rena3_model_package.rena3_model;



architecture testbench of rena3_model_tb is

    constant clock_period   : time       := (1 sec)/(50_000_000); -- 50 MHz

    constant test_config_channel0_c : std_ulogic_vector := "00000011010001100000111111111111111111110"; -- 000000_1_1_0_1_00_0_1_1_0_0000_1_11111111_1_11111111_1_1_0
    constant test_config_channel1_c : std_ulogic_vector := "00000100000000000000000000000000000000000"; -- 000001_0_0_0_0_00_0_0_0_0_0000_0_00000000_0_00000000_0_0_0
    constant test_config_channel2_c : std_ulogic_vector := "10000000000000000000000000000000000000001";

    type state_t is (IDLE, CONFIG0, WAITING, CONFIG1, CONFIG2, READY);
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
        state       : state_t;
        cshift      : std_ulogic;
        cin         : std_ulogic;
        cs          : std_ulogic;
        config      : configuration_t;
        waitcounter : natural;
    end record reg_t;
    constant default_reg_c : reg_t := (
        state       => IDLE,
        cshift      => '1',
        cin         => '0',
        cs          => '0',
        config      => default_configuration_c,
        waitcounter => 10
    );

    signal   simulation_run : boolean    := true;
    signal   clock          : std_ulogic := '0';
    signal   reset          : std_ulogic;

    signal   r, r_in        : reg_t;
    signal   cshift         : std_ulogic;



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

begin

    -- clock and reset
    clock <= not clock after clock_period/2 when simulation_run;
    reset <= '1', '0'  after  10 * clock_period;

    -- dut
    rena3_model_i0: rena3_model
        port map(
            TEST        => 0.0,             --   : in  real;       -- +/-720mV step input to simulate signal. This signal is for testing
            DETECTOR_IN => (others => 0.0), --   : in  real_array(0 to 35); -- Detector inputs pins
            CSHIFT      => r.cshift,        --   : in  std_ulogic; -- Shift one bit (from Cin) into the shift register on the rising edge
            CIN         => r.cin,           --   : in  std_ulogic; -- Data input. Must be valid on the rising edge of CShift
            CS          => r.cs             --   : in  std_ulogic  -- Chip Select. After shifting 41 bits, pulse this signal high to load the
        );

    -- main
    comb: process(r)
        variable v : reg_t;
    begin
        v   := r;
                    
        configure_rena( v);

        case v.state is

            when IDLE    =>
                v.state             := CONFIG0;
                v.config.vector     := test_config_channel0_c;
                v.config.start      := true;

            when CONFIG0 =>
                if v.config.ready then
                    v.state         := WAITING;
                end if;

            when WAITING =>
                if v.waitcounter = 0 then
                    v.state         := CONFIG1;
                    v.config.vector := test_config_channel1_c;
                    v.config.start  := true;
                else
                    v.waitcounter   := v.waitcounter - 1;
                end if;

            when CONFIG1 =>
                if v.config.ready then
                    v.state         := CONFIG2;
                    v.config.vector := test_config_channel2_c;
                    v.config.start  := true;
                end if;

            when CONFIG2 =>
                if v.config.ready then
                    v.state         := READY;
                    v.waitcounter   := 10;
                end if;

            when READY =>
                if v.waitcounter = 0 then
                    simulation_run  <= false;
                else
                    v.waitcounter   := v.waitcounter - 1;
                end if;

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
