------------------------------------------------------------------------------
----                                                                      ----
----  ZPU Trace Module                                                    ----
----                                                                      ----
----  http://www.opencores.org/                                           ----
----                                                                      ----
----  Description:                                                        ----
----  ZPU is a 32 bits small stack cpu. This is a module to log an        ----
----  execution trace.                                                    ----
----                                                                      ----
----  To Do:                                                              ----
----  -                                                                   ----
----                                                                      ----
----  Author:                                                             ----
----    - Øyvind Harboe, oyvind.harboe zylin.com                          ----
----    - Salvador E. Tropea, salvador inti.gob.ar                        ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Copyright (c) 2008 Øyvind Harboe <oyvind.harboe zylin.com>           ----
---- Copyright (c) 2008 Salvador E. Tropea <salvador inti.gob.ar>         ----
---- Copyright (c) 2008 Instituto Nacional de Tecnología Industrial       ----
----                                                                      ----
---- Distributed under the BSD license                                    ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Design unit:      Trace(Behave) (Entity and architecture)            ----
---- File name:        trace.vhdl                                         ----
---- Note:             None                                               ----
---- Limitations:      None known                                         ----
---- Errors:           None known                                         ----
---- Library:          zpu                                                ----
---- Dependencies:     IEEE.std_logic_1164                                ----
----                   IEEE.numeric_std                                   ----
----                   std.textio                                         ----
----                   zpu.zpupkg                                         ----
----                   zpu.txt_util                                       ----
---- Target FPGA:      N/A                                                ----
---- Language:         VHDL                                               ----
---- Wishbone:         No                                                 ----
---- Synthesis tools:  N/A                                                ----
---- Simulation tools: GHDL [Sokcho edition] (0.2x)                       ----
---- Text editor:      SETEdit 0.5.x                                      ----
----                                                                      ----
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use std.textio.all;

library zpu;
use zpu.zpupkg.all;
use zpu.txt_util.all;

entity Trace is
   generic(
      LOG_FILE   : string:="trace.txt"; -- Name of the trace file
      ADDR_W     : integer:=16;  -- Address width
      WORD_SIZE  : integer:=32); -- 16/32
   port(
      clk_i      : in std_logic;
      dbg_i      : in zpu_dbgo_t;
      stop_i     : in std_logic;
      busy_i     : in std_logic
      );
end entity Trace;
   
architecture Behave of Trace is
   file l_file : text open write_mode is LOG_FILE;
   signal counter : unsigned(63 downto 0);
