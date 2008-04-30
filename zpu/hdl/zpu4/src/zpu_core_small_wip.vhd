-- Company: ZPU3

-- Engineer: �yvind Harboe



library IEEE;

use IEEE.STD_LOGIC_1164.ALL;

use ieee.numeric_std.all;



library work;

use work.zpu_config.all;

use work.zpupkg.all;



entity zpu_core is

    Port (    clk : in std_logic;

              areset : in std_logic;

              enable : in std_logic;

              in_mem_busy : in std_logic;

              mem_read : in std_logic_vector(wordSize-1 downto 0);

              mem_write : out std_logic_vector(wordSize-1 downto 0);

              out_mem_addr : out std_logic_vector(maxAddrBitIncIO

downto 0);

              out_mem_writeEnable : out std_logic;

              out_mem_readEnable : out std_logic;

              mem_writeMask: out std_logic_vector(wordBytes-1 downto 0);

              interrupt : in std_logic;

              break : out std_logic

        );



end zpu_core;



architecture behave of zpu_core is



signal      readIO : std_logic;







signal memAWriteEnable : std_logic;

signal memAAddr : unsigned(maxAddrBit downto minAddrBit);

signal memAWrite : unsigned(wordSize-1 downto 0);

signal memARead : unsigned(wordSize-1 downto 0);

signal memBWriteEnable : std_logic;

signal memBAddr : unsigned(maxAddrBit downto minAddrBit);

signal memBWrite : unsigned(wordSize-1 downto 0);

signal memBRead : unsigned(wordSize-1 downto 0);



signal  pc              : unsigned(maxAddrBit downto 0);

signal  sp              : unsigned(maxAddrBit downto minAddrBit);



signal  idim_flag           : std_logic;



--signal    storeToStack        : std_logic;

--signal    fetchNextInstruction        : std_logic;

--signal    extraCycle          : std_logic;



signal  busy                : std_logic;

--signal    fetching            : std_logic;



signal  begin_inst          : std_logic;



signal trace_opcode      : std_logic_vector(7 downto 0);

signal trace_pc          : std_logic_vector(maxAddrBitIncIO downto 0);

signal trace_sp          : std_logic_vector(maxAddrBitIncIO downto

minAddrBit);

signal trace_topOfStack  : std_logic_vector(wordSize-1 downto 0);

signal trace_topOfStackB : std_logic_vector(wordSize-1 downto 0);



-- state machine.

type State_Type is

(

State_Fetch,

State_WriteIODone,

State_Execute,

State_StoreToStack,

State_Add,

State_Or,

State_And,

State_Store,

State_ReadIO,

State_WriteIO,

State_Load,

State_FetchNext,

State_AddSP,

State_ReadIODone,

State_Decode,

State_Resync

);



type DecodedOpcodeType is

(

Decoded_Nop,

Decoded_Im,

Decoded_ImShift,

Decoded_LoadSP,

Decoded_StoreSP ,

Decoded_AddSP,

Decoded_Emulate,

Decoded_Break,

Decoded_PushSP,

Decoded_PopPC,

Decoded_Add,

Decoded_Or,

Decoded_And,

Decoded_Load,

Decoded_Not,

Decoded_Flip,

Decoded_Store,

Decoded_PopSP

);





signal sampledOpcode : std_logic_vector(OpCode_Size-1 downto 0);

signal opcode : std_logic_vector(OpCode_Size-1 downto 0);



signal decodedOpcode : DecodedOpcodeType;

signal sampledDecodedOpcode : DecodedOpcodeType;





signal state : State_Type;



subtype AddrBitBRAM_range is natural range maxAddrBitBRAM downto

minAddrBit;

signal memAAddr_stdlogic  : std_logic_vector(AddrBitBRAM_range);

