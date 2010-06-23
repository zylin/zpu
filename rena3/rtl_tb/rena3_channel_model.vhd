--
-- this model describes the behaviour of the RENA3 ASIC (one channel)
--



--  +--------+   +--------+   +--------+   +------------+   +---------+
--  |        |   | diff.  |   |        |   |    slow    |   |  slow   |
--  | preamp |-->| & gain |-->| shaper |+->| comparator |-->| trigger |
--  |        |   |        |   |        ||  |            |   |         |
--  +--------+   +--------+   +--------+|  +------------+   +---------+
--                                      |  +------------+   +---------+
--                                      |  |    fast    |   |  fast   |
--                                      +->| comparator |-->| trigger |
--                                         |            |   |         |
--                                         +------------+   +---------+



library ieee;
use ieee.std_logic_1164.all;


library rena3;
use rena3.rena3_model_types_package.all;


entity rena3_channel_model is
    generic (
        channel_nr         : natural
    );
    port (
        inp                : in  rena3_channel_in_t;
        config             : in  channel_configuration_t;
        outp               : out rena3_channel_out_t
    );
end entity rena3_channel_model;





use std.textio.all;

library ieee;
use ieee.numeric_std.all;

library tools;
use tools.fio_pkg.all;



architecture behave of rena3_channel_model is


    ------------------------------------------
    -- definitions

    constant me_c : string := behave'path_name;



    ------------------------------------------
    -- signal definitions
    signal vu : real := 0.0;
    signal vv : real := 0.0;

begin

    main: process (inp, config, vv, vu)
        variable preamp_input  : real;
        variable shaper_input  : real;
                               
        variable fast_dac      : real;
        variable slow_dac      : real;
                               
        variable peak_detector : real := 0.0;
    begin
        -- clear fast channel
        if inp.clear_fast_channel = '1' then 
            outp.vu <= default_rena3_channel_out_c.vu;
            outp.vv <= default_rena3_channel_out_c.vv;
            vu      <= default_rena3_channel_out_c.vu;
            vv      <= default_rena3_channel_out_c.vv;
        end if;
        
        -- input selection
        preamp_input := 0.0;
        if inp.input > real'left then
            preamp_input := inp.input;
        end if;
        if config.ecal = '1' then
            preamp_input := inp.test;
        end if;
        if config.pdwn = '1' then
            preamp_input := 0.0;
            report me_c & ": channel " & integer'image(channel_nr) & " power down";
        end if;
    
        -- diff. & gain
        shaper_input      := preamp_input * config.g;

        -- fast path (shaper, DAC, comparator)
        --fast_dac := vreflo - 3.0/16.0 * 1.5 * real(config.df)/255.0;
        --slow_dac := vreflo - 3.0/16.0 * 1.5 * real(config.ds)/255.0;
        fast_dac          := real(to_integer(config.df))/255.0;
        slow_dac          := real(to_integer(config.ds))/255.0;

        outp.fast_trigger          <= '0';
        if (shaper_input > fast_dac) and (config.fpdwn = '0') then
            if config.enf = '1' then
                outp.fast_trigger  <= '1';
            end if;
            if inp.vu > vu then
                outp.vu            <= inp.vu;
                vu                 <= inp.vu;
            end if;
            if inp.vv > vv then
                outp.vv            <= inp.vv;
                vv                 <= inp.vv;
            end if;
        end if;
            

        -- slow path
        outp.slow_trigger          <= '0';
        if (shaper_input > slow_dac) and (config.pdwn = '0') then
            if config.ens = '1' then
                outp.slow_trigger  <= '1';
            end if;
            peak_detector      := shaper_input;
        end if;

        
    end process;


end architecture behave;
