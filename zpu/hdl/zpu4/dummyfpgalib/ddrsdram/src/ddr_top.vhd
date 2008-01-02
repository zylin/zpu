library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

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
			ddr_req_adr		: in std_logic_vector(23 downto 1);		-- Request address
			ddr_req			: in std_logic;							-- Request DDR SDRAM access
			ddr_req_ack		: out std_logic;							-- Request acknowledge
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
signal	clk4_phase_short	: std_logic_vector(1 downto 0);

signal	ddr_clk_tog			: std_logic;
signal	ddr_clk_smp1		: std_logic;
signal	ddr_clk_smp2		: std_logic;
signal	ddr_clk_phase		: std_logic;

signal	smp_req_adr			: std_logic_vector(23 downto 1);
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
signal	sdr_oe_ctrl			: std_logic;
signal	sdr_wr_msw			: std_logic_vector(17 downto 0);
attribute keep of sdr_wr_msw:signal is "true";
signal	dm_q				: std_logic_vector(1 downto 0);

signal	cas_n_smp			: std_logic;
signal	ras_n_smp			: std_logic;
signal	we_n_smp			: std_logic;
signal	read_start_sig		: std_logic;
signal	sdr_d_in			: std_logic_vector(15 downto 0);
signal	read_time_cnt		: std_logic_vector(1 downto 0);
signal	read_input_en		: std_logic;
signal	ddr_data_read_int	: std_logic_vector(31 downto 0);

signal	refresh_pend		: std_logic;
signal	refresh_end			: std_logic;
signal	refresh_cnt			: std_logic_vector(9 downto 0);
signal	refresh_wait_cnt	: std_logic_vector(2 downto 0);
signal	refresh_wait_end	: std_logic;

signal	cas_qn_p_del		: std_logic;
signal	ras_qn_p_del		: std_logic;
signal	we_qn_p_del			: std_logic;
signal	sdr_d_p_del			: std_logic_vector(15 downto 0);

type state_type is (idle, act, act_nop1, act_nop2, rd_wr, rd_nop1, 
					rd_nop2, pre, pre_nop1, pre_nop2, wr_nop1, wr_nop2, 
					wr_nop3, cmd, cpu_pre, refresh, refresh_wait);
signal	ddr_state			: state_type;

