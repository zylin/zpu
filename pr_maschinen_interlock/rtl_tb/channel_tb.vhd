library ieee;
use ieee.std_logic_1164.all;


entity channel_tb is
end entity channel_tb;

architecture testbench of channel_tb is

    constant zeit : time := 10 ns;
        
    signal tb_clk               : std_ulogic := '0';
    signal tb_channel_active_in : std_ulogic := '0';
    signal tb_error_in_n        : std_ulogic; -- low active
    signal tb_test_in_n         : std_ulogic; -- low active
    signal tb_test_sps_in       : std_ulogic;
    signal tb_clear             : std_ulogic;
    signal tb_clear_sps         : std_ulogic;
    --                
    signal tb_error_out         : std_ulogic;
    signal tb_channel_ok_out    : std_ulogic;

begin


    channel_i0: entity work.channel
    port map (
        clk               => tb_clk,                  --: in  std_ulogic;
        channel_active_in => tb_channel_active_in,    --: in  std_ulogic;
        error_in_n        => tb_error_in_n,           --: in  std_ulogic; -- low active
        test_in_n         => tb_test_in_n,            --: in  std_ulogic; -- low active
        test_sps_in       => tb_test_sps_in,          --: in  std_ulogic;
        clear             => tb_clear,                --: in  std_ulogic;
        clear_sps         => tb_clear_sps,            --: in  std_ulogic;
        --                              
        error_out         => tb_error_out,            --: out std_ulogic;
        channel_ok_out    => tb_channel_ok_out        --: out std_ulogic
    );


    process
    begin
        report "test for clear";
        wait for zeit;
        tb_clear <= '1';
        wait for zeit;
        tb_clear <= '0';
        wait for 2 * zeit;

        report "channel active";
        tb_channel_active_in <= '1';
        wait for zeit;
        tb_clear_sps <= '1';
        wait for zeit;
        tb_clear_sps <= '0';
        wait for 2 * zeit;

        report "clear (from sps, test_sps is active)";
        tb_test_sps_in <= '1';
        wait for zeit;
        tb_clear_sps   <= '1';
        wait for zeit;
        tb_test_sps_in <= '0';
        wait for zeit;
        tb_clear_sps   <= '0';
        wait for 2 * zeit;
        
        report "clear (from sps, test_sps is inactive)";
        tb_clear_sps <= '1';
        wait for zeit;
        tb_test_sps_in <= '1';
        wait for zeit;
        tb_test_sps_in <= '0';
        wait for zeit;
        tb_clear_sps <= '0';
        wait for 2 * zeit;

        report "error";
        tb_error_in_n <= '0';
        wait for zeit;
        tb_error_in_n <= '1';
        wait for zeit;
        tb_clear    <= '1';
        wait for zeit;
        tb_clear    <= '0';
        wait for 2 * zeit;


        report "error (but inactive)";
        tb_channel_active_in <= '0';
        wait for zeit;
        tb_error_in_n <= '0';
        wait for zeit;
        tb_error_in_n <= '1';
        wait for zeit;
        tb_clear    <= '1';
        wait for zeit;
        tb_clear    <= '0';
        wait for 2 * zeit;

        report "error (with try to clear)";
        tb_channel_active_in <= '1';
        wait for zeit;
        tb_error_in_n <= '0';
        wait for zeit;
        tb_clear    <= '1';
        wait for zeit;
        tb_clear    <= '0';
        wait for 2 * zeit;

        report "error gone (with try to clear)";
        wait for zeit;
        tb_clear    <= '1';
        wait for zeit;
        tb_error_in_n <= '1';
        wait for zeit;
        tb_clear    <= '0';
        wait for 2 * zeit;

        report "switch on with clear";
        tb_channel_active_in <= '0';
        tb_clear             <= '0';
        tb_clear_sps         <= '1';
        tb_error_in_n        <= '1';
        wait for zeit;
        tb_channel_active_in <= '1';
        wait for 2 * zeit;

        report "Simulation end.";
        wait;
    end process;


end architecture testbench;
