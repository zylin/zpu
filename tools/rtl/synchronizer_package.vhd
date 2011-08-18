--------------------------------------------------------------------------------
-- $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/hardware/board_sp601/rtl/teilerregister.vhd $
-- $Date: 2010-10-29 15:57:42 +0200 (Fr, 29 Okt 2010) $
-- $Author: lange $
-- $Revision: 659 $
--------------------------------------------------------------------------------

package synchronizer_package is


entity level_synchronizer is
    port (
        clk    : std_ulogic;
        input  : in std_logic;
        synced : out std_ulogic
    );
end entity level_synchronizer;


entity edge_detect_synchronizer is
    generic (
        rising_edge : boolean := true
    );
    port (
        clk    : std_ulogic;
        input  : in std_logic;
        synced : out std_ulogic
    );
end package synchronizer_package;
