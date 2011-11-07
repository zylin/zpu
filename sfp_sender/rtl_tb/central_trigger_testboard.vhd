

library ieee;
use ieee.std_logic_1164.all;


entity central_trigger_testboard is
    port (
        simulation_run        : boolean := true;
        fmc_lpc_row_c         : inout std_logic_vector(40 downto 1);
        fmc_lpc_row_d         : inout std_logic_vector(40 downto 1);
        fmc_lpc_row_g         : inout std_logic_vector(40 downto 1);
        fmc_lpc_row_h         : inout std_logic_vector(40 downto 1)
    );
end entity central_trigger_testboard;


architecture model of central_trigger_testboard is

    constant gnd              : std_logic := '0';
    --
    constant clk_slow_period  : time := 1 sec / 13_000_000;
    constant clk_fast_period  : time := 1 sec / 260_000_000;


    signal clk_slow_n : std_logic := '0';
    signal clk_slow_p : std_logic := '1';
    signal clk_fast_n : std_logic := '0';
    signal clk_fast_p : std_logic := '1';

    alias led_1  : std_logic is fmc_lpc_row_h(16);
    alias led_2  : std_logic is fmc_lpc_row_h(17);
    --           
    alias led_3  : std_logic is fmc_lpc_row_h(19);
    alias led_4  : std_logic is fmc_lpc_row_h(20);
    --           
    alias led_5  : std_logic is fmc_lpc_row_h(22);
    alias led_6  : std_logic is fmc_lpc_row_h(23);
    --           
    alias led_7  : std_logic is fmc_lpc_row_h(25);
    alias led_8  : std_logic is fmc_lpc_row_h(26);
    --           
    alias led_9  : std_logic is fmc_lpc_row_h(28);
    alias led_10 : std_logic is fmc_lpc_row_h(29);

