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


signal	busy 				: std_logic;

signal	begin_inst			: std_logic;



signal trace_opcode		: std_logic_vector(7 downto 0);
signal	trace_pc				: std_logic_vector(maxAddrBit downto 0);
signal	trace_sp				: std_logic_vector(maxAddrBit downto minAddrBit);
signal	trace_topOfStack				: std_logic_vector(wordSize-1 downto 0);
signal	trace_topOfStackB				: std_logic_vector(wordSize-1 downto 0);

type DecodedOpcodeType is 
(
Decoded_Stall				,
Decoded_Nop				,
Decoded_Im					,
Decoded_ImShift			,
Decoded_LoadSP				,
Decoded_StoreSP			,
Decoded_AddSP				,
Decoded_Emulate			,
Decoded_Break				,
Decoded_PushPC				,
Decoded_PushSP				,
Decoded_PopPC				,
Decoded_Add				,
Decoded_Or					,
Decoded_And				,
Decoded_Load				,
Decoded_Not				,
Decoded_Flip				,
Decoded_Store				,
Decoded_Storeb				,
Decoded_PopSP				,
Decoded_Ashiftleft 		,
Decoded_Ashiftright		,
Decoded_Lshiftright		,
Decoded_Eqbranch			,
Decoded_Neqbranch			,
Decoded_Eq					,
Decoded_Neq				,
Decoded_Loadb				,
Decoded_Lessthan			,
Decoded_Lessthanorequal	,
Decoded_Ulessthan			,
Decoded_Ulessthanorequal	,
Decoded_Duplicate			,
Decoded_Duplicate2			,
Decoded_Duplicate3			,
Decoded_MoveDown,			
Decoded_MoveDown2,			
Decoded_MoveDown3,
Decoded_Pushspadd,
Decoded_Callpcrel,
Decoded_Sub
); 


signal decode_pc : std_logic_vector(maxAddrBit downto 0);
signal decode_fetchedPC : std_logic_vector(maxAddrBit downto 0);
signal decode_fetched : std_logic;
signal decode_opcode : std_logic_vector(OpCode_Size-1 downto 0);
signal decode_opcodeWord : std_logic_vector(wordSize-1 downto 0);
signal decode_starved : std_logic;
signal decode_wordStarved : std_logic;
signal decode_willBeStarved : std_logic;
signal decode_idim_flag : std_logic;

signal execute1_stall : std_logic;
signal execute1_fetched : std_logic;
signal execute1_decodedOpcode : DecodedOpcodeType;
signal execute1_fetchedPC : std_logic_vector(maxAddrBit downto 0);
signal execute1_sp : std_logic_vector(maxAddrBit downto minAddrBit);
signal execute1_opcode : std_logic_vector(opCode_Size-1 downto 0);
signal execute1_spOffset : std_logic_vector(4 downto 0);
signal execute1_fetchPC : std_logic_vector(maxAddrBit downto 0);
signal execute1_push1 : std_logic;
signal execute1_push2 : std_logic;
signal execute1_pop1 : std_logic;
signal execute1_pop2 : std_logic;
signal execute1_antialias : std_logic;
signal execute1_savedTopOfStack : std_logic_vector(wordSize-1 downto 0);


signal load_decodedOpcode : DecodedOpcodeType;
signal load_opcode : std_logic_vector(opCode_Size-1 downto 0);
signal load_spOffset : std_logic_vector(4 downto 0);
signal load_stall : std_logic;
signal load_willBeStalled : std_logic;

