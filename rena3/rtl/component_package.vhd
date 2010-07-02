

library ieee;
use ieee.std_logic_1164.all;

library rena3;
use rena3.types_package.all;

library zpu;
use zpu.zpu_wrapper_package.all; -- type definitions

package component_package is

    component rena3_controller is
        port (
            -- system
            clock     : std_ulogic;
            -- rena3 (connection to chip)
            rena3_in  : in  rena3_controller_in_t;
            rena3_out : out rena3_controller_out_t;
            -- connection to soc
            zpu_in    : in  zpu_out_t;
            zpu_out   : out zpu_in_t
        );
    end component rena3_controller;

    component controller_top is
        port (
            clk       : in  std_ulogic;
            reset     : in  std_ulogic 
        );
    end component controller_top;

end package component_package;
