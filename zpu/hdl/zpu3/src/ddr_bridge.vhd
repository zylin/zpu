library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.vcomponents.all;

library zylin;
use zylin.ddr.all;

library work;
use work.phi_config.all;

entity ddr_bridge is
	port (	areset			: in std_logic;
			cpu_clk			: in std_logic;
			cpu_clk_2x		: in std_logic;
			cpu_clk_4x		: in std_logic;
			ddr_in_clk		: in std_logic;
			ddr_in_clk_2x	: in std_logic;

			cpu_we			: in std_logic_vector(1 downto 0);
			cpu_re			: in std_logic;
			cpu_din			: in std_logic_vector(15 downto 0);
			cpu_a			: in std_logic_vector(20 downto 0);
			cpu_dout		: inout std_logic_vector(15 downto 0);
			
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
end ddr_bridge;

architecture behave of ddr_bridge is

signal	refresh_en			: std_logic;
signal	ddr_command_we		: std_logic;
signal	ddr_command			: std_logic_vector(15 downto 0);

signal	ddr_req				: std_logic;
signal	ddr_req_adr			: std_logic_vector(23 downto 1);
signal	ddr_rd_wr_n			: std_logic;
signal	ddr_req_len			: std_logic;

signal	ddr_read_en			: std_logic;
signal	ddr_write_en		: std_logic;
signal	ddr_data_read		: std_logic_vector(31 downto 0);
signal	ddr_data_write		: std_logic_vector(35 downto 0);

signal	ddr_read_smp		: std_logic_vector(31 downto 0);
signal	ddr_read_delay		: std_logic_vector(15 downto 0);

signal	ddr_write_smp		: std_logic_vector(15 downto 0);
signal	ddr_addr_smp		: std_logic_vector(15 downto 0);

signal	ddr_req_type_smp	: std_logic;
signal	ddr_req_on			: std_logic;
signal	ddr_req_off			: std_logic;
signal	ddr_req_int			: std_logic;

constant Sim_Delay			: time := 1.0 ns;

begin

	ddr_req_len <= '0';
	ddr_data_write <= "0000" & ddr_write_smp & ddr_write_smp;
	ddr_req_adr <= "0000000" & ddr_addr_smp;
	ddr_rd_wr_n	<= ddr_req_type_smp;
	ddr_req <= ddr_req_int;

	process(cpu_clk, areset)	-- CPU writeable registers
	begin
		if areset = '1' then
			refresh_en <= '0';
			ddr_command_we <= '0';
			ddr_command <= "0000000000000000";
			ddr_write_smp <= "0000000000000000";
			ddr_req_type_smp <= '0';
			ddr_req_on <= '0';
		elsif (cpu_clk'event and cpu_clk = '1') then

			if cpu_we(0) = '1' and cpu_a(19 downto 17) = Fpga_DDR_Ctrl_Base and cpu_a(3 downto 1) = DDR_Ctrl_Reg_Addr then
				refresh_en <= cpu_din(0);
			else
				refresh_en <= refresh_en;
			end if;
			
			if cpu_we(0) = '1' and cpu_a(19 downto 17) = Fpga_DDR_Ctrl_Base and cpu_a(3 downto 1) = DDR_Mode_Reg_Addr then
				ddr_command <= cpu_din;
				ddr_command_we <= '1';
			else
				ddr_command <= ddr_command;
				ddr_command_we <= '0';
			end if;
			
			if cpu_we(0) = '1' and cpu_a(19 downto 17) = Fpga_DDR_Ctrl_Base and cpu_a(3 downto 1) = DDR_Data_Reg_Addr then
				ddr_write_smp <= cpu_din;
			else
				ddr_write_smp <= ddr_write_smp;
			end if;
			
			if cpu_we(0) = '1' and cpu_a(19 downto 17) = Fpga_DDR_Ctrl_Base and cpu_a(3 downto 1) = DDR_Addr_Reg_Addr then
				ddr_addr_smp <= cpu_din;
			else
				ddr_addr_smp <= ddr_addr_smp;
			end if;
			
			if cpu_we(0) = '1' and cpu_a(19 downto 17) = Fpga_DDR_Ctrl_Base and cpu_a(3 downto 1) = DDR_Req_Reg_Addr then
				ddr_req_type_smp <= cpu_din(0);
				ddr_req_on <= '1';
			else
				ddr_req_type_smp <= ddr_req_type_smp;
				ddr_req_on <= '0';
			end if;
			
		end if;
	end process;
	
	-- CPU readable registers
	cpu_dout <= ddr_read_delay when (cpu_re = '1' and cpu_a(19 downto 17) = Fpga_DDR_Ctrl_Base and cpu_a(3 downto 1) = DDR_Data_Reg_Addr) else "ZZZZZZZZZZZZZZZZ";
	
	-- Capture data read from DDR
	process(cpu_clk_2x, areset)
	begin
		if areset = '1' then
			ddr_read_smp <= (others => '0');
		elsif (cpu_clk_2x'event and cpu_clk_2x = '1') then
			if ddr_read_en = '1' then
				ddr_read_smp <= ddr_data_read after Sim_Delay;
			else
				ddr_read_smp <= ddr_read_smp after Sim_Delay;
			end if;
		end if;
	end process;
	
	-- Move captured data from DDR to cpu_clk domain (for better routing timing)
	process(cpu_clk, areset)
	begin
		if areset = '1' then
			ddr_read_delay <= "0000000000000000";
		elsif (cpu_clk'event and cpu_clk = '1') then
			ddr_read_delay <= ddr_read_smp(15 downto 0);
		end if;
	end process;
	
	process(cpu_clk_2x, areset)
	begin
		if areset = '1' then
			ddr_req_int <= '0';
		elsif (cpu_clk_2x'event and cpu_clk_2x = '1') then
			if ddr_req_on = '1' then
				ddr_req_int <= '1' after Sim_Delay;
			elsif ddr_read_en = '1' or ddr_write_en = '1' then
				ddr_req_int <= '0' after Sim_Delay;
			else
				ddr_req_int <= ddr_req_int after Sim_Delay;
			end if;
		end if;
	end process;
	

	ddr_interface:
	ddr_top port map(
		areset => areset,
		cpu_clk => cpu_clk,
		cpu_clk_2x => cpu_clk_2x,
		cpu_clk_4x => cpu_clk_4x,
		ddr_in_clk => ddr_in_clk,
		ddr_in_clk_2x => ddr_in_clk_2x,
		ddr_command => ddr_command,
		ddr_command_we => ddr_command_we,
		refresh_en => refresh_en,
		ddr_data_read => ddr_data_read,
		ddr_data_write => ddr_data_write,
		ddr_req => ddr_req,
		ddr_req_adr => ddr_req_adr,
		ddr_rd_wr_n => ddr_rd_wr_n,
		ddr_req_len => ddr_req_len,
		ddr_read_en => ddr_read_en,
		ddr_write_en => ddr_write_en,
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


end behave;
