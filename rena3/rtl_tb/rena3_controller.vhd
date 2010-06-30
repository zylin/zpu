
library ieee;
use ieee.std_logic_1164.all;

library rena3;
use rena3.types_package.all;


entity rena3_controller is
    port (
        -- system
        reset     : std_ulogic;
        clock     : std_ulogic;
        -- rena3 (connection to chip)
        rena3_in  : rena3_controller_in_t;
        rena3_out : rena3_controller_out_t
        -- connection to soc
    );
end entity rena3_controller;


architecture rtl of rena3_controller is
begin
end;
