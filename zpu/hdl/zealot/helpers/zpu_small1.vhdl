------------------------------------------------------------------------------
----                                                                      ----
----  ZPU Small + PHI I/O + BRAM                                          ----
----                                                                      ----
----  http://www.opencores.org/                                           ----
----                                                                      ----
----  Description:                                                        ----
----  ZPU is a 32 bits small stack cpu. This is a helper that joins the   ----
----  small version, the PHI I/O basic layout and a program BRAM.         ----
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
---- Design unit:      ZPU_Small1(Structural) (Entity and architecture)   ----
---- File name:        zpu_small1.vhdl                                    ----
---- Note:             None                                               ----
---- Limitations:      None known                                         ----
---- Errors:           None known                                         ----
---- Library:          work                                               ----
---- Dependencies:     IEEE.std_logic_1164                                ----
----                   IEEE.numeric_std                                   ----
----                   zpu.zpupkg                                         ----
----                   work.zpu_memory                                    ----
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

library zpu;
use zpu.zpupkg.all;

-- RAM declaration
library work;
use work.zpu_memory.all;

entity ZPU_Small1 is
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
      break_o    : out std_logic;  -- Break executed
      dbg_o      : out zpu_dbgo_t; -- Debug info
      rs232_tx_o : out std_logic;  -- UART Tx
      rs232_rx_i : in  std_logic;  -- UART Rx
      gpio_in    : in  std_logic_vector(31 downto 0);
      gpio_out   : out std_logic_vector(31 downto 0);
      gpio_dir   : out std_logic_vector(31 downto 0)  -- 1 = in, 0 = out
      );
end entity ZPU_Small1;

architecture Structural of ZPU_Small1 is
   constant BYTE_BITS  : integer:=WORD_SIZE/16; -- # of bits in a word that addresses bytes
   constant IO_BIT     : integer:=ADDR_W-1; -- Address bit to determine this is an I/O
   constant BRDIVISOR  : positive:=CLK_FREQ*1e6/BRATE/4;

   -- Program+data+stack BRAM
   -- Port A
   signal a_we     : std_logic;
   signal a_addr   : unsigned(BRAM_W-1 downto BYTE_BITS);
   signal a_write  : unsigned(WORD_SIZE-1 downto 0);
   signal a_read   : unsigned(WORD_SIZE-1 downto 0);
   -- Port B
   signal b_we     : std_logic;
   signal b_addr   : unsigned(BRAM_W-1 downto BYTE_BITS);
   signal b_write  : unsigned(WORD_SIZE-1 downto 0);
   signal b_read   : unsigned(WORD_SIZE-1 downto 0);

   -- I/O space
   signal io_busy  : std_logic;
   signal io_write : unsigned(WORD_SIZE-1 downto 0);
   signal io_read  : unsigned(WORD_SIZE-1 downto 0);
   signal io_addr  : unsigned(ADDR_W-1 downto 0);
   signal phi_addr : unsigned(2 downto 0);
   signal io_we    : std_logic;
   signal io_re    : std_logic;
begin
   memory: DualPortRAM
      generic map(
         WORD_SIZE => WORD_SIZE, BYTE_BITS => BYTE_BITS, BRAM_W => BRAM_W)
      port map(
         clk_i => clk_i,
         -- Port A
         a_we_i => a_we, a_addr_i => a_addr, a_write_i => a_write,
         a_read_o => a_read,
         -- Port B
         b_we_i => b_we, b_addr_i => b_addr, b_write_i => b_write,
         b_read_o => b_read);

   -- I/O: Phi layout
   io_map: ZPUPhiIO
      generic map(
         BRDIVISOR => BRDIVISOR, 
         LOG_FILE  => "zpu_small1_io.log"
         )
      port map(
         clk_i      => clk_i, 
         reset_i    => rst_i, 
         busy_o     => io_busy, 
         we_i       => io_we,
         re_i       => io_re, 
         data_i     => io_write, 
         data_o     => io_read,
         addr_i     => phi_addr, 
         rs232_rx_i => rs232_rx_i, 
         rs232_tx_o => rs232_tx_o,
         br_clk_i   => '1',
         gpio_in    => gpio_in,
         gpio_out   => gpio_out,
         gpio_dir   => gpio_dir
         );
   phi_addr <= io_addr(4 downto 2);

   zpu : ZPUSmallCore
      generic map(
         WORD_SIZE => WORD_SIZE, ADDR_W => ADDR_W, MEM_W => BRAM_W,
         D_CARE_VAL => D_CARE_VAL)
      port map(
         clk_i => clk_i, reset_i => rst_i, interrupt_i => '0',
         break_o => break_o, dbg_o => dbg_o,
         -- BRAM (text, data, bss and stack)
         a_we_o => a_we, a_addr_o => a_addr, a_o => a_write, a_i => a_read,
         b_we_o => b_we, b_addr_o => b_addr, b_o => b_write, b_i => b_read,
         -- Memory mapped I/O
         mem_busy_i => io_busy, data_i => io_read, data_o => io_write,
         addr_o => io_addr, write_en_o => io_we, read_en_o => io_re);
end architecture Structural; -- Entity: ZPU_Small1

