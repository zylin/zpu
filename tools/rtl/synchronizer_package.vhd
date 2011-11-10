--------------------------------------------------------------------------------
-- $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/hardware/board_sp601/rtl/teilerregister.vhd $
-- $Date: 2010-10-29 15:57:42 +0200 (Fr, 29 Okt 2010) $
-- $Author: lange $
-- $Revision: 659 $
--------------------------------------------------------------------------------

library ieee;
use ieee. std_logic_1164.all;


package synchronizer_package is


    component level_synchronizer is
        port (
            clk    : std_ulogic;
            input  : in std_logic;
            synced : out std_ulogic
        );
    end component level_synchronizer;


    component edge_detect_synchronizer is
        generic (
            detect_rising_edge : boolean := true
        );
        port (
            clk    : std_ulogic;
            input  : in std_logic;
            synced : out std_ulogic
        );
    end component edge_detect_synchronizer;


end package synchronizer_package;
