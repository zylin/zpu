------------------------------------------------------------------------------
----                                                                      ----
----  Testbench for the ZPU Small connection to the FPGA                  ----
----                                                                      ----
----  http://www.opencores.org/                                           ----
----                                                                      ----
----  Description:                                                        ----
----  This is a testbench to simulate the ZPU_Small1 core as used in the  ----
----  *_small1.vhdl                                                       ----
----                                                                      ----
----  ...plus the JTAG debugger proof of concept for the Small core.
----
----  To Do:                                                              ----
----  -                                                                   ----
----                                                                      ----
----  Author:                                                             ----
----    - Salvador E. Tropea, salvador inti.gob.ar                        ----
----    Modifications for core debug signal testing
----    - Martin Strubel <hackfin@section5.ch>
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Copyright (c) 2008 Salvador E. Tropea <salvador inti.gob.ar>         ----
---- Copyright (c) 2008 Instituto Nacional de Tecnología Industrial       ----
----                                                                      ----
---- Distributed under the BSD license                                    ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Design unit:      HWDbg_Small1_TB(Behave) (Entity and architecture)        ----
---- File name:        small1_tb.vhdl                                     ----
---- Note:             None                                               ----
---- Limitations:      None known                                         ----
---- Errors:           None known                                         ----
---- Library:          work                                               ----
---- Dependencies:     IEEE.std_logic_1164                                ----
----                   IEEE.numeric_std                                   ----
----                   zpu.zpupkg                                         ----
----                   zpu.txt_util                                       ----
----                   work.zpu_memory                                    ----
---- Target FPGA:      Spartan 3 (XC3S1500-4-FG456)                       ----
---- Language:         VHDL                                               ----
---- Wishbone:         No                                                 ----
---- Synthesis tools:  N/A                                                ----
---- Simulation tools: Isim
---- Text editor:      gvim
----                                                                      ----
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library zpu;
use zpu.zpupkg.all;
use zpu.txt_util.all;

library work;
use work.zpu_memory.all;

entity HWDbg_Small1_TB is
end entity HWDbg_Small1_TB;

architecture Behave of HWDbg_Small1_TB is
   constant WORD_SIZE  : natural:=32; -- 32 bits data path
   constant ADDR_W     : natural:=18;  -- 18 bits address space=256 kB, 128 kB I/O
   constant BRAM_W     : natural:=14; -- 15 bits RAM space=32 kB
   constant D_CARE_VAL : std_logic:='0'; -- Fill value
   constant CLK_FREQ   : positive:=50; -- 50 MHz clock
   constant CLK_S_PER  : time:=1 us/(2.0*real(CLK_FREQ)); -- Clock semi period
   constant BRATE      : positive:=115200;

   -- Opcode to leave emulation:
   constant OPCODE_LEAVE_EMULATION  : unsigned(3 downto 0) := OPCODE_BREAK;

   component tap
    generic (EMUDAT_SIZE : natural;
      EMUIR_SIZE : natural);
    port (
      emu : out  std_logic;
      tck : in  std_logic;
      trst : in  std_logic;
      tms : in  std_logic;
      tdi : in  std_logic;
      tdo : out  std_logic;
      emuexec     : out std_logic; -- Execute opcode on rising edge
      emurequest  : out std_logic; -- Emulation request to core
      emuack      : in std_logic; -- Core has acknowledged EMULATION request
      emurdy      : in std_logic; -- Core ready to execute next instruction
      -- Program Counter without going to emulation.
      dbgpc       : in std_logic_vector(32-1 downto 0);

      emudata_i   : in std_logic_vector(32-1 downto 0);
      emudata_o   : out std_logic_vector(32-1 downto 0);
      emudat_wr   : in std_logic;
      emudat_rd   : in std_logic;
      emuir       : out std_logic_vector(OPCODE_W-1 downto 0)
      );
    end component;

   component ZPU_Small1 is
      generic(
         WORD_SIZE  : natural:=32;  -- 32 bits data path
         D_CARE_VAL : std_logic:='0'; -- Fill value
         CLK_FREQ   : positive:=50; -- 50 MHz clock
         BRATE      : positive:=115200; -- RS232 baudrate
         ADDR_W     : natural:=16;  -- 16 bits address space=64 kB, 32 kB I/O
         BRAM_W     : natural:=15); -- 15 bits RAM space=32 kB
      port(
         clk_i      : in  std_logic;  -- CPU clock
         rst_i      : in  std_logic;  -- Reset

         -- Emulation pins:
         emureq_i     : in std_logic;
         emuexec_i    : in std_logic;
         emuack_o     : out std_logic;
         emurdy_o     : out std_logic;
         emuir        : in std_logic_vector(OPCODE_W-1 downto 0);

         break_o    : out std_logic;  -- Break executed
         dbg_o      : out zpu_dbgo_t; -- Debug info
         rs232_tx_o : out std_logic;  -- UART Tx
         rs232_rx_i : in  std_logic); -- UART Rx
   end component ZPU_Small1;

   signal clk          : std_logic;
   signal reset        : std_logic:='1';

   signal emureq       : std_logic := '0';
   signal emuexec      : std_logic := '0';
   signal emuack       : std_logic;
   signal emurdy       : std_logic := '0';
   signal emuir        : std_logic_vector(OPCODE_W-1 downto 0);

   signal break        : std_logic := '0';
   signal dbg          : zpu_dbgo_t; -- Debug info
   signal rs232_tx     : std_logic;
   signal rs232_rx     : std_logic;


   -- Auxiliary signals
   signal terminate       : std_logic := '0';
   signal mismatch       : std_logic := '0';
   signal finish       : std_logic;
   signal save_sp      : unsigned(31 downto 0);

