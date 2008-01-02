library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.phi_config.all;
use work.wishbone_pkg.all;
use work.zpupkg.all;
use work.zpu_config.all;

entity zpu_wb_bridge is
	port (	-- Native ZPU interface
 			clk 				: in std_logic;
	 		areset 				: in std_logic;

	 		mem_req 			: in std_logic;
	 		mem_we				: in std_logic;
	 		mem_ack				: out std_logic; 
	 		mem_read 			: out std_logic_vector(wordSize-1 downto 0);
	 		mem_write 			: in std_logic_vector(wordSize-1 downto 0);
			out_mem_addr 		: in std_logic_vector(maxAddrBitIncIO downto 0);
	 		mem_writeMask		: in std_logic_vector(wordBytes-1 downto 0);
			
			-- Wishbone from ZPU
			zpu_wb_i			: in wishbone_bus_out;
			zpu_wb_o			: out wishbone_bus_in);

end zpu_wb_bridge;

architecture behave of zpu_wb_bridge is

begin

	mem_read <= zpu_wb_i.dat;
	mem_ack <= zpu_wb_i.ack;
	
	zpu_wb_o.adr <= "000000" & out_mem_addr(27) & out_mem_addr(24 downto 0);
	zpu_wb_o.dat <= mem_write;
	zpu_wb_o.sel <= mem_writeMask;
	zpu_wb_o.stb <= mem_req;
	zpu_wb_o.cyc <= mem_req;
	zpu_wb_o.we <= mem_we;

end behave;

			

	

