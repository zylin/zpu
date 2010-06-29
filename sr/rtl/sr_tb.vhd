--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:30:17 06/28/2010
-- Design Name:   
-- Module Name:   D:/home/bl5599/projects/sr/sr_tb.vhd
-- Project Name:  sr
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: sr
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity sr_tb is
end sr_tb;
 
architecture testbench of sr_tb is 
 
    -- component declaration for the unit under test (uut)
 
    component sr
        generic (
            port_count_in  : positive := 4;
            port_count_out : positive := 10
        );
        port(
            di             : in  std_logic;
            do             : out std_logic;
            clk            : in  std_logic;
            latch_or_shift : in  std_logic; -- 1=latch, 0=shift
            port_in        : in  std_ulogic_vector( port_count_in -1 downto 0);
            port_out       : out std_ulogic_vector( port_count_out-1 downto 0)
        );
    end component;
    

   --inputs
   signal di             : std_ulogic := '0';
   signal clk            : std_ulogic := '0';
   signal latch_or_shift : std_ulogic := '0';
   signal port_in        : std_ulogic_vector(3 downto 0) := (others => '0');

    --outputs
   signal do       : std_ulogic;
   signal port_out : std_ulogic_vector(9 downto 0);

   procedure clocking is
   begin
   end procedure;
 
begin

    port_in <= "1100";
 
    -- instantiate the unit under test (uut)
   uut: sr port map (
          di             => di,
          do             => do,
          clk            => clk,
          latch_or_shift => latch_or_shift,
          port_in        => port_in,
          port_out       => port_out
        );
 
 

   stim_proc: process
   begin        
      wait for 50 ns;

      latch_or_shift <= '0';

      report "shift" severity note;
      di  <= '1';
      for i in 1 to 10 loop
          -- clocking;
          clk <= '1';
          wait for 10 ns;
          clk <= '0';
          wait for 10 ns;
      end loop;
      
      wait for 50 ns;
      report "latch" severity note;
      latch_or_shift <= '1';
      wait for 5 ns;

      -- clocking;
      clk <= '1';
      wait for 10 ns;
      clk <= '0';
      wait for 10 ns;

      wait for 50 ns;
      latch_or_shift <= '0';
      report "shift again" severity note;
      for i in 1 to 4 loop
          --clocking;
          clk <= '1';
          wait for 10 ns;
          clk <= '0';
          wait for 10 ns;
      end loop;

      wait for 50 ns;
      report "end simulation." severity note;
      wait;
   end process;

end testbench;
