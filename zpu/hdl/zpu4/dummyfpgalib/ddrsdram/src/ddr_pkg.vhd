library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

package ddr is

	component ddr_top
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
	end component;
	
	component MT46V16M16
    GENERIC (                                   -- Timing for -75Z CL2
        tCK       : TIME    :=  7.500 ns;
        tCH       : TIME    :=  3.375 ns;       -- 0.45*tCK
        tCL       : TIME    :=  3.375 ns;       -- 0.45*tCK
        tDH       : TIME    :=  0.500 ns;
        tDS       : TIME    :=  0.500 ns;
        tIH       : TIME    :=  0.900 ns;
        tIS       : TIME    :=  0.900 ns;
        tMRD      : TIME    := 15.000 ns;
        tRAS      : TIME    := 40.000 ns;
        tRAP      : TIME    := 20.000 ns;
        tRC       : TIME    := 65.000 ns;
        tRFC      : TIME    := 75.000 ns;
        tRCD      : TIME    := 20.000 ns;
        tRP       : TIME    := 20.000 ns;
        tRRD      : TIME    := 15.000 ns;
        tWR       : TIME    := 15.000 ns;
        addr_bits : INTEGER := 13;
        data_bits : INTEGER := 16;
        cols_bits : INTEGER :=  9
    );
    PORT (
        Dq    : INOUT STD_LOGIC_VECTOR (data_bits - 1 DOWNTO 0) := (OTHERS => 'Z');
        Dqs   : INOUT STD_LOGIC_VECTOR (1 DOWNTO 0) := "ZZ";
        Addr  : IN    STD_LOGIC_VECTOR (addr_bits - 1 DOWNTO 0);
        Ba    : IN    STD_LOGIC_VECTOR (1 DOWNTO 0);
        Clk   : IN    STD_LOGIC;
        Clk_n : IN    STD_LOGIC;
        Cke   : IN    STD_LOGIC;
        Cs_n  : IN    STD_LOGIC;
        Ras_n : IN    STD_LOGIC;
        Cas_n : IN    STD_LOGIC;
        We_n  : IN    STD_LOGIC;
        Dm    : IN    STD_LOGIC_VECTOR (1 DOWNTO 0)
    );
	end component;
	
end ddr;
	