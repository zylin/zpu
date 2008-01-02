-- Company: ZPU3
-- Engineer: Øyvind Harboe

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

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
signal	trace_topOfStackB				: std_logic_vector(wordSize-1 downto 0);

-- state machine.

subtype State_Type is std_logic_vector(3 downto 0);
constant State_Fetch		: State_Type := b"0000";
constant State_WriteIODone	: State_Type := b"0001";
constant State_Execute		: State_Type := b"0010";
constant State_StoreToStack	: State_Type := b"0011";
constant State_Add			: State_Type := b"0100";
constant State_Or			: State_Type := b"0101";
constant State_And			: State_Type := b"0110";
constant State_Store		: State_Type := b"0111";
constant State_ReadIO		: State_Type := b"1000";
constant State_WriteIO		: State_Type := b"1001";
constant State_Load			: State_Type := b"1010";
constant State_FetchNext	: State_Type := b"1011";
constant State_AddSP		: State_Type := b"1100";
constant State_ReadIODone	: State_Type := b"1101";
constant State_Decode		: State_Type := b"1110";
constant State_Resync		: State_Type := b"1111";


subtype DecodedOpcodeType is std_logic_vector(4 downto 0);
constant Decoded_Nop		: DecodedOpcodeType := b"00000";
constant Decoded_Im			: DecodedOpcodeType := b"00001";
constant Decoded_ImShift	: DecodedOpcodeType := b"00010";
constant Decoded_LoadSP		: DecodedOpcodeType := b"00011";
constant Decoded_StoreSP	: DecodedOpcodeType := b"00100";
constant Decoded_AddSP		: DecodedOpcodeType := b"00101";
constant Decoded_Emulate	: DecodedOpcodeType := b"00110";
constant Decoded_Break		: DecodedOpcodeType := b"00111";
constant Decoded_PushPC		: DecodedOpcodeType := b"01000";
constant Decoded_PushSP		: DecodedOpcodeType := b"01001";
constant Decoded_PopPC		: DecodedOpcodeType := b"01010";
constant Decoded_Add		: DecodedOpcodeType := b"01011";
constant Decoded_Or			: DecodedOpcodeType := b"01100";
constant Decoded_And		: DecodedOpcodeType := b"01101";
constant Decoded_Load		: DecodedOpcodeType := b"01110";
constant Decoded_Not		: DecodedOpcodeType := b"01111";
constant Decoded_Flip		: DecodedOpcodeType := b"10000";
constant Decoded_Store		: DecodedOpcodeType := b"10001";
constant Decoded_PopSP		: DecodedOpcodeType := b"10010";

signal opcode : std_logic_vector(OpCode_Size-1 downto 0);

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
		variable tOpcode : std_logic_vector(OpCode_Size-1 downto 0);
		variable spOffset : std_logic_vector(4 downto 0);
	begin
		if areset = '1' then
			state <= State_Resync;
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
			-- This saves ca. 100 LUT's, by explicitly declaring that the
			-- memAWrite can be left at whatever value if memAWriteEnable is
			-- not set.
			memAWrite <= (others => DontCareValue);
			memBWrite <= (others => DontCareValue);
			opcode <= (others => DontCareValue);
