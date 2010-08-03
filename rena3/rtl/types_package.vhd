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
    constant default_rena3_controller_in_c : rena3_controller_in_t := (
        ts    => '0',
        tf    => '0',
        fout  => '0',
        sout  => '0',
        tout  => '0'
    );

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
    constant default_rena3_controller_out_c: rena3_controller_out_t := (
        cshift  => '0', 
        cin     => '0', 
        cs      => '0',
        read    => '0',
        tin     => '0',
        sin     => '0',
        fin     => '0',
        shrclk  => '0',
        fhrclk  => '0',
        acquire => '0',
        cls     => '0',
        clf     => '0',
        tclk    => '0'
    );

end package types_package;

