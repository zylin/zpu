------------------------------------------------------------------------------
----                                                                      ----
----  ZPU Small connection to the FPGA pins                               ----
----                                                                      ----
----  http://www.opencores.org/                                           ----
----                                                                      ----
----  Description:                                                        ----
----  This module connects the ZPU_Small1 (zpu_small1.vhdl) core to a     ----
----  Spartan 3 1500 Xilinx FPGA available in the GR-XC3S board from      ----
----  Pender.                                                             ----
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
---- Distributed under the GPL license                                    ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Design unit:      DMIPS_Small1(FPGA) (Entity and architecture)       ----
---- File name:        dmips_small1.vhdl                                  ----
---- Note:             None                                               ----
---- Limitations:      None known                                         ----
---- Errors:           None known                                         ----
---- Library:          work                                               ----
---- Dependencies:     IEEE.std_logic_1164                                ----
----                   IEEE.numeric_std                                   ----
----                   zpu.zpu_pkg                                        ----
---- Target FPGA:      Spartan 3 (XC3S1500-4-FG456)                       ----
---- Language:         VHDL                                               ----
---- Wishbone:         No                                                 ----
---- Synthesis tools:  Xilinx Release 9.2.03i - xst J.39                  ----
---- Simulation tools: N/A                                                ----
---- Text editor:      SETEdit 0.5.x                                      ----
----                                                                      ----
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library zpu;
use zpu.zpupkg.all;

entity DMIPS_Small1 is
   generic(
      WORD_SIZE  : natural:=32;  -- 32 bits data path
      D_CARE_VAL : std_logic:='0'; -- Fill value, I got better results with it
      CLK_FREQ   : positive:=50; -- 50 MHz clock
      BRATE      : positive:=115200; -- RS-232 baudrate
      ADDR_W     : natural:=18;  -- 18 bits address space=256 kB, 128 kB I/O
      BRAM_W     : natural:=15); -- 15 bits RAM space=32 kB
   port(
      clk_i      : in  std_logic;  -- CPU clock
      rst_i      : in  std_logic;  -- Reset
      rs232_tx_o : out std_logic;  -- UART Tx
      rs232_rx_i : in  std_logic); -- UART Rx

   constant BRD_PB1_I      : string:="D19";  -- SWITCH8==S2
   constant BRD_CLK1_I     : string:="AA12"; -- 50 MHz clock
   --constant BRD_CLK1_I     : string:="AB12"; -- 40 MHz clock
   -- UART: direct 1:1 cable
   constant BRD_TX_O       : string:="L4"; -- UART 1 (J1) TXD1 DB9 pin 2
   constant BRD_RX_I       : string:="L3"; -- UART 1 (J1) RXD1 DB9 pin 3

   ------------
   -- Pinout --
   ------------
   attribute LOC        : string;
   attribute IOSTANDARD : string;
   constant  IOSTD      : string:="LVTTL";

   attribute LOC        of rst_i       : signal is BRD_PB1_I;
   attribute IOSTANDARD of rst_i       : signal is IOSTD;
   attribute LOC        of clk_i       : signal is BRD_CLK1_I;
   attribute LOC        of rs232_tx_o  : signal is BRD_TX_O;
   attribute IOSTANDARD of rs232_tx_o  : signal is IOSTD;
   attribute LOC        of rs232_rx_i  : signal is BRD_RX_I;
   attribute IOSTANDARD of rs232_rx_i  : signal is IOSTD;
end entity DMIPS_Small1;

architecture FPGA of DMIPS_Small1 is
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
         break_o    : out std_logic;  -- Break executed
         dbg_o      : out zpu_dbgo_t; -- Debug info
         rs232_tx_o : out std_logic;  -- UART Tx
         rs232_rx_i : in  std_logic;  -- UART Rx
         gpio_in    : in  std_logic_vector(31 downto 0);
         gpio_out   : out std_logic_vector(31 downto 0);
         gpio_dir   : out std_logic_vector(31 downto 0)  -- 1 = in, 0 = out
         );
   end component ZPU_Small1;
begin
   zpu : ZPU_Small1
      generic map(
         WORD_SIZE => WORD_SIZE, D_CARE_VAL => D_CARE_VAL,
         CLK_FREQ => CLK_FREQ, BRATE => BRATE, ADDR_W => ADDR_W,
         BRAM_W => BRAM_W)
      port map(
         clk_i => clk_i, rst_i => rst_i, rs232_tx_o => rs232_tx_o,
         rs232_rx_i => rs232_rx_i, dbg_o => open, gpio_in => (others => '0'));
end architecture FPGA; -- Entity: DMIPS_Small1

