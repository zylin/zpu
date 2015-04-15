library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.vcomponents.all;

entity ddr_top is
	generic(
			simulate_io_time	: boolean := false);
	port (	-- Asyncronous reset and clocks
			areset			: in std_logic;
			cpu_clk			: in std_logic;
			cpu_clk_2x		: in std_logic;
			cpu_clk_4x		: in std_logic;
			ddr_in_clk		: in std_logic;
			ddr_in_clk_2x	: in std_logic;
			
			-- Command interface
			ddr_command		: in std_logic_vector(15 downto 0);
			ddr_command_we	: in std_logic;
			refresh_en		: in std_logic;
			
			-- Data interface signals
			ddr_data_read	: out std_logic_vector(31 downto 0);	-- Data read from DDR SDRAM
			ddr_data_write	: in std_logic_vector(35 downto 0);		-- Data to be written to DDR SDRAM
			ddr_req_adr		: in std_logic_vector(25 downto 1);		-- Request address
			ddr_req			: in std_logic;							-- Request DDR SDRAM access
			ddr_busy		: out std_logic;							-- Request acknowledge
			ddr_rd_wr_n		: in std_logic;							-- Access type 1=READ, 0=WRITE
			ddr_req_len		: in std_logic;							-- Number of 16-bits words to transfer (0=2, 1=8)
			ddr_read_en		: out std_logic;						-- Enable signal for read data
			ddr_write_en	: out std_logic;						-- Enable (read) signal for data write

		    -- DDR SDRAM Signals
		    sdr_clk_p       : out std_logic;    -- ddr_sdram_clock
		    sdr_clk_n_p     : out std_logic;    -- /ddr_sdram_clock
		    cke_q_p         : out std_logic;    -- clock enable
		    cs_qn_p         : out std_logic;    -- /chip select
		    ras_qn_p        : inout std_logic;    -- /ras
		    cas_qn_p        : inout std_logic;    -- /cas
		    we_qn_p         : inout std_logic;    -- /write enable
		    dm_q_p          : out std_logic_vector(1 downto 0);     -- data mask bits, set to "00"
		    dqs_q_p         : out std_logic_vector(1 downto 0);    -- data strobe, only for write
		    ba_q_p          : out std_logic_vector(1 downto 0);   -- bank select
		    sdr_a_p		    : out std_logic_vector(12 downto 0);   -- address bus 
		    sdr_d_p         : inout std_logic_vector(15 downto 0)); 			-- bidir data bus
end ddr_top;

architecture behave of ddr_top is

attribute keep : string;

type	clk4_type			is array(0 to 15) of std_logic_vector(1 downto 0);

signal	cpu_clk_tog			: std_logic;
signal	ddr_cmd				: std_logic_vector(15 downto 0);
signal	ddr_cmd_we_smp		: std_logic;
signal	new_command			: std_logic;

signal	cpu_clk_2x_smp1		: std_logic;		
signal	cpu_clk_2x_smp2		: std_logic;		
signal	cpu_clk_4x_smp1		: std_logic;		
signal	cpu_clk_4x_smp2		: std_logic;

signal	clk2_phase			: std_logic;	
signal	clk4_phase			: std_logic_vector(3 downto 0);
signal	clk4_phase_short	: clk4_type;
attribute keep of clk4_phase_short:signal is "true";

signal	ddr_clk_tog			: std_logic;
signal	ddr_clk_smp1		: std_logic;
signal	ddr_clk_smp2		: std_logic;
signal	ddr_clk_phase		: std_logic;

signal	smp_req_adr			: std_logic_vector(25 downto 1);
signal	smp_req_type		: std_logic;
signal	smp_req_len			: std_logic;
signal	ddr_write_en_int	: std_logic;
signal	ddr_read_en_int		: std_logic;

