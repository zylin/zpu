library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use std.textio.all;

library work;
use work.zpu_config.all;
use work.zpupkg.all;
use work.txt_util.all;
 
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
		write	: in std_logic_vector(wordSize-1 downto 0);
		read	: out std_logic_vector(wordSize-1 downto 0);
		addr : in std_logic_vector(maxAddrBit downto minAddrBit)
		);
end zpu_io;
   
   
architecture behave of zpu_io is



signal timer_read : std_logic_vector(7 downto 0);
--signal timer_write : std_logic_vector(7 downto 0);
signal timer_we : std_logic;

signal serving : std_logic;

file 		l_file		: TEXT open write_mode is log_file;

begin

	
	timerinst: timer port map (
       clk => clk,
		 areset => areset,
		 we => timer_we,
		 din => write(7 downto 0),
		 adr => addr(4 downto 2),
		 dout => timer_read);
	
	busy <= writeEnable or readEnable;
	timer_we <= writeEnable and addr(12);
	
	process(areset, clk)
	begin
		if (areset = '1') then
--			timer_we <= '0';
		elsif (clk'event and clk = '1') then
--			timer_we <= '0';
			if writeEnable = '1' then
				-- external interface
				if addr=x"2028003" then
					-- Write to UART
					-- report "" & character'image(conv_integer(memBint)) severity note;
				    print(l_file, character'val(conv_integer(write)));
				elsif addr(12)='1' then
--				    report "xxx" severity failure;
-- 					timer_we <= '1';
				else
					print(l_file, character'val(conv_integer(write)));
					report "Illegal IO write" severity warning;
				end if;
				
			end if;
			read <= (others => '0');
			if (readEnable = '1') then
				if addr=x"1001" then
					read <= (0=>'1', others => '0'); -- recieve empty
 				elsif addr(12)='1' then
 					read(7 downto 0) <= timer_read;
 				elsif addr(11)='1' then
 					read(7 downto 0) <= ZPU_Frequency;
 				elsif addr=x"2028003" then
					read <= (others => '0');
				else
					read <= (others => '0');
					read(8) <= '1';
					report "Illegal IO read" severity warning;
				end if;
			end if;
		end if;
	end process;


end behave;
 
