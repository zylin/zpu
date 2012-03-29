library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity top_tb is
end entity top_tb;

architecture testbench of top_tb is

    constant clk_period     : time := (1 sec) / 50;
    constant spi_clk_period : time := (1 sec) / 500;

    signal simulation_run   : boolean := true;
        
    signal tb_reset_n       : std_ulogic;
    signal tb_clk           : std_ulogic := '0';
    --
    signal tb_dip_switch_n  : std_ulogic_vector(3 downto 0);
    signal tb_button_n      : std_ulogic_vector(1 downto 0);		  
    signal tb_led_n         : std_ulogic_vector(7 downto 0);
    --
    signal tb_ssio_do       : std_ulogic;
    signal tb_ssio_clk      : std_ulogic;
    signal tb_ssio_lo       : std_ulogic;
    signal tb_ssio_di       : std_ulogic;
    signal tb_ssio_li       : std_ulogic;

begin

    -- generate clock and reset
    tb_reset_n <= '0', '1' after 25 ms;
    tb_clk     <= not tb_clk after clk_period / 2 when simulation_run;

    -- stimulate buttons
    tb_button_n(0)  <= '1';--'1', '0' after 300 ms, '1' after 500 ms;
    tb_button_n(1)  <= '1';
    tb_dip_switch_n <= x"3";


    top_i0: entity work.top
	port map (
        reset_n       => tb_reset_n,      --: in  std_logic;
        clk           => tb_clk,          --: in  std_logic;
        dip_switch_n  => tb_dip_switch_n, --: in  std_logic_vector(3 downto 0);
        button_n      => tb_button_n,     --: in  std_logic_vector(1 downto 0);		  
		led_n         => tb_led_n,        --: out std_logic_vector(7 downto 0)
        ssio_do       => tb_ssio_do,      --: in  std_logic;
        ssio_clk      => tb_ssio_clk,     --: in  std_logic;
        ssio_lo       => tb_ssio_lo,      --: in  std_logic;
        ssio_di       => tb_ssio_di,      --: out std_logic;
        ssio_li       => tb_ssio_li       --: in  std_logic
	);

    process
        variable data       : unsigned(15 downto 0) := x"a0F5";
        variable data_count : integer;
    begin
        -- stimulate spi inputs

        -- initalize
        tb_ssio_do  <= '0';
        tb_ssio_clk <= '1';
        tb_ssio_lo  <= '0';
        tb_ssio_li  <= '1';

        wait for 333 ms;


        -- from hilscher to CPLD
        data_count := 16;
        while data_count > 0 loop
            data_count := data_count - 1;

            tb_ssio_do  <= data( data_count);
            tb_ssio_clk <= '0';
            wait for spi_clk_period / 2;

            tb_ssio_clk <= '1';
            wait for spi_clk_period / 2;

        end loop;
        
        -- load impulse
        tb_ssio_lo <= '1';
        wait for spi_clk_period / 2;

        tb_ssio_lo <= '0';
        wait for spi_clk_period / 2;

        wait for 200 ms;



        -- from CPLD to hilscher 

        -- load impulse
        tb_ssio_li <= '0';
        wait for spi_clk_period / 2;

        tb_ssio_li <= '1';
        wait for spi_clk_period / 2;


        data_count := 16;
        while data_count > 0 loop
            
            data_count := data_count - 1;

            data( data_count) := tb_ssio_di;
            tb_ssio_clk <= '0';
            wait for spi_clk_period / 2;

            tb_ssio_clk <= '1';
            wait for spi_clk_period / 2;

        end loop;

        report "received: " & integer'image( to_integer( data));

        wait for 50 ms;

        simulation_run <= false;
        wait;
    end process;

end architecture testbench;
