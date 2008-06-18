library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.wishbone_pkg.all;

package arm7 is

	component arm7wb
	generic(
			simulate_io_time	: boolean := false);
	port (	areset			: in std_logic;
			cpu_clk			: in std_logic;
			cpu_clk_2x		: in std_logic;
			cpu_a_p			: in std_logic_vector(23 downto 1);
			cpu_wr_n_p		: in std_logic_vector(1 downto 0);
			cpu_cs_n_p		: in std_logic_vector(3 downto 1);
			cpu_oe_n_p		: in std_logic;
			cpu_d_p			: inout std_logic_vector(15 downto 0);
			cpu_wait_n_p	: out std_logic;
			
			arm7_debug		: out std_logic;
			arm7_debug2		: out std_logic;
			
			wb_o			: out wishbone_bus_in;
			wb_i            : in wishbone_bus_out);			
	end component;
	
end arm7;

			