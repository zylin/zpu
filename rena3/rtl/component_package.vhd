

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
            clk               : in  std_ulogic;
            reset             : in  std_ulogic;
            -- rena 3 
            rena3_ts          : in  std_ulogic;
            rena3_tf          : in  std_ulogic;
            rena3_fout        : in  std_ulogic;
            rena3_sout        : in  std_ulogic;
            rena3_tout        : in  std_ulogic;
            --
            rena3_chsift      : out std_ulogic;
            rena3_cin         : out std_ulogic; 
            rena3_cs          : out std_ulogic;
            rena3_read        : out std_ulogic;
            rena3_tin         : out std_ulogic;
            rena3_sin         : out std_ulogic;
            rena3_fin         : out std_ulogic;
            rena3_shrclk      : out std_ulogic;
            rena3_fhrclk      : out std_ulogic;
            rena3_acquire     : out std_ulogic;
            rena3_cls         : out std_ulogic;
            rena3_clf         : out std_ulogic;
            rena3_tclk        : out std_ulogic
          );
    end component controller_top;

end package component_package;
