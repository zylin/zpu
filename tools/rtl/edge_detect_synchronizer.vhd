--------------------------------------------------------------------------------
-- $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/hardware/board_sp601/rtl/teilerregister.vhd $
-- $Date: 2010-10-29 15:57:42 +0200 (Fr, 29 Okt 2010) $
-- $Author: lange $
-- $Revision: 659 $
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- description:
-- three stage (FF) synchronizer, with edge detect
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


entity edge_detect_synchronizer is
    generic (
        rising_edge : boolean := true
    );
    port (
        clk    : std_ulogic;
        input  : in std_logic;
        synced : out std_ulogic
    );
end entity edge_detect_synchronizer;


architecture rtl of edge_detect_synchronizer is

    signal in_stage     : std_ulogic;
    signal in_stage_d1  : std_ulogic;
    signal in_stage_d2  : std_ulogic;

begin
    
    process
    begin
        wait until rising_edge( clk);
        in_stage     <= std_ulogic( input);
        in_stage_d1  <= in_stage;
        in_stage_d2  <= in_stage_d1; -- third ff
    end process;

    synced <= in_stage_d1 and not in_stage_d2 when rising_edge else
              not in_stage_d1 and in_stage_d2;

end architecture rtl;

