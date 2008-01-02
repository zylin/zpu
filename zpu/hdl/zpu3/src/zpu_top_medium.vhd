-- Company: ZPU3
-- Engineer: Øyvind Harboe

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_arith.ALL;

library zylin;
use zylin.zpu_config.all;
use zylin.zpupkg.all;


entity zpu_top is
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
end zpu_top;

architecture behave of zpu_top is

signal		readIO : std_logic;



signal memAWriteEnable : std_logic;
signal memAAddr : std_logic_vector(maxAddrBit downto minAddrBit);
signal memAWrite : std_logic_vector(wordSize-1 downto 0);
signal memARead : std_logic_vector(wordSize-1 downto 0);
signal memBWriteEnable : std_logic;
signal memBAddr : std_logic_vector(maxAddrBit downto minAddrBit);
signal memBWrite : std_logic_vector(wordSize-1 downto 0);
signal memBRead : std_logic_vector(wordSize-1 downto 0);



signal	pc				: std_logic_vector(maxAddrBit downto 0);
signal	sp				: std_logic_vector(maxAddrBit downto minAddrBit);

signal	idim_flag			: std_logic;

--signal	storeToStack		: std_logic;
--signal	fetchNextInstruction		: std_logic;
--signal	extraCycle			: std_logic;
signal	busy 				: std_logic;
--signal	fetching			: std_logic;

signal	begin_inst			: std_logic;



signal trace_opcode		: std_logic_vector(7 downto 0);
signal	trace_pc				: std_logic_vector(maxAddrBit downto 0);
signal	trace_sp				: std_logic_vector(maxAddrBit downto minAddrBit);
signal	trace_topOfStack				: std_logic_vector(wordSize-1 downto 0);

-- state machine.

subtype State_Type is std_logic_vector(4 downto 0);
constant State_ResyncDecode	: State_Type := b"00000";
constant State_WriteIODone	: State_Type := b"00001";
constant State_Execute		: State_Type := b"00010";
constant State_StoreToStack	: State_Type := b"00011";
constant State_Add			: State_Type := b"00100";
constant State_Or			: State_Type := b"00101";
constant State_And			: State_Type := b"00110";
constant State_Store		: State_Type := b"00111";
constant State_ReadIO		: State_Type := b"01000";
constant State_WriteIO		: State_Type := b"01001";
constant State_Load			: State_Type := b"01010";
constant State_ResyncStack	: State_Type := b"01011";
constant State_AddSP		: State_Type := b"01100";
constant State_ReadIODone	: State_Type := b"01101";
constant State_Decode		: State_Type := b"01110";
constant State_LoadByte1	: State_Type := b"01111";
constant State_LoadByte2	: State_Type := b"10000";
constant State_StoreByte1	: State_Type := b"10001";
constant State_StoreByte2	: State_Type := b"10010";
constant State_Mult1		: State_Type := b"10011";
constant State_Mult2		: State_Type := b"10100";
constant State_Mult3		: State_Type := b"10101";


