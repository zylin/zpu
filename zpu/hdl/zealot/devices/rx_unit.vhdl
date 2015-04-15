------------------------------------------------------------------------------
----                                                                      ----
----  RS-232 simple Rx module                                             ----
----                                                                      ----
----  http://www.opencores.org/                                           ----
----                                                                      ----
----  Description:                                                        ----
----  Implements a simple 8N1 rx module for RS-232.                       ----
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
---- Design unit:      RxUnit(Behaviour) (Entity and architecture)        ----
---- File name:        rx_unit.vhdl                                       ----
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
   
entity RxUnit is
   port(
      clk_i    : in  std_logic;  -- System clock signal
      reset_i  : in  std_logic;  -- Reset input (sync)
      enable_i : in  std_logic;  -- Enable input (rate*4)
      read_i   : in  std_logic;  -- Received Byte Read
      rxd_i    : in  std_logic;  -- RS-232 data input
      rxav_o   : out std_logic;  -- Byte available
      datao_o  : out std_logic_vector(7 downto 0)); -- Byte received
end entity RxUnit;

architecture Behaviour of RxUnit is
   signal r_r      : std_logic_vector(7 downto 0); -- Receive register
   signal bavail_r : std_logic:='0';               -- Byte received
begin
   rxav_o <= bavail_r;
   -- Rx Process
   RxProc:
   process (clk_i)
      variable bitpos    : integer range 0 to 10; -- Position of the bit in the frame
      variable samplecnt : integer range 0 to 3;  -- Count from 0 to 3 in each bit
   begin
      if rising_edge(clk_i) then
         if reset_i='1' then
            bavail_r <= '0';
            bitpos:=0;
         else -- reset_i='0'
            if read_i='1' then
               bavail_r <= '0';
            end if;
            if enable_i='1' then
               case bitpos is
                    when 0 => -- idle
                         bavail_r <= '0';
                         if rxd_i='0' then -- Start Bit
                            samplecnt:=0;
                            bitpos:=1;
                         end if;
                    when 10 => -- Stop Bit
                         bitpos:=0;    -- next is idle
                         bavail_r <= '1';    -- Indicate byte received
                         datao_o  <= r_r; -- Store received byte
                    when others =>
                         if samplecnt=1 and bitpos>=2 then -- Sample RxD on 1
                            r_r(bitpos-2) <= rxd_i; -- Deserialisation
                         end if;
                         if samplecnt=3 then -- Increment BitPos on 3
                            bitpos:=bitpos+1;
                         end if;
               end case;
               if samplecnt=3 then
                  samplecnt:=0;
               else
                  samplecnt:=samplecnt+1;
               end if;
            end if; -- enable_i='1'
         end if; -- reset_i='0'
      end if; -- rising_edge(clk_i)
   end process RxProc;
end architecture Behaviour;