signal	dqs_q				: std_logic_vector(1 downto 0);
signal	dqs_oe_n			: std_logic_vector(1 downto 0);
attribute keep of dqs_oe_n:signal is "true";
signal	cas_qn				: std_logic;
signal	ras_qn				: std_logic;
signal	we_qn				: std_logic;
signal	ba_q				: std_logic_vector(1 downto 0);
signal	sdr_clk				: std_logic;
signal	sdr_clk_n			: std_logic;
signal	sdr_a				: std_logic_vector(12 downto 0);
signal	sdr_d				: std_logic_vector(15 downto 0);
signal	sdr_smp				: std_logic_vector(35 downto 0);
signal	sdr_oe_n			: std_logic_vector(15 downto 0);
attribute keep of sdr_oe_n:signal is "true";
signal	sdr_oe_ctrl			: std_logic_vector(15 downto 0);
attribute keep of sdr_oe_ctrl:signal is "true";
signal	sdr_wr_msw			: std_logic_vector(17 downto 0);
attribute keep of sdr_wr_msw:signal is "true";
signal	dm_q				: std_logic_vector(1 downto 0);

signal  nowin_idle_dqs      : std_logic_vector(1 downto 0);
signal  nowin_wr_nop1_d     : std_logic_vector(15 downto 0);
signal  nowin_wr_nop1_dqs   : std_logic_vector(1 downto 0);
signal  nowin_wr_nop1_dm    : std_logic_vector(1 downto 0);
signal  nowin_wr_nop2_dqs   : std_logic_vector(1 downto 0);
signal  nowin_wr_nop3_d     : std_logic_vector(15 downto 0);
signal  nowin_wr_nop3_dqs   : std_logic_vector(1 downto 0);
attribute keep of nowin_idle_dqs:signal is "true";
attribute keep of nowin_wr_nop1_d:signal is "true";
attribute keep of nowin_wr_nop1_dqs:signal is "true";
attribute keep of nowin_wr_nop1_dm:signal is "true";
attribute keep of nowin_wr_nop2_dqs:signal is "true";
attribute keep of nowin_wr_nop3_d:signal is "true";
attribute keep of nowin_wr_nop3_dqs:signal is "true";

signal	cas_n_smp			: std_logic;
signal	ras_n_smp			: std_logic;
signal	we_n_smp			: std_logic;
signal	read_start_sig		: std_logic;
signal	sdr_d_in			: std_logic_vector(15 downto 0);
signal	read_time_cnt		: std_logic_vector(1 downto 0);
signal	read_input_en		: std_logic;
signal	read_input_en_del	: std_logic;
signal	ddr_data_read_int	: std_logic_vector(31 downto 0);

signal	refresh_pend		: std_logic;
signal	refresh_end			: std_logic;
signal	refresh_cnt			: std_logic_vector(9 downto 0);
signal	refresh_wait_cnt	: std_logic_vector(3 downto 0);
signal	refresh_wait_end	: std_logic;

signal	cas_qn_p_del		: std_logic;
signal	ras_qn_p_del		: std_logic;
signal	we_qn_p_del			: std_logic;
signal	sdr_d_p_del			: std_logic_vector(15 downto 0);

signal	saved_row			: std_logic_vector(26 downto 11);
signal	operation			: std_logic_vector(1 downto 0);

signal	ddr_req_adr_int		: std_logic_vector(25 downto 1);

type state_type is (idle, act, act_nop1, act_nop2, rd_wr, rd_nop1, 
					rd_nop2,rd_nop3,rd_nop4, rd_nop5,pre, pre_nop1, pre_nop2, wr_nop1, wr_nop2, 
					wr_nop3, cmd, cpu_pre, refresh, refresh_wait);
signal	ddr_state			: state_type;

constant	Clk_to_Output	: time := 2.2 ns;
constant	Input_Setup	: time := 2.5 ns;

constant	Refresh_Interval	: std_logic_vector(9 downto 0) := "1111100110";

