--------------------------------------------------------------------------------
-- $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/hardware/board_sp601/rtl/teilerregister.vhd $
-- $Date: 2010-10-29 15:57:42 +0200 (Fr, 29 Okt 2010) $
-- $Author: lange $
-- $Revision: 659 $
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

