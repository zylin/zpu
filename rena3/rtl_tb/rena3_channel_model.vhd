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
        input              : real;
        test               : real;
        config             : channel_configuration_t;
        clear_fast_channel : std_ulogic;
        vu                 : real;
        vv                 : real
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


begin

    process (input, test, config)
        variable preamp_input : real;
        variable shaper_input : real;
    begin
        
        -- input selection
        preamp_input := input;
        if config.ecal = '1' then
            preamp_input := test;
        end if;
        if config.pdwn = '1' then
            preamp_input := 0.0;
            report me_c & ": channel " & integer'image(channel_nr) & " power down";
        end if;
    
        -- diff. & gain
        shaper_input := preamp_input * config.g;

        
    end process;


end architecture behave;
