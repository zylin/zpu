library IEEE;
use IEEE.STD_LOGIC_1164.all;

package ic300pkg is

	component ic300 is
	port (	-- Clock inputs
			cpu_clk_p		: in std_logic;
			
			-- CPU interface signals
			cpu_a_p			: in std_logic_vector(20 downto 0);
			cpu_wr_n_p		: in std_logic_vector(1 downto 0);
			cpu_cs_n_p		: in std_logic_vector(3 downto 1);
			cpu_oe_n_p		: in std_logic;
			cpu_d_p			: inout std_logic_vector(15 downto 0);
			cpu_irq_p		: out std_logic_vector(1 downto 0);
			cpu_fiq_p		: out std_logic;
			cpu_wait_n_p	: out std_logic;
			
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
		    sdr_d_p         : inout std_logic_vector(15 downto 0); 			-- bidir data bus
		    sdr_clk_fb_p	: in std_logic		-- DDR clock feedback
		);
	end component;

	component clocks is
	port (	areset			: in std_logic;
			cpu_clk_p		: in std_logic;
			sdr_clk_fb_p	: in std_logic;
			cpu_clk			: out std_logic;
			cpu_clk_2x		: out std_logic;
			cpu_clk_4x		: out std_logic;
			ddr_in_clk		: out std_logic;
			ddr_in_clk_2x	: out std_logic;
			locked			: out std_logic_vector(2 downto 0));
	end component;

	component cpu_regs is
	port (	areset			: in std_logic;
			cpu_clk			: in std_logic;
			clk_status		: in std_logic_vector(2 downto 0);
			cpu_din			: in std_logic_vector(15 downto 0);
			cpu_a			: in std_logic_vector(20 downto 0);
			cpu_we			: in std_logic_vector(1 downto 0);
			cpu_re			: in std_logic;
			cpu_dout		: inout std_logic_vector(15 downto 0));
	end component;

	component ddr_bridge is
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
	end component;
	
end ic300pkg;
