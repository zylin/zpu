--------------------------------------------------------------------------------
-- $Date$
-- $Author$
-- $Revision$
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- description:
-- two stage (FF) synchronizer
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


entity level_synchronizer is
    port (
        clk    : std_ulogic;
        input  : in std_logic;
        synced : out std_ulogic
    );
end entity level_synchronizer;


architecture rtl of level_synchronizer is

    signal in_stage : std_ulogic;

begin
    
    process
    begin
        wait until rising_edge( clk);
        in_stage <= std_ulogic( input);
        synced   <= in_stage;
    end process;

end architecture rtl;

