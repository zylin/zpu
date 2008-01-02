library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
entity timer is
  port(
       clk              : in std_logic;
		 areset				: in std_logic;
		 we					: in std_logic;
		 din					: in std_logic_vector(7 downto 0);
		 adr					: in std_logic_vector(2 downto 0);
		 dout					: out std_logic_vector(7 downto 0));
end timer;
   
   
architecture behave of timer is

signal	sample	: std_logic;
signal	reset		: std_logic;

signal	c			: std_logic_vector(1 to 7);

signal	cnt		: std_logic_vector(63 downto 0);
signal	cnt_smp	: std_logic_vector(63 downto 0);

begin

	reset <= '1' when (we = '1' and din(0) = '1') else '0';
	sample <= '1' when (we = '1' and din(1) = '1') else '0';

	process(clk, areset)	-- Carry generation
	begin
		if areset = '1' then
			c <= "0000000";
		elsif (clk'event and clk = '1') then
			if reset = '1' then
				c <= "0000000";
			else
				if cnt(7 downto 0) = "11111110" then
					c(1) <= '1';
				else
					c(1) <= '0';
				end if;
				if cnt(15 downto 8) = "11111111" then
					c(2) <= '1';
				else
					c(2) <= '0';
				end if;
				if cnt(23 downto 16) = "11111111" and c(2) = '1' then
					c(3) <= '1';
				else
					c(3) <= '0';
				end if;
				if cnt(31 downto 24) = "11111111" and c(3) = '1' then
					c(4) <= '1';
				else
					c(4) <= '0';
				end if;
				if cnt(39 downto 32) = "11111111" and c(4) = '1' then
					c(5) <= '1';
				else
					c(5) <= '0';
				end if;
				if cnt(47 downto 40) = "11111111" and c(5) = '1' then
					c(6) <= '1';
				else
					c(6) <= '0';
				end if;
				if cnt(55 downto 48) = "11111111" and c(6) = '1' then
					c(7) <= '1';
				else
					c(7) <= '0';
				end if;
			end if;	
		end if;
	end process;
	
	process(clk, areset)
	begin
		if areset = '1' then
			cnt <= (others=>'0');
		elsif (clk'event and clk = '1') then
			if reset = '1' then
				cnt <= (others=>'0');
			else
				cnt(7 downto 0) <= cnt(7 downto 0) + '1';
				if c(1) = '1' then
					cnt(15 downto 8) <= cnt(15 downto 8) + '1';
				else
					cnt(15 downto 8) <= cnt(15 downto 8);
				end if;
				if c(2) = '1' and c(1) = '1' then
					cnt(23 downto 16) <= cnt(23 downto 16) + '1';
				else
					cnt(23 downto 16) <= cnt(23 downto 16);
				end if;
				if c(3) = '1' and c(1) = '1' then
					cnt(31 downto 24) <= cnt(31 downto 24) + '1';
				else
					cnt(31 downto 24) <= cnt(31 downto 24);
				end if;
				if c(4) = '1' and c(1) = '1' then
					cnt(39 downto 32) <= cnt(39 downto 32) + '1';
				else
					cnt(39 downto 32) <= cnt(39 downto 32);
				end if;
				if c(5) = '1' and c(1) = '1' then
					cnt(47 downto 40) <= cnt(47 downto 40) + '1';
				else
					cnt(47 downto 40) <= cnt(47 downto 40);
				end if;
				if c(6) = '1' and c(1) = '1' then
					cnt(55 downto 48) <= cnt(55 downto 48) + '1';
				else
					cnt(55 downto 48) <= cnt(55 downto 48);
				end if;
				if c(7) = '1' and c(1) = '1' then
					cnt(63 downto 56) <= cnt(63 downto 56) + '1';
				else
					cnt(63 downto 56) <= cnt(63 downto 56);
				end if;
			end if;
		end if;
	end process;
	
	process(clk, areset)
	begin
		if areset = '1' then
			cnt_smp <= (others=>'0');
		elsif (clk'event and clk = '1') then
			if reset = '1' then
				cnt_smp <= (others=>'0');
			elsif sample = '1' then
				cnt_smp <= cnt;
			else
				cnt_smp <= cnt_smp;
			end if;
		end if;
	end process;
	
	process(cnt_smp, adr)
	begin
		case adr is
			when "000"	=> dout <= cnt_smp(7 downto 0);
			when "001"	=> dout <= cnt_smp(15 downto 8);
			when "010"	=> dout <= cnt_smp(23 downto 16);
			when "011"	=> dout <= cnt_smp(31 downto 24);
			when "100"	=> dout <= cnt_smp(39 downto 32);
			when "101"	=> dout <= cnt_smp(47 downto 40);
			when "110"	=> dout <= cnt_smp(55 downto 48);
			when others	=> dout <= cnt_smp(63 downto 56);
		end case;
	end process;
	

end behave;
 
