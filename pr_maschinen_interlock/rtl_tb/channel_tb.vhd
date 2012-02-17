library ieee;
use ieee.std_logic_1164.all;


entity channel_tb is
end entity channel_tb;

architecture testbench of channel_tb is

    constant zeit : time := 10 ns;
        
    signal simulation_active      : boolean := true;
	signal tb_reset_n             : std_ulogic;
    signal tb_clk                 : std_ulogic := '0';
    signal tb_channel_active_in_n : std_ulogic := '1';
    signal tb_error_in_n          : std_ulogic; -- low active
    signal tb_test_in_n           : std_ulogic; -- low active
    signal tb_test_sps_in_n       : std_ulogic;
    signal tb_clear_n             : std_ulogic;
    signal tb_clear_sps           : std_ulogic;
    --                            
    signal tb_error_out           : std_ulogic;
    signal tb_channel_ok_out      : std_ulogic;

begin

    tb_clk <= not tb_clk after 1 ns when simulation_active;

    channel_i0: entity work.channel
    port map (
		reset_n             => tb_reset_n,              --: in  std_ulogic;
        clk                 => tb_clk,                  --: in  std_ulogic;
        channel_active_in_n => tb_channel_active_in_n,  --: in  std_ulogic;
        error_in_n          => tb_error_in_n,           --: in  std_ulogic; -- low active
        test_in_n           => tb_test_in_n,            --: in  std_ulogic; -- low active
        test_sps_in_n       => tb_test_sps_in_n,        --: in  std_ulogic;
        clear_n             => tb_clear_n,              --: in  std_ulogic;
        clear_sps_n         => tb_clear_sps,            --: in  std_ulogic;
        --                                
        error_out           => tb_error_out,            --: out std_ulogic;
        channel_ok_out      => tb_channel_ok_out        --: out std_ulogic
    );


    process
    begin
        tb_reset_n <= '0';
        wait for 10 * zeit;
        tb_reset_n <= '1';
        report "test for clear";
        wait for 5 * zeit;
        tb_clear_n <= '0';
        wait for zeit;
        tb_clear_n <= '1';
        wait for 2 * zeit;

        report "channel active";
        tb_channel_active_in_n <= '0';
        wait for zeit;
        tb_clear_sps <= '1';
        wait for zeit;
        tb_clear_sps <= '0';
        wait for 2 * zeit;

        report "clear (from sps, test_sps is active)";
        tb_test_sps_in_n <= '0';
        wait for zeit;
        tb_clear_sps   <= '1';
        wait for zeit;
        tb_test_sps_in_n <= '1';
        wait for zeit;
        tb_clear_sps   <= '0';
        wait for 2 * zeit;
        
        report "clear (from sps, test_sps is inactive)";
        tb_clear_sps <= '1';
        wait for zeit;
        tb_test_sps_in_n <= '0';
        wait for zeit;
        tb_test_sps_in_n <= '1';
        wait for zeit;
        tb_clear_sps <= '0';
        wait for 2 * zeit;

        report "error";
        tb_error_in_n <= '0';
        wait for zeit;
        tb_error_in_n <= '1';
        wait for zeit;
        tb_clear_n  <= '0';
        wait for zeit;
        tb_clear_n  <= '1';
        wait for 2 * zeit;


        report "error (but inactive)";
        tb_channel_active_in_n <= '1';
        wait for zeit;
        tb_error_in_n <= '0';
        wait for zeit;
        tb_error_in_n <= '1';
        wait for zeit;
        tb_clear_n  <= '0';
        wait for zeit;
        tb_clear_n  <= '1';
        wait for 2 * zeit;

        report "error (with try to clear)";
        tb_channel_active_in_n <= '0';
        wait for zeit;
        tb_error_in_n <= '0';
        wait for zeit;
        tb_clear_n  <= '0';
        wait for zeit;
        tb_clear_n  <= '1';
        wait for 2 * zeit;

        report "error gone (with try to clear)";
        wait for zeit;
        tb_clear_n  <= '0';
        wait for zeit;
        tb_error_in_n <= '1';
        wait for zeit;
        tb_clear_n  <= '1';
        wait for 2 * zeit;

        report "switch on with clear";
        tb_channel_active_in_n <= '1';
        tb_clear_n             <= '1';
        tb_clear_sps           <= '1';
        tb_error_in_n          <= '1';
        wait for zeit;
        tb_channel_active_in_n <= '0';
        wait for 2 * zeit;

        report "Simulation end.";
        simulation_active <= false;
        wait;
    end process;


end architecture testbench;