signal execute2_opcode : std_logic_vector(opCode_Size-1 downto 0);
signal execute2_topOfStack : std_logic_vector(wordSize-1 downto 0);
signal execute2_addResult : std_logic_vector(wordSize-1 downto 0);
signal execute2_topOfStackB : std_logic_vector(wordSize-1 downto 0);
signal execute2_pc : std_logic_vector(maxAddrBit downto 0);
signal execute2_sp : std_logic_vector(maxAddrBit downto minAddrBit);
signal execute2_loading : std_logic;
signal execute2_loadByte : std_logic;
signal execute2_storeByte : std_logic;
signal execute2_loadingDone : std_logic;
signal execute2_decodedOpcode : DecodedOpcodeType;
signal execute2_spOffset : std_logic_vector(4 downto 0);
signal execute2_persistTopOfStack : std_logic;
signal execute2_persistTopOfStackB : std_logic;
signal execute2_resync : std_logic;
signal execute2_resync2 : std_logic;
signal execute2_resync3 : std_logic;
signal execute2_resync4 : std_logic;
signal execute2_resync5 : std_logic;
signal execute2_resync6 : std_logic;
signal execute2_resync7 : std_logic;
signal execute2_resync8 : std_logic;
signal execute2_resync9 : std_logic;
signal execute2_resync10 : std_logic;
			

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
		memB => trace_topOfStackB,
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

	opcodeControl:
	process(clk, areset)
		variable compareA : signed(wordSize-1 downto 0);
		variable compareB : signed(wordSize-1 downto 0);
		variable execute1_doFetch : boolean;
	begin
		if areset = '1' then
			break <= '0';
			begin_inst <= '0';
			memAAddr <= (others => '0');
			memBAddr <= (others => '0');
			memAWriteEnable <= '0';
			memBWriteEnable <= '0';
			memAWrite <= (others => '0');
			memBWrite <= (others => '0');
			
			memBAddr <= (others => '0');
			memBWrite <= (others => '0');


			io_writeEnable <= '0';
			io_readEnable <= '0';
			io_addr <= (others => '0');
			io_write <= (others => '0');
		
			-- stage 1. Don't care since this is driven by stage2
			decode_pc <= (others => '0');
			decode_fetched <= '0';
			decode_starved <= '0';
			decode_opcode <= (others => '0');
			decode_opcodeWord  <= (others => '0');

			-- stage 2.
			execute1_antialias <= '0';
			execute1_fetchPC <= (others => '0');
			execute1_fetched <= '0';
			execute1_decodedOpcode <= Decoded_Stall; 
			execute1_sp <= (2 => '0', others => '1'); 
			execute1_push1 <= '0';
			execute1_push2 <= '0';
			execute1_pop1 <= '0';
			execute1_pop2 <= '0';
			execute1_stall <= '1';

			-- stage 3
			load_decodedOpcode <= Decoded_Stall;
			load_stall <= '1';
			load_willBeStalled <= '1';

			-- stage 4
			decode_idim_flag <= '0';
			execute2_pc <= (others => '0');
			execute2_sp <= (2 => '0', others => '1'); 
			execute2_loading <= '0';
			execute2_loadByte <= '0';
			execute2_storeByte <= '0';
			execute2_loadingDone <= '0';
			execute2_decodedOpcode <= Decoded_Stall;
			execute2_resync <= '1';
			execute2_resync2 <= '0';
			execute2_resync3 <= '0';
			execute2_resync4 <= '0';
			execute2_resync5 <= '0';
			execute2_resync6 <= '0';
			execute2_resync7 <= '0';
			execute2_resync8 <= '0';
			execute2_resync9 <= '0';
			execute2_resync10 <= '0';
			execute2_persistTopOfStack <= '0';
			execute2_persistTopOfStackB <= '0';

			-- stage 5 
			memBWriteEnable <= '0';
			
			
		elsif (clk'event and clk = '1') then
			memAWriteEnable <= '0';
			memBWriteEnable <= '0';
			io_writeEnable <= '0';
			io_readEnable <= '0';
			begin_inst <= '0';

			-- stage0: fetch
			decode_willBeStarved <= '0';
			if (decode_fetched='1') then
				-- resync #4
				decode_opcodeWord <= memARead;
				decode_pc <= decode_fetchedPC;
			elsif (decode_pc(minAddrBit-1 downto 0)=b"11") then
				decode_willBeStarved <= '1';
			else
				-- we can continue decoding.
				decode_pc <= decode_pc + 1;
			end if;
			
			-- stage 0b: move to byte..
			-- resync #5
			decode_starved <= decode_willBeStarved;
			case decode_pc(minAddrBit-1 downto 0) is
				when "00" 	=> decode_opcode <= decode_opcodeWord(31 downto 24);
				when "01" 	=> decode_opcode <= decode_opcodeWord(23 downto 16);
				when "10" 	=> decode_opcode <= decode_opcodeWord(15 downto 8);
				when others	=> decode_opcode <= decode_opcodeWord(7 downto 0);
			end case;
			
			-- stage1: decode 1
			execute1_opcode <= decode_opcode;

			execute1_spOffset(4)<=not decode_opcode(4);
			execute1_spOffset(3 downto 0)<=decode_opcode(3 downto 0);

			execute1_decodedOpcode<=Decoded_Break;

			decode_idim_flag <= '0';

			-- resync #6
			-- resync #1
			if (decode_starved = '1') then
				execute1_decodedOpcode<=Decoded_Stall;
				decode_idim_flag <= decode_idim_flag;
			elsif (decode_opcode(7 downto 7)=OpCode_Im) then
				decode_idim_flag <= '1';
				if (decode_idim_flag = '0') then
					execute1_decodedOpcode<=Decoded_Im;
				else
					execute1_decodedOpcode<=Decoded_ImShift;
				end if;
			elsif (decode_opcode(7 downto 5)=OpCode_StoreSP) then
				if (decode_opcode(4 downto 0)=b"10001") then
					execute1_decodedOpcode<=Decoded_MoveDown;
				elsif (decode_opcode(4 downto 0)=b"10010") then
					execute1_decodedOpcode<=Decoded_MoveDown2;
--				elsif (decode_opcode(4 downto 0)=b"10011") then
--					execute1_decodedOpcode<=Decoded_MoveDown3;
				else
					execute1_decodedOpcode<=Decoded_StoreSP;
				end if;
			elsif (decode_opcode(7 downto 5)=OpCode_LoadSP) then
				if (decode_opcode(4 downto 0)=b"10000") then
					execute1_decodedOpcode<=Decoded_Duplicate;
				elsif (decode_opcode(4 downto 0)=b"10001") then
					execute1_decodedOpcode<=Decoded_Duplicate2;
				elsif (decode_opcode(4 downto 0)=b"10010") then
					execute1_decodedOpcode<=Decoded_Duplicate3;
				else
					execute1_decodedOpcode<=Decoded_LoadSP;
				end if;
			elsif (decode_opcode(7 downto 5)=OpCode_Emulate) then
				execute1_decodedOpcode<=Decoded_Emulate;
				if decode_opcode(5 downto 0)=OpCode_Neqbranch then
					execute1_decodedOpcode <= Decoded_Neqbranch;
				elsif decode_opcode(5 downto 0)=OpCode_Eq then
					execute1_decodedOpcode <= Decoded_Eq;
				elsif decode_opcode(5 downto 0)=OpCode_Lessthan then
					execute1_decodedOpcode <= Decoded_Lessthan;
				elsif decode_opcode(5 downto 0)=OpCode_Ulessthan then
					execute1_decodedOpcode <= Decoded_Ulessthan;
				elsif decode_opcode(5 downto 0)=OpCode_Loadb then
					execute1_decodedOpcode <= Decoded_Loadb;
				elsif decode_opcode(5 downto 0)=OpCode_Storeb then
					execute1_decodedOpcode <= Decoded_Storeb;
				elsif decode_opcode(5 downto 0)=OpCode_Pushspadd then
					execute1_decodedOpcode <= Decoded_Pushspadd;
				elsif decode_opcode(5 downto 0)=OpCode_Callpcrel then
					execute1_decodedOpcode <= Decoded_Callpcrel;
				elsif decode_opcode(5 downto 0)=OpCode_Sub then
					execute1_decodedOpcode <= Decoded_Sub;
				end if;
			elsif (decode_opcode(7 downto 4)=OpCode_AddSP) then
				if (decode_opcode(3 downto 0) = 0) then
					execute1_decodedOpcode<=Decoded_Ashiftleft;
				elsif (decode_opcode(3 downto 0) = 1) then
--					execute1_decodedOpcode<=Decoded_AddSP;
				elsif (decode_opcode(3 downto 0) = 2) then
--					execute1_decodedOpcode<=Decoded_AddSP;
				else
					execute1_decodedOpcode<=Decoded_AddSP;
				end if;
			else
				case decode_opcode(3 downto 0) is
					when OpCode_Nop =>
						execute1_decodedOpcode<=Decoded_Nop;
					when OpCode_PushSP =>
						execute1_decodedOpcode<=Decoded_PushSP;
					when OpCode_PopPC =>
						execute1_decodedOpcode<=Decoded_PopPC;
					when OpCode_Add =>
						execute1_decodedOpcode<=Decoded_Add;
					when OpCode_Or =>
						execute1_decodedOpcode<=Decoded_Or;
					when OpCode_And =>
						execute1_decodedOpcode<=Decoded_And;
					when OpCode_Load =>
						execute1_decodedOpcode<=Decoded_Load;
					when OpCode_Not =>
						execute1_decodedOpcode<=Decoded_Not;
					when OpCode_Flip =>
						execute1_decodedOpcode<=Decoded_Flip;
					when OpCode_Store =>
						execute1_decodedOpcode<=Decoded_Store;
					when OpCode_PopSP =>
						execute1_decodedOpcode<=Decoded_PopSP;
					when others =>
						execute1_decodedOpcode<=Decoded_Break;
				end case;
			end if;


			-- stage 2: execute 1 - load stage.
			-- 
			-- the address must be known without using the value on top of the stack...
			-- resync #3
			execute1_fetched <= '0';
			decode_fetched <= execute1_fetched; -- the value in memAAddr will be valid for 1 cycle only
			decode_fetchedPC <= execute1_fetchedPC;
			
			if (execute1_fetchPC(1 downto 0)/=b"00") then
				execute1_fetchPC <= execute1_fetchPC+1;
			end if;

			execute1_push1 <= '0';
			execute1_push2 <= execute1_push1;
			execute1_pop1 <= '0';
			execute1_pop2 <= execute1_pop1;
			
			if ((execute1_push1 and execute1_push2)='1') then
				memAWrite <= execute2_topOfStack;
			else
				memAWrite <= execute2_topOfStackB;
			end if;
			
			-- resync #7
			case execute1_decodedOpcode is
				when Decoded_Neqbranch | Decoded_MoveDown3 | Decoded_Load | Decoded_Loadb | Decoded_Store | Decoded_Storeb | Decoded_Emulate | Decoded_PopSP | Decoded_PopPC| Decoded_Callpcrel =>
					execute1_stall <= '1';
				when others =>
					-- nothing...
			end case;
			
			execute1_antialias <= load_stall;
			execute1_doFetch := false;
			case execute1_decodedOpcode is
				when Decoded_PushSP | Decoded_Emulate =>
					execute1_sp <= execute1_sp - 1;
					execute1_push1 <= '1';
					execute1_doFetch := true;
				when Decoded_Duplicate3 =>
					memAWriteEnable <= ((execute1_push1 and execute1_push2) or
					                   (execute1_push1 and not execute1_pop2) or
					                   (execute1_push2 and not execute1_pop1)) and 
					                   (not execute1_antialias and not execute1_stall);
					memAAddr <= execute1_sp + 2;
					execute1_sp <= execute1_sp - 1;
					execute1_push1 <= '1';
				when Decoded_Im | Decoded_Duplicate | Decoded_Duplicate2 =>
					execute1_sp <= execute1_sp - 1;
					execute1_push1 <= '1';
					execute1_doFetch := true;
				when Decoded_LoadSP =>
					memAAddr <= execute1_sp+execute1_spOffset;
					execute1_sp <= execute1_sp - 1;
					execute1_push1 <= '1';
				when Decoded_AddSP =>
					memAAddr <= execute1_sp+execute1_spOffset;
				when Decoded_MoveDown2 =>
					execute1_sp <= execute1_sp + 1;
					execute1_pop1 <= '1';
					execute1_doFetch := true;
				when Decoded_Ulessthan | Decoded_Lessthan | Decoded_Eq | Decoded_Neqbranch | Decoded_MoveDown3 | Decoded_MoveDown | Decoded_Add | Decoded_Sub | Decoded_Or | Decoded_And | Decoded_PopPC | Decoded_StoreSP =>
					-- be afraid :-)
					memAWriteEnable <= ((execute1_push1 and execute1_push2) or
					                   (execute1_push1 and not execute1_pop2) or
					                   (execute1_push2 and not execute1_pop1)) and 
					                   (not execute1_antialias and not execute1_stall);
					memAAddr <= execute1_sp + 2;
					execute1_sp <= execute1_sp + 1;
					execute1_pop1 <= '1';
				when others =>
					execute1_doFetch := true;
			end case;

			if execute1_doFetch then
				-- resync #2
				-- some instruction that does not change the stack pointer
				-- and does not need use a memory operand.
				-- We can fetch the next word to be decoded to avoid stalls
				execute1_fetchPC <= execute1_fetchPC+1;
				memAAddr <= execute1_fetchPC(maxAddrBit downto minAddrBit);
				execute1_fetchedPC <= execute1_fetchPC;
				execute1_fetched <= '1';
			end if;
			
			
			-- stage 3: fetching memory takes 1 cycle
			-- here we also verify that we've fetched & decoded the right
			-- opcode.
			-- resync #8
			load_decodedOpcode <= execute1_decodedOpcode;
			load_opcode <= execute1_opcode;
			load_spOffset <= execute1_spOffset;
			load_stall <= execute1_stall;
			-- resync #9
			if (load_stall = '1') then
				execute2_decodedOpcode <= Decoded_Stall;
			else
				execute2_decodedOpcode <= load_decodedOpcode;
			end if;
			execute2_opcode <= load_opcode;
			execute2_spOffset <= load_spOffset;
			
			-- stage 4: execute 2 - we now have both operands. This is the
			-- main execute stage...
			begin_inst <= '1';
			trace_pc <= execute2_pc;
			trace_opcode <= execute2_opcode;
			trace_sp <=	execute2_sp;
			trace_topOfStack <=	execute2_topOfStack;
			trace_topOfStackB <=	execute2_topOfStackB;
			
			execute2_pc <= execute2_pc + 1;
			execute2_loading <= '0';
			memBWriteEnable <= '0';
			
			case execute2_decodedOpcode is
				when Decoded_PopSP =>
					execute2_sp <= execute2_topOfStack(maxAddrBit downto minAddrBit);

					memBWriteEnable <= '1';
					memBAddr <= execute2_sp + 1;
					memBWrite <= execute2_topOfStackB;
					execute2_resync <= '1';
				when Decoded_Callpcrel =>
					execute2_topOfStack <= (others => DontCareValue);
					execute2_topOfStack(maxAddrBit downto 0) <= execute2_pc + 1;
					execute2_pc <= execute2_pc + execute2_topOfStack(maxAddrBit downto 0);
					execute2_persistTopOfStack <= '1';
				when Decoded_PopPC =>
					execute2_pc <= execute2_topOfStack(maxAddrBit downto 0);
					execute2_sp <= execute2_sp + 1;

					memBWriteEnable <= '1';
					memBAddr <= execute2_sp + 1;
					memBWrite <= execute2_topOfStackB;
					execute2_resync <= '1';
				when Decoded_Emulate =>
					execute2_sp <= execute2_sp - 1;
					
					execute2_topOfStack <= (others => DontCareValue);
					execute2_topOfStack(maxAddrBit downto 0) <= execute2_pc + 1;
					execute2_topOfStackB <= execute2_topOfStack;
					
					memBWriteEnable <= '1';
					memBAddr <= execute2_sp+1;
					memBWrite <= execute2_topOfStackB;
					-- The emulate address is:
					--        98 7654 3210
					-- 0000 00aa aaa0 0000
					execute2_pc <= (others => '0');
					execute2_pc(9 downto 5) <= execute2_opcode(4 downto 0);
					execute2_persistTopOfStack <= '1';
				when Decoded_Im =>
					execute2_sp <= execute2_sp - 1;
					for i in wordSize-1 downto 7 loop
						execute2_topOfStack(i) <= execute2_opcode(6);
					end loop;
					execute2_topOfStack(6 downto 0) <= execute2_opcode(6 downto 0);
	
					execute2_topOfStackB <= execute2_topOfStack;
					memBWriteEnable <= '1';
					memBAddr <= execute2_sp + 1;
					memBWrite <= execute2_topOfStackB;
				when Decoded_ImShift =>
					execute2_topOfStack(wordSize-1 downto 7) <= execute2_topOfStack(wordSize-8 downto 0);
					execute2_topOfStack(6 downto 0) <= execute2_opcode(6 downto 0);
				when Decoded_LoadSP =>
					execute2_sp <= execute2_sp - 1;
					execute2_topOfStack <= memARead;
					execute2_topOfStackB <= execute2_topOfStack;
					memBWriteEnable <= '1';
					memBAddr <= execute2_sp + 1;
					memBWrite <= execute2_topOfStackB;
				when Decoded_Break =>
					report "Break instruction encountered" severity failure;
					break <= '1';
				when Decoded_PushSP =>
					execute2_topOfStack <= (others => DontCareValue);
					execute2_topOfStack(maxAddrBit downto minAddrBit) <= execute2_sp;

					execute2_sp <= execute2_sp - 1;
					execute2_topOfStackB <= execute2_topOfStack;
					memBWriteEnable <= '1';
					memBAddr <= execute2_sp + 1;
					memBWrite <= execute2_topOfStackB;
				when Decoded_Add =>
					execute2_sp <= execute2_sp + 1;
					execute2_topOfStack <= execute2_topOfStackB + execute2_topOfStack;
					execute2_topOfStackB <= memARead;
				when Decoded_Sub =>
					execute2_sp <= execute2_sp + 1;
					execute2_topOfStack <= execute2_topOfStackB - execute2_topOfStack;
					execute2_topOfStackB <= memARead;
				when Decoded_AddSP =>
					execute2_topOfStack <= execute2_topOfStack + memARead;
				when Decoded_Or =>
					execute2_sp <= execute2_sp + 1;
					execute2_topOfStack <= execute2_topOfStackB or execute2_topOfStack;
					execute2_topOfStackB <= memARead;
				when Decoded_And =>
					execute2_sp <= execute2_sp + 1;
					execute2_topOfStack <= execute2_topOfStackB and execute2_topOfStack;
					execute2_topOfStackB <= memARead;
				when Decoded_Load | Decoded_Loadb | Decoded_Storeb  =>
					if (execute2_topOfStack(ioBit)='1') then
						io_addr <= execute2_topOfStack(maxAddrBit downto minAddrBit);
						io_readEnable <= '1';
					else
						memAAddr <= execute2_topOfStack(maxAddrBit downto minAddrBit);
						execute1_fetched <= '0';
					end if;
					if (execute2_decodedOpcode = Decoded_Loadb) then
						execute2_loadByte <= '1';
					else
						execute2_loadByte <= '0';
					end if;
					if (execute2_decodedOpcode = Decoded_Storeb) then
						execute2_storeByte <= '1';
					else
						execute2_storebyte <= '0';
					end if;
					execute2_loading <= '1';
				when Decoded_Ashiftleft =>
					execute2_topOfStack(wordSize-1 downto 1) <= execute2_topOfStack(wordSize-2 downto 0);
					execute2_topOfStack(0) <= '0'; 
				when Decoded_MoveDown =>
					execute2_sp <= execute2_sp + 1;
					execute2_topOfStackB <= memARead;
				when Decoded_MoveDown2 =>
					execute2_sp <= execute2_sp + 1;
					execute2_topOfStack <= execute2_topOfStackB;
					execute2_topOfStackB <= execute2_topOfStack;
				when Decoded_MoveDown3 =>
					execute2_sp <= execute2_sp + 1;
					memBWriteEnable <= '1';
					memBAddr <= execute2_sp+execute2_spOffset;
					memBWrite <= execute2_topOfStack;

					execute2_topOfStack <= execute2_topOfStackB;
					execute2_topOfStackB <= memARead;
					execute2_persistTopOfStack <= '1';
				when Decoded_Duplicate =>
					execute2_topOfStackB <= execute2_topOfStack;
					execute2_sp <= execute2_sp - 1;
					memBWriteEnable <= '1';
					memBAddr <= execute2_sp + 1;
					memBWrite <= execute2_topOfStackB;
				when Decoded_Duplicate2 =>
					execute2_topOfStack <= execute2_topOfStackB;
					execute2_topOfStackB <= execute2_topOfStack;
					execute2_sp <= execute2_sp - 1;
					memBWriteEnable <= '1';
					memBAddr <= execute2_sp + 1;
					memBWrite <= execute2_topOfStackB;
				when Decoded_Duplicate3 =>
					execute2_topOfStack <= memARead;
					execute2_topOfStackB <= execute2_topOfStack;
					execute2_sp <= execute2_sp - 1;
					memBWriteEnable <= '1';
					memBAddr <= execute2_sp + 1;
					memBWrite <= execute2_topOfStackB;
				when Decoded_Pushspadd =>
					execute2_topOfStack <= (others => DontCareValue);
					execute2_topOfStack(maxAddrBit downto minAddrBit) <= execute2_sp + execute2_topOfStack(maxAddrBit-minAddrBit downto 0);
				when Decoded_Not =>
					execute2_topOfStack <= not execute2_topOfStack;
				when Decoded_Flip =>
					for i in 0 to wordSize-1 loop
						execute2_topOfStack(i) <= execute2_topOfStack(wordSize-1-i);
		  			end loop;
				when Decoded_Store =>
					execute2_sp <= execute2_sp + 2;
					if (execute2_topOfStack(ioBit)='0') then
						memBAddr <= execute2_topOfStack(maxAddrBit downto minAddrBit);
						memBWrite <= execute2_topOfStackB;
						memBWriteEnable <= '1';
					else
						io_addr <= execute2_topOfStack(maxAddrBit downto minAddrBit);
						io_write <= execute2_topOfStackB(7 downto 0);
						io_writeEnable <= '1';
					end if;
					execute2_resync <= '1';
				when Decoded_StoreSP =>
					execute2_sp <= execute2_sp + 1;
					memBWriteEnable <= '1';
					memBAddr <= execute2_sp+execute2_spOffset;
					memBWrite <= execute2_topOfStack;

					execute2_topOfStack <= execute2_topOfStackB;
					execute2_topOfStackB <= memARead;
                when Decoded_Neqbranch =>
                	execute2_sp <= execute2_sp + 2;
                	if (execute2_topOfStackB/=0) then
                		execute2_pc <= execute2_topOfStack(maxAddrBit downto 0) + execute2_pc;
                	end if;
					execute2_resync <= '1';
                when Decoded_Eq =>
                	execute2_sp <= execute2_sp + 1;
            		execute2_topOfStack <= (others => '0');
                	if (execute2_topOfStack=execute2_topOfStackB) then
                		execute2_topOfStack(0) <= '1';
                	end if;
					execute2_topOfStackB <= memARead;
                when Decoded_Ulessthan =>
                	execute2_sp <= execute2_sp + 1;
            		execute2_topOfStack <= (others => '0');
                	if (execute2_topOfStack<execute2_topOfStackB) then
                		execute2_topOfStack(0) <= '1';
                	end if;
					execute2_topOfStackB <= memARead;
                when Decoded_Lessthan =>
                	execute2_sp <= execute2_sp + 1;
            		execute2_topOfStack <= (others => '0');
            		compareA := signed(execute2_topOfStack);
            		compareB := signed(execute2_topOfStackB);
                	if (compareA<compareB) then
                		execute2_topOfStack(0) <= '1';
                	end if;
					execute2_topOfStackB <= memARead;
				when Decoded_Stall =>
					begin_inst <= '0'; 
					execute2_pc <= execute2_pc;
				when others =>
					-- nop
			end case;
			
			-- load cycle...
			execute2_loadingDone <= execute2_loading;
			if (execute2_loadingDone ='1') then
				if (execute2_topOfStack(ioBit)='1') then
					if (io_busy = '0') then
						execute2_topOfStack <= (others => '0');
						execute2_topOfStack(7 downto 0) <= io_read;
						execute2_persistTopOfStack <= '1';
					else
						execute2_loadingDone <= '1';
					end if;
				else
					if (execute2_storeByte = '1') then
						execute2_sp <= execute2_sp + 2;
						memBWriteEnable <= '1';
						memBAddr <= execute2_topOfStack(maxAddrBit downto minAddrBit);
						memBWrite <= memARead;
						case execute2_topOfStack(minAddrBit-1 downto 0) is
							when "00" 	=> memBWrite(31 downto 24) <= execute2_topOfStackB(7 downto 0);
							when "01" 	=> memBWrite(23 downto 16) <= execute2_topOfStackB(7 downto 0);
							when "10" 	=> memBWrite(15 downto 8) <= execute2_topOfStackB(7 downto 0);
							when others	=> memBWrite(7 downto 0) <= execute2_topOfStackB(7 downto 0);
						end case;
