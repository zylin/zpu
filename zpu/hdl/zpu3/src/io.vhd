library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use std.textio.all;

library zylin;
use zylin.zpu_config.all;
use zylin.zpupkg.all;
use zylin.txt_util.all;
 
entity  zpu_io is
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
end zpu_io;
   
   
architecture behave of zpu_io is



signal timer_read : std_logic_vector(7 downto 0);
--signal timer_write : std_logic_vector(7 downto 0);
signal timer_we : std_logic;

file 		l_file		: TEXT open write_mode is log_file;

begin

	
	timerinst: timer port map (
       clk => clk,
		 areset => areset,
		 we => timer_we,
		 din => write,
		 adr => addr(4 downto 2),
		 dout => timer_read);
	
	
	process(areset, clk)
	begin
		if (areset = '1') then
			timer_we <= '0';
			busy <= '1';
		elsif (clk'event and clk = '1') then
			busy <= '1';
			timer_we <= '0';
			if writeEnable = '1' then
				-- external interface
				if addr=x"1000" then
					-- Write to UART
					-- report "" & character'image(conv_integer(memBint)) severity note;
				    print(l_file, character'val(conv_integer(write)));
				    busy <= '0';
				elsif addr(12)='1' then
 					timer_we <= '1';
				    busy <= '0';
				else
					report "Illegal IO write" severity failure;
				end if;
				
			end if;
			if (readEnable = '1') then
				if addr=x"1001" then
					read <= (0=>'1', others => '0'); -- recieve empty
				    busy <= '0';
 				elsif addr(12)='1' then
 					read <= timer_read;
				    busy <= '0';
 				elsif addr(11)='1' then
 					read <= ZPU_Frequency;
				    busy <= '0';
				else
					report "Illegal IO read" severity failure;
				end if;
			else 
				read <= (others => '1');
			end if;
		end if;
	end process;


end behave;
 
