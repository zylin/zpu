library ieee;
use ieee.std_logic_1164.all;

package zpu_config is

	constant	Generate_Trace		: boolean := true;
	constant 	wordPower			: integer := 5;
	-- during simulation, set this to '0' to get matching trace.txt 
	constant	DontCareValue		: std_logic := '0';
	-- Clock frequency in MHz.
	constant	ZPU_Frequency		: std_logic_vector(7 downto 0) := x"64";
	constant 	maxAddrBitIncIO		: integer := 27;
	constant 	maxAddrBitDRAM		: integer := 16;
	constant 	maxAddrBitBRAM		: integer := 16;
	constant 	spStart				: std_logic_vector(maxAddrBitIncIO downto 0) := x"001fff8"; 	
	
end zpu_config;