begin

	iotimingon:
	if simulate_io_time generate
	begin
		cas_qn_p_del <= 'X' after 0 ns, cas_qn_p after Input_Setup;
		ras_qn_p_del <= 'X' after 0 ns, ras_qn_p after Input_Setup;
		we_qn_p_del <= 'X' after 0 ns, we_qn_p after Input_Setup;
		sdr_d_p_del <= "XXXXXXXXXXXXXXXX" after 0 ns, sdr_d_p after Input_Setup;
	end generate;
	
	iotimingoff:
	if not simulate_io_time generate
	begin
		cas_qn_p_del <= cas_qn_p;
		ras_qn_p_del <= ras_qn_p;
		we_qn_p_del <= we_qn_p;
		sdr_d_p_del <= sdr_d_p;
	end generate;
	
	ddr_write_en <= ddr_write_en_int;
	ddr_read_en <= ddr_read_en_int;
	ddr_data_read <= ddr_data_read_int;
	
	ddr_req_adr_int <= (ddr_req_adr(24 downto 10) & '0' & ddr_req_adr(9 downto 1)) when (simulate_io_time) else ddr_req_adr;

	process(cpu_clk, areset)	-- Toggle a flip-flop with cpu_clk, in order 
	begin						-- to find phase relation with 2x and 4x clocks
		if areset = '1' then
			cpu_clk_tog <= '0';
		elsif (cpu_clk'event and cpu_clk = '1') then
			cpu_clk_tog <= not(cpu_clk_tog);
		end if;
	end process;
	
	process(cpu_clk_2x, areset)	-- Find phase relation between cpu_clk and cpu_clk_2x
	begin
		if areset = '1' then
			cpu_clk_2x_smp1 <= '0';
			cpu_clk_2x_smp2 <= '0';
			clk2_phase <= '0';
		elsif (cpu_clk_2x'event and cpu_clk_2x = '1') then
			cpu_clk_2x_smp1 <= cpu_clk_tog;
			cpu_clk_2x_smp2 <= cpu_clk_2x_smp1;
			if (cpu_clk_2x_smp1 = '1' and cpu_clk_2x_smp2 = '0') then
				clk2_phase <= '0';
			else
				clk2_phase <= not(clk2_phase);
			end if;
		end if;
	end process;
	
	process(cpu_clk_4x, areset)	-- Find phase relation between cpu_clk and cpu_clk_4x
	begin
		if areset = '1' then
			cpu_clk_4x_smp1 <= '0';
			cpu_clk_4x_smp2 <= '0';
			clk4_phase <= "0000";
			clk4_phase_short(0) <= "00";
			clk4_phase_short(1) <= "00";
			clk4_phase_short(2) <= "00";
			clk4_phase_short(3) <= "00";
			clk4_phase_short(4) <= "00";
			clk4_phase_short(5) <= "00";
			clk4_phase_short(6) <= "00";
			clk4_phase_short(7) <= "00";
			clk4_phase_short(8) <= "00";
			clk4_phase_short(9) <= "00";
			clk4_phase_short(10) <= "00";
			clk4_phase_short(11) <= "00";
			clk4_phase_short(12) <= "00";
			clk4_phase_short(13) <= "00";
			clk4_phase_short(14) <= "00";
			clk4_phase_short(15) <= "00";
		elsif (cpu_clk_4x'event and cpu_clk_4x = '1') then
			cpu_clk_4x_smp1 <= cpu_clk_tog;
			cpu_clk_4x_smp2 <= cpu_clk_4x_smp1;
			for i in 0 to 15 loop
				if (cpu_clk_4x_smp1 = '1' and cpu_clk_4x_smp2 = '0') then
					clk4_phase <= "0100";
					clk4_phase_short(i) <= "01";
				else
					clk4_phase <= (clk4_phase(2 downto 0) & clk4_phase(3));
					clk4_phase_short(i) <= clk4_phase_short(i)(0) & clk4_phase_short(i)(1);
				end if;
			end loop;
		end if;
	end process;

	process(cpu_clk_4x, areset)	--
	begin
		if areset = '1' then
			sdr_clk <= '0';			
			sdr_clk_n <= '0';			
		elsif (cpu_clk_4x'event and cpu_clk_4x = '1') then
			if clk4_phase_short(0)(0) = '1' then
				sdr_clk <= '1';
			else
				sdr_clk <= '0';
			end if;
			if clk4_phase_short(0)(1) = '1' then
				sdr_clk_n <= '1';
			else
				sdr_clk_n <= '0';
			end if;
		end if;
	end process;
	
    cke_q_p <= '1' after Clk_to_Output;
    cs_qn_p <= '0' after Clk_to_Output;
	
	process(cpu_clk_4x, areset)	--
	begin
		if areset = '1' then
		    ras_qn_p <= '1';
		    cas_qn_p <= '1';
		    we_qn_p <= '1';
		    dqs_q_p <= "ZZ";
		    sdr_a_p <= "0000000000000";
			ba_q_p <= "00";
			sdr_clk_p <= '0';
			sdr_clk_n_p <= '1';
		elsif (cpu_clk_4x'event and cpu_clk_4x = '1') then
		    ras_qn_p <= transport ras_qn after Clk_to_Output;
		    cas_qn_p <= transport cas_qn after Clk_to_Output;
		    we_qn_p <= transport we_qn after Clk_to_Output;
		    if dqs_oe_n(0) = '0' then
		    	dqs_q_p(0) <= transport dqs_q(0) after Clk_to_Output;
		    else
		    	dqs_q_p(0) <= transport 'Z' after Clk_to_Output;
		    end if;
		    if dqs_oe_n(1) = '0' then
		    	dqs_q_p(1) <= transport dqs_q(1) after Clk_to_Output;
		    else
		    	dqs_q_p(1) <= transport 'Z' after Clk_to_Output;
		    end if;
		    sdr_a_p <= transport sdr_a after Clk_to_Output;
		    ba_q_p <= transport ba_q after Clk_to_Output;
		    sdr_clk_p <= transport sdr_clk after Clk_to_Output;
		    sdr_clk_n_p <= transport sdr_clk_n after Clk_to_Output;
		end if;
	end process;
	
	process(cpu_clk_2x, areset)	--
	begin
		if areset = '1' then
			ddr_state <= idle;
			ras_qn <= '1';
			cas_qn <= '1';
			we_qn <= '1';
			smp_req_adr <= (others => '0');
			smp_req_type <= '0';
			smp_req_len <= '0';
			sdr_a <= "XXXXXXXXXXXXX";
			ba_q <= "00";
			ddr_busy <= '1';
			saved_row <= "1000000000000000";
			ddr_write_en_int <= '0';
			ddr_read_en_int <= '0';
			nowin_idle_dqs <= "11";
			nowin_wr_nop1_d <= "0000000000000000";
			nowin_wr_nop1_dqs <= "00";
			nowin_wr_nop1_dm <= "00";
			nowin_wr_nop2_dqs <= "00";
			nowin_wr_nop3_d <= "0000000000000000";
			nowin_wr_nop3_dqs <= "00";
		elsif (cpu_clk_2x'event and cpu_clk_2x = '1') then
		
			-- Default values
			ras_qn <= '1';
			cas_qn <= '1';
			we_qn <= '1';
			sdr_a <= "XXXXXXXXXXXXX";
			ddr_busy <= '1';
			ddr_write_en_int <= '0';
			ddr_read_en_int <= '0';

			nowin_idle_dqs <= "00";
			nowin_wr_nop1_d <= "0000000000000000";
			nowin_wr_nop1_dqs <= "00";
			nowin_wr_nop1_dm <= "00";
			nowin_wr_nop2_dqs <= "00";
			nowin_wr_nop3_d <= "0000000000000000";
			nowin_wr_nop3_dqs <= "00";
		
			case ddr_state is
				when idle =>
					smp_req_adr <= ddr_req_adr_int;
					smp_req_type <= ddr_rd_wr_n;
					smp_req_len <= ddr_req_len;
					ddr_busy <= '0';
					operation <= "00";
					if refresh_pend = '1' then
						operation <= "01";
						ddr_state <= pre;
					elsif new_command = '1' then
						if ddr_cmd(15) = '1' then
							operation <= "10";
							ddr_state <= cpu_pre;
						else
							ddr_state <= cmd;
						end if;
					elsif (ddr_req = '1' and ddr_req_adr_int(25 downto 11) = saved_row(25 downto 11) and saved_row(26) = '0') then
						operation <= "11";
						ddr_write_en_int <= not(ddr_rd_wr_n);
						ddr_state <= rd_wr;
					elsif ddr_req = '1' then
						operation <= "11";
						ddr_state <= pre;
					else
						ddr_state <= idle;
						nowin_idle_dqs <= "11";
					end if;
				when act =>
					sdr_a <= smp_req_adr(23 downto 11);
					ba_q <= smp_req_adr(25 downto 24);
					ras_qn <= '0';
					ddr_write_en_int <= not(smp_req_type);
					ddr_state <= act_nop1;
				when act_nop1 =>
					ddr_state <= act_nop2;
				when act_nop2 =>
					ddr_state <= rd_wr;
				when rd_wr =>
					sdr_a(10) <= '0';		-- Disable auto precharge
					sdr_a(9 downto 0) <= smp_req_adr(10 downto 1);
					ba_q <= smp_req_adr(25 downto 24);
					saved_row <= '0' & smp_req_adr(25 downto 11);
					cas_qn <= '0';
					we_qn <= smp_req_type;
					if smp_req_type = '1' then
						ddr_state <= rd_nop1;
					else
						ddr_state <= wr_nop1;
						nowin_wr_nop1_d <= "1111111111111111";
						nowin_wr_nop1_dqs <= "11";
						nowin_wr_nop1_dm <= "11";
					end if;
				when wr_nop1 =>
					ddr_state <= wr_nop2;	
					nowin_wr_nop2_dqs <= "11";
				when wr_nop2 =>
					ddr_state <= wr_nop3;
					nowin_wr_nop3_d <= "1111111111111111";
					nowin_wr_nop3_dqs <= "11";
				when wr_nop3 =>
					nowin_idle_dqs <= "11";
					ddr_state <= idle;
				when rd_nop1 =>
					ddr_state <= rd_nop2;
				when rd_nop2 =>
					if operation /= "11" then
						nowin_idle_dqs <= "11";
						ddr_state <= idle;
					else
						ddr_state <= rd_nop3;
					end if;
				when rd_nop3 =>
					ddr_state <= rd_nop4;
				when rd_nop4 =>
					ddr_read_en_int <= '1';
					ddr_state <= rd_nop5;
				when rd_nop5 =>
					nowin_idle_dqs <= "11";
					ddr_state <= idle;
				when pre =>					
					ras_qn <= '0';
					we_qn <= '0';
					sdr_a(10) <= '1';	-- Precharge all banks
					ba_q <= smp_req_adr(25 downto 24);
					ddr_state <= pre_nop1;
				when pre_nop1 =>
					ddr_state <= pre_nop2;
				when cmd =>
					cas_qn <= '0';
					ras_qn <= '0';
					we_qn <= '0';
					ba_q <= ddr_cmd(14 downto 13);
					sdr_a <= ddr_cmd(12 downto 0);
					nowin_idle_dqs <= "11";
					ddr_state <= idle;
				when cpu_pre =>
					ddr_state <= pre;
				when refresh =>
					cas_qn <= '0';
					ras_qn <= '0';
					saved_row(26) <= '1';
					ddr_state <= refresh_wait;
				when refresh_wait =>
					if refresh_wait_end = '1' then
						ddr_state <= pre_nop2;
					end if;
				when pre_nop2 =>
					if operation = "01" then
						operation <= "10";
						ddr_state <= refresh;
					elsif operation = "10" then
						nowin_idle_dqs <= "11";
						ddr_state <= idle;
					else
						ddr_state <= act;
					end if;
				when others =>
					ddr_state <= idle;
					nowin_idle_dqs <= "11";
			end case;
		end if;
	end process;
	
	process(cpu_clk, areset)	--
	begin
		if areset = '1' then
			ddr_cmd <= "0000000000000000";
		elsif (cpu_clk'event and cpu_clk = '1') then
			if ddr_command_we = '1' then
				ddr_cmd <= ddr_command;
			else
				ddr_cmd <= ddr_cmd;
			end if;
		end if;
	end process;
	
	process(cpu_clk_2x, areset)	--
	begin
		if areset = '1' then
			ddr_cmd_we_smp <= '0';
			new_command <= '0';
			sdr_smp <= "000000000000000000000000000000000000";
		elsif (cpu_clk_2x'event and cpu_clk_2x = '1') then
			ddr_cmd_we_smp <= ddr_command_we;
			if ddr_command_we = '0' and ddr_cmd_we_smp = '1' then
				new_command <= '1';
			elsif ddr_state = cmd or ddr_state = cpu_pre then
				new_command <= '0';
			else
				new_command <= new_command;
			end if;
			
			if ddr_write_en_int = '1' then
			   	sdr_smp <= ddr_data_write;
			else
				sdr_smp <= sdr_smp;
			end if;
			
		end if;
	end process;
	
	process(cpu_clk_4x, areset)	--
	begin
		if areset = '1' then
			dqs_q <= "00";
			dqs_oe_n <= "11";
			sdr_oe_ctrl <= "1111111111111111";
			sdr_wr_msw <= "000000000000000000";
		elsif (cpu_clk_4x'event and cpu_clk_4x = '1') then
		
			for i in 0 to 15 loop
				if nowin_wr_nop1_d(i) = '1' and clk4_phase_short(i)(0) = '1' then
					sdr_oe_ctrl(i) <= '0';
				elsif nowin_wr_nop3_d(i) = '1' and clk4_phase_short(i)(0) = '1' then
					sdr_oe_ctrl(i) <= '1';
				end if;
			end loop;
		
			for i in 0 to 1 loop
				if nowin_idle_dqs(i) = '1' or nowin_wr_nop3_dqs(i) = '1' then
					dqs_oe_n(i) <= '1';
				elsif nowin_wr_nop1_dqs(i) = '1' then
					dqs_oe_n(i)  <= '0';
				end if;
			end loop;

			for i in 0 to 1 loop
				if (nowin_wr_nop2_dqs(i) = '1' and clk4_phase_short(i)(0) = '1') then
					dqs_q(i) <= '1';
				else
					dqs_q(i) <= '0';
				end if;
			end loop;

			for i in 0 to 15 loop
				if nowin_wr_nop1_d(i) = '1' and clk4_phase_short(i)(1) = '1' then
					sdr_wr_msw(i) <= '1';
				else
					sdr_wr_msw(i) <= '0';
				end if;
			end loop;
			
			for i in 0 to 1 loop
				if nowin_wr_nop1_dm(i) = '1' and clk4_phase_short(i)(1) = '1' then
					sdr_wr_msw(i+16) <= '1';
				else
					sdr_wr_msw(i+16) <= '0';
				end if;
			end loop;

		end if;
	end process;
	
	-- NOTE! DATA OUTPUT PATH. CLOCKED ON FALLING 4X CLOCK
	process(cpu_clk_4x, areset)	--
	begin
		if areset = '1' then
		    sdr_d_p <= "ZZZZZZZZZZZZZZZZ";
		    dm_q_p <= "11";
		    sdr_oe_n <= "1111111111111111";
		    sdr_d <= "0000000000000000";
		    dm_q <= "11";
		elsif (cpu_clk_4x'event and cpu_clk_4x = '0') then

			for i in 0 to 15 loop
				if sdr_oe_n(i) = '0' then
					sdr_d_p(i) <= transport sdr_d(i) after Clk_to_Output;
				else
					sdr_d_p(i) <= transport 'Z' after Clk_to_Output;
				end if;
		   	end loop;			

			dm_q_p <= transport dm_q after Clk_to_Output;

			for i in 0 to 15 loop
				if sdr_oe_ctrl(i) = '0' then
					sdr_oe_n(i) <= '0';
				else
					sdr_oe_n(i) <= '1';
				end if;
			end loop;
			
			for i in 0 to 15 loop
				if sdr_wr_msw(i) = '1' then
		   			sdr_d(i) <= sdr_smp(i);
		   		else
	   				sdr_d(i) <= sdr_smp(i+16);
	   			end if;
		   	end loop;
		   	
			for i in 0 to 1 loop
				if sdr_wr_msw(i+16) = '1' then
		   			dm_q(i) <= sdr_smp(i+32);
		   		else
		   			dm_q(i) <= sdr_smp(i+34);
		   		end if;
		   	end loop;
		   	
		end if;
	end process;
	
	process(cpu_clk_2x, areset)	--
	begin
		if areset = '1' then
			refresh_cnt <= "0000000000";
			refresh_pend <= '0';
			refresh_end <= '0';
			refresh_wait_cnt <= "0000";
			refresh_wait_end <= '0';
		elsif (cpu_clk_2x'event and cpu_clk_2x = '1') then
		
			if refresh_cnt = Refresh_Interval then
				refresh_end <= '1';
			else
				refresh_end <= '0';
			end if;
			
			if refresh_end = '1' then
				refresh_cnt <= "0000000000";
			else
				refresh_cnt <= refresh_cnt + '1';
			end if;
			
			if refresh_end = '1' and refresh_en = '1' then
				refresh_pend <= '1';
			elsif ddr_state = refresh then
				refresh_pend <= '0';
			else
				refresh_pend <= refresh_pend;
			end if;
			
			if ddr_state = refresh_wait then
				refresh_wait_cnt <= refresh_wait_cnt + '1';
			else
				refresh_wait_cnt <= "0000";
			end if;
			
			if refresh_wait_cnt = "1011" then
				refresh_wait_end <= '1';
			else
				refresh_wait_end <= '0';
			end if;
			
		end if;
	end process;
	
	-- 911. THIS IS A DUMMY FOR FGPA IMPEMENTATION TESTING

	process(ddr_in_clk, areset)
	begin
		if areset = '1' then
			ddr_clk_tog <= '0';
		elsif (ddr_in_clk'event and ddr_in_clk = '1') then
			ddr_clk_tog <= not(ddr_clk_tog);
		end if;
	end process;	
	
	process(ddr_in_clk_2x, areset)
	begin
		if areset = '1' then
			ddr_clk_smp1 <= '0';
			ddr_clk_smp2 <= '0';
			ddr_clk_phase <= '0';
		elsif (ddr_in_clk_2x'event and ddr_in_clk_2x = '1') then
			ddr_clk_smp1 <= ddr_clk_tog;
			ddr_clk_smp2 <= ddr_clk_smp1;
			if ddr_clk_smp1 = '1' and ddr_clk_smp2 = '0' then
				ddr_clk_phase <= '0';
			else
				ddr_clk_phase <= not(ddr_clk_phase);
			end if;
		end if;
	end process;

	process(ddr_in_clk_2x, areset)
	begin
		if areset = '1' then
			cas_n_smp <= '0';
			ras_n_smp <= '0';
			we_n_smp <= '0';
			read_start_sig <= '0';
		elsif (ddr_in_clk_2x'event and ddr_in_clk_2x = '1') then
			cas_n_smp <= cas_qn_p_del;
			ras_n_smp <= ras_qn_p_del;
			we_n_smp <= we_qn_p_del;
			if ras_n_smp = '1' and cas_n_smp = '0' and we_n_smp = '1' and ddr_clk_phase = '1' then
				read_start_sig <= '1';
			else
				read_start_sig <= '0';
			end if;
		end if;
	end process;

	process(ddr_in_clk_2x, areset)
	begin
		if areset = '1' then
			sdr_d_in <= "0000000000000000";
		elsif (ddr_in_clk_2x'event and ddr_in_clk_2x = '1') then
			sdr_d_in <= sdr_d_p_del;
		end if;
	end process;
	
	process(ddr_in_clk_2x, areset)
	begin
		if areset = '1' then
			read_time_cnt <= "00";
			read_input_en <= '0';
		elsif (ddr_in_clk_2x'event and ddr_in_clk_2x = '1') then

			if read_start_sig = '1' then	
				read_time_cnt <= "01";
			elsif read_time_cnt = "00" then
				read_time_cnt <= read_time_cnt;
			else
				read_time_cnt <= read_time_cnt + '1';
			end if;

			if read_time_cnt = "11" then
				read_input_en <= '1';
			else
				read_input_en <= '0';
			end if;
			
			read_input_en_del <= read_input_en;

		end if;
	end process;
	
	process(ddr_in_clk_2x, areset)
	begin
		if areset = '1' then
			ddr_data_read_int <= "00000000000000000000000000000000";
		elsif (ddr_in_clk_2x'event and ddr_in_clk_2x = '1') then
			if read_input_en = '1' then
				ddr_data_read_int(15 downto 0) <= sdr_d_in;
			end if;
			if read_input_en_del = '1' then
				ddr_data_read_int(31 downto 16) <= sdr_d_in;
			end if;
		end if;
	end process;

end behave;