begin
        
    -- generate clocks
    clk_slow_n <= not clk_slow_n after clk_slow_period / 2 when simulation_run;
    clk_slow_p <= not clk_slow_p after clk_slow_period / 2 when simulation_run;

    clk_fast_n <= not clk_fast_n after clk_fast_period / 2 when simulation_run;
    clk_fast_p <= not clk_fast_p after clk_fast_period / 2 when simulation_run;


    --signal connections
    fmc_lpc_row_h( 4) <= clk_fast_p; -- clkin_p
    fmc_lpc_row_h( 5) <= clk_fast_n; -- clkin_n

    fmc_lpc_row_g( 6) <= clk_slow_p; -- clkin_13_p
    fmc_lpc_row_g( 7) <= clk_slow_n; -- clkin_13_n

    -- predefined connections on fmc connector
    -- X - power, 0 - gnd, U - unknown signal
    fmc_lpc_row_c  <= (others => 'Z');
    fmc_lpc_row_d  <= (others => 'Z');
    fmc_lpc_row_g  <= (others => 'Z');
    fmc_lpc_row_h  <= (others => 'Z');
    -- row c
    fmc_lpc_row_c(1)  <= gnd;
    fmc_lpc_row_c(2)  <= 'U';
    fmc_lpc_row_c(3)  <= 'U';
    fmc_lpc_row_c(4)  <= gnd;
    fmc_lpc_row_c(5)  <= gnd;
    fmc_lpc_row_c(6)  <= 'U';
    fmc_lpc_row_c(7)  <= 'U';
    fmc_lpc_row_c(8)  <= gnd;
    fmc_lpc_row_c(9)  <= gnd;
    fmc_lpc_row_c(12) <= gnd;
    fmc_lpc_row_c(13) <= gnd;
    fmc_lpc_row_c(16) <= gnd;
    fmc_lpc_row_c(17) <= gnd;
    fmc_lpc_row_c(20) <= gnd;
    fmc_lpc_row_c(21) <= gnd;
    fmc_lpc_row_c(24) <= gnd;
    fmc_lpc_row_c(25) <= gnd;
    fmc_lpc_row_c(28) <= gnd;
    fmc_lpc_row_c(29) <= gnd;
    fmc_lpc_row_c(30) <= 'Z'; -- tb_iic_scl_main;
    fmc_lpc_row_c(31) <= 'Z'; -- tb_iic_sda_main;
    fmc_lpc_row_c(32) <= gnd;
    fmc_lpc_row_c(33) <= gnd;
    fmc_lpc_row_c(34) <= 'U';
    fmc_lpc_row_c(35) <= 'X';
    fmc_lpc_row_c(36) <= gnd;
    fmc_lpc_row_c(37) <= 'X';
    fmc_lpc_row_c(38) <= gnd;
    fmc_lpc_row_c(39) <= 'X';
    fmc_lpc_row_c(40) <= gnd;
    -- row d
    fmc_lpc_row_d(2)  <= gnd;
    fmc_lpc_row_d(3)  <= gnd;
    fmc_lpc_row_d(4)  <= 'U';
    fmc_lpc_row_d(5)  <= 'U';
    fmc_lpc_row_d(6)  <= gnd;
    fmc_lpc_row_d(7)  <= gnd;
    fmc_lpc_row_d(10) <= gnd;
    fmc_lpc_row_d(13) <= gnd;
    fmc_lpc_row_d(16) <= gnd;
    fmc_lpc_row_d(19) <= gnd;
    fmc_lpc_row_d(22) <= gnd;
    fmc_lpc_row_d(25) <= gnd;
    fmc_lpc_row_d(28) <= gnd;
    fmc_lpc_row_d(29) <= 'U';
    fmc_lpc_row_d(30) <= 'U';
    fmc_lpc_row_d(31) <= 'U';
    fmc_lpc_row_d(32) <= 'X';
    fmc_lpc_row_d(33) <= 'U';
    fmc_lpc_row_d(34) <= 'U';
    fmc_lpc_row_d(35) <= 'U';
    fmc_lpc_row_d(36) <= 'X';
    fmc_lpc_row_d(37) <= gnd;
    fmc_lpc_row_d(38) <= 'X';
    fmc_lpc_row_d(39) <= gnd;
    fmc_lpc_row_d(40) <= 'X';
    -- row g
    fmc_lpc_row_g(1)  <= gnd;
    fmc_lpc_row_g(4)  <= gnd;
    fmc_lpc_row_g(5)  <= gnd;
    fmc_lpc_row_g(8)  <= gnd;
    fmc_lpc_row_g(11) <= gnd;
    fmc_lpc_row_g(14) <= gnd;
    fmc_lpc_row_g(17) <= gnd;
    fmc_lpc_row_g(20) <= gnd;
    fmc_lpc_row_g(23) <= gnd;
    fmc_lpc_row_g(26) <= gnd;
    fmc_lpc_row_g(29) <= gnd;
    fmc_lpc_row_g(32) <= gnd;
    fmc_lpc_row_g(35) <= gnd;
    fmc_lpc_row_g(38) <= gnd;
    fmc_lpc_row_g(39) <= 'X';
    fmc_lpc_row_g(40) <= gnd;
    -- row h
    fmc_lpc_row_h(1)  <= 'X';
    fmc_lpc_row_h(3)  <= gnd;
    fmc_lpc_row_h(6)  <= gnd;
    fmc_lpc_row_h(9)  <= gnd;
    fmc_lpc_row_h(12) <= gnd;
    fmc_lpc_row_h(15) <= gnd;
    fmc_lpc_row_h(18) <= gnd;
    fmc_lpc_row_h(21) <= gnd;
    fmc_lpc_row_h(24) <= gnd;
    fmc_lpc_row_h(27) <= gnd;
    fmc_lpc_row_h(30) <= gnd;
    fmc_lpc_row_h(33) <= gnd;
    fmc_lpc_row_h(36) <= gnd;
    fmc_lpc_row_h(39) <= gnd;
    fmc_lpc_row_h(40) <= 'X';

end architecture model;
