library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library tools;
use tools.tools_pkg.log2;


package types is


    constant  taps_c : natural := 256;

    -------------------- 
    type unsigned_vector is array ( natural range <> ) of unsigned( log2(taps_c) downto 0);
 

end package types;