--						case execute2_topOfStack(0 downto 0) is
--							when "1" 	=> memBWrite(15 downto 8) <= execute2_topOfStackB(7 downto 0);
--							when others	=> memBWrite(7 downto 0) <= execute2_topOfStackB(7 downto 0);
--						end case;
						execute2_resync <= '1';
					elsif (execute2_loadByte = '1') then
						execute2_topOfStack <= (others => '0');
						case execute2_topOfStack(minAddrBit-1 downto 0) is
							when "00" 	=> execute2_topOfStack(7 downto 0) <= memARead(31 downto 24);
							when "01" 	=> execute2_topOfStack(7 downto 0) <= memARead(23 downto 16);
							when "10" 	=> execute2_topOfStack(7 downto 0) <= memARead(15 downto 8);
							when others	=> execute2_topOfStack(7 downto 0) <= memARead(7 downto 0);
						end case;
--						case execute2_topOfStack(0 downto 0) is
--							when "1" 	=> execute2_topOfStack(7 downto 0) <= memARead(15 downto 8);
--							when others	=> execute2_topOfStack(7 downto 0) <= memARead(7 downto 0);
--						end case;
						execute2_persistTopOfStack <= '1';
					else
						execute2_topOfStack <= memARead;
						execute2_persistTopOfStack <= '1';
					end if;
				end if;
			end if;

			-- write top of stack...
			execute2_persistTopOfStackB <= execute2_persistTopOfStack;
			if (execute2_persistTopOfStack = '1') then
				execute2_persistTopOfStack <= '0';
				memBWriteEnable <= '1';
				memBAddr <= execute2_sp;
				memBWrite <= execute2_topOfStack;
			end if;
			if (execute2_persistTopOfStackB = '1') then
				memBWriteEnable <= '1';
				memBAddr <= execute2_sp+1;
				memBWrite <= execute2_topOfStackB;
				
				execute2_resync <= '1';
			end if;
			
			-- here we resync the pipeline.
			-- a number of things have to happen on certain cycles 
			execute2_resync2 <= execute2_resync;
			execute2_resync3 <= execute2_resync2;
			execute2_resync4 <= execute2_resync3;
			execute2_resync5 <= execute2_resync4;
			execute2_resync6 <= execute2_resync5;
			execute2_resync7 <= execute2_resync6;
			execute2_resync8 <= execute2_resync7;
			execute2_resync9 <= execute2_resync8;
			execute2_resync10 <= execute2_resync9;
			
			if (execute2_resync = '1' ) then
				-- resync #1
				execute2_resync <= '0';
				decode_starved <= '1';
				memAAddr <= execute2_sp;
			end if;
			if (execute2_resync2 = '1') then
				-- resync #2
				execute1_fetchPC <= execute2_pc;
				memAAddr <= execute2_sp + 1;
			end if;
			if (execute2_resync3 = '1') then
				-- resync #3
				execute2_topOfStack <= memARead;
			end if;
			if (execute2_resync4 = '1') then
				-- resync #4
				-- during this cycle the address is set to the opcode
				execute2_topOfStackB <= memARead;
			end if;
			if (execute2_resync5 = '1') then
				-- resync #5
				execute1_pop1 <= '0';
				execute1_push1 <= '0';
			end if;
			if (execute2_resync6 = '1') then
				-- resync #6
				decode_idim_flag <= '0';
				execute1_pop1 <= '0';
				execute1_push1 <= '0';
			end if;
			if (execute2_resync7 = '1') then
				-- resync #7
				execute1_sp <= execute2_sp;
				execute1_stall <= '0';
			end if;
			if (execute2_resync8 = '1') then
				-- resync #8
--				load_stall <= '0';
			end if;
			if (execute2_resync9 = '1') then
				-- resync #9
			end if;
			if (execute2_resync10 = '1') then
			end if;
			
			


		end if;
	end process;



end behave;