signal memAWrite_stdlogic : std_logic_vector(memAWrite'range);

signal memARead_stdlogic  : std_logic_vector(memARead'range);

signal memBAddr_stdlogic  : std_logic_vector(AddrBitBRAM_range);

signal memBWrite_stdlogic : std_logic_vector(memBWrite'range);

signal memBRead_stdlogic  : std_logic_vector(memBRead'range);



-- debug

subtype index is integer range 0 to 31;

signal tOpcode_sel : index;





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

        busy => busy,

        intsp => (others => 'U')

        );

    end generate;



    -- not used in this design

    mem_writeMask <= (others => '1');



    memAAddr_stdlogic  <= std_logic_vector(memAAddr(AddrBitBRAM_range));

    memAWrite_stdlogic <= std_logic_vector(memAWrite);

    memBAddr_stdlogic  <= std_logic_vector(memBAddr(AddrBitBRAM_range));

    memBWrite_stdlogic <= std_logic_vector(memBWrite);

    memory: dualport_ram port map (

            clk => clk,

            memAWriteEnable => memAWriteEnable,

            memAAddr => memAAddr_stdlogic,

            memAWrite => memAWrite_stdlogic,

            memARead => memARead_stdlogic,

            memBWriteEnable => memBWriteEnable,

            memBAddr => memBAddr_stdlogic,

            memBWrite => memBWrite_stdlogic,

            memBRead => memBRead_stdlogic

        );

    memARead <= unsigned(memARead_stdlogic);

    memBRead <= unsigned(memBRead_stdlogic);



tOpcode_sel <= to_integer(pc(minAddrBit-1 downto 0));



    decodeControl:

    process(memBRead, pc,tOpcode_sel)

        variable tOpcode : std_logic_vector(OpCode_Size-1 downto 0);

    begin

        -- not worked with synopsys

        -- tOpcode :=

std_logic_vector(memBRead((wordBytes-1-to_integer(pc(minAddrBit-1

downto 0))+1)*8-1 downto (wordBytes-1-to_integer(pc(minAddrBit-1

downto 0)))*8));

        case (tOpcode_sel) is

            when 0 => tOpcode := std_logic_vector(memBRead(31 downto 24));

            when 1 => tOpcode := std_logic_vector(memBRead(23 downto 16));

            when 2 => tOpcode := std_logic_vector(memBRead(15 downto 8));

            when 3 => tOpcode := std_logic_vector(memBRead(7 downto 0));

            when others => tOpcode := std_logic_vector(memBRead(7

downto 0));

        end case;

        sampledOpcode <= tOpcode;



        if (tOpcode(7 downto 7)=OpCode_Im) then

            sampledDecodedOpcode<=Decoded_Im;

        elsif (tOpcode(7 downto 5)=OpCode_StoreSP) then

            sampledDecodedOpcode<=Decoded_StoreSP;

        elsif (tOpcode(7 downto 5)=OpCode_LoadSP) then

            sampledDecodedOpcode<=Decoded_LoadSP;

        elsif (tOpcode(7 downto 5)=OpCode_Emulate) then

            sampledDecodedOpcode<=Decoded_Emulate;

        elsif (tOpcode(7 downto 4)=OpCode_AddSP) then

            sampledDecodedOpcode<=Decoded_AddSP;

        else

            case tOpcode(3 downto 0) is

                when OpCode_Break =>

                    sampledDecodedOpcode<=Decoded_Break;

                when OpCode_PushSP =>

                    sampledDecodedOpcode<=Decoded_PushSP;

                when OpCode_PopPC =>

                    sampledDecodedOpcode<=Decoded_PopPC;

                when OpCode_Add =>

                    sampledDecodedOpcode<=Decoded_Add;

                when OpCode_Or =>

                    sampledDecodedOpcode<=Decoded_Or;

                when OpCode_And =>

                    sampledDecodedOpcode<=Decoded_And;

                when OpCode_Load =>

                    sampledDecodedOpcode<=Decoded_Load;

                when OpCode_Not =>

                    sampledDecodedOpcode<=Decoded_Not;

                when OpCode_Flip =>

                    sampledDecodedOpcode<=Decoded_Flip;

                when OpCode_Store =>

                    sampledDecodedOpcode<=Decoded_Store;

                when OpCode_PopSP =>

                    sampledDecodedOpcode<=Decoded_PopSP;

                when others =>

                    sampledDecodedOpcode<=Decoded_Nop;

            end case;

        end if;

    end process;





    opcodeControl:

    process(clk, areset)

        variable spOffset : unsigned(4 downto 0);

    begin

        if areset = '1' then

            state <= State_Resync;

            break <= '0';

            sp <= unsigned(spStart(maxAddrBit downto minAddrBit));

            pc <= (others => '0');

            idim_flag <= '0';

            begin_inst <= '0';

            memAAddr <= (others => '0');

            memBAddr <= (others => '0');

            memAWriteEnable <= '0';

            memBWriteEnable <= '0';

            out_mem_writeEnable <= '0';

            out_mem_readEnable <= '0';

            memAWrite <= (others => '0');

            memBWrite <= (others => '0');

            -- avoid Latch in synopsys

            -- mem_writeMask <= (others => '1');

        elsif (clk'event and clk = '1') then

            memAWriteEnable <= '0';

            memBWriteEnable <= '0';

            -- This saves ca. 100 LUT's, by explicitly declaring that the

            -- memAWrite can be left at whatever value if

memAWriteEnable is

            -- not set.

            memAWrite <= (others => DontCareValue);

            memBWrite <= (others => DontCareValue);

--          out_mem_addr <= (others => DontCareValue);

--          mem_write <= (others => DontCareValue);

            spOffset := (others => DontCareValue);

            memAAddr <= (others => DontCareValue);

            memBAddr <= (others => DontCareValue);

            

            out_mem_writeEnable <= '0';

            out_mem_readEnable <= '0';

            begin_inst <= '0';

            out_mem_addr <= std_logic_vector(memARead(maxAddrBitIncIO

downto 0));

            mem_write <= std_logic_vector(memBRead);

            

            decodedOpcode <= sampledDecodedOpcode;

            opcode <= sampledOpcode;



            case state is

                when State_Execute =>

                    state <= State_Fetch;

                    -- at this point:

                    -- memBRead contains opcode word

                    -- memARead contains top of stack

                    pc <= pc + 1;



                    -- trace

                    begin_inst <= '1';

                    trace_pc <= (others => '0');

                    trace_pc(maxAddrBit downto 0) <= std_logic_vector(pc);

                    trace_opcode <= opcode;

                    trace_sp <= (others => '0');

                    trace_sp(maxAddrBit downto minAddrBit) <=

std_logic_vector(sp);

                    trace_topOfStack <= std_logic_vector(memARead);

                    trace_topOfStackB <= std_logic_vector(memBRead);



                    -- during the next cycle we'll be reading the next

opcode

                    spOffset(4):=not opcode(4);

                    spOffset(3 downto 0) := unsigned(opcode(3 downto 0));



                    idim_flag <= '0';

                    case decodedOpcode is

                        when Decoded_Im =>

                            idim_flag <= '1';

                            memAWriteEnable <= '1';

                            if (idim_flag='0') then

                                sp <= sp - 1;

                                memAAddr <= sp-1;

                                for i in wordSize-1 downto 7 loop

                                    memAWrite(i) <= opcode(6);

                                end loop;

                                memAWrite(6 downto 0) <=

unsigned(opcode(6 downto 0));

                            else

                                memAAddr <= sp;

                                memAWrite(wordSize-1 downto 7) <=

memARead(wordSize-8 downto 0);

                                memAWrite(6 downto 0) <=

unsigned(opcode(6 downto 0));

                            end if;

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

                            pc(9 downto 5) <= unsigned(opcode(4 downto

0));

                        when Decoded_AddSP =>

                            memAAddr <= sp;

                            memBAddr <= sp+spOffset;

                            state <= State_AddSP;

                        when Decoded_Break =>

                            report "Break instruction encountered"

severity failure;

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

                                out_mem_addr <=

std_logic_vector(memARead(maxAddrBitIncIO downto 0));

                                out_mem_readEnable <= '1';

                                state <= State_ReadIO;

                            else 

                                memAAddr <= memARead(maxAddrBit downto

minAddrBit);

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

                    if (in_mem_busy = '0') then

                        state <= State_Fetch;

                        memAWriteEnable <= '1';

                        memAWrite <= unsigned(mem_read);

                    end if;

                when State_WriteIO =>

                    sp <= sp + 1;

                    out_mem_writeEnable <= '1';

                    out_mem_addr <=

std_logic_vector(memARead(maxAddrBitIncIO downto 0));

                    mem_write <= std_logic_vector(memBRead);

                    state <= State_WriteIODone;

                when State_WriteIODone =>

                    if (in_mem_busy = '0') then

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

                    -- at this point memARead contains the value that

is either

                    -- from the top of stack or should be copied to

the top of the stack

                    memAWriteEnable <= '1';

                    memAWrite <= memARead; 

                    memAAddr <= sp;

                    memBAddr <= sp + 1;

                    state <= State_Decode;

                when State_Decode =>

                    -- during the State_Execute cycle we'll be

fetching SP+1

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
