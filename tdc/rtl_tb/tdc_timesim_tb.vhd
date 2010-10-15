entity tdc_timesim_tb is
end entity tdc_timesim_tb;


library ieee;
use ieee.std_logic_1164.all;

library simprim;
use simprim.vpackage.std_logic_vector2;



architecture testbench of tdc_timesim_tb is

    constant clk_period   : time := (1 sec / 100e6); -- 100 MHz
    constant channels_c   : positive := 2;


    component my_tdc_timesim is
        port (
            clk : in STD_LOGIC := 'X';
            results : out STD_LOGIC_VECTOR2 ( 1 downto 0 , 6 downto 0 );
            channels : in STD_LOGIC_VECTOR ( 1 downto 0 )
        );
    end component my_tdc_timesim;



    signal simulation_run         : boolean    := true;
    signal tb_clk                 : std_ulogic := '0';

    signal tdc_timesim_i0_results : std_logic_vector2( 1 downto 0, 6 downto 0);

    signal pulses                 : std_ulogic_vector( channels_c-1 downto 0) := (others => '0');
    signal pulse0                 : std_ulogic;
    signal pulse1                 : std_ulogic;

begin

    tb_clk <= not tb_clk after clk_period/2 when simulation_run;
    
    puls_gen0 : process
    begin
        pulse0     <= '0';
        if simulation_run then
            wait until rising_edge( tb_clk);

            wait for 43 ps;
            pulse0 <= '1';

            wait for 2 * clk_period;
        else
            wait;
        end if;
    end process;

    puls_gen1 : process
    begin
        pulse1     <= '0';
        if simulation_run then
            wait until rising_edge( tb_clk);

            wait for 73 ps;
            pulse1 <= '1';

            wait for 2 * clk_period;
        else
            wait;
        end if;
    end process;


    process
    begin
        wait for 100 us;
        wait for 6 * clk_period;
        simulation_run <= false;
        report "Simulation ends." severity note;
        wait; -- forever
    end process;

    pulses(1 downto 0)    <= pulse1 & pulse0;


    tdc_timesim_i0 : my_tdc_timesim
        port map (
            channels => std_logic_vector( pulses),
            clk      => tb_clk,
            results  => tdc_timesim_i0_results
        );


end architecture testbench;
