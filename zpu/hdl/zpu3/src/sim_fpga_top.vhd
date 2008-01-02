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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

library zylin;
use zylin.zpu_config.all;
use zylin.zpupkg.all;

entity fpga_top is
end fpga_top;

architecture behave of fpga_top is


signal clk : std_logic;

signal	areset			: std_logic;


component zpu_top is
    Port ( clk : in std_logic;
	 		  areset : in std_logic;
	 		  io_busy : in std_logic;
	 		  io_read : in std_logic_vector(7 downto 0);
	 		  io_write : out std_logic_vector(7 downto 0);
			  io_addr : out std_logic_vector(maxAddrBit downto minAddrBit);
			  io_writeEnable : out std_logic;
			  io_readEnable : out std_logic;
	 		  interrupt : in std_logic;
	 		  break : out std_logic);
end component;


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
		write	: in std_logic_vector(7 downto 0);
		read	: out std_logic_vector(7 downto 0);
		addr : in std_logic_vector(maxAddrBit downto minAddrBit)
		);
end component;



signal	 		  io_busy : std_logic;
signal	 		  io_read : std_logic_vector(7 downto 0);
signal	 		  io_write : std_logic_vector(7 downto 0);
signal			  io_addr : std_logic_vector(maxAddrBit downto minAddrBit);
signal			  io_writeEnable : std_logic;
signal			  io_readEnable : std_logic;

signal break : std_logic;

begin
	poweronreset: roc port map (O => areset);



	zpu: zpu_top port map (
    	clk => clk ,
	 	areset => areset,
	 	io_busy => io_busy,
	 	io_read => io_read,
	 	io_write => io_write,
		io_addr => io_addr,
		io_writeEnable => io_writeEnable,
		io_readEnable => io_readEnable,
		interrupt => '0',
	 	break => break);


	ioMap: zpu_io port map (
       	clk => clk,
	 	areset => areset,
		busy => io_busy,
		writeEnable => io_writeEnable,
		readEnable => io_readEnable,
		write	=> io_write,
		read	=> io_read,
		addr => io_addr
	);



	-- wiggle the clock @ 100MHz
	clock : PROCESS
	   begin
   			clk <= '0';
		   wait for 5 ns; 
   			clk <= '1';
		   wait for 5 ns; 
	end PROCESS clock;


end behave;