constant	Clk_to_Output	: time := 2.2 ns;
constant	Sim_Delay		: time := 0.5 ns;
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

	process(cpu_clk, areset)	-- Toggle a flip-flop with cpu_clk, in order 
	begin						-- to find phase relation with 2x and 4x clocks
		if areset = '1' then
			cpu_clk_tog <= '0';
		elsif (cpu_clk'event and cpu_clk = '1') then
			cpu_clk_tog <= not(cpu_clk_tog) after Sim_Delay;
		end if;
	end process;
	
	process(cpu_clk_2x, areset)	-- Find phase relation between cpu_clk and cpu_clk_2x
	begin
		if areset = '1' then
			cpu_clk_2x_smp1 <= '0';
			cpu_clk_2x_smp2 <= '0';
			clk2_phase <= '0';
		elsif (cpu_clk_2x'event and cpu_clk_2x = '1') then
			cpu_clk_2x_smp1 <= cpu_clk_tog after Sim_Delay;
			cpu_clk_2x_smp2 <= cpu_clk_2x_smp1 after Sim_Delay;
			if (cpu_clk_2x_smp1 = '1' and cpu_clk_2x_smp2 = '0') then
				clk2_phase <= '0' after Sim_Delay;
			else
				clk2_phase <= not(clk2_phase) after Sim_Delay;
			end if;
		end if;
	end process;
	
	process(cpu_clk_4x, areset)	-- Find phase relation between cpu_clk and cpu_clk_4x
	begin
		if areset = '1' then
			cpu_clk_4x_smp1 <= '0';
			cpu_clk_4x_smp2 <= '0';
			clk4_phase <= "0000";
			clk4_phase_short <= "00";
		elsif (cpu_clk_4x'event and cpu_clk_4x = '1') then
			cpu_clk_4x_smp1 <= cpu_clk_tog after Sim_Delay;
			cpu_clk_4x_smp2 <= cpu_clk_4x_smp1 after Sim_Delay;
			if (cpu_clk_4x_smp1 = '1' and cpu_clk_4x_smp2 = '0') then
				clk4_phase <= "0100" after Sim_Delay;
				clk4_phase_short <= "01" after Sim_Delay;
			else
				clk4_phase <= (clk4_phase(2 downto 0) & clk4_phase(3)) after Sim_Delay;
				clk4_phase_short <= clk4_phase_short(0) & clk4_phase_short(1);
			end if;
		end if;
	end process;

	process(cpu_clk_4x, areset)	--
	begin
		if areset = '1' then
			sdr_clk <= '0';			
			sdr_clk_n <= '0';			
		elsif (cpu_clk_4x'event and cpu_clk_4x = '1') then
			if clk4_phase_short(0) = '1' then
				sdr_clk <= '1' after Sim_Delay;
			else
				sdr_clk <= '0' after Sim_Delay;
			end if;
			if clk4_phase_short(1) = '1' then
				sdr_clk_n <= '1' after Sim_Delay;
			else
				sdr_clk_n <= '0' after Sim_Delay;
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
			ddr_req_ack <= '0';
			ddr_busy <= '1';
			ddr_write_en_int <= '0';
			ddr_read_en_int <= '0';
		elsif (cpu_clk_2x'event and cpu_clk_2x = '1') then
		
			-- Default values
			ras_qn <= '1' after Sim_Delay;
			cas_qn <= '1' after Sim_Delay;
			we_qn <= '1' after Sim_Delay;
			sdr_a <= "XXXXXXXXXXXXX" after Sim_Delay;
			ba_q <= "00" after Sim_Delay;
			ddr_req_ack <= '0' after Sim_Delay;
			ddr_busy <= '1' after Sim_Delay;
			ddr_write_en_int <= '0' after Sim_Delay;
			ddr_read_en_int <= '0' after Sim_Delay;
		
			case ddr_state is
				when idle =>
					smp_req_adr <= ddr_req_adr after Sim_Delay;
					smp_req_type <= ddr_rd_wr_n after Sim_Delay;
					smp_req_len <= ddr_req_len after Sim_Delay;
					ddr_busy <= '0' after Sim_Delay;
					if refresh_pend = '1' then
						ddr_state <= refresh after Sim_Delay;
					elsif new_command = '1' then
						if ddr_cmd(15) = '1' then
							ddr_state <= cpu_pre after Sim_Delay;
						else
							ddr_state <= cmd after Sim_Delay;
						end if;
					elsif ddr_req = '1' then
						ddr_state <= act after Sim_Delay;
					else
						ddr_state <= idle after Sim_Delay;
					end if;
				when act =>
					sdr_a <= smp_req_adr(23 downto 11) after Sim_Delay;
					ras_qn <= '0' after Sim_Delay;
					ddr_state <= act_nop1 after Sim_Delay;
					ddr_req_ack <= '1' after Sim_Delay;
					ddr_write_en_int <= not(smp_req_type) after Sim_Delay;
				when act_nop1 =>
					ddr_state <= act_nop2 after Sim_Delay;
				when act_nop2 =>
					ddr_state <= rd_wr after Sim_Delay;
				when rd_wr =>
					sdr_a(10) <= '0' after Sim_Delay;		-- Disable auto precharge
					sdr_a(9 downto 0) <= smp_req_adr(10 downto 1) after Sim_Delay;
					cas_qn <= '0' after Sim_Delay;
					we_qn <= smp_req_type after Sim_Delay;
					if smp_req_type = '1' then
						ddr_state <= rd_nop1 after Sim_Delay;
					else
						ddr_state <= wr_nop1 after Sim_Delay;
					end if;
				when wr_nop1 =>
					ddr_state <= wr_nop2 after Sim_Delay;	
				when wr_nop2 =>
					ddr_state <= wr_nop3 after Sim_Delay;	
				when wr_nop3 =>
					ddr_state <= pre after Sim_Delay;	
				when rd_nop1 =>
					ddr_state <= rd_nop2 after Sim_Delay;	
				when rd_nop2 =>
					ddr_state <= pre after Sim_Delay;	
				when pre =>					
					ras_qn <= '0' after Sim_Delay;
					we_qn <= '0' after Sim_Delay;
					sdr_a(10) <= '1' after Sim_Delay;	-- Precharge all banks
					ddr_state <= pre_nop1 after Sim_Delay;
					ddr_read_en_int <= smp_req_type after Sim_Delay;
				when pre_nop1 =>
					ddr_state <= pre_nop2 after Sim_Delay;
				when cmd =>
					cas_qn <= '0' after Sim_Delay;
					ras_qn <= '0' after Sim_Delay;
					we_qn <= '0' after Sim_Delay;
					ba_q <= ddr_cmd(14 downto 13) after Sim_Delay;
					sdr_a <= ddr_cmd(12 downto 0) after Sim_Delay;
					ddr_state <= idle after Sim_Delay;
				when cpu_pre =>
					ddr_state <= pre after Sim_Delay;
				when refresh =>
					cas_qn <= '0' after Sim_Delay;
					ras_qn <= '0' after Sim_Delay;
					ddr_state <= refresh_wait after Sim_Delay;
				when refresh_wait =>
					if refresh_wait_end = '1' then
						ddr_state <= pre after Sim_Delay;
					end if;
				when pre_nop2 =>
					ddr_state <= idle after Sim_Delay;
				when others =>
					ddr_state <= idle after Sim_Delay;
			end case;
		end if;
	end process;
	
	process(cpu_clk, areset)	--
	begin
		if areset = '1' then
			ddr_cmd <= "0000000000000000";
		elsif (cpu_clk'event and cpu_clk = '1') then
			if ddr_command_we = '1' then
				ddr_cmd <= ddr_command after Sim_Delay;
			else
				ddr_cmd <= ddr_cmd after Sim_Delay;
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
			ddr_cmd_we_smp <= ddr_command_we after Sim_Delay;
			if ddr_command_we = '0' and ddr_cmd_we_smp = '1' then
				new_command <= '1' after Sim_Delay;
			elsif ddr_state = cmd or ddr_state = cpu_pre then
				new_command <= '0' after Sim_Delay;
			else
				new_command <= new_command after Sim_Delay;
			end if;
			
			if ddr_write_en_int = '1' then
			   	sdr_smp <= ddr_data_write after Sim_Delay;
			else
				sdr_smp <= sdr_smp after Sim_Delay;
			end if;
			
		end if;
	end process;
	
	process(cpu_clk_4x, areset)	--
	begin
		if areset = '1' then
			dqs_q <= "00";
			dqs_oe_n <= "11";
			sdr_oe_ctrl <= '1';
			sdr_wr_msw <= "000000000000000000";
		elsif (cpu_clk_4x'event and cpu_clk_4x = '1') then
		
			if ddr_state = wr_nop1 and clk4_phase_short(0) = '1' then
				sdr_oe_ctrl <= '0' after Sim_Delay;
			elsif ddr_state = wr_nop3 and clk4_phase_short(0) = '1' then
				sdr_oe_ctrl <= '1' after Sim_Delay;
			else
				sdr_oe_ctrl <= sdr_oe_ctrl after Sim_Delay;
			end if;

			if ddr_state = idle or ddr_state = wr_nop3 then
				dqs_oe_n <= "11" after Sim_Delay;
			elsif ddr_state = wr_nop1 then
				dqs_oe_n  <= "00" after Sim_Delay;
			else
				dqs_oe_n <= dqs_oe_n after Sim_Delay;
			end if;

			if (ddr_state = wr_nop2 and clk4_phase_short(0) = '1') then
				dqs_q <= "11" after Sim_Delay;
			else
				dqs_q <= "00" after Sim_Delay;
			end if;
			
			if ddr_state = wr_nop1 and clk4_phase_short(1) = '1' then
				sdr_wr_msw <= "111111111111111111" after Sim_Delay;
			else
				sdr_wr_msw <= "000000000000000000" after Sim_Delay;
			end if;
			
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

			if sdr_oe_ctrl = '0' then
				sdr_oe_n <= "0000000000000000" after Sim_Delay;
			else
				sdr_oe_n <= "1111111111111111" after Sim_Delay;
			end if;
			
			for i in 0 to 15 loop
				if sdr_wr_msw(i) = '0' then
		   			sdr_d(i) <= sdr_smp(i) after Sim_Delay;
		   		else
		   			sdr_d(i) <= sdr_smp(i+16) after Sim_Delay;
		   		end if;
		   	end loop;
		   	
			for i in 0 to 1 loop
				if sdr_wr_msw(i+16) = '0' then
		   			dm_q(i) <= sdr_smp(i+32) after Sim_Delay;
		   		else
		   			dm_q(i) <= sdr_smp(i+34) after Sim_Delay;
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
			refresh_wait_cnt <= "000";
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
				refresh_pend <= '1' after Sim_Delay;
			elsif ddr_state = refresh then
				refresh_pend <= '0' after Sim_Delay;
			else
				refresh_pend <= refresh_pend after Sim_Delay;
			end if;
			
			if ddr_state = refresh_wait then
				refresh_wait_cnt <= refresh_wait_cnt + '1';
			else
				refresh_wait_cnt <= "000";
			end if;
			
			if refresh_wait_cnt = "111" then
				refresh_wait_end <= '1' after Sim_Delay;
			else
				refresh_wait_end <= '0' after Sim_Delay;
			end if;
			
		end if;
	end process;
	
	-- 911. THIS IS A DUMMY FOR FGPA IMPEMENTATION TESTING

	process(ddr_in_clk, areset)
	begin
		if areset = '1' then
			ddr_clk_tog <= '0';
		elsif (ddr_in_clk'event and ddr_in_clk = '1') then
			ddr_clk_tog <= not(ddr_clk_tog) after Sim_Delay;
		end if;
	end process;	
	
	process(ddr_in_clk_2x, areset)
	begin
		if areset = '1' then
			ddr_clk_smp1 <= '0';
			ddr_clk_smp2 <= '0';
			ddr_clk_phase <= '0';
		elsif (ddr_in_clk_2x'event and ddr_in_clk_2x = '1') then
			ddr_clk_smp1 <= ddr_clk_tog after Sim_Delay;
			ddr_clk_smp2 <= ddr_clk_smp1 after Sim_Delay;
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
			cas_n_smp <= cas_qn_p_del after Sim_Delay;
			ras_n_smp <= ras_qn_p_del after Sim_Delay;
			we_n_smp <= we_qn_p_del after Sim_Delay;
			if ras_n_smp = '1' and cas_n_smp = '0' and we_n_smp = '1' and ddr_clk_phase = '1' then
				read_start_sig <= '1' after Sim_Delay;
			else
				read_start_sig <= '0' after Sim_Delay;
			end if;
		end if;
	end process;

	process(ddr_in_clk_2x, areset)
	begin
		if areset = '1' then
			sdr_d_in <= "0000000000000000";
		elsif (ddr_in_clk_2x'event and ddr_in_clk_2x = '1') then
			sdr_d_in <= sdr_d_p_del after Sim_Delay;
		end if;
	end process;
	
	process(ddr_in_clk_2x, areset)
	begin
		if areset = '1' then
			read_time_cnt <= "00";
			read_input_en <= '0';
		elsif (ddr_in_clk_2x'event and ddr_in_clk_2x = '1') then

			if read_start_sig = '1' then	
				read_time_cnt <= "01" after Sim_Delay;
			elsif read_time_cnt = "00" then
				read_time_cnt <= read_time_cnt after Sim_Delay;
			else
				read_time_cnt <= read_time_cnt + '1' after Sim_Delay;
			end if;

			if read_time_cnt = "11" then
				read_input_en <= '1' after Sim_Delay;
			else
				read_input_en <= '0' after Sim_Delay;
			end if;

		end if;
	end process;
	
	process(ddr_in_clk_2x, areset)
	begin
		if areset = '1' then
			ddr_data_read_int <= "00000000000000000000000000000000";
		elsif (ddr_in_clk_2x'event and ddr_in_clk_2x = '1') then
			ddr_data_read_int(31 downto 16) <= "0000000000000000" after Sim_Delay;
			if read_input_en = '1' then
				ddr_data_read_int(15 downto 0) <= sdr_d_in after Sim_Delay;
			else
				ddr_data_read_int(15 downto 0) <= ddr_data_read_int(15 downto 0) after Sim_Delay;
			end if;
		end if;
	end process;








	-- ###############

	process(cpu_clk, areset)	--
	begin
		if areset = '1' then
		elsif (cpu_clk'event and cpu_clk = '1') then
		end if;
	end process;
	
	
	process(cpu_clk_2x, areset)	--
	begin
		if areset = '1' then
		elsif (cpu_clk_2x'event and cpu_clk_2x = '1') then
		end if;
	end process;
	
	
	process(cpu_clk_4x, areset)	--
	begin
		if areset = '1' then
		elsif (cpu_clk_4x'event and cpu_clk_4x = '1') then
		end if;
	end process;
	

end behave;


