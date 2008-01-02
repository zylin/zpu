library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity arm7wb is
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
end arm7wb;
			
architecture behave of arm7wb is

attribute keep : string;

signal	cpu_oe_n		: std_logic;
signal	cpu_fiq			: std_logic;
signal	cpu_wait_n		: std_logic;
signal	cpu_clk_toggle	: std_logic;
signal	cpu_clk_smp1	: std_logic;
signal	cpu_clk_smp2	: std_logic;
signal	cpu_clk_phase	: std_logic;
signal	cpu_oe_n_del	: std_logic;
signal	cpu_a_smp		: std_logic_vector(20 downto 0);
signal	cpu_d_smp		: std_logic_vector(15 downto 0);

signal	int_oe_n		: std_logic_vector(15 downto 0);
attribute keep of int_oe_n:signal is "true";

signal	cpu_irq			: std_logic_vector(1 downto 0);
signal	cpu_wr_n		: std_logic_vector(1 downto 0);
signal	cpu_cs_n		: std_logic_vector(3 downto 1);

signal	dout			: std_logic_vector(15 downto 0);
signal	cpu_d_p_out		: std_logic_vector(15 downto 0);
signal	read_cnt		: std_logic_vector(1 downto 0);

signal	cpu_wr_n_p_del	: std_logic_vector(1 downto 0);
signal	cpu_a_p_del		: std_logic_vector(20 downto 0);
signal	cpu_d_p_del		: std_logic_vector(15 downto 0);
signal	cpu_cs_n_p_del	: std_logic_vector(3 downto 1);
signal	cpu_oe_n_p_del	: std_logic;

constant	Sim_Delay	: time := 0.5 ns;
constant	Clock_2_Out	: time := 5.5 ns;
constant	Input_Setup	: time := 2.5 ns;

begin

	cpu_wait_n <= '1';
	cpu_fiq <= '1';
	cpu_irq <= "11";
	
	iotimingon:
	if simulate_io_time generate
	begin
		cpu_wr_n_p_del <= "XX" after 0 ns, cpu_wr_n_p after Input_Setup;
		cpu_a_p_del <= "XXXXXXXXXXXXXXXXXXXXX" after 0 ns, cpu_a_p after Input_Setup;
		cpu_d_p_del <= "XXXXXXXXXXXXXXXX" after 0 ns, cpu_d_p after Input_Setup;
		cpu_cs_n_p_del <= "XXX" after 0 ns, cpu_cs_n_p after Input_Setup;
		cpu_oe_n_p_del <= 'X' after 0 ns, cpu_oe_n_p after Input_Setup;
	end generate;
	
	iotimingoff:
	if not simulate_io_time generate
	begin
		cpu_wr_n_p_del <= cpu_wr_n_p;
		cpu_a_p_del <=  cpu_a_p;
		cpu_d_p_del <= cpu_d_p;
		cpu_cs_n_p_del <= cpu_cs_n_p;
		cpu_oe_n_p_del <= cpu_oe_n_p;
	end generate;
	
	process(cpu_clk, areset)	-- Toggle FF with 1x clock to find phase
	begin
		if areset = '1' then
			cpu_clk_toggle <= '0';
		elsif (cpu_clk'event and cpu_clk = '1') then
			cpu_clk_toggle <= not(cpu_clk_toggle);
		end if;
	end process;
	
	process(cpu_clk_2x, areset)	-- Find phase relationsship between 1x and 2x clock
	begin
		if areset = '1' then
			cpu_clk_smp1 <= '0';
			cpu_clk_smp2 <= '1';
			cpu_clk_phase <= '0';
		elsif (cpu_clk_2x'event and cpu_clk_2x = '1') then
			cpu_clk_smp1 <= cpu_clk_toggle;
			cpu_clk_smp2 <= cpu_clk_smp1;
			if cpu_clk_smp1 = '1' and cpu_clk_smp2 = '0' then
				cpu_clk_phase <= '0' after Sim_Delay;
			else
				cpu_clk_phase <= not(cpu_clk_phase) after Sim_Delay;
			end if;
		end if;
	end process;
	
	process(cpu_clk_2x, areset)	-- Sample input signals
	begin
		if areset = '1' then
			cpu_oe_n <= '1';
			cpu_a_smp <= "000000000000000000000";
			cpu_d_smp <= "0000000000000000";
			cpu_wr_n <= "11";
			cpu_cs_n <= "111";
		elsif (cpu_clk_2x = '1' and cpu_clk_2x'event) then
			cpu_oe_n <= cpu_oe_n_p_del after Sim_Delay;
			cpu_a_smp <= cpu_a_p_del after Sim_Delay;
			cpu_d_smp <= cpu_d_p_del after Sim_Delay;
			cpu_wr_n <= cpu_wr_n_p_del after Sim_Delay;
			cpu_cs_n <= cpu_cs_n_p_del after Sim_Delay;
		end if;
	end process;

	cpu_d_out:
   	for i in 0 to 15 generate
      	begin
      		process(cpu_clk_2x, areset)
      		begin
      			if areset = '1' then
      				cpu_d_p(i) <= 'Z';
      			elsif (cpu_clk_2x'event and cpu_clk_2x = '1') then
      				if int_oe_n(i) = '0' then
			        	cpu_d_p(i) <= cpu_d_p_out(i) after Clock_2_Out;
			       	else
			       		cpu_d_p(i) <= 'Z' after Clock_2_Out;
			       	end if;
			  	end if;
			end process;
   	end generate;
   	
	process(cpu_clk, areset)	-- Clocked output pins
	begin
		if areset = '1' then
			cpu_d_p_out <= "1111111111111111";
			cpu_wait_n_p <= '1';
			cpu_irq_p <= "11";
			cpu_fiq_p <= '1';
		elsif (cpu_clk = '1' and cpu_clk'event) then
			cpu_d_p_out <= cpu_dout;
			cpu_wait_n_p <= '1';
			cpu_irq_p <= "11";
			cpu_fiq_p <= '1';
		end if;
	end process;
	
	process(cpu_clk, areset)	-- Generate control signals
	begin
		if areset = '1' then
			int_oe_n <= "1111111111111111";
			read_cnt <= "00";
			cpu_we <= "00";
			cpu_re <= '0';
			cpu_a <= "000000000000000000000";
			cpu_din <= "0000000000000000";
		elsif (cpu_clk = '1' and cpu_clk'event) then
		
			cpu_a <= cpu_a_smp;
			cpu_din <= cpu_d_smp;
			
			cpu_oe_n_del <= cpu_oe_n;
			
			if cpu_cs_n(1) = '1' then
				read_cnt <= "00";
			else
				read_cnt <= read_cnt + '1';
			end if;
			
			if read_cnt = "01" and cpu_cs_n(1) = '0' and cpu_wr_n(0) = '0' then
				cpu_we(0) <= '1';
			else
				cpu_we(0) <= '0';
			end if;
			
			if read_cnt = "01" and cpu_cs_n(1) = '0' and cpu_wr_n(1) = '0' then
				cpu_we(1) <= '1';
			else
				cpu_we(1) <= '0';
			end if;
			
			if read_cnt = "00" and cpu_cs_n(1) = '0' and cpu_oe_n = '0' then
				cpu_re <= '1';
			else
				cpu_re <= '0';
			end if;
			
			if read_cnt = "01" and cpu_cs_n(1) = '0' and cpu_oe_n = '0' then
				int_oe_n <= "0000000000000000";
			else
				int_oe_n <= "1111111111111111";
			end if;
						
		end if;
	end process;
	
end behave;			