subtype DecodedOpcodeType is std_logic_vector(5 downto 0);
constant Decoded_Nop				: DecodedOpcodeType := b"000000";
constant Decoded_Im					: DecodedOpcodeType := b"000001";
constant Decoded_ImShift			: DecodedOpcodeType := b"000010";
constant Decoded_LoadSP				: DecodedOpcodeType := b"000011";
constant Decoded_StoreSP			: DecodedOpcodeType := b"000100";
constant Decoded_AddSP				: DecodedOpcodeType := b"000101";
constant Decoded_Emulate			: DecodedOpcodeType := b"000110";
constant Decoded_Break				: DecodedOpcodeType := b"000111";
constant Decoded_PushPC				: DecodedOpcodeType := b"001000";
constant Decoded_PushSP				: DecodedOpcodeType := b"001001";
constant Decoded_PopPC				: DecodedOpcodeType := b"001010";
constant Decoded_Add				: DecodedOpcodeType := b"001011";
constant Decoded_Or					: DecodedOpcodeType := b"001100";
constant Decoded_And				: DecodedOpcodeType := b"001101";
constant Decoded_Load				: DecodedOpcodeType := b"001110";
constant Decoded_Not				: DecodedOpcodeType := b"001111";
constant Decoded_Flip				: DecodedOpcodeType := b"010000";
constant Decoded_Store				: DecodedOpcodeType := b"010001";
constant Decoded_PopSP				: DecodedOpcodeType := b"010010";
constant Decoded_Ashiftleft 		: DecodedOpcodeType := b"010011";
constant Decoded_Ashiftright		: DecodedOpcodeType := b"010100";
constant Decoded_Lshiftright		: DecodedOpcodeType := b"010101";
constant Decoded_Eqbranch			: DecodedOpcodeType := b"010110";
constant Decoded_Neqbranch			: DecodedOpcodeType := b"010111";
constant Decoded_Eq					: DecodedOpcodeType := b"011000";
constant Decoded_Neq				: DecodedOpcodeType := b"011001";
constant Decoded_Loadb				: DecodedOpcodeType := b"011010";
constant Decoded_Lessthan			: DecodedOpcodeType := b"011011";
constant Decoded_Lessthanorequal	: DecodedOpcodeType := b"011100";
constant Decoded_Ulessthan			: DecodedOpcodeType := b"011101";
constant Decoded_Ulessthanorequal	: DecodedOpcodeType := b"011110";
constant Decoded_Storeb				: DecodedOpcodeType := b"011111";
constant Decoded_Lshift2			: DecodedOpcodeType := b"100000";
constant Decoded_DoubleIm			: DecodedOpcodeType := b"100001";
constant Decoded_AddIm				: DecodedOpcodeType := b"100011";
constant Decoded_Mult16x16			: DecodedOpcodeType := b"100100";
constant Decoded_Swap				: DecodedOpcodeType := b"100101";
constant Decoded_Callpcrel			: DecodedOpcodeType := b"100110";
constant Decoded_Pushspadd			: DecodedOpcodeType := b"100111";


signal mult1			: std_logic_vector(wordSize/2-1 downto 0);
signal mult2			: std_logic_vector(wordSize/2-1 downto 0);
signal multResult		: std_logic_vector(wordSize-1 downto 0);

signal storeByte		: std_logic_vector(7 downto 0);
signal byteSelect		: std_logic_vector(minAddrBit-1 downto 0);

signal opcode : std_logic_vector(OpCode_Size-1 downto 0);
signal opcode2 : std_logic_vector(OpCode_Size-1 downto 0);

signal decodedOpcode : DecodedOpcodeType;

signal state : State_Type;

