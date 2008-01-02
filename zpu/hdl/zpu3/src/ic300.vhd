--------------------------------------------------------------------------------
-- Company: Zylin AS
-- Engineer: Tore Ramsland
--
-- Create Date:    21:47:41 07/03/05
-- Design Name:    ic300
-- Module Name:    ic300 - behave
-- Project Name:   eCosBoard
-- Target Device:  XC3S400400-FG256
-- Tool versions:  7.1i
-- Description:	   Top level
--
-- Dependencies:
-- 
-- Revision:
--	2005-07-11	Updated to test FPGA
-- 
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library zylin;
use zylin.arm7.all;

library zylin;
use zylin.zpu_config.all;
use zylin.zpupkg.all;

library work;
use work.phi_config.all;
use work.ic300pkg.all;

entity ic300 is
	generic(
			simulate_io_time	: boolean := false);
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
end ic300;

architecture behave of ic300 is

signal	cpu_we				: std_logic_vector(1 downto 0);			-- Write signal for lower(0) and upper(1) 8 data bits
signal	cpu_re				: std_logic;							-- Read enable signal for all 16 bits
signal	areset				: std_logic;							-- Asyncronous active high reset (for initialization)
signal	areset_dummy		: std_logic;

-- Clock module signals
signal	clk_status			: std_logic_vector(2 downto 0);			-- DLL lock status (from 3 DLL's)
signal	cpu_clk				: std_logic;							-- 64 MHz CPU clk
signal	cpu_clk_2x			: std_logic;							-- 128 MHz CPU clk (in phase with 64 MHz)
signal	cpu_clk_4x			: std_logic;							-- 256 MHz CPU clk (in phase with 64 MHz)
signal	ddr_in_clk			: std_logic;							-- 128 MHz clock from DDR SDRAM
signal	ddr_in_clk_2x		: std_logic;							-- 256 MHz clock from DDR SDRAM
																	-- NOTE! Phase relation to 64 MHz clock unknown

-- Internal CPU interface signals
signal	cpu_din				: std_logic_vector(15 downto 0);		-- 16-bit data from CPU
signal	cpu_dout			: std_logic_vector(15 downto 0);		-- 16-bit data to CPU
signal	cpu_a				: std_logic_vector(20 downto 0);		-- 21-bit address from CPU

begin

--	areset <= '0';
	areset_dummy <= '0';

	global_init_reset:
	rocbuf port map(I=>areset_dummy,O=>areset);

	allclocks:
	clocks port map(
		areset => areset,
		cpu_clk_p => cpu_clk_p,
		cpu_clk => cpu_clk,
		cpu_clk_2x => cpu_clk_2x,
		cpu_clk_4x => cpu_clk_4x,
		sdr_clk_fb_p => sdr_clk_fb_p,
		ddr_in_clk => ddr_in_clk,
		ddr_in_clk_2x => ddr_in_clk_2x,
		locked => clk_status);

	arm7cpu:
	arm7wb generic map (simulate_io_time => simulate_io_time)
	port map(
		areset => areset,
		cpu_clk => cpu_clk,
		cpu_clk_2x => cpu_clk_2x,
		cpu_a_p => cpu_a_p,
		cpu_wr_n_p => cpu_wr_n_p,
		cpu_cs_n_p => cpu_cs_n_p,
		cpu_oe_n_p => cpu_oe_n_p,
		cpu_d_p => cpu_d_p,
		cpu_irq_p => cpu_irq_p,
		cpu_fiq_p => cpu_fiq_p,
		cpu_wait_n_p => cpu_wait_n_p,
		cpu_din => cpu_din,
		cpu_a => cpu_a,
		cpu_we => cpu_we,
		cpu_re => cpu_re,
		cpu_dout => cpu_dout);
		
		
	cpu_fpga_regs:
	zpuio port map(
		areset => areset,
		cpu_clk => cpu_clk,
		clk_status => clk_status,
		cpu_din => cpu_din,
		cpu_a => cpu_a,
		cpu_we => cpu_we,
		cpu_re => cpu_re,
		cpu_dout => cpu_dout);


end behave;
