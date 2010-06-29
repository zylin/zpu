--
-- this model describes the behaviour of the RENA3 ASIC
--



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package rena3_model_types_package is

    constant gain_array_c : real_vector := (1.6, 1.8, 2.3, 5.0);
    constant sel_array_c  : real_vector := (0.29, 0.31, 0.31, 0.32, 0.35, 0.37, 0.39, 0.40, 0.71, 0.81, 0.89, 1.1, 1.9, 2.8, 4.5, 38.0);

    
    function get_gain( g: std_ulogic_vector)  return real;
    function get_sel( sel: std_ulogic_vector) return real;



    --------------------
    type channel_configuration_t is record
        
        -- FB_TC, Feedback time constant selection. Selects the size of the feedback
        -- resistor for the input stage. 1 Selects 1.2Gohm feedback resistance, 0
        -- Selection 200Mohm.
        fb_tc    : std_ulogic;
        
        -- ECAL, Enable channel calibration. Set to 1 to enable TEST signal input to
        -- channel.
        ecal     : std_ulogic;
        
        -- FPDWN, Set to a 1 to power down fast path circuits. This includes the fast
        -- shaper, a DAC, and the comparator for the fast path.
        fpdwn    : std_ulogic;
        
        -- FETSEL, Set to a 1 to use the simple FET feedback instead of the resistive
        -- multiplier circuit.
        fetsel   : std_ulogic;
        
        -- G[1-0], Gain selection. The gain selection following the differentiation
        -- stage has 4 selections for gain. [00] = 1.6, [01] = 1.8 [10] = 2.3 [11] = 5.0
        g        : real;
        
        -- PDWN, Set to a 1 to power down most of the circuits in the channel.
        -- FPDWN must still be used to power down the fast components.
        pdwn     : std_ulogic;
        
        -- PZSEL, Pole Zero cancellation selection. Set this bit to a 1 to enable the pole
        -- zero cancellation circuit.
        pzsel    : std_ulogic;
        
        -- RANGE, Sets the feedback capacitor size. Set to a 1 for 60fF feedback. Set
        -- to a 0 for 15fF feedback.
        cap_range : std_ulogic;
        
        -- RSEL, Reference selection for the channel. Set to a 1 to select VREFHI (for
        -- negative going signals)
        rsel     : std_ulogic;
        
        -- SEL[3-0], Time constant selection. All 0's is the shortest time constant. All
        -- 1's is the longest time constant. Selections are, from shortest to longest (us):
        -- 0.29, 0.31, 0.31, 0.32, 0.35, 0.37, 0.39, 0.40, 0.71, 0.81, 0.89, 1.1, 1.9, 2.8,
        -- 4.5, 38. SEL[0] is the LSB and this goes into the shift register after SEL[3-1].
        sel      : real;
        
        -- SIZEA, Selects the size of the input FET for noise optimization. Set to a 1
        -- for a FET of size 1000um. Set to a 0 for a size of 450um.
        sizea    : std_ulogic;
        
        -- DF[7-0], Fast DAC value. All 0's gives the lowest output voltage (VREFLO
        -- - 3/16*1.5*DACREF). All 1's are largest output voltage (VREFLO +
        -- 13/16*1.5*DACREF). DF[0] is the LSB and goes into the shift register last.
        df       : unsigned(7 downto 0);
        
        -- POL, Polarity selection for comparators. Select a 1 for positive going
        -- signals.
        pol      : std_ulogic;
        
        -- DS[7-0], Slow DAC value. All 0's are smallest output voltage (VREFLO –
        -- 13/16*1.5*DACREF). All 1's are largest output voltage (VREFLO +
        -- 13/16*1.5*DACREF). DS[0] is the LSB and goes into the shift register last.
        ds       : unsigned(7 downto 0);
        
        -- ENF, Set to a 1 to enable FAST trigger.
        enf      : std_ulogic;
        
        -- ENS, Set to a 1 to enable the SLOW trigger.
        ens      : std_ulogic;
        
        -- FM, Follower mode. Set to a one to enable peak detector to work in follower
        -- mode. It only makes sense to have a single one of these bits set at a time for
        -- all channels.
        fm       : std_ulogic;
    end record channel_configuration_t;
    constant default_channel_configuration_c : channel_configuration_t := (
        fb_tc     => '0', 
        ecal      => '0',
        fpdwn     => '0',
        fetsel    => '0',
        g         => gain_array_c(0),
        pdwn      => '0',
        pzsel     => '0',
        cap_range => '0',
        rsel      => '0',
        sel       => sel_array_c(0),
        sizea     => '0', 
        df        => "00000000",
        pol       => '0',
        ds        => "00000000",
        enf       => '0',
        ens       => '0',
        fm        => '0'
    );




    --------------------
    type rena3_channel_in_t is record
        input              : real;
        test               : real;
        clear_fast_channel : std_ulogic;
        clear_slow_channel : std_ulogic;
        vu                 : real;
        vv                 : real;
    end record rena3_channel_in_t;

    --------------------
    type rena3_channel_out_t is record
        peak_detector      : real;
        slow_trigger       : std_ulogic;
        fast_trigger       : std_ulogic;
        vu                 : real;
        vv                 : real;
    end record rena3_channel_out_t;
    constant default_rena3_channel_out_c : rena3_channel_out_t := (
        peak_detector => 0.0,
        slow_trigger  => '0',
        fast_trigger  => '0',
        vu            => 0.0,
        vv            => 0.0
    );


end package rena3_model_types_package;



package body rena3_model_types_package is
    
    function get_gain( g: std_ulogic_vector) return real is
    begin
        return gain_array_c( to_integer( unsigned(g)));
    end function get_gain;
    

    function get_sel( sel: std_ulogic_vector) return real is
    begin
        return sel_array_c( to_integer( unsigned(sel)));
    end function get_sel;

end package body rena3_model_types_package;

