--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:    20:15:31 04/14/05
-- Design Name:    
-- Module Name:    fpga_top - behave
-- Project Name:   
-- Target Device:  
-- Tool versions:  
-- Description:
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library work;
use work.zpu_config.all;

entity fpga_top is
end fpga_top;

use work.zpupkg.all;

architecture behave of fpga_top is


signal clk : std_logic;

signal	areset			: std_logic := '1';


component  zpu_io is
  generic (
           log_file:       string  := "log.txt"
          );
  port(
       	clk         : in std_logic;
       	areset        : in std_logic;
		busy : out std_logic;
		writeEnable : in std_logic;
		readEnable : in std_logic;
		write	: in std_logic_vector(wordSize-1 downto 0);
		read	: out std_logic_vector(wordSize-1 downto 0);
		addr : in std_logic_vector(maxAddrBit downto minAddrBit)
		);
end component;





signal			  mem_busy : std_logic;
signal			  mem_read : std_logic_vector(wordSize-1 downto 0);
signal			  mem_write : std_logic_vector(wordSize-1 downto 0);
signal			  mem_addr : std_logic_vector(maxAddrBitIncIO downto 0);
signal			  mem_writeEnable : std_logic; 
signal			  mem_readEnable : std_logic;
signal			  mem_writeMask: std_logic_vector(wordBytes-1 downto 0);

signal			  enable : std_logic;

signal			  dram_mem_busy : std_logic;
signal			  dram_mem_read : std_logic_vector(wordSize-1 downto 0);
signal			  dram_mem_write : std_logic_vector(wordSize-1 downto 0);
signal			  dram_mem_writeEnable : std_logic; 
signal			  dram_mem_readEnable : std_logic;
signal			  dram_mem_writeMask: std_logic_vector(wordBytes-1 downto 0);


signal	 		  io_busy : std_logic;

signal			  io_mem_read : std_logic_vector(wordSize-1 downto 0);
signal			  io_mem_writeEnable : std_logic; 
signal			  io_mem_readEnable : std_logic;


signal			  dram_ready : std_logic;
signal			  io_ready : std_logic;
signal			  io_reading : std_logic;


signal break : std_logic;

begin
	zpu: zpu_core port map (
		clk => clk ,
	 	reset => areset,
	 	enable => enable,
 		in_mem_busy => mem_busy, 
 		mem_read => mem_read,
 		mem_write => mem_write, 
		out_mem_addr => mem_addr, 
		out_mem_writeEnable => mem_writeEnable,  
		out_mem_readEnable => mem_readEnable,
 		mem_writeMask => mem_writeMask, 
 		interrupt => '0',
 		break  => break);

	dram_imp: dram port map (
		clk => clk ,
		areset => areset,
 		mem_busy => dram_mem_busy, 
 		mem_read => dram_mem_read,
 		mem_write => mem_write, 
		mem_addr => mem_addr(maxAddrBit downto 0), 
		mem_writeEnable => dram_mem_writeEnable,  
		mem_readEnable => dram_mem_readEnable,
 		mem_writeMask => mem_writeMask);


	ioMap: zpu_io port map (
       	clk => clk,
	 	areset => areset,
		busy => io_busy,
		writeEnable => io_mem_writeEnable,
		readEnable => io_mem_readEnable,
		write	=> mem_write(wordSize-1 downto 0),
		read	=> io_mem_read,
		addr => mem_addr(maxAddrBit downto minAddrBit)
	);

	dram_mem_writeEnable <= mem_writeEnable and not mem_addr(ioBit);
	dram_mem_readEnable <= mem_readEnable and not mem_addr(ioBit);
	io_mem_writeEnable <= mem_writeEnable and mem_addr(ioBit);
	io_mem_readEnable <= mem_readEnable and mem_addr(ioBit);
	mem_busy <= io_busy or dram_mem_busy or io_busy;
	
	

	-- Memory reads either come from IO or DRAM. We need to pick the right one.
	memorycontrol:
	process(dram_mem_read, dram_ready, io_ready, io_mem_read)
	begin
		mem_read <= (others => 'U');
		if dram_ready='1' then
			mem_read <= dram_mem_read;
		end if;
			 
		if io_ready='1' then
			mem_read <= io_mem_read;
		end if;
	end process;

	
	io_ready <= (io_reading or io_mem_readEnable) and not io_busy;

	memoryControlSync:
	process(clk, areset)
	begin
		if areset = '1' then
			enable <= '0';
			io_reading <= '0';
			dram_ready <= '0';
		elsif (clk'event and clk = '1') then
			enable <= '1';
			io_reading <= io_busy or io_mem_readEnable; 
			dram_ready<=dram_mem_readEnable;
			
		end if;
	end process;

	-- wiggle the clock @ 100MHz
	clock : PROCESS
	   begin
   			clk <= '0';
		   wait for 5 ns; 
   			clk <= '1';
		   wait for 5 ns; 
		   areset <= '0';
	end PROCESS clock;


end behave;
