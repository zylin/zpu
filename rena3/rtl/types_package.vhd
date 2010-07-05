library ieee;
use ieee.std_logic_1164.all;

package types_package is

    type rena3_controller_in_t is record
        ts     : std_ulogic;
        tf     : std_ulogic;
        fout   : std_ulogic;
        sout   : std_ulogic;
        tout   : std_ulogic;
    end record rena3_controller_in_t;

    type rena3_controller_out_t is record
        cshift  : std_ulogic;
        cin     : std_ulogic;
        cs      : std_ulogic;
        read    : std_ulogic;
        tin     : std_ulogic;
        sin     : std_ulogic;
        fin     : std_ulogic;
        shrclk  : std_ulogic;
        fhrclk  : std_ulogic;
        acquire : std_ulogic;
        cls     : std_ulogic;
        clf     : std_ulogic;
        tclk    : std_ulogic;
    end record rena3_controller_out_t;

end package types_package;

