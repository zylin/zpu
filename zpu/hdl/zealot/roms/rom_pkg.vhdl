------------------------------------------------------------------------------
----                                                                      ----
----  ZPU memories package                                                ----
----                                                                      ----
----  http://www.opencores.org/                                           ----
----                                                                      ----
----  Description:                                                        ----
----  This is a package with the memories used for the ZPU core.          ----
----                                                                      ----
----  To Do:                                                              ----
----  -                                                                   ----
----                                                                      ----
----  Author:                                                             ----
----    - Salvador E. Tropea, salvador inti.gob.ar                        ----
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
---- Design unit:      zpu_memory (Package)                               ----
---- File name:        rom_pkg.vhdl (template used)                       ----
---- Note:             None                                               ----
---- Limitations:      None known                                         ----
---- Errors:           None known                                         ----
---- Library:          work                                               ----
---- Dependencies:     IEEE.std_logic_1164                                ----
----                   IEEE.numeric_std                                   ----
---- Target FPGA:      Spartan 3 (XC3S1500-4-FG456)                       ----
---- Language:         VHDL                                               ----
---- Wishbone:         No                                                 ----
---- Synthesis tools:  Xilinx Release 9.2.03i - xst J.39                  ----
---- Simulation tools: GHDL [Sokcho edition] (0.2x)                       ----
---- Text editor:      SETEdit 0.5.x                                      ----
----                                                                      ----
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package zpu_memory is
   component DualPortRAM is
      generic(
         WORD_SIZE    : integer:=32;  -- Word Size 16/32
         BYTE_BITS    : integer:=2;   -- Bits used to address bytes
         BRAM_W       : integer:=15); -- Address Width
      port(
         clk_i     : in  std_logic;
         -- Port A
         a_we_i    : in  std_logic;
         a_addr_i  : in  unsigned(BRAM_W-1 downto BYTE_BITS);
         a_write_i : in  unsigned(WORD_SIZE-1 downto 0);
         a_read_o  : out unsigned(WORD_SIZE-1 downto 0);
         -- Port B
         b_we_i    : in  std_logic;
         b_addr_i  : in  unsigned(BRAM_W-1 downto BYTE_BITS);
         b_write_i : in  unsigned(WORD_SIZE-1 downto 0);
         b_read_o  : out unsigned(WORD_SIZE-1 downto 0));
   end component DualPortRAM;

   component SinglePortRAM is
      generic(
         WORD_SIZE    : integer:=32;  -- Word Size 16/32
         BYTE_BITS    : integer:=2;   -- Bits used to address bytes
         BRAM_W       : integer:=15); -- Address Width
      port(
         clk_i   : in  std_logic;
         we_i    : in  std_logic;
         re_i    : in  std_logic;
         addr_i  : in  unsigned(BRAM_W-1 downto BYTE_BITS);
         write_i : in  unsigned(WORD_SIZE-1 downto 0);
         read_o  : out unsigned(WORD_SIZE-1 downto 0);
         busy_o  : out std_logic);
   end component SinglePortRAM;
end package zpu_memory;