--			io_addr <= (others => DontCareValue);
--			io_write <= (others => DontCareValue);
			spOffset := (others => DontCareValue);
			memAAddr <= (others => DontCareValue);
			memBAddr <= (others => DontCareValue);
			
			io_writeEnable <= '0';
			io_readEnable <= '0';
			begin_inst <= '0';

			case state is
				when State_Execute =>
					state <= State_Fetch;
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
					trace_topOfStackB <= memBRead;

					-- during the next cycle we'll be reading the next opcode	
					spOffset(4):=not opcode(4);
					spOffset(3 downto 0):=opcode(3 downto 0);
	
					case decodedOpcode is
						when Decoded_Im =>
							memAWriteEnable <= '1';
							sp <= sp - 1;
							memAAddr <= sp-1;
							for i in wordSize-1 downto 7 loop
								memAWrite(i) <= opcode(6);
							end loop;
							memAWrite(6 downto 0) <= opcode(6 downto 0);
						when Decoded_ImShift =>
							memAAddr <= sp;
							memAWriteEnable <= '1';
							memAWrite(wordSize-1 downto 7) <= memARead(wordSize-8 downto 0);
							memAWrite(6 downto 0) <= opcode(6 downto 0);
						when Decoded_StoreSP =>
							memBWriteEnable <= '1';
							memBAddr <= sp+spOffset;
							memBWrite <= memARead;
							sp <= sp + 1;
							state <= State_Resync;
						when Decoded_LoadSP =>
							sp <= sp - 1;
							memAAddr <= sp+spOffset;
						when Decoded_Emulate =>
							sp <= sp - 1;
							memAWriteEnable <= '1';
							memAAddr <= sp - 1;
							memAWrite <= (others => DontCareValue);
							memAWrite(maxAddrBit downto 0) <= pc + 1;
							-- The emulate address is:
							--        98 7654 3210
							-- 0000 00aa aaa0 0000
							pc <= (others => '0');
							pc(9 downto 5) <= opcode(4 downto 0);
						when Decoded_AddSP =>
							memAAddr <= sp;
							memBAddr <= sp+spOffset;
							state <= State_AddSP;
						when Decoded_Break =>
							report "Break instruction encountered" severity failure;
							break <= '1';
						when Decoded_PushSP =>
							memAWriteEnable <= '1';
							memAAddr <= sp - 1;
							sp <= sp - 1;
							memAWrite <= (others => DontCareValue);
							memAWrite(maxAddrBit downto minAddrBit) <= sp;
						when Decoded_PopPC =>
							pc <= memARead(maxAddrBit downto 0);
							sp <= sp + 1;
							state <= State_Resync;
						when Decoded_Add =>
							sp <= sp + 1;
							state <= State_Add;
						when Decoded_Or =>
							sp <= sp + 1;
							state <= State_Or;
						when Decoded_And =>
							sp <= sp + 1;
							state <= State_And;
						when Decoded_Load =>
							if (memARead(ioBit)='1') then
								io_addr <= memARead(maxAddrBit downto minAddrBit);
								io_readEnable <= '1';
								state <= State_ReadIO;
							else 
								memAAddr <= memARead(maxAddrBit downto minAddrBit);
							end if;
						when Decoded_Not =>
							memAAddr <= sp(maxAddrBit downto minAddrBit);
							memAWriteEnable <= '1';
							memAWrite <= not memARead;
						when Decoded_Flip =>
							memAAddr <= sp(maxAddrBit downto minAddrBit);
							memAWriteEnable <= '1';
							for i in 0 to wordSize-1 loop
								memAWrite(i) <= memARead(wordSize-1-i);
				  			end loop;
						when Decoded_Store =>
							memBAddr <= sp + 1;
							sp <= sp + 1;
							if (memARead(ioBit)='1') then
								state <= State_WriteIO;
							else
								state <= State_Store;
							end if;
						when Decoded_PopSP =>
							sp <= memARead(maxAddrBit downto minAddrBit);
							state <= State_Resync;
						when Decoded_Nop =>	
							memAAddr <= sp;
						when others =>	
							null; 
					end case;
				when State_ReadIO =>
					if (io_busy = '0') then
						state <= State_Fetch;
						memAWriteEnable <= '1';
						memAWrite <= (others => '0');
						memAWrite(7 downto 0) <= io_read;
					end if;
				when State_WriteIO =>
					sp <= sp + 1;
					io_writeEnable <= '1';
					io_addr <= memARead(maxAddrBit downto minAddrBit);
					io_write <= memBRead(7 downto 0);
					state <= State_WriteIODone;
				when State_WriteIODone =>
					if (io_busy = '0') then
						state <= State_Resync;
					end if;
				when State_Fetch =>
					-- We need to resync. During the *next* cycle
					-- we'll fetch the opcode @ pc and thus it will
					-- be available for State_Execute the cycle after
					-- next
					memBAddr <= pc(maxAddrBit downto minAddrBit);
					state <= State_FetchNext;
				when State_FetchNext =>
					-- at this point memARead contains the value that is either
					-- from the top of stack or should be copied to the top of the stack
					memAWriteEnable <= '1';
					memAWrite <= memARead; 
					memAAddr <= sp;
					memBAddr <= sp + 1;
					state <= State_Decode;
				when State_Decode =>
					case pc(1 downto 0) is
						when "00" 	=> tOpcode := memBRead(31 downto 24);
						when "01" 	=> tOpcode := memBRead(23 downto 16);
						when "10" 	=> tOpcode := memBRead(15 downto 8);
						when others	=> tOpcode := memBRead(7 downto 0);
					end case;
					idim_flag <= tOpcode(7);
					opcode <= tOpcode;
					if (tOpcode(7 downto 7)=OpCode_Im) then
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
						decodedOpcode<=Decoded_Emulate;
					elsif (tOpcode(7 downto 4)=OpCode_AddSP) then
						decodedOpcode<=Decoded_AddSP;
					else
						case tOpcode(3 downto 0) is
							when OpCode_Break =>
								decodedOpcode<=Decoded_Break;
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
					-- during the State_Execute cycle we'll be fetching SP+1
					memAAddr <= sp;
					memBAddr <= sp + 1;
					state <= State_Execute;
				when State_Store =>
					sp <= sp + 1;
					memAWriteEnable <= '1';
					memAAddr <= memARead(maxAddrBit downto minAddrBit);
					memAWrite <= memBRead;
					state <= State_Resync;
				when State_AddSP =>
					state <= State_Add;
				when State_Add =>
					memAAddr <= sp;
					memAWriteEnable <= '1';
					memAWrite <= memARead + memBRead;
					state <= State_Fetch;
				when State_Or =>
					memAAddr <= sp;
					memAWriteEnable <= '1';
					memAWrite <= memARead or memBRead;
					state <= State_Fetch;
				when State_Resync =>
					memAAddr <= sp;
					state <= State_Fetch;
				when State_And =>
					memAAddr <= sp;
					memAWriteEnable <= '1';
					memAWrite <= memARead and memBRead;
					state <= State_Fetch;
				when others =>
					null;
			end case;				
		end if;
	end process;



end behave;