begin
	traceFileGenerate:
   if Generate_Trace generate
	trace_file: trace port map (
       	clk => clk,
       	begin_inst => begin_inst,
       	pc => trace_pc,
		opcode => trace_opcode,
		sp => trace_sp,
		memA => trace_topOfStack,
		busy => busy
        );
	end generate;


	memory: dualport_ram port map (
       	clk => clk,
	memAWriteEnable => memAWriteEnable,
	memAAddr => memAAddr,
	memAWrite => memAWrite,
	memARead => memARead,
	memBWriteEnable => memBWriteEnable,
	memBAddr => memBAddr,
	memBWrite => memBWrite,
	memBRead => memBRead
        );


	process(clk, areset)
	begin
		if (clk'event and clk = '1') then
			multResult <= mult1 * mult2;
		end if;
	end process;
	


	opcodeControl:
	process(clk, areset)
		variable tOpcode : std_logic_vector(OpCode_Size-1 downto 0);
		variable tOpcode2 : std_logic_vector(OpCode_Size-1 downto 0);
		variable spOffset : std_logic_vector(4 downto 0);
		variable spOffset2 : std_logic_vector(4 downto 0);
		variable nextPC	: std_logic_vector(maxAddrBit downto 0);
		variable pushspaddTemp	: std_logic_vector(maxAddrBit downto minAddrBit);
		variable tempVal : std_logic_vector(wordSize-1 downto 0);
		variable compareA : signed(wordSize-1 downto 0);
		variable compareB : signed(wordSize-1 downto 0);
	begin
		if areset = '1' then
			mult1 <= (others => '0');
			mult2 <= (others => '0');
			state <= State_ResyncDecode;
			break <= '0';
			sp <= (2 => '0', others => '1'); 
			pc <= (others => '0');
			idim_flag <= '0';
			begin_inst <= '0';
			memAAddr <= (others => '0');
			memBAddr <= (others => '0');
			memAWriteEnable <= '0';
			memBWriteEnable <= '0';
			io_writeEnable <= '0';
			io_readEnable <= '0';
			decodedOpcode <= (others => '0');
			memAWrite <= (others => '0');
			memBWrite <= (others => '0');
			opcode <= (others => '0');
			io_addr <= (others => '0');
			io_write <= (others => '0');
		elsif (clk'event and clk = '1') then
			memAWriteEnable <= '0';
			memBWriteEnable <= '0';
			
			io_writeEnable <= '0';
			io_readEnable <= '0';
			begin_inst <= '0';

			case state is
				when State_Decode =>
					nextPC:=pc+1;
					case pc(1 downto 0) is
						when "00" 	=> tOpcode := memARead(31 downto 24);
						when "01" 	=> tOpcode := memARead(23 downto 16);
						when "10" 	=> tOpcode := memARead(15 downto 8);
						when others	=> tOpcode := memARead(7 downto 0);
					end case;
					case nextPC(1 downto 0) is
						when "00" 	=> tOpcode2 := memBRead(31 downto 24);
						when "01" 	=> tOpcode2 := memBRead(23 downto 16);
						when "10" 	=> tOpcode2 := memBRead(15 downto 8);
						when others	=> tOpcode2 := memBRead(7 downto 0);
					end case;
					idim_flag <= tOpcode(7);
					opcode <= tOpcode;
					opcode2 <= tOpcode2;
					if (tOpcode(7 downto 7)=OpCode_Im and tOpcode2(7 downto 4)=0 and tOpcode2(3 downto 0)=Opcode_Add and idim_flag='0') then
						idim_flag <= '0';
						decodedOpcode <= Decoded_AddIm;
						nextPC := pc + 2;
					elsif (tOpcode(7 downto 7)=OpCode_Im and tOpcode2(7 downto 7)=OpCode_Im and idim_flag='0') then
						decodedOpcode <= Decoded_DoubleIm;
						nextPC := pc + 2;
					elsif (tOpcode(7 downto 4)=OpCode_AddSP and tOpcode(3 downto 0)=0 and 
					    tOpcode2(7 downto 4)=OpCode_AddSP and tOpcode2(3 downto 0)=0) then
						decodedOpcode <= Decoded_Lshift2;
						nextPC := pc + 2;
					elsif (tOpcode(7 downto 7)=OpCode_Im) then
						if (idim_flag='1') then
							decodedOpcode<=Decoded_ImShift;
						else
							decodedOpcode<=Decoded_Im;
						end if;
					elsif (tOpcode(7 downto 5)=OpCode_StoreSP) then
						decodedOpcode<=Decoded_StoreSP;
					elsif (tOpcode(7 downto 5)=OpCode_LoadSP) then
						decodedOpcode<=Decoded_LoadSP;
					elsif (tOpcode(7 downto 5)=OpCode_Emulate) then
						if tOpcode(5 downto 0)=OpCode_Eqbranch then
							decodedOpcode <= Decoded_Eqbranch;
						elsif tOpcode(5 downto 0)=OpCode_Neqbranch then
							decodedOpcode <= Decoded_Neqbranch;
						elsif tOpcode(5 downto 0)=OpCode_Eq then
							decodedOpcode <= Decoded_Eq;
						elsif tOpcode(5 downto 0)=OpCode_Neq then
							decodedOpcode <= Decoded_Neq;
						elsif tOpcode(5 downto 0)=OpCode_Lessthan then
							decodedOpcode <= Decoded_Lessthan;
						elsif tOpcode(5 downto 0)=OpCode_Lessthanorequal then
							decodedOpcode <= Decoded_Lessthanorequal;
						elsif tOpcode(5 downto 0)=OpCode_Ulessthan then
							decodedOpcode <= Decoded_Ulessthan;
						elsif tOpcode(5 downto 0)=OpCode_Ulessthanorequal then
							decodedOpcode <= Decoded_Ulessthanorequal;
						elsif tOpcode(5 downto 0)=OpCode_Loadb then
							decodedOpcode <= Decoded_Loadb;
						elsif tOpcode(5 downto 0)=OpCode_Storeb then
							decodedOpcode <= Decoded_Storeb;
						elsif tOpcode(5 downto 0)=OpCode_Mult16x16 then
							decodedOpcode <= Decoded_Mult16x16;
						elsif tOpcode(5 downto 0)=OpCode_Swap then
							decodedOpcode <= Decoded_Swap;
						elsif tOpcode(5 downto 0)=OpCode_Callpcrel then
							decodedOpcode <= Decoded_Callpcrel;
						elsif tOpcode(5 downto 0)=OpCode_Pushspadd then
							decodedOpcode <= Decoded_Pushspadd;
--						elsif tOpcode(5 downto 0)=OpCode_Lshiftright then
--							decodedOpcode <= Decoded_Lshiftright;
--						elsif tOpcode(5 downto 0)=OpCode_Ashiftleft then
--							decodedOpcode <= Decoded_Ashiftleft;
--						elsif tOpcode(5 downto 0)=OpCode_Ashiftright then
--							decodedOpcode <= Decoded_Ashiftright;
						else
							decodedOpcode<=Decoded_Emulate;
						end if;
					elsif (tOpcode(7 downto 4)=OpCode_AddSP) then
						decodedOpcode<=Decoded_AddSP;
					else
						case tOpcode(3 downto 0) is
							when OpCode_Break =>
								decodedOpcode<=Decoded_Break;
							when OpCode_PushPC =>
								decodedOpcode<=Decoded_PushPC;
							when OpCode_PushSP =>
								decodedOpcode<=Decoded_PushSP;
							when OpCode_PopPC =>
								decodedOpcode<=Decoded_PopPC;
							when OpCode_Add =>
								decodedOpcode<=Decoded_Add;
							when OpCode_Or =>
								decodedOpcode<=Decoded_Or;
							when OpCode_And =>
								decodedOpcode<=Decoded_And;
							when OpCode_Load =>
								decodedOpcode<=Decoded_Load;
							when OpCode_Not =>
								decodedOpcode<=Decoded_Not;
							when OpCode_Flip =>
								decodedOpcode<=Decoded_Flip;
							when OpCode_Store =>
								decodedOpcode<=Decoded_Store;
							when OpCode_PopSP =>
								decodedOpcode<=Decoded_PopSP;
							when others =>
								decodedOpcode<=Decoded_Nop;
						end case;
					end if;
					-- Fetch the two next opcodes... :-)
					memAAddr <= nextPC(maxAddrBit downto minAddrBit);
					nextPC:=nextPC+1;
					memBAddr <= nextPC(maxAddrBit downto minAddrBit);
					state <= State_Execute;
				when State_Execute =>
					state <= State_Decode;
					-- at this point:
					-- memBRead contains opcode word
					-- memARead contains top of stack
					pc <= pc + 1;
	
					-- trace
					begin_inst <= '1';
					trace_pc <= pc;
					trace_opcode <= opcode;
					trace_sp <=	sp;
					trace_topOfStack <= memARead;

					-- during the next cycle we'll be reading the next opcode	
					spOffset(4):=not opcode(4);
					spOffset(3 downto 0):=opcode(3 downto 0);
					spOffset2(4):=not opcode2(4);
					spOffset2(3 downto 0):=opcode2(3 downto 0);

					case decodedOpcode is
							
						when Decoded_DoubleIm =>
							memAWriteEnable <= '1';
							sp <= sp - 1;
							memAAddr <= sp-1;
							for i in wordSize-1 downto 14 loop
								memAWrite(i) <= opcode(6);
							end loop;
							memAWrite(13 downto 7) <= opcode(6 downto 0);
							memAWrite(6 downto 0) <= opcode2(6 downto 0);
							memBAddr <= sp;
							memBWrite <= memARead;
							memBWriteEnable <= '1';
							pc <= pc + 2;
						when Decoded_Im =>
							memAWriteEnable <= '1';
							sp <= sp - 1;
							memAAddr <= sp-1;
							for i in wordSize-1 downto 7 loop
								memAWrite(i) <= opcode(6);
							end loop;
							memAWrite(6 downto 0) <= opcode(6 downto 0);
							memBAddr <= sp;
							memBWrite <= memARead;
							memBWriteEnable <= '1';
						when Decoded_ImShift =>
							memAAddr <= sp;
							memAWriteEnable <= '1';
							memAWrite(wordSize-1 downto 7) <= memARead(wordSize-8 downto 0);
							memAWrite(6 downto 0) <= opcode(6 downto 0);
							memBAddr <= sp + 1;
						when Decoded_StoreSP =>
							memAWriteEnable <= '1';
							memAAddr <= sp+spOffset;
							memAWrite <= memARead;
							-- avoid address crashes.
							memBAddr <= sp - 1;
							sp <= sp + 1;
							state <= State_ResyncDecode;
						when Decoded_LoadSP =>
							sp <= sp - 1;
							if (spOffset = 0) then
								-- This is a duplicate instruction.
								memAAddr <= sp-1;
								memAWriteEnable <= '1';
								memAWrite <= memARead;
							else 
								memAAddr <= sp+spOffset;
							end if;
							memBAddr <= sp;
							memBWrite <= memARead;
							memBWriteEnable <= '1';
						when Decoded_Callpcrel =>
							memAWriteEnable <= '1';
							memAAddr <= sp;
							memAWrite <= (others => DontCareValue);
							memAWrite(maxAddrBit downto 0) <= pc + 1;
							memBAddr <= sp+1;
							pc <= pc + memARead(maxAddrBit downto 0);
							state <= State_ResyncDecode;
						when Decoded_Emulate =>
							sp <= sp - 1;
							memAWriteEnable <= '1';
							memAAddr <= sp - 1;
							memAWrite <= (others => DontCareValue);
							memAWrite(maxAddrBit downto 0) <= pc;
							memBAddr <= sp;
							memBWrite <= memARead;
							memBWriteEnable <= '1';
							-- The emulate address is:
							--        98 7654 3210
							-- 0000 00aa aaa0 0000
							pc <= (others => '0');
							pc(9 downto 5) <= opcode(4 downto 0);
							state <= State_ResyncDecode;
						when Decoded_AddSP =>
							if spOffset=0 then
								-- avoid address line crashes...
								-- FIX!!! is this an issue?
								-- oh-well. While we are at it, we've got a faster
								-- shift operation without updating the toolchain.
								memAWriteEnable <= '1';
								memAAddr <= sp;
								memAWrite <= memARead + memARead;
								memBAddr <= sp+1;
							else 
								memAWriteEnable <= '1';
								memAAddr <= sp;
								memAWrite <= memARead;
								memBAddr <= sp+spOffset;
								state <= State_AddSP;
							end if;
						when Decoded_Break =>
							report "Break instruction encountered" severity failure;
							break <= '1';
						when Decoded_PushPC =>
							memAWriteEnable <= '1';
							memAAddr <= sp - 1;
							sp <= sp - 1;
							memAWrite <= (others => DontCareValue);
							memAWrite(maxAddrBit downto 0) <= pc;
							memBAddr <= sp;
							memBWrite <= memARead;
							memBWriteEnable <= '1';
						when Decoded_PushSP =>
							memAWriteEnable <= '1';
							memAAddr <= sp - 1;
							sp <= sp - 1;
							memAWrite <= (others => DontCareValue);
							memAWrite(maxAddrBit downto minAddrBit) <= sp;
							memBAddr <= sp;
							memBWrite <= memARead;
							memBWriteEnable <= '1';
						when Decoded_Pushspadd =>
							memAWriteEnable <= '1';
							memAAddr <= sp;
							memAWrite <= (others => DontCareValue);
							pushspaddTemp := memARead(maxAddrBit-minAddrBit downto 0);
							memAWrite(maxAddrBit downto minAddrBit) <= sp+pushspaddTemp;
							memBAddr <= sp+1;
						when Decoded_PopPC =>
							memAAddr <= sp;
							pc <= memARead(maxAddrBit downto 0);
							sp <= sp + 1;
							state <= State_ResyncDecode;
						when Decoded_AddIm =>
							memAWriteEnable <= '1';
							memAAddr <= sp;
							tempVal(wordSize-1 downto 7) := (others => tOpcode(6));
							tempVal(6 downto 0) := tOpcode(6 downto 0);
							memAWrite <= memARead + tempVal;
							memBAddr <= sp + 1;
							pc <= pc + 2;
						when Decoded_Add =>
							memAWriteEnable <= '1';
							memAWrite <= memARead + memBRead;
							memAAddr <= sp + 1;
							memBAddr <= sp + 2;
							sp <= sp + 1;
						when Decoded_Or =>
							sp <= sp + 1;
							memAWriteEnable <= '1';
							memAWrite <= memARead or memBRead;
							memAWriteEnable <= '1';
							memAAddr <= sp + 1;
							memBAddr <= sp + 2;
						when Decoded_And =>
							sp <= sp + 1;
							memAWriteEnable <= '1';
							memAWrite <= memARead and memBRead;
							memAWriteEnable <= '1';
							memAAddr <= sp + 1;
							memBAddr <= sp + 2;
						when Decoded_Load =>
							if (memARead(ioBit)='1') then
								io_addr <= memARead(maxAddrBit downto minAddrBit);
								io_readEnable <= '1';
								state <= State_ReadIO;
							else 
								memAAddr <= memARead(maxAddrBit downto minAddrBit);
								memBAddr <= sp + 1;
							end if;
						when Decoded_Swap =>
							memAAddr <= sp;
							memAWriteEnable <= '1';
							memAWrite(wordSize/2-1 downto 0) <= memARead(wordSize-1 downto wordSize/2);
							memAWrite(wordSize-1 downto wordSize/2) <= memARead(wordSize/2-1 downto 0);
							memBAddr <= sp + 1;
						when Decoded_Not =>
							memAAddr <= sp;
							memAWriteEnable <= '1';
							memAWrite <= not memARead;
							memBAddr <= sp + 1;
						when Decoded_Flip =>
							memAAddr <= sp;
							memAWriteEnable <= '1';
							for i in 0 to wordSize-1 loop
								memAWrite(i) <= memARead(wordSize-1-i);
				  			end loop;
							memBAddr <= sp + 1;
						when Decoded_Lshift2 =>
							memAAddr <= sp;
							memAWriteEnable <= '1';
							memAWrite(1 downto 0) <= (others => '0');
							memAWrite(wordSize-1 downto 2) <= memARead(wordSize-1-2 downto 0);
							memBAddr <= sp + 1;
							pc <= pc + 2;
						when Decoded_Store =>
							sp <= sp + 2;
							if (memARead(ioBit)='1') then
								io_writeEnable <= '1';
								io_addr <= memARead(maxAddrBit downto minAddrBit);
								io_write <= memBRead(7 downto 0);
								state <= State_WriteIO;
							else
								memAWriteEnable <= '1';
								memAAddr <= memARead(maxAddrBit downto minAddrBit);
								memAWrite <= memBRead;
								state <= State_ResyncDecode;
							end if;
						when Decoded_PopSP =>
							sp <= memARead(maxAddrBit downto minAddrBit);
							state <= State_ResyncDecode;
	                    when Decoded_Ashiftleft =>
	                    	memAWrite(wordSize-1 downto conv_integer(memARead(wordPower-1 downto 0))) <=
	                        memBRead(wordSize-conv_integer(memARead(wordPower-1 downto 0))-1 downto 0);      
	                        if memARead(wordPower-1 downto 0)/=0 then
	                        	memAWrite(conv_integer(memARead(wordPower-1 downto 0))-1 downto 0) <= (others => '0');
	                        end if;
	                        memAWriteEnable <= '1';
	                        memAAddr <= sp + 1;
	                        memBAddr <= sp + 2;
	                        sp <= sp + 1;
                      when Decoded_Ashiftright | Decoded_Lshiftright =>
                            memAWrite(wordSize-1-conv_integer(memARead(wordPower-1 downto 0)) downto 0) <=
                            memBRead(wordSize-1 downto conv_integer(memARead(wordPower-1 downto 0)));
                            if memARead(wordPower-1 downto 0)/=0 then
                            	if decodedOpcode=Decoded_Ashiftright and memBRead(wordSize-1)='1' then
	    	                        memAWrite(wordSize-1 downto wordSize-conv_integer(memARead(wordPower-1 downto 0))-1) <= (others => '1');
                            	else
                	                memAWrite(wordSize-1 downto wordSize-conv_integer(memARead(wordPower-1 downto 0))-1) <= (others => '0');
                            	end if;
                            end if;
	                        memAWriteEnable <= '1';
                            memAAddr <= sp + 1;
                            memBAddr <= sp + 2;
	                        sp <= sp + 1;
	                    when Decoded_Eqbranch =>
	                    	sp <= sp + 2;
	                    	if (memBRead=0) then
	                    		pc <= memARead(maxAddrBit downto 0) + pc;
	                    	end if;
	                    	state <= State_ResyncDecode;
	                    when Decoded_Neqbranch =>
	                    	sp <= sp + 2;
	                    	if (memBRead/=0) then
	                    		pc <= memARead(maxAddrBit downto 0) + pc;
	                    	end if;
	                    	state <= State_ResyncDecode;
	                    when Decoded_Eq =>
	                    	sp <= sp + 1;
                    		memAWrite <= (others => '0');
	                    	if (memARead=memBRead) then
	                    		memAWrite(0) <= '1';
	                    	end if;
							memAAddr <= sp + 1;
							memAWriteEnable <= '1';
							memBAddr <= sp + 2;
	                    when Decoded_Neq =>
	                    	sp <= sp + 1;
                    		memAWrite <= (others => '0');
	                    	if (memARead/=memBRead) then
	                    		memAWrite(0) <= '1';
	                    	end if;
							memAAddr <= sp + 1;
							memAWriteEnable <= '1';
							memBAddr <= sp + 2;
	                    when Decoded_Ulessthan =>
	                    	sp <= sp + 1;
                    		memAWrite <= (others => '0');
	                    	if (memARead<memBRead) then
	                    		memAWrite(0) <= '1';
	                    	end if;
							memAAddr <= sp + 1;
							memAWriteEnable <= '1';
							memBAddr <= sp + 2;
	                    when Decoded_Ulessthanorequal =>
	                    	sp <= sp + 1;
                    		memAWrite <= (others => '0');
	                    	if (memARead<=memBRead) then
	                    		memAWrite(0) <= '1';
	                    	end if;
							memAAddr <= sp + 1;
							memAWriteEnable <= '1';
							memBAddr <= sp + 2;
	                    when Decoded_Lessthan =>
	                    	sp <= sp + 1;
                    		memAWrite <= (others => '0');
                    		compareA := signed(memARead);
                    		compareB := signed(memBRead);
	                    	if (compareA<compareB) then
	                    		memAWrite(0) <= '1';
	                    	end if;
							memAAddr <= sp + 1;
							memAWriteEnable <= '1';
							memBAddr <= sp + 2;
	                    when Decoded_Lessthanorequal =>
	                    	sp <= sp + 1;
                    		memAWrite <= (others => '0');
                    		compareA := signed(memARead);
                    		compareB := signed(memBRead);
	                    	if (compareA<=compareB) then
	                    		memAWrite(0) <= '1';
	                    	end if;
							memAAddr <= sp + 1;
							memAWriteEnable <= '1';
							memBAddr <= sp + 2;
	                    when Decoded_Loadb =>
	                    	byteSelect <= memARead(minAddrBit-1 downto 0);
							memAAddr <= memARead(maxAddrBit downto minAddrBit);
							state <= State_LoadByte1;
	                    when Decoded_Storeb =>
	                    	sp <= sp + 2;
	                    	byteSelect <= memARead(minAddrBit-1 downto 0);
	                    	storeByte <= memBRead(7 downto 0);
							memAAddr <= memARead(maxAddrBit downto minAddrBit);
							memBAddr <= sp;
							state <= State_StoreByte1;
						when Decoded_Mult16x16 =>
							mult1 <= memARead(wordSize/2-1 downto 0);
							mult2 <= memBRead(wordSize/2-1 downto 0);
							sp <= sp + 1;
							state <= State_Mult1;
						when others =>
							-- nop. Here we persist whatever was loaded into
							-- memARead
							memAAddr <= sp;
							memAWriteEnable <= '1';
							memAWrite <= memARead;
							memBAddr <= sp + 1;
							
					end case;
				when State_ReadIO =>
					state <= State_ReadIODone;
				when State_ReadIODone =>
					if (io_busy = '0') then
						state <= State_ResyncDecode;
						memAWriteEnable <= '1';
						memAWrite <= (others => '0');
						memAWrite(7 downto 0) <= io_read;
						memAAddr <= sp;
					end if;
				when State_WriteIO =>
					state <= State_WriteIODone;
				when State_WriteIODone =>
					if (io_busy = '0') then
						state <= State_ResyncDecode;
					end if;
				when State_ResyncDecode =>
					memAAddr <= pc(maxAddrBit downto minAddrBit);
					nextPC:=pc+1;
					memBAddr <= nextPC(maxAddrBit downto minAddrBit);
					state <= State_ResyncStack;
				when State_ResyncStack =>
					memAAddr <= sp;
					memBAddr <= sp+1;
					state <= State_Decode;
				when State_AddSP =>
					memAAddr <= pc(maxAddrBit downto minAddrBit);
					nextPC:=pc+1;
					memBAddr <= nextPC(maxAddrBit downto minAddrBit);
					state <= State_Add;
				when State_Add =>
					memAWriteEnable <= '1';
					memAWrite <= memARead + memBRead;
					memAAddr <= sp;
					memBAddr <= sp + 1;
					state <= State_Decode;
				when State_LoadByte1 =>
					memAAddr <= pc(maxAddrBit downto minAddrBit);
					nextPC:=pc+1;
					memBAddr <= nextPC(maxAddrBit downto minAddrBit);
					state <= State_LoadByte2;
				when State_LoadByte2 =>
					memAWriteEnable <= '1';
					memAAddr <= sp;
					memAWrite <= (others => '0');
					case byteSelect is
						when "00" 	=> memAWrite(7 downto 0) <= memARead(31 downto 24);
						when "01" 	=> memAWrite(7 downto 0) <= memARead(23 downto 16);
						when "10" 	=> memAWrite(7 downto 0) <= memARead(15 downto 8);
						when others	=> memAWrite(7 downto 0) <= memARead(7 downto 0);
					end case;
					memBAddr <= sp + 1;
					state <= State_Decode;
				when State_StoreByte1 =>
					state <= State_StoreByte2;
				when State_StoreByte2 =>
					memAWriteEnable <= '1';
					memAAddr <= memBRead(maxAddrBit downto minAddrBit);
					memAWrite <= memARead;
					case byteSelect is
						when "00" 	=> memAWrite(31 downto 24) <= storeByte;
						when "01" 	=> memAWrite(23 downto 16) <= storeByte;
						when "10" 	=> memAWrite(15 downto 8) <= storeByte;
						when others	=> memAWrite(7 downto 0) <= storeByte;
					end case;
					state <= State_ResyncDecode;
				when State_Mult1 =>
					memAAddr <= pc(maxAddrBit downto minAddrBit);
					nextPC:=pc+1;
					memBAddr <= nextPC(maxAddrBit downto minAddrBit);
					state <= State_Mult2;
				when State_Mult2 =>
					memAWriteEnable <= '1';
					memAWrite <= multResult;
					memAAddr <= sp;
					memBAddr <= sp + 1;
					state <= State_Decode;
					
				when others =>
					null;
			end case;				
		end if;
	end process;



end behave;
