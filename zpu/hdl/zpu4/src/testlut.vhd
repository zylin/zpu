-- Company: Zylin AS
--
-- Hooks up the ZPU to physical pads to ensure that it is not optimized to
-- oblivion. This is purely to have something to measure LUT usage against.
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.zpu_config.all;
use work.zpupkg.all;

entity ic300 is
	port (	-- Clock inputs
			cpu_clk_p		: in std_logic;
			
			-- CPU interface signals
			cpu_a_p			: in std_logic_vector(20 downto 0);
			cpu_wr_n_p		: in std_logic_vector(1 downto 0);
			cpu_cs_n_p		: in std_logic_vector(3 downto 1);
			cpu_oe_n_p		: in std_logic;
			cpu_d_p			: out std_logic_vector(15 downto 0);
			cpu_irq_p		: out std_logic_vector(1 downto 0);
			cpu_fiq_p		: out std_logic;
			cpu_wait_n_p	: out std_logic;
			
		    sdr_clk_fb_p	: in std_logic		-- DDR clock feedback
		);
end ic300;

architecture behave of ic300 is


signal io_busy : std_logic;
signal io_read : std_logic_vector(7 downto 0);
signal io_write : std_logic_vector(7 downto 0);
signal io_addr : std_logic_vector(maxAddrBit downto minAddrBit);
signal io_writeEnable : std_logic;
signal io_readEnable : std_logic;


signal	cpu_we				: std_logic_vector(1 downto 0);
signal	cpu_re				: std_logic;
signal	areset				: std_logic;

-- Clock module signals
signal	clk_status			: std_logic_vector(2 downto 0);
signal	cpu_clk				: std_logic;
signal	cpu_clk_2x			: std_logic;
signal	cpu_clk_4x			: std_logic;
signal	ddr_in_clk			: std_logic;


-- Internal CPU interface signals
signal	cpu_din				: std_logic_vector(15 downto 0);
signal	cpu_dout			: std_logic_vector(15 downto 0);
signal	cpu_a				: std_logic_vector(20 downto 0);

signal dummy : std_logic_vector(maxAddrBit downto minAddrBit+5);

signal dummy2 : std_logic_vector(wordSize-1 downto 0);
signal dummy3 : std_logic_vector(wordSize-1 downto 0);
signal dummy4 : std_logic_vector(wordSize-1 downto 0);
begin

	areset <= '0';	-- MUST BE CHANGED TO SOMETHING CORRECT
	
--	cpu_d_p <= (others => '0');
	cpu_irq_p <= (others => '0');
	cpu_fiq_p <= '0';
	cpu_wait_n_p <= '0';

	cpu_d_p(15 downto 15) <= (others => '0');

	-- delay signals going out/in w/1 clk so the 
	-- ZPU does not have to drive those pins. 
	-- 
	-- these registers can be placed close to the ZPU and these
	-- registers then have a full clock to drive the pins.
	process(cpu_clk_p, areset)
	begin
		if (cpu_clk_p'event and cpu_clk_p = '1') then
			cpu_d_p(0) <= io_writeEnable;
			cpu_d_p(1) <= io_readEnable;
			cpu_d_p(9 downto 2) <= io_write;
			io_read <= cpu_a_p(7 downto 0);
			-- 32 read/write registers is plenty realisitic for a minimal size
			-- soft-CPU
			cpu_d_p(14 downto 10) <= io_addr(minAddrBit+4 downto minAddrBit);
		end if;
	end process;
	

	zpu: zpu_core port map (
    	clk => cpu_clk_p ,
	 	areset => areset,
	 	enable => '1', 
	 	
		in_mem_busy => '0',
		out_mem_writeEnable => io_writeEnable,
		out_mem_readEnable => io_readEnable,
		mem_write(7 downto 0)	=> io_write,
		mem_write(wordSize-1 downto 8)	=> dummy3(wordSize-1 downto 8),
		mem_read(7 downto 0)	=> io_read,
		mem_read(wordSize-1 downto 8) => dummy2(wordSize-1 downto 8),
		out_mem_addr(maxAddrBitIncIO) => dummy4(maxAddrBitIncIO),
		out_mem_addr(minAddrBit-1 downto 0) => dummy4(minAddrBit-1 downto 0) ,
		out_mem_addr(maxAddrBit downto minAddrBit) => io_addr,
		interrupt => '0'
	);


end behave;
