
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library grlib;
use grlib.amba.all;

library gaisler;
use gaisler.misc.all; -- types
use gaisler.uart.all; -- types
use gaisler.net.all;  -- types


package component_package is

    
    component debug_con_apb is
        generic (
            pindex       : integer := 0;
            paddr        : integer := 0;
            pmask        : integer := 16#fff#;
            version_time : string( 1 to 21) := "undefined version    "
        );
        port (
            rst       : in  std_ulogic;
            clk       : in  std_ulogic;
            apbi      : in  apb_slv_in_type;
            apbo      : out apb_slv_out_type;
            --
            softreset : out std_ulogic
        );
    end component debug_con_apb;



end package component_package;
