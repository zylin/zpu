library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.phi_config.all;
use work.wishbone_pkg.all;

entity arm7wb is
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
end arm7wb;
			
architecture behave of arm7wb is

type	cpu_state_type		is (cpu_idle, cpu_cs, cpu_end);

-- Input simulated delay
signal	cpu_wr_n_p_del		: std_logic_vector(1 downto 0);
signal 	cpu_a_p_del			: std_logic_vector(23 downto 1);
signal	cpu_d_p_del			: std_logic_vector(15 downto 0);
signal	cpu_cs_n_p_del		: std_logic_vector(3 downto 1);
signal	cpu_oe_n_p_del		: std_logic;

-- Clock phase detect signals
signal	cpu_clk_toggle		: std_logic;
signal	cpu_clk_smp1		: std_logic;
signal	cpu_clk_smp2		: std_logic;
signal	cpu_clk_phase		: std_logic;

-- Internal version of control signal (for feedback)
signal	arm7_din_int		: std_logic_vector(15 downto 0);
signal	arm7_dout_int		: std_logic_vector(15 downto 0);
signal	arm7_a_int			: std_logic_vector(23 downto 1);
signal	arm7_we_int			: std_logic_vector(1 downto 0);
signal  cyc_int             : std_logic;
signal	we_int				: std_logic;
signal  adr_reg             : std_logic_vector(25 downto 24);

-- Input sampled
signal	cpu_a_smp			: std_logic_vector(23 downto 1);
signal	cpu_d_smp			: std_logic_vector(15 downto 0);
signal	cpu_cs_n 			: std_logic_vector(3 downto 1);
signal	cpu_oe_n			: std_logic;
signal	cpu_wr_n 			: std_logic_vector(1 downto 0);

-- Main FSM
signal	cpu_state			: cpu_state_type;

constant	Clock_2_Out	: time := 5.5 ns;
constant	Input_Setup	: time := 2.5 ns;

begin

	arm7_dout_int <= wb_i.dat(15 downto 0) when (arm7_a_int(1) = '0') else wb_i.dat(31 downto 16);
	arm7_debug <= cpu_oe_n;
	arm7_debug2 <= cpu_wr_n(0);

	-- Generate 64 MBytes address based on 3 CS_N signals from CPU
	-- Memory map FPGA internal
	--  0x00000000 DDR 32 MBytes (CS_N2 and CS_N3)
	--  0x00200000 FPGA/Ethernet (CS_N1)
	wb_o.adr(31 downto 26) <= "000000";
	wb_o.adr(25 downto 24) <= adr_reg;
	wb_o.adr(23 downto 1) <= arm7_a_int(23 downto 1);
	wb_o.adr(0) <= '0';
	
	wb_o.dat <= (x"0000" & arm7_din_int) when (arm7_a_int(1) = '0') else (arm7_din_int & x"0000");
	wb_o.sel <= ("00" & arm7_we_int) when (arm7_a_int(1) = '0') else (arm7_we_int & "00");	
	
	wb_o.cyc <= cyc_int;
	wb_o.stb <= cyc_int;
	wb_o.we <= cpu_oe_n;

	iotimingon:
	if simulate_io_time generate
	begin
		cpu_wr_n_p_del <= transport "XX" after 0 ns, cpu_wr_n_p after Input_Setup;
		cpu_a_p_del <= transport "XXXXXXXXXXXXXXXXXXXXXXX" after 0 ns, cpu_a_p after Input_Setup;
		cpu_d_p_del <= transport "XXXXXXXXXXXXXXXX" after 0 ns, cpu_d_p after Input_Setup;
		cpu_cs_n_p_del <= transport "XXX" after 0 ns, cpu_cs_n_p after Input_Setup;
		cpu_oe_n_p_del <= transport 'X' after 0 ns, cpu_oe_n_p after Input_Setup;
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
				cpu_clk_phase <= '0';
			else
				cpu_clk_phase <= not(cpu_clk_phase);
			end if;
		end if;
	end process;
	
	process(cpu_clk_2x, areset)	-- Sample input signals on 2x clock
	begin
		if areset = '1' then
			cpu_d_smp <= "0000000000000000";
			cpu_cs_n <= "111";
		elsif (cpu_clk_2x = '1' and cpu_clk_2x'event) then
			cpu_d_smp <= cpu_d_p_del;
			cpu_cs_n <= cpu_cs_n_p_del;
		end if;
	end process;

	process(cpu_clk, areset)	-- Sample input signals on 1x clock
	begin
		if areset = '1' then
			cpu_a_smp <= "00000000000000000000000";
			cpu_oe_n <= '1';
			cpu_wr_n <= "11";
		elsif (cpu_clk = '1' and cpu_clk'event) then
			cpu_a_smp <= cpu_a_p_del;
			cpu_oe_n <= cpu_oe_n_p_del;
			cpu_wr_n <= cpu_wr_n_p_del;
		end if;
	end process;

	arm7_din_int <= cpu_d_smp;
	arm7_a_int <= cpu_a_smp;
	arm7_we_int <= not(cpu_wr_n);
	
	process(cpu_clk, areset)
	begin
		if areset = '1' then
			cpu_state <= cpu_idle;
			cyc_int <= '0';
			we_int <= '0';
			adr_reg <= "00";
			cpu_d_p	<= (others => 'Z');
		elsif (cpu_clk'event and cpu_clk = '1') then
			
			cyc_int <= '0';
			we_int <= '0';
			cpu_d_p	<= (others => 'Z') after Clock_2_Out;
			
			
			case cpu_state is
			
				when cpu_idle =>
					if cpu_oe_n = '1' then
						we_int <= '1';
					end if;
					if cpu_cs_n(1) = '0' then
						cyc_int <= '1';
						adr_reg <= "10";
						cpu_state <= cpu_cs;
					end if;
					if cpu_cs_n(2) = '0' then
						cyc_int <= '1';
						adr_reg <= "00";
						cpu_state <= cpu_cs;
					end if;
					if cpu_cs_n(3) = '0' then
						cyc_int <= '1';
						adr_reg <= "01";
						cpu_state <= cpu_cs;
					end if;
					
				when cpu_cs =>
					if cpu_oe_n = '0' then
						cpu_d_p <= arm7_dout_int after Clock_2_Out;
						if wb_i.ack = '1' then
							cpu_state <= cpu_end;
						else
							cyc_int <= '1';
						end if;
					else
						if wb_i.ack = '0' then
							cyc_int <= '1';
							we_int <= '1';
						else
							cpu_state <= cpu_end;
						end if;
					end if;
						
				when others =>
					cpu_state <= cpu_idle;

			end case;
		end if;
	end process;
	
	process(cpu_clk_2x, areset)
	begin
		if areset = '1' then
			cpu_wait_n_p <= '1';
		elsif (cpu_clk_2x'event and cpu_clk_2x = '1') then
			cpu_wait_n_p <= '1' after Clock_2_Out;
			if (cpu_state = cpu_cs and wb_i.ack = '0') then
			   	cpu_wait_n_p <= '0' after Clock_2_Out;
			end if;
		end if;
	end process;
	
end behave;			
