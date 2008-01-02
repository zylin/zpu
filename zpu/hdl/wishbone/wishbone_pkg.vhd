library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

package wishbone_pkg is

	type wishbone_bus_in is record
		adr			: std_logic_vector(31 downto 0); 
		sel			: std_logic_vector(3 downto 0); 
		we			: std_logic;
		dat			: std_logic_vector(31 downto 0); 	-- Note! Data written with 'we'
		cyc			: std_logic; 
		stb			: std_logic;
	end record;

	type wishbone_bus_out is record
		dat		: std_logic_vector(31 downto 0);
		ack			: std_logic;
	end record;
	
	type wishbone_bus is record
		insig		: wishbone_bus_in;
		outsig  	: wishbone_bus_out;
	end record;

	component atomic32_access is
	port (	cpu_clk			: in std_logic;
			areset			: in std_logic;
	
			-- Wishbone from CPU interface
			wb_16_i			: in wishbone_bus_in;
			wb_16_o     	: out wishbone_bus_out;
			-- Wishbone to FPGA registers and ethernet core
			wb_32_i			: in wishbone_bus_out;
			wb_32_o			: out wishbone_bus_in);
	end component;
	
	component eth_access_corr is
	port (	cpu_clk			: in std_logic;
			areset			: in std_logic;
	
			-- Wishbone from Wishbone MUX
			eth_raw_o		: out wishbone_bus_out;
			eth_raw_i		: in wishbone_bus_in;
			
			-- Wishbone ethernet core
			eth_slave_i 	: in wishbone_bus_out;
			eth_slave_o		: out wishbone_bus_in);
	end component;


end wishbone_pkg;
