library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

library zylin;
use zylin.zpu_config.all;

package zpupkg is

	component dualport_ram is
	port (clk : in std_logic;
		memAWriteEnable : in std_logic;
		memAAddr : in std_logic_vector(maxAddrBit downto minAddrBit);
		memAWrite : in std_logic_vector(wordSize-1 downto 0);
		memARead : out std_logic_vector(wordSize-1 downto 0);
		memBWriteEnable : in std_logic;
		memBAddr : in std_logic_vector(maxAddrBit downto minAddrBit);
		memBWrite : in std_logic_vector(wordSize-1 downto 0);
		memBRead : out std_logic_vector(wordSize-1 downto 0));
	end component;


	component trace is
	  port(
	       	clk         : in std_logic;
	       	begin_inst  : in std_logic;
	       	pc          : in std_logic_vector(maxAddrBit downto 0);
			opcode		: in std_logic_vector(7 downto 0);
			sp			: in std_logic_vector(maxAddrBit downto minAddrBit);
			memA		: in std_logic_vector(wordSize-1 downto 0);
			memB		: in std_logic_vector(wordSize-1 downto 0);
			busy         : in std_logic
			);
	end component;

	component zpu_top is
	    Port ( clk : in std_logic;
		 		  areset : in std_logic;
		 		  io_busy : in std_logic;
		 		  io_read : in std_logic_vector(7 downto 0);
		 		  io_write : out std_logic_vector(7 downto 0);
				  io_addr : out std_logic_vector(maxAddrBit downto minAddrBit);
				  io_writeEnable : out std_logic;
				  io_readEnable : out std_logic;
		 		  interrupt : in std_logic;
		 		  break : out std_logic);
	end component;


	component timer is
	  port(
	       clk              : in std_logic;
			 areset				: in std_logic;
			 we					: in std_logic;
			 din					: in std_logic_vector(7 downto 0);
			 adr					: in std_logic_vector(2 downto 0);
			 dout					: out std_logic_vector(7 downto 0));
	end component;
	

	component  zpuio is
		port (	areset			: in std_logic;
				cpu_clk			: in std_logic;
				clk_status		: in std_logic_vector(2 downto 0);
				cpu_din			: in std_logic_vector(15 downto 0);
				cpu_a			: in std_logic_vector(20 downto 0);
				cpu_we			: in std_logic_vector(1 downto 0);
				cpu_re			: in std_logic;
				cpu_dout		: inout std_logic_vector(15 downto 0));
	end component;

	
	-- opcode decode constants
	constant	OpCode_Im		: std_logic_vector(7 downto 7) := "1";
	constant	OpCode_StoreSP	: std_logic_vector(7 downto 5) := "010";
	constant	OpCode_LoadSP	: std_logic_vector(7 downto 5) := "011";
	constant	OpCode_Emulate	: std_logic_vector(7 downto 5) := "001";
	constant	OpCode_AddSP	: std_logic_vector(7 downto 4) := "0001";
	constant	OpCode_Short	: std_logic_vector(7 downto 4) := "0000";
	
	constant	OpCode_Break	: std_logic_vector(3 downto 0) := "0000";
	constant	OpCode_Shiftleft: std_logic_vector(3 downto 0) := "0001";
	constant	OpCode_PushSP	: std_logic_vector(3 downto 0) := "0010";
	constant	OpCode_PushInt	: std_logic_vector(3 downto 0) := "0011";
	
	constant	OpCode_PopPC	: std_logic_vector(3 downto 0) := "0100";
	constant	OpCode_Add		: std_logic_vector(3 downto 0) := "0101";
	constant	OpCode_And		: std_logic_vector(3 downto 0) := "0110";
	constant	OpCode_Or		: std_logic_vector(3 downto 0) := "0111";
	
	constant	OpCode_Load		: std_logic_vector(3 downto 0) := "1000";
	constant	OpCode_Not		: std_logic_vector(3 downto 0) := "1001";
	constant	OpCode_Flip		: std_logic_vector(3 downto 0) := "1010";
	constant	OpCode_Nop		: std_logic_vector(3 downto 0) := "1011";
	
	constant	OpCode_Store	: std_logic_vector(3 downto 0) := "1100";
	constant	OpCode_PopSP	: std_logic_vector(3 downto 0) := "1101";
	constant	OpCode_Compare	: std_logic_vector(3 downto 0) := "1110";
	constant	OpCode_PopInt	: std_logic_vector(3 downto 0) := "1111";
	
	constant	OpCode_Lessthan				: std_logic_vector(5 downto 0) := conv_std_logic_vector(36, 6);
	constant	OpCode_Lessthanorequal		: std_logic_vector(5 downto 0) := conv_std_logic_vector(37, 6);
	constant	OpCode_Ulessthan			: std_logic_vector(5 downto 0) := conv_std_logic_vector(38, 6);
	constant	OpCode_Ulessthanorequal		: std_logic_vector(5 downto 0) := conv_std_logic_vector(39, 6);

	constant	OpCode_Swap					: std_logic_vector(5 downto 0) := conv_std_logic_vector(40, 6);
	
	constant	OpCode_Lshiftright			: std_logic_vector(5 downto 0) := conv_std_logic_vector(42, 6);
	constant	OpCode_Ashiftleft			: std_logic_vector(5 downto 0) := conv_std_logic_vector(43, 6);
	constant	OpCode_Ashiftright			: std_logic_vector(5 downto 0) := conv_std_logic_vector(44, 6);

	constant	OpCode_Eq					: std_logic_vector(5 downto 0) := conv_std_logic_vector(46, 6);
	constant	OpCode_Neq					: std_logic_vector(5 downto 0) := conv_std_logic_vector(47, 6);

	constant	OpCode_Sub					: std_logic_vector(5 downto 0) := conv_std_logic_vector(49, 6);
	constant	OpCode_Loadb				: std_logic_vector(5 downto 0) := conv_std_logic_vector(51, 6);
	constant	OpCode_Storeb				: std_logic_vector(5 downto 0) := conv_std_logic_vector(52, 6);

	constant	OpCode_Eqbranch				: std_logic_vector(5 downto 0) := conv_std_logic_vector(55, 6);
	constant	OpCode_Neqbranch			: std_logic_vector(5 downto 0) := conv_std_logic_vector(56, 6);

	constant	OpCode_Pushspadd			: std_logic_vector(5 downto 0) := conv_std_logic_vector(61, 6);
	constant	OpCode_Mult16x16			: std_logic_vector(5 downto 0) := conv_std_logic_vector(62, 6);
	constant	OpCode_Callpcrel			: std_logic_vector(5 downto 0) := conv_std_logic_vector(63, 6);
	


	constant OpCode_Size		: integer := 8;
		
end zpupkg;
