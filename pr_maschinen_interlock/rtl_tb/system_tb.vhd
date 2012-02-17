
library ieee;
use ieee.std_logic_1164.all;


entity system_tb is
end entity system_tb;

architecture testbench of system_tb is

    constant zeit : time := 10 ns;
        

    signal simulation_active      : boolean := true;
	signal tb_reset_n             : std_ulogic;
    signal tb_clk                 : std_ulogic := '0';
    signal tb_channel_active_in_n : std_ulogic_vector(16 downto 1) := (others => '1');
    signal tb_error_in_n          : std_ulogic_vector(16 downto 1) := (others => '1');
    signal tb_test_in_n           : std_ulogic := '1';
    signal tb_test_sps_in_n       : std_ulogic := '1';
    signal tb_clear_n             : std_ulogic := '1';
    signal tb_clear_sps_n         : std_ulogic := '1';
    --                            
    signal tb_error_out           : std_ulogic_vector(16 downto 1);
    signal tb_channel_ok_out      : std_ulogic_vector(16 downto 1);
    signal tb_main_error_out      : std_ulogic;
    signal tb_main_ok_out         : std_ulogic;

begin

    tb_clk <= not tb_clk after 1 ns when simulation_active;

    system_i0: entity work.system
    port map (
		reset_n             => tb_reset_n,              --: in  std_ulogic;
        clk                 => tb_clk,                  --: in  std_ulogic;
        channel_active_in_n => tb_channel_active_in_n,  --: in  std_ulogic_vector(16 downto 1);
        error_in_n          => tb_error_in_n,           --: in  std_ulogic_vector(16 downto 1);
        test_in_n           => tb_test_in_n,            --: in  std_ulogic;
        test_sps_in_n       => tb_test_sps_in_n,        --: in  std_ulogic;
        clear_n             => tb_clear_n,              --: in  std_ulogic;
        clear_sps_n         => tb_clear_sps_n,          --: in  std_ulogic;
        --                  
        error_out           => tb_error_out,            --: out std_ulogic_vector(16 downto 1);
        channel_ok_out      => tb_channel_ok_out,       --: out std_ulogic_vector(16 downto 1);
        main_error_out      => tb_main_error_out,       --: out std_ulogic;
        main_ok_out         => tb_main_ok_out           --: out std_ulogic
    );

    process
    begin
        report "Start simulation.";
        tb_reset_n <= '0';
        wait for 4 * zeit;
        report "deactivate reset";
        tb_reset_n <= '1';
        wait for 2 * zeit;

        wait for zeit;
        report "active channel x";
        tb_channel_active_in_n(5) <= '0';
        wait for 2 * zeit;

        report "clear from SPS";
        tb_clear_sps_n <= '0';
        wait for zeit;
        tb_clear_sps_n <= '1';
        wait for zeit;
        
        report "deactive channel x";
        tb_channel_active_in_n(5) <= '1';
        wait for 2 * zeit;

        wait for 5 * zeit;
        
        report "End simulation.";
        simulation_active <= false;
        wait;
    end process;

end architecture testbench;

