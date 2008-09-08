------------------------------------------------------------------------------
----                                                                      ----
----  RS-232 simple Tx module                                             ----
----                                                                      ----
----  http://www.opencores.org/                                           ----
----                                                                      ----
----  Description:                                                        ----
----  Implements a simple 8N1 tx module for RS-232.                       ----
----                                                                      ----
----  To Do:                                                              ----
----  -                                                                   ----
----                                                                      ----
----  Author:                                                             ----
----    - Philippe Carton, philippe.carton2 libertysurf.fr                ----
----    - Juan Pablo Daniel Borgna, jpdborgna gmail.com                   ----
----    - Salvador E. Tropea, salvador inti.gob.ar                        ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Copyright (c) 2001-2003 Philippe Carton                              ----
---- Copyright (c) 2005 Juan Pablo Daniel Borgna                          ----
---- Copyright (c) 2005-2008 Salvador E. Tropea                           ----
---- Copyright (c) 2005-2008 Instituto Nacional de Tecnología Industrial  ----
----                                                                      ----
---- Distributed under the GPL license                                    ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Design unit:      TxUnit(Behaviour) (Entity and architecture)        ----
---- File name:        Txunit.vhdl                                        ----
---- Note:             None                                               ----
---- Limitations:      None known                                         ----
---- Errors:           None known                                         ----
---- Library:          zpu                                                ----
---- Dependencies:     IEEE.std_logic_1164                                ----
----                   zpu.UART                                           ----
---- Target FPGA:      Spartan                                            ----
---- Language:         VHDL                                               ----
---- Wishbone:         No                                                 ----
---- Synthesis tools:  Xilinx Release 9.2.03i - xst J.39                  ----
---- Simulation tools: GHDL [Sokcho edition] (0.2x)                       ----
---- Text editor:      SETEdit 0.5.x                                      ----
----                                                                      ----
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
library zpu;
use zpu.UART.all;

entity TxUnit is
  port (
     clk_i    : in  std_logic;  -- Clock signal
     reset_i  : in  std_logic;  -- Reset input
     enable_i : in  std_logic;  -- Enable input
     load_i   : in  std_logic;  -- Load input
     txd_o    : out std_logic;  -- RS-232 data output
     busy_o   : out std_logic;  -- Tx Busy
     datai_i  : in  std_logic_vector(7 downto 0)); -- Byte to transmit
end entity TxUnit;

architecture Behaviour of TxUnit is
   signal tbuff_r  : std_logic_vector(7 downto 0); -- transmit buffer
   signal t_r      : std_logic_vector(7 downto 0); -- transmit register
   signal loaded_r : std_logic:='0';  -- Buffer loaded
   signal txd_r    : std_logic:='1';  -- Tx buffer ready
begin
  busy_o <= load_i or loaded_r;
  txd_o  <= txd_r;

  -- Tx process
  TxProc:
  process (clk_i)
     variable bitpos : integer range 0 to 10; -- Bit position in the frame
  begin
     if rising_edge(clk_i) then
        if reset_i='1' then
           loaded_r <= '0';
           bitpos:=0;
           txd_r <= '1';
        else -- reset_i='0'
           if load_i='1' then
              tbuff_r  <= datai_i;
              loaded_r <= '1';
           end if;
           if enable_i='1' then
              case bitpos is
                   when 0 => -- idle or stop bit
                        txd_r <= '1';
                        if loaded_r='1' then -- start transmit. next is start bit
                           t_r <= tbuff_r;
                           loaded_r <= '0';
                           bitpos:=1;
                        end if;
                   when 1 => -- Start bit
                        txd_r <= '0';
                        bitpos:=2;
                   when others =>
                        txd_r <= t_r(bitpos-2); -- Serialisation of t_r
                        bitpos:=bitpos+1;
              end case;
              if bitpos=10 then -- bit8. next is stop bit
                 bitpos:=0;
              end if;
           end if; -- enable_i='1'
        end if; -- reset_i='0'
     end if; -- rising_edge(clk_i)
  end process TxProc;
end architecture Behaviour;