begin
   -- write data and control information to a file
   receive_data:
   process
      variable l       : line;
      variable stk_min : unsigned(31 downto 0):=(others => '1');
      variable stk_ini : unsigned(31 downto 0);
      variable first   : boolean:=true;
      variable sp_off  : unsigned(4 downto 0);
      variable idim    : boolean:=false;
      variable im_val  : unsigned(31 downto 0):=(others => '0');
   begin
      counter <= to_unsigned(1,64);
      -- print header for the logfile
      print(l_file,"#PC      Opcode    SP       A=[SP]    B=[SP+1]  Clk Counter        Assembler");
      print(l_file,"#---------------------------------------------------------------------------");
      print(l_file," ");
   
      wait until clk_i='1';
      wait until clk_i='0';
   
      while true loop
         counter <= counter+1;
         if dbg_i.b_inst='1' then
            write(l, "0x"&hstr(dbg_i.pc(ADDR_W-1 downto 0))&
                    " 0x"&hstr(dbg_i.opcode)&
                    " 0x"&hstr(dbg_i.sp)&
                    " 0x"&hstr(dbg_i.stk_a)&
                    " 0x"&hstr(dbg_i.stk_b)&
                    " 0x"&hstr(counter)&" ");
            --------------------------
            -- Instruction Decoder  --
            --------------------------
            sp_off(4):=not dbg_i.opcode(4);
            sp_off(3 downto 0):=dbg_i.opcode(3 downto 0);
            if dbg_i.opcode(7 downto 7)=OPCODE_IM then
               if idim then
                  im_val(31 downto 7):=im_val(24 downto 0);
                  im_val(6 downto 0):=dbg_i.opcode(6 downto 0);
               else
                  im_val:=unsigned(resize(signed(dbg_i.opcode(6 downto 0)),32));
               end if;
               idim:=true;
               write(l,"im 0x"&hstr(dbg_i.opcode(6 downto 0))&" ; 0x"&hstr(im_val));
            elsif dbg_i.opcode(7 downto 5)=OPCODE_STORESP then
               if sp_off=0 then
                  write(l,string'("storesp 0 ; pop"));
               elsif sp_off=1 then
                  write(l,string'("storesp 4 ; 1*4 = popdown"));
               else
                  write(l,"storesp "&integer'image(to_integer(sp_off)*4)&" ; "&
                        integer'image(to_integer(sp_off))&"*4");
               end if;
            elsif dbg_i.opcode(7 downto 5)=OPCODE_LOADSP then
               if sp_off=0 then
                  write(l,string'("loadsp 0 ; dup"));
               elsif sp_off=1 then
                  write(l,string'("loadsp 4 ; 1*4 = dupstkb"));
               else
                  write(l,"loadsp "&integer'image(to_integer(sp_off)*4)&" ; "&
                        integer'image(to_integer(sp_off))&"*4");
               end if;
            elsif dbg_i.opcode(7 downto 5)=OPCODE_EMULATE then
               if dbg_i.opcode(5 downto 0)=OPCODE_EQ then
                  write(l,string'("eq"));
               elsif dbg_i.opcode(5 downto 0)=OPCODE_LOADB then
                  write(l,string'("loadb"));
               elsif dbg_i.opcode(5 downto 0)=OPCODE_NEQBRANCH then
                  write(l,string'("neqbranch"));
               elsif dbg_i.opcode(5 downto 0)=OPCODE_PUSHSPADD then
                  write(l,string'("pushspadd"));
               elsif dbg_i.opcode(5 downto 0)=OPCODE_LESSTHAN then
                  write(l,string'("lessthan"));
               elsif dbg_i.opcode(5 downto 0)=OPCODE_ULESSTHAN then
                  write(l,string'("ulessthan"));
               elsif dbg_i.opcode(5 downto 0)=OPCODE_MULT then
                  write(l,string'("mult"));
               elsif dbg_i.opcode(5 downto 0)=OPCODE_STOREB then
                  write(l,string'("storeb"));
               elsif dbg_i.opcode(5 downto 0)=OPCODE_CALLPCREL then
                  write(l,string'("callpcrel"));
               elsif dbg_i.opcode(5 downto 0)=OPCODE_SUB then
                  write(l,string'("sub"));
               elsif dbg_i.opcode(5 downto 0)=OPCODE_LESSTHANOREQUAL then
                  write(l,string'("lessthanorequal"));
               elsif dbg_i.opcode(5 downto 0)=OPCODE_ULESSTHANOREQUAL then
                  write(l,string'("ulessthanorequal"));
               elsif dbg_i.opcode(5 downto 0)=OPCODE_CALL then
                  write(l,string'("call"));
               elsif dbg_i.opcode(5 downto 0)=OPCODE_POPPCREL then
                  write(l,string'("poppcrel"));
               elsif dbg_i.opcode(5 downto 0)=OPCODE_LSHIFTRIGHT then
                  write(l,string'("lshiftright"));
               elsif dbg_i.opcode(5 downto 0)=OPCODE_LOADH then
                  write(l,string'("loadh"));
               elsif dbg_i.opcode(5 downto 0)=OPCODE_STOREH then
                  write(l,string'("storeh"));
               elsif dbg_i.opcode(5 downto 0)=OPCODE_ASHIFTLEFT then
                  write(l,string'("ashiftleft"));
               elsif dbg_i.opcode(5 downto 0)=OPCODE_ASHIFTRIGHT then
                  write(l,string'("ashiftright"));
               elsif dbg_i.opcode(5 downto 0)=OPCODE_NEQ then
                  write(l,string'("neq"));
               elsif dbg_i.opcode(5 downto 0)=OPCODE_NEG then
                  write(l,string'("neg"));
               elsif dbg_i.opcode(5 downto 0)=OPCODE_XOR then
                  write(l,string'("xor"));
               elsif dbg_i.opcode(5 downto 0)=OPCODE_DIV then
                  write(l,string'("div"));
               elsif dbg_i.opcode(5 downto 0)=OPCODE_MOD then
                  write(l,string'("mod"));
               elsif dbg_i.opcode(5 downto 0)=OPCODE_EQBRANCH then
                  write(l,string'("eqbranch"));
               elsif dbg_i.opcode(5 downto 0)=OPCODE_CONFIG then
                  write(l,string'("config"));
               elsif dbg_i.opcode(5 downto 0)=OPCODE_PUSHPC then
                  write(l,string'("pushpc"));
               else
                  write(l,integer'image(to_integer(dbg_i.opcode(5 downto 0)))&
                        " ; invalid emulated instruction");
               end if;
            elsif dbg_i.opcode(7 downto 4)=OPCODE_ADDSP then
               if sp_off=0 then
                  write(l,string'("addsp 0 ; shift"));
               elsif sp_off=1 then
                  write(l,string'("addsp 4 ; 1*4 = addtop"));
               else
                  write(l,"addsp "&integer'image(to_integer(sp_off)*4)&" ; "&
                        integer'image(to_integer(sp_off))&"*4");
               end if;
            else -- OPCODE_SHORT
               case dbg_i.opcode(3 downto 0) is
                    when OPCODE_BREAK =>
                         write(l,string'("break"));
                    when OPCODE_PUSHSP =>
                         write(l,string'("pushsp"));
                    when OPCODE_POPPC =>
                         write(l,string'("poppc"));
                    when OPCODE_ADD =>
                         write(l,string'("add"));
                    when OPCODE_OR =>
                         write(l,string'("or"));
                    when OPCODE_AND =>
                         write(l,string'("and"));
                    when OPCODE_LOAD =>
                         write(l,string'("load"));
                    when OPCODE_NOT =>
                         write(l,string'("not"));
                    when OPCODE_FLIP =>
                         write(l,string'("flip"));
                    when OPCODE_STORE =>
                         write(l,string'("store"));
                    when OPCODE_POPSP =>
                         write(l,string'("popsp"));
                    when OPCODE_NOP =>
                         write(l,string'("nop"));
                    when others =>
                         write(l,integer'image(to_integer(dbg_i.opcode))&
                               " ; invalid instruction");
               end case;
            end if;
            if dbg_i.opcode(7 downto 7)/=OPCODE_IM then
               idim:=false;
            end if;
            -----------------------------
            -- End Instruction Decoder --
            -----------------------------
            writeline(l_file,l);
            if dbg_i.sp<stk_min then
               stk_min:=dbg_i.sp;
            end if;
            if first then
               stk_ini:=dbg_i.sp+8;
               first:=false;
            end if;
         end if;
         wait until clk_i='0' or stop_i='1';
         if stop_i='1' then
            print(output,"Minimum SP: 0x"&hstr(stk_min)&" Size: 0x"&hstr(stk_ini-stk_min));
            wait;
         end if;
      end loop;
   end process receive_data;
end Behave;
 
