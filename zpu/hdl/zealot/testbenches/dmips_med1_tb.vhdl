------------------------------------------------------------------------------
----                                                                      ----
----  Testbench for the ZPU Medium connection to the FPGA                 ----
----                                                                      ----
----  http://www.opencores.org/                                           ----
----                                                                      ----
----  Description:                                                        ----
----  This is a testbench to simulate the ZPU_Med1 core as used in the    ----
----  dmips_med1.vhdl                                                     ----
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
---- Design unit:      DMIPS_Med1_TB(Behave) (Entity and architecture)    ----
---- File name:        dmips_med1_tb.vhdl                                 ----
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
---- Simulation tools: GHDL [Sokcho edition] (0.2x)                       ----
---- Text editor:      SETEdit 0.5.x                                      ----
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

entity DMIPS_Med1_TB is
end entity DMIPS_Med1_TB;

architecture Behave of DMIPS_Med1_TB is
   constant WORD_SIZE  : natural:=32; -- 32 bits data path
   constant ADDR_W     : natural:=18; -- 18 bits address space=256 kB, 128 kB I/O
   constant BRAM_W     : natural:=15; -- 15 bits RAM space=32 kB
   constant D_CARE_VAL : std_logic:='0'; -- Fill value
   constant CLK_FREQ   : positive:=50; -- 50 MHz clock
   constant CLK_S_PER  : time:=1 us/(2.0*real(CLK_FREQ)); -- Clock semi period
   constant BRATE      : positive:=115200;

   component ZPU_Med1 is
      generic(
         WORD_SIZE  : natural:=32;  -- 32 bits data path
         D_CARE_VAL : std_logic:='X'; -- Fill value
         CLK_FREQ   : positive:=50; -- 50 MHz clock
         BRATE      : positive:=9600; -- RS232 baudrate
         ADDR_W     : natural:=18;  -- 18 bits address space=256 kB, 128 kB I/O
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
   end component ZPU_Med1;

   signal clk          : std_logic;
   signal reset        : std_logic:='1';

   signal break        : std_logic;
   signal dbg          : zpu_dbgo_t; -- Debug info
   signal rs232_tx     : std_logic;
   signal rs232_rx     : std_logic;
begin
   zpu : ZPU_Med1
      generic map(
         WORD_SIZE => WORD_SIZE, D_CARE_VAL => D_CARE_VAL,
         CLK_FREQ => CLK_FREQ, BRATE => BRATE, ADDR_W => ADDR_W,
         BRAM_W => BRAM_W)
      port map(
         clk_i => clk, rst_i => reset, rs232_tx_o => rs232_tx,
         rs232_rx_i => rs232_rx, break_o => break, dbg_o => dbg,
         gpio_in => (others => '0'));

   trace_mod : Trace
      generic map(
         ADDR_W => ADDR_W, WORD_SIZE => WORD_SIZE,
         LOG_FILE => "dmips_med1.log")
      port map(
         clk_i => clk, dbg_i => dbg, stop_i => break, busy_i => '0');

   do_clock:
   process
   begin
      clk <= '0';
      wait for CLK_S_PER;
      clk <= '1';
      wait for CLK_S_PER;
      if break='1' then
         print("* Break asserted, end of test");
         wait;
      end if;
   end process do_clock;

   do_reset:
   process
   begin
      wait until rising_edge(clk);
      reset <= '0';
   end process do_reset;
end architecture Behave; -- Entity: DMIPS_Med1_TB
