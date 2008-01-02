library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library zylin;
use zylin.ddr.all;

entity ddr_tb is
	port (	areset			: in std_logic;
			break_out		: out std_logic);
end ddr_tb;

architecture behave of ddr_tb is

signal	cpu_clk			: std_logic;
signal	cpu_clk_2x		: std_logic;
signal	cpu_clk_4x		: std_logic;
signal	ddr_in_clk		: std_logic;
signal	ddr_in_clk_2x	: std_logic;

signal	ddr_command		: std_logic_vector(15 downto 0);
signal	ddr_command_we	: std_logic;
			
signal	ddr_data_read	: std_logic_vector(31 downto 0);	-- Data read from DDR SDRAM
signal	ddr_data_write	: std_logic_vector(35 downto 0);		-- Data to be written to DDR SDRAM
signal	ddr_req_adr		: std_logic_vector(23 downto 1);		-- Request address
signal	ddr_req			: std_logic;							-- Request DDR SDRAM access
signal	ddr_req_ack		: std_logic;							-- Request acknowledge
signal	ddr_busy		: std_logic;							-- Request acknowledge
signal	ddr_rd_wr_n		: std_logic;							-- Access type 1=READ, 0=WRITE
signal	ddr_req_len		: std_logic;							-- Number of 16-bits words to transfer
signal	ddr_read_en		: std_logic;						-- Enable signal for read data
signal	ddr_write_en	: std_logic;						-- Enable (read) signal for data write
signal	refresh_en		: std_logic;

signal	sdr_clk_p       : std_logic;    -- ddr_sdram_clock
signal	sdr_clk_n_p     : std_logic;    -- /ddr_sdram_clock
signal	cke_q_p         : std_logic;    -- clock enable
signal	cs_qn_p         : std_logic;    -- /chip select
signal	ras_qn_p        : std_logic;    -- /ras
signal	cas_qn_p        : std_logic;    -- /cas
signal	we_qn_p         : std_logic;    -- /write enable
signal	dm_q_p          : std_logic_vector(1 downto 0);     -- data mask bits, set to "00"
signal	dqs_q_p         : std_logic_vector(1 downto 0);    -- data strobe, only for write
signal	ba_q_p          : std_logic_vector(1 downto 0);   -- bank select
signal	sdr_a_p		    : std_logic_vector(12 downto 0);   -- address bus 
signal	sdr_d_p         : std_logic_vector(15 downto 0); 			-- bidir data bus

constant min_time	: time := 1.875 ns;

