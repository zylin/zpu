library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use std.textio.all;
use work.zpu_config.all;
 
 
entity trace is
  port(
       	clk         : in std_logic;
       	begin_inst  : in std_logic;
       	pc          : in std_logic_vector(maxAddrBit downto 0);
		opcode		: in std_logic_vector(7 downto 0);
		sp			: in std_logic_vector(maxAddrBit downto 2);
		memA		: in std_logic_vector(wordSize-1 downto 0);
		busy  : in std_logic);
end trace;
   
   
architecture behave of trace is
  
begin

end behave;
 
