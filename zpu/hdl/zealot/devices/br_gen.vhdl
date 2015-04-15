------------------------------------------------------------------------------
----                                                                      ----
----  RS-232 baudrate generator                                           ----
----                                                                      ----
----  http://www.opencores.org/                                           ----
----                                                                      ----
----  Description:                                                        ----
----  This counter is a parametrizable clock divider. The count value is  ----
----  the generic parameter COUNT. It has a chip enable ce_i input.       ----
----  (will count only if CE is high).                                    ----
----  When it overflows, will emit a pulse on o_o.                        ----
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
---- Design unit:      BRGen(Behaviour) (Entity and architecture)         ----
---- File name:        br_gen.vhdl                                        ----
---- Note:             None                                               ----
---- Limitations:      None known                                         ----
---- Errors:           None known                                         ----
---- Library:          zpu                                                ----
---- Dependencies:     IEEE.std_logic_1164                                ----
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

entity BRGen is
  generic(
     COUNT : integer range 0 to 65535);-- Count revolution
  port (
     clk_i   : in  std_logic;  -- Clock
     reset_i : in  std_logic;  -- Reset input
     ce_i    : in  std_logic;  -- Chip Enable
     o_o     : out std_logic); -- Output
end entity BRGen;

architecture Behaviour of BRGen is

begin
  CountGen:
  if COUNT/=1 generate
     Counter:
     process (clk_i)
        variable cnt : integer range 0 to COUNT-1;
     begin
        if rising_edge(clk_i) then
           o_o <= '0';
           if reset_i='1' then
              cnt:=COUNT-1;
           elsif ce_i='1' then
              if cnt=0 then
                 o_o <= '1';
                 cnt:=COUNT-1;
              else
                 cnt:=cnt-1;
              end if; -- cnt/=0
           end if; -- ce_i='1'
        end if; -- rising_edge(clk_i)
     end process Counter;
  end generate CountGen;

  CountWire:
  if COUNT=1 generate
     o_o <= '0' when reset_i='1' else ce_i;
  end generate CountWire;
end architecture Behaviour; -- Entity: BRGen