begin

   zpu : ZPU_Small1
      generic map(
         WORD_SIZE => WORD_SIZE, D_CARE_VAL => D_CARE_VAL,
         CLK_FREQ => CLK_FREQ, BRATE => BRATE, ADDR_W => ADDR_W,
         BRAM_W => BRAM_W)
      port map(
         clk_i => clk, rst_i => reset, rs232_tx_o => rs232_tx,
         emureq_i => emureq, emuexec_i => emuexec,
         emuack_o => emuack, emurdy_o => emurdy,
         emuir => emuir,
         rs232_rx_i => rs232_rx, break_o => break, dbg_o => dbg);

   trace_mod : Trace
      generic map(
         ADDR_W => ADDR_W, WORD_SIZE => WORD_SIZE,
         LOG_FILE => "dbg_small1_trace.log")
      port map(
         clk_i => clk, dbg_i => dbg, emu_i => emuack, stop_i => '0',
            busy_i => '0');

   do_clock:
   process
   begin
      clk <= '0';
      wait for CLK_S_PER;
      clk <= '1';
      wait for CLK_S_PER;
      if finish='1' then
         print("* Finish asserted, end of test");
         if terminate = '1' then
            print("* Reason: Terminate");
         end if;
         if mismatch = '1' then
            print("* Reason: Mismatch");
         end if;
         if break = '1' then
            print("* Reason: Breakpoint");
         end if;
         wait;
      end if;
   end process do_clock;

   do_reset:
   process
   begin
      wait until rising_edge(clk);
      reset <= '0';
   end process do_reset;

do_emulation:
   process
   procedure execute_opcode(
      code: unsigned(OPCODE_W-1 downto 0)
     )
   is begin
      emuir <= std_logic_vector(code);

      wait until rising_edge(clk);
      emuexec <= '1';
      wait until rising_edge(clk);
      emuexec <= '0';
      wait for 200ns;
   end execute_opcode;

   procedure push_imm32(
     imm: unsigned(31 downto 0)
     )
   is begin
      execute_opcode(OPCODE_IM & "000" & imm(31 downto 28));
      execute_opcode(OPCODE_IM & imm(27 downto 21));
      execute_opcode(OPCODE_IM & imm(20 downto 14));
      execute_opcode(OPCODE_IM & imm(13 downto 7));
      execute_opcode(OPCODE_IM & imm(6 downto 0));
   end push_imm32;

   procedure getsp
   is begin
      execute_opcode(OPCODE_SHORT & OPCODE_PUSHSP); -- Restore context
      execute_opcode(OPCODE_SHORT & OPCODE_NOP);
      print("sp: " & hstr(dbg.stk_a));
      -- execute_opcode(OPCODE_LOADSP & '1' & x"1"); -- Restore context
      execute_opcode(OPCODE_SHORT & OPCODE_POPSP); -- Restore context
   end getsp;

   procedure mem_read(
     addr: unsigned(31 downto 0)
   )
   is begin
      execute_opcode(OPCODE_SHORT & OPCODE_PUSHSP); -- Restore context
      -- Save current SP for for reference. Note the dbg.sp is not yet
      -- updated to the above command.
      save_sp <= dbg.sp;
      push_imm32(addr);
      execute_opcode(OPCODE_SHORT & OPCODE_LOAD); -- Load indirect
      execute_opcode(OPCODE_SHORT & OPCODE_NOP);
      print("value: " & hstr(dbg.stk_a));
      execute_opcode(OPCODE_LOADSP & '1' & x"1"); -- Restore context
      execute_opcode(OPCODE_SHORT & OPCODE_POPSP); -- Restore context
      execute_opcode(OPCODE_SHORT & OPCODE_NOP);

      if (dbg.sp /= save_sp) then
         mismatch <= '1';
         print("* ERROR: Stack pointers don't match");
         print("sp: " & hstr(dbg.sp) & "  SAVE_SP: " & hstr(save_sp));
      end if;


   end mem_read;

   begin
      wait for 400ns;
      emuir <= "00001011"; -- NOP
      -- emureq <= '1';

      -- It is IMPORTANT to wait after an emu request
      wait until emurdy = '1' and break ='1';
      wait for 100ns;

