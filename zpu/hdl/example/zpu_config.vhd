library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

package zpu_config is
	-- generate trace output
	constant	Generate_Trace		: boolean := true;
	constant 	wordPower			: integer := 5;
	-- during simulation, set this to '0' to get matching trace.txt 
	constant	DontCareValue		: std_logic := '0';
	-- Clock frequency in MHz.
	constant	ZPU_Frequency		: std_logic_vector(7 downto 0) := x"64";
	-- This is the msb address bit. bytes=2^(maxAddrBitIncIO+1)
	constant 	maxAddrBitIncIO		: integer := 27;
	constant 	maxAddrBitBRAM		: integer := 16;
		
	-- start byte address of stack. 
	-- point to top of RAM - 2*words
	constant 	spStart				: std_logic_vector(maxAddrBitIncIO downto 0) :=
					conv_std_logic_vector((2**(maxAddrBitBRAM+1))/4-8, maxAddrBitIncIO+1);
end zpu_config;
