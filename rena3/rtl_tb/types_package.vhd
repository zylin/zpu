library ieee;
use ieee.std_logic_1164.all;

package types_package is

    type rena3_controller_in_t is record
        ts     : std_ulogic;
    end record rena3_controller_in_t;

    type rena3_controller_out_t is record
        cshift : std_ulogic;
        cin    : std_ulogic;
    end record rena3_controller_out_t;

end package types_package;

