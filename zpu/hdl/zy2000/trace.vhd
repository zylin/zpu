library ieee;
use ieee.std_logic_1164.all;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use std.textio.all;

library work;
use work.zpu_config.all;
use work.zpupkg.all;
use work.txt_util.all;
 
 
entity trace is
  generic (
           log_file:       string  := "trace.txt"
          );
  port(
       	clk         : in std_logic;
       	begin_inst  : in std_logic;
       	pc          : in std_logic_vector(maxAddrBitIncIO downto 0);
		opcode		: in std_logic_vector(7 downto 0);
		sp			: in std_logic_vector(maxAddrBitIncIO downto 2);
		memA		: in std_logic_vector(wordSize-1 downto 0);
		memB		: in std_logic_vector(wordSize-1 downto 0);
		busy  : in std_logic;
		intSp		: in std_logic_vector(stack_bits-1 downto 0)
		);
end trace;
   
   
architecture behave of trace is
  
  
file 		l_file		: TEXT open write_mode is log_file;


begin


-- write data and control information to a file

receive_data: process

variable l: line;
variable t	: std_logic_vector(wordSize-1 downto 0);
variable t2	: std_logic_vector(maxAddrBitIncIO downto 0);
variable counter : std_logic_vector(63 downto 0);
   
   
   
begin                                       

	t:= (others => '0');
	t2:= (others => '0');

counter := (others => '0');
   -- print header for the logfile
   print(l_file, "#pc,opcode,sp,top_of_stack ");
   print(l_file, "#----------");
   print(l_file, " ");

	wait until clk = '1';
	wait until clk = '0'; 

   while true loop

		counter := counter + 1;
		if begin_inst = '1' then
			t(maxAddrBitIncIO downto 2):=sp;
			t2:=pc;
     		print(l_file, "0x" & hstr(t2) & " 0x" & hstr(opcode) & " 0x" & hstr(t) & " 0x" & hstr(memA) & " 0x" & hstr(memB) & " 0x" & hstr(intSp) & " 0x" & hstr(counter));
		end if;
		
     	wait until clk = '0';
    
   end loop;

 end process receive_data;



end behave;
 