----------------------------------------------------------------------------

      -- Single stepping:
      emureq <= '1';
      wait for 100ns;

      for i in 0 to 200 loop
         getsp;
         execute_opcode(OPCODE_SHORT & OPCODE_LEAVE_EMULATION);
      end loop;


----------------------------------------------------------------------------
      -- Save context here:

      execute_opcode(OPCODE_SHORT & OPCODE_PUSHSP); -- Restore context
      -- Save current SP for for reference. Note the dbg.sp is not yet
      -- updated to the above command.
      save_sp <= dbg.sp;

      -- Now do your stuff and count the pushes, including the above

      -- MEMORY READ {

      push_imm32(x"000008d8");
      
      -- execute_opcode(OPCODE_LOADSP & '1' & x"0");
      execute_opcode(OPCODE_SHORT & OPCODE_LOAD); -- Load indirect

      execute_opcode(OPCODE_SHORT & OPCODE_NOP);
      print("value: " & hstr(dbg.stk_a));

      -- Now we should see the data from the address above in
      -- dbg.stk_a
      -- }


      -- Restore old stack:

      -- RESTORE
      -- execute_opcode(OPCODE_SHORT & OPCODE_PUSHSP);
      -- Fix up stack:
      -- execute_opcode(OPCODE_IM & "000" & x"8");
      -- execute_opcode(OPCODE_SHORT & OPCODE_ADD);
      execute_opcode(OPCODE_LOADSP & '1' & x"1"); -- Restore context
      execute_opcode(OPCODE_SHORT & OPCODE_POPSP); -- Restore context
      -- push_imm32(save_sp);

      -- Need one NOP to update dbg.sp (for sanity check):
      execute_opcode(OPCODE_SHORT & OPCODE_NOP);

      if (dbg.sp /= save_sp) then
         mismatch <= '1';
         print("* MEM_READ ERROR: Stack pointers don't match");
         print("sp: " & hstr(dbg.sp) & "  SAVE_SP: " & hstr(save_sp));
      end if;

----------------------------------------------------------------------------
-- MEMORY WRITE
      execute_opcode(OPCODE_SHORT & OPCODE_PUSHSP); -- Restore context
      -- Save current SP for for reference. Note the dbg.sp is not yet
      -- updated to the above command.
      save_sp <= dbg.sp;

      push_imm32(x"deadbeef");
      execute_opcode(OPCODE_SHORT & OPCODE_NOP);
      push_imm32(x"000008d8");
      execute_opcode(OPCODE_SHORT & OPCODE_STORE); -- Store indirect

      execute_opcode(OPCODE_LOADSP & '1' & x"0"); -- Restore context
      execute_opcode(OPCODE_SHORT & OPCODE_POPSP); -- Restore context

      -- Need one NOP to update dbg.sp (for sanity check):
      execute_opcode(OPCODE_SHORT & OPCODE_NOP);

      if (dbg.sp /= save_sp) then
         mismatch <= '1';
         print("* MEM_WRITE ERROR: Stack pointers don't match");
         print("sp: " & hstr(dbg.sp) & "  SAVE_SP: " & hstr(save_sp));
      end if;

----------------------------------------------------------------------------
-- VERIFY:
      mem_read(x"000008d8");

----------------------------------------------------------------------------
-- SET PC
      push_imm32(x"00000000");
      execute_opcode(OPCODE_SHORT & OPCODE_POPPC); -- Restore context
----------------------------------------------------------------------------

      wait for 100ns;
      execute_opcode(OPCODE_SHORT & OPCODE_NOP);
      getsp;

      terminate <= '1';
      wait;


   end process;


finish <= mismatch or terminate; -- or break;

end architecture Behave; -- Entity: HWDbg_Small1_TB
