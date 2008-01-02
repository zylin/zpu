library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all; 

library work;
use work.wishbone_pkg.all;
use work.zpupkg.all;
use work.zpu_config.all;
use work.ic300pkg.all;

entity zpu_system is
	generic(
			simulate		: boolean := false);
	port (	areset			: in std_logic;
			cpu_clk			: in std_logic;

			-- ZPU Control signals
			enable			: in std_logic;
			interrupt		: in std_logic;

			zpu_status		: out std_logic_vector(63 downto 0);

			-- wishbone interfaces
			zpu_wb_i		: in wishbone_bus_out;
			zpu_wb_o		: out wishbone_bus_in);
end zpu_system;

architecture behave of zpu_system is

signal	mem_req					: std_logic;
signal	mem_we 					: std_logic;
signal	mem_ack 				: std_logic; 
signal	mem_read 				: std_logic_vector(wordSize-1 downto 0);
signal	mem_write 				: std_logic_vector(wordSize-1 downto 0);
signal	out_mem_addr 			: std_logic_vector(maxAddrBitIncIO downto 0);
signal	mem_writeMask			: std_logic_vector(wordBytes-1 downto 0);


begin

	my_zpu_core:
	zpu_core port map (
    	clk 				=> cpu_clk, 
		areset 				=> areset,
	 	enable 				=> enable,
	  	mem_req 			=> mem_req,
	 	mem_we 				=> mem_we,
	 	mem_ack 			=> mem_ack, 
	 	mem_read 			=> mem_read,
	 	mem_write 			=> mem_write,
		out_mem_addr 		=> out_mem_addr,
	 	mem_writeMask		=> mem_writeMask,
	 	interrupt			=> interrupt,
	 	zpu_status			=> zpu_status,
	 	break				=> open);

	my_zpu_wb_bridge:
	zpu_wb_bridge port map (
		clk 				=> cpu_clk,
	 	areset 				=> areset,
	  	mem_req 			=> mem_req,
	 	mem_we 				=> mem_we,
	 	mem_ack 			=> mem_ack, 
	 	mem_read 			=> mem_read,
	 	mem_write 			=> mem_write,
		out_mem_addr 		=> out_mem_addr,
	 	mem_writeMask		=> mem_writeMask,
		zpu_wb_i			=> zpu_wb_i,
		zpu_wb_o			=> zpu_wb_o);

end behave;
