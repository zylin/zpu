library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package zpu_config is

	constant	Generate_Trace		: boolean := false;
	-- during simulation, set this to '0' to get matching trace.txt 
	constant	DontCareValue		: std_logic := '0';
	-- Clock frequency in MHz.
	constant	ZPU_Frequency		: std_logic_vector(7 downto 0) := x"64";
	-- maximum address includes upper bit for IO registers
	-- the rest is RAM
	constant maxAddrBit			: integer := 14;
	constant minAddrBit			: integer := 2;
	-- This bit is set for read/writes to IO
	-- FIX!!! eventually this should be set to wordSize-1 so as to
	-- to make the address of IO independent of amount of memory
	-- reserved for CPU. Requires trivial tweaks in toolchain/runtime
	-- libraries.
	constant ioBit				: integer := maxAddrBit+1;
	constant wordPower			: integer := 5;
	constant wordSize			: integer := 2**wordPower;
	
end zpu_config;
