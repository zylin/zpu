library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library zylin;
use zylin.arm7.all;

library zylin;
use zylin.zpu_config.all;
use zylin.zpupkg.all;

entity zpuio is
	port (	areset			: in std_logic;
			cpu_clk			: in std_logic;
			clk_status		: in std_logic_vector(2 downto 0);
			cpu_din			: in std_logic_vector(15 downto 0);
			cpu_a			: in std_logic_vector(20 downto 0);
			cpu_we			: in std_logic_vector(1 downto 0);
			cpu_re			: in std_logic;
			cpu_dout		: inout std_logic_vector(15 downto 0));
end zpuio;

architecture behave of zpuio is

signal timer_read : std_logic_vector(7 downto 0);
--signal timer_write : std_logic_vector(7 downto 0);
signal timer_we : std_logic;


signal io_busy : std_logic;
signal io_read : std_logic_vector(7 downto 0);
signal io_write : std_logic_vector(7 downto 0);
signal io_addr : std_logic_vector(maxAddrBit downto minAddrBit);
signal io_writeEnable : std_logic;
signal io_readEnable : std_logic;

signal		  din :  std_logic_vector(7 downto 0);
signal	 		  dout : std_logic_vector(7 downto 0);
signal			  adr : std_logic_vector(15 downto 0);
signal			  break : std_logic;
signal			  we : std_logic;
signal			  re : std_logic;


-- uart forwarding...

signal uartTXPending : std_logic;
signal uartTXCleared : std_logic;
signal uartData : std_logic_vector(7 downto 0);

signal readingTimer : std_logic;
begin

	timerinst: timer port map (
       clk => cpu_clk,
		 areset => areset,
		 we => timer_we,
		 din => io_write,
		 adr => io_addr(4 downto 2),
		 dout => timer_read);

	zpu: zpu_top port map (
    	clk => cpu_clk ,
	 	areset => areset,
		io_busy => io_busy,
		io_writeEnable => io_writeEnable,
		io_readEnable => io_readEnable,
		io_write	=> io_write,
		io_read	=> io_read,
		io_addr => io_addr,
		interrupt => '0'
		--,
--	 	break => cpu_fiq_p
);


	-- Read/write are on different addresses
	-- The registers are 8 bits and mapped to bit[7:0]
	-- 
	-- 0xC000 Write: Writes to UART TX FIFO (4 byte FIFO) 
	--        Read : Reads from UART RX FIFO (4 byte FIFO)
	-- 0xC004 Read : UART status register
	--                       Bit 0 = RX FIFO empty
	--                       Bit 1 = TX FIFO full
	-- 0xA000 Skrive: LED's (8 stk.)
	
	-- 0x9000 Write: bit 0: 1= reset counter
	-- 			   0= counter running
	-- 		  bit 1: 1= sample counter (when set to 1)
	-- 			   0=not used
	-- 	 Read : counter bit[7:0]
	-- 0x9004 Read: counter bit [15:8]
	-- 0x9008 Read: counter bit [23:16]
	-- 0x900C Read: counter bit [31:24]
	-- 0x9010 Read: counter bit [39:32]
	-- 0x9014 Read: counter bit [47:40]
	-- 0x9018 Read: counter bit [55:48]
	-- 0x901C Read: counter bit [63:56]
	-- 
	-- 0x8800 Read: unsigned 8-bit integer with FPGA frequency (in MHz)
	
	fauxUart:
	process(cpu_clk, areset)
	begin
		if areset = '1' then
			io_busy <= '0';
			uartTXPending <= '0';
			timer_we <= '0';
			io_busy <= '1';
			uartData <= x"58"; -- 'X'
			readingTimer <= '0';
		elsif (cpu_clk'event and cpu_clk = '1') then
			timer_we <= '0';
			io_busy <= '1';
			if uartTXCleared = '1' then
				uartTXPending <= '0';
			end if;
		
			if io_writeEnable = '1' then
				if io_addr=x"1000" then
					-- Write to UART
					uartData <= io_write;
					uartTXPending <= '1';
					io_busy <= '0';
 				elsif io_addr(12)='1' then
 					timer_we <= '1';
					io_busy <= '0';
				else
					report "Illegal IO write" severity failure;
				end if;
			end if;
			if (io_readEnable = '1') then
				if io_addr=x"1001" then
					io_read <= (0=>'1',  		-- recieve empty
 					            1 => uartTXPending,   -- tx full
 					            others => '0');
 					io_busy <= '0';
 				elsif io_addr(12)='1' then
 					readingTimer <= '1';
 					io_busy <= '1';
 				elsif io_addr(11)='1' then
 					io_read <= ZPU_Frequency;
 					io_busy <= '0';
				else
					report "Illegal IO read" severity failure;
				end if;
				
			else 
				if (readingTimer = '1') then
					readingTimer <= '0';
 					io_read <= timer_read;
 					io_busy <= '0';
 				else
					io_read <= (others => '1');
 				end if;
			end if;
		end if;
	end process;


	forwardUARTOutputToARM:
	process(cpu_clk, areset)
	begin
		if areset = '1' then
			uartTXCleared <= '0';
		elsif (cpu_clk = '1' and cpu_clk'event) then
			if cpu_we(0) = '1' and cpu_a(3 downto 1) = "000" then
				uartTXCleared <= cpu_din(0);
			else
				uartTXCleared <= uartTXCleared;
			end if;
		end if;
	end process;	

	cpu_dout(7 downto 0) <= uartData when (cpu_re = '1' and cpu_a(3 downto 1) = "001") else (others => 'Z');
	cpu_dout <= (0 => uartTXPending, others => '0') when (cpu_re = '1' and cpu_a(3 downto 1) = "000") else (others => 'Z');
	


end behave;