begin

	clock1:
	process
	begin
		loop
			cpu_clk_4x <= '1';
			wait for min_time;
			cpu_clk_4x <= '0';
			wait for min_time;
		end loop;
	end process;

	clock2:
	process
	begin
		loop
			cpu_clk_2x <= '1' after 100 ps;
			wait until rising_edge(cpu_clk_4x);
			cpu_clk_2x <= '0' after 100 ps;
			wait until rising_edge(cpu_clk_4x);
		end loop;
	end process;

	clock3:
	process
	begin
		loop
			cpu_clk <= '1' after 100 ps;
			wait until rising_edge(cpu_clk_2x);
			cpu_clk <= '0' after 100 ps;
			wait until rising_edge(cpu_clk_2x);
		end loop;
	end process;
	
	ddr_in_clk_2x <= cpu_clk_4x after 1 ns;

	clock4:
	process
	begin
		loop
			ddr_in_clk <= '0' after 100 ps;
			wait until rising_edge(ddr_in_clk_2x);
			ddr_in_clk <= '1' after 100 ps;
			wait until rising_edge(ddr_in_clk_2x);
		end loop;
	end process;
	
	inputdata:
	process
	begin
		-- Wait until global reset released
		loop
			ddr_command <= x"0000";
			ddr_command_we <= '0';
			ddr_data_write <= x"000000000";
			ddr_req <= '0';
			ddr_req_adr <= "00000000000000000000000";
			ddr_rd_wr_n <= '0';
			ddr_req_len <= '0';
			break_out <= '0';
			refresh_en <= '0';
			
			wait until falling_edge(areset);
			
			-- DDR initialization sequence
				-- Wait more than 200 us
				wait for 201000 ns;	
				
				-- Send precharge command
				wait until rising_edge(cpu_clk);	
				ddr_command <= x"8000";
				ddr_command_we <= '1';
				wait until rising_edge(cpu_clk);
				ddr_command <= x"0000";
				ddr_command_we <= '0';
				
				-- Wait for 1 us
				wait for 1000 ns;
				
				-- Load extended mode register
				--  Enable DLL
				--  Normal drive strength
				wait until rising_edge(cpu_clk);	
				ddr_command <= x"2000";
				ddr_command_we <= '1';
				wait until rising_edge(cpu_clk);
				ddr_command <= x"0000";
				ddr_command_we <= '0';
							
				-- Wait for 1 us
				wait for 1000 ns;
				
				-- Load mode register
				--  Burst length: 2
				--  Burst type: Sequential
				--  Cas latency: 2
				--  Reset DLL
				wait until rising_edge(cpu_clk);	
				ddr_command <= x"0121";
				ddr_command_we <= '1';
				wait until rising_edge(cpu_clk);
				ddr_command <= x"0000";
				ddr_command_we <= '0';
							
				-- Wait for 1 us
				wait for 1000 ns;
				
				-- Send precharge command
				wait until rising_edge(cpu_clk);	
				ddr_command <= x"8000";
				ddr_command_we <= '1';
				wait until rising_edge(cpu_clk);
				ddr_command <= x"0000";
				ddr_command_we <= '0';
				
				-- Enable refresh
				refresh_en <= '1';
			
				-- Wait 30 us (minimum 2 autorefresh cycles)
				wait for 30000 ns;
						
				-- Load mode register
				--  Burst length: 2
				--  Burst type: Sequential
				--  Cas latency: 2
				--  Deactivate Reset DLL
				wait until rising_edge(cpu_clk);	
				ddr_command <= x"0021";
				ddr_command_we <= '1';
				wait until rising_edge(cpu_clk);
				ddr_command <= x"0000";
				ddr_command_we <= '0';
	
				-- Wait for 2 us (DLL stable)
				wait for 2000 ns;
				
			-- Write data to DDR
			wait until rising_edge(cpu_clk_2x);
			ddr_data_write <= x"312345678";
			ddr_req <= '1';
			ddr_req_adr <= "00000000000000000000000";
			ddr_rd_wr_n <= '0';
			ddr_req_len <= '0';
			wait until rising_edge(ddr_write_en);
			wait until rising_edge(cpu_clk_2x);
			ddr_req <= '0';
			ddr_req_adr <= "00000000000000000000000";
			ddr_rd_wr_n <= '0';
			ddr_req_len <= '0';
			ddr_data_write <= x"000000000";
			wait for 100 ns;
			
			-- Read data from DDR
			wait until rising_edge(cpu_clk_2x);
			ddr_req <= '1';
			ddr_req_adr <= "00000000000000000000000";
			ddr_rd_wr_n <= '1';
			ddr_req_len <= '0';
			wait until rising_edge(ddr_req_ack);
			wait until rising_edge(cpu_clk_2x);
			ddr_req <= '0';
			ddr_req_adr <= "00000000000000000000000";
			ddr_rd_wr_n <= '0';
			ddr_req_len <= '0';
			ddr_data_write <= x"000000000";



			wait for 100 ns;
			break_out <= '1';
			wait for 100 ns;
						
		end loop;
		
	end process;
	
	ddr_ctrl:
	ddr_top port map(
		areset => areset,
		cpu_clk => cpu_clk,
		cpu_clk_2x => cpu_clk_2x,
		cpu_clk_4x => cpu_clk_4x,
		ddr_in_clk => ddr_in_clk,
		ddr_in_clk_2x => ddr_in_clk_2x,
		
		-- Command interface
		ddr_command => ddr_command,
		ddr_command_we => ddr_command_we,
		refresh_en => refresh_en,			
		
		-- Data interface signals
		ddr_data_read => ddr_data_read,
		ddr_data_write => ddr_data_write,
		ddr_req_adr => ddr_req_adr,
		ddr_req => ddr_req,
		ddr_req_ack => ddr_req_ack,
		ddr_busy => ddr_busy,
		ddr_rd_wr_n => ddr_rd_wr_n,
		ddr_req_len => ddr_req_len,
		ddr_read_en => ddr_read_en,
		ddr_write_en => ddr_write_en,
		    -- DDR SDRAM Signals
	    sdr_clk_p => sdr_clk_p,
	    sdr_clk_n_p => sdr_clk_n_p,
	    cke_q_p => cke_q_p,
	    cs_qn_p => cs_qn_p,
	    ras_qn_p => ras_qn_p,
	    cas_qn_p => cas_qn_p,
	    we_qn_p => we_qn_p,
	    dm_q_p => dm_q_p,
	    dqs_q_p => dqs_q_p,
	    ba_q_p => ba_q_p,
	    sdr_a_p => sdr_a_p,
	    sdr_d_p => sdr_d_p);
	   
	myram:
	MT46V16M16 generic map(
        tCK => 7.500 ns,
        tCH => 3.375 ns,       -- 0.45*tCK
        tCL => 3.375 ns,       -- 0.45*tCK
        tDH => 0.500 ns,
        tDS => 0.500 ns,
        tIH => 0.900 ns,
        tIS => 0.900 ns,
        tMRD => 15.000 ns,
        tRAS => 40.000 ns,
        tRAP => 20.000 ns,
        tRC => 65.000 ns,
        tRFC => 75.000 ns,
        tRCD => 20.000 ns,
        tRP => 20.000 ns,
        tRRD => 15.000 ns,
        tWR => 15.000 ns,
        addr_bits => 13,
        data_bits => 16,
        cols_bits => 9)
    port map(
        Dq => sdr_d_p,
        Dqs => dqs_q_p,
        Addr => sdr_a_p,
        Ba => ba_q_p,
        Clk => sdr_clk_p,
        Clk_n => sdr_clk_n_p,
        Cke => cke_q_p,
        Cs_n => cs_qn_p,
        Ras_n => ras_qn_p,
        Cas_n => cas_qn_p,
        We_n => we_qn_p,
        Dm => dm_q_p);

end behave;
