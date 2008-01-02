library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

package arm7 is

	component arm7wb
	generic(
			simulate_io_time	: boolean := false);
	port (	areset			: in std_logic;
			cpu_clk			: in std_logic;
			cpu_clk_2x		: in std_logic;
			cpu_a_p			: in std_logic_vector(20 downto 0);
			cpu_wr_n_p		: in std_logic_vector(1 downto 0);
			cpu_cs_n_p		: in std_logic_vector(3 downto 1);
			cpu_oe_n_p		: in std_logic;
			cpu_d_p			: inout std_logic_vector(15 downto 0);
			cpu_irq_p		: out std_logic_vector(1 downto 0);
			cpu_fiq_p		: out std_logic;
			cpu_wait_n_p	: out std_logic;
			
			cpu_din			: out std_logic_vector(15 downto 0);
			cpu_a			: out std_logic_vector(20 downto 0);
			cpu_we			: out std_logic_vector(1 downto 0);
			cpu_re			: out std_logic;
			cpu_dout		: in std_logic_vector(15 downto 0));
	end component;
	
end arm7;

			