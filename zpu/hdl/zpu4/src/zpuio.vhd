library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.zpu_config.all;
use work.zpupkg.all;

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
--signal io_write : std_logic_vector(7 downto 0);
signal io_addr : std_logic_vector(maxAddrBit downto minAddrBit);
signal io_writeEnable : std_logic;
signal Enable : std_logic;

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




signal			  mem_busy : std_logic;
signal			  mem_read : std_logic_vector(wordSize-1 downto 0);
signal			  mem_write : std_logic_vector(wordSize-1 downto 0);
signal			  mem_addr : std_logic_vector(maxAddrBitIncIO downto 0);
signal			  mem_writeEnable : std_logic; 
signal			  mem_readEnable : std_logic;
signal			  mem_writeMask: std_logic_vector(wordBytes-1 downto 0);

signal			  dram_mem_busy : std_logic;
signal			  dram_mem_read : std_logic_vector(wordSize-1 downto 0);
signal			  dram_mem_write : std_logic_vector(wordSize-1 downto 0);
signal			  dram_mem_writeEnable : std_logic; 
signal			  dram_mem_readEnable : std_logic;
signal			  dram_mem_writeMask: std_logic_vector(wordBytes-1 downto 0);



--signal			  io_mem_read : std_logic_vector(7 downto 0);
--signal			  io_mem_writeEnable : std_logic; 
--signal			  io_mem_readEnable : std_logic;
signal			  io_readEnable : std_logic;


signal			  dram_read : std_logic;



begin

	io_addr <= mem_addr(maxAddrBit downto minAddrBit);
	
	timerinst: timer port map (
       clk => cpu_clk,
		 areset => areset,
		 we => timer_we,
		 din => mem_write(7 downto 0),
		 adr => io_addr(4 downto 2),
		 dout => timer_read);

		zpu: zpu_core port map (
		clk => cpu_clk ,
	 	areset => areset,
 		in_mem_busy => mem_busy, 
 		mem_read => mem_read,
 		mem_write => mem_write, 
		out_mem_addr => mem_addr, 
		out_mem_writeEnable => mem_writeEnable,  
		out_mem_readEnable => mem_readEnable,
 		mem_writeMask => mem_writeMask, 
 		interrupt => '0',
 		break  => break);


ram_imp: dram port map (
		clk => cpu_clk ,
		areset => areset,
 		mem_busy => dram_mem_busy, 
 		mem_read => dram_mem_read,
 		mem_write => mem_write, 
		mem_addr => mem_addr(maxAddrBit downto 0), 
		mem_writeEnable => dram_mem_writeEnable,  
		mem_readEnable => dram_mem_readEnable,
 		mem_writeMask => mem_writeMask);


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
			io_busy <= '0';
			uartData <= x"58"; -- 'X'
			readingTimer <= '0';
		elsif (cpu_clk'event and cpu_clk = '1') then
			timer_we <= '0';
			io_busy <= '0';
			if uartTXCleared = '1' then
				uartTXPending <= '0';
			end if;
		
			if io_writeEnable = '1' then
				if io_addr=x"1000" then
					-- Write to UART
					uartData <= mem_write(7 downto 0);
					uartTXPending <= '1';
					io_busy <= '1';
 				elsif io_addr(12)='1' then
 					timer_we <= '1';
					io_busy <= '1';
				else
					report "Illegal IO write" severity failure;
				end if;
			end if;
			if (io_readEnable = '1') then
				if io_addr=x"1001" then
					io_read <= (0=>'1',  		-- recieve empty
 					            1 => uartTXPending,   -- tx full
 					            others => '0');
 					io_busy <= '1';
 				elsif io_addr(12)='1' then
 					readingTimer <= '1';
 					io_busy <= '1';
 				elsif io_addr(11)='1' then
 					io_read <= ZPU_Frequency;
 					io_busy <= '1';
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
	
	dram_mem_writeEnable <= mem_writeEnable and not mem_addr(ioBit);
	dram_mem_readEnable <= mem_readEnable and not mem_addr(ioBit);
	io_writeEnable <= mem_writeEnable and mem_addr(ioBit);
--	io_readEnable <= mem_readEnable and mem_addr(ioBit);
	mem_busy <= io_busy or dram_mem_busy or dram_read or io_readEnable;

	-- Memory reads either come from IO or DRAM. We need to pick the right one.
	memorycontrol:
	process(cpu_clk, areset)
	begin
		if areset = '1' then
			dram_read <= '0';
			io_readEnable <= '0';

		
		elsif (cpu_clk'event and cpu_clk = '1') then
			mem_read <= (others => '0');
			if mem_addr(ioBit)='0' and mem_readEnable='1' then
				dram_read <= '1';
			end if;
			if dram_read='1' and dram_mem_busy='0' then
				dram_read <= '0';
				mem_read <= dram_mem_read;
			end if;
			 
			if mem_addr(ioBit)='1' and mem_readEnable='1' then
				io_readEnable <= '1';
			end if;
			if io_readEnable='1' and io_busy='0' then
				io_readEnable <= '0';
				mem_read(7 downto 0) <= io_read;
			end if;
			
		end if;
	end process;


end behave;
