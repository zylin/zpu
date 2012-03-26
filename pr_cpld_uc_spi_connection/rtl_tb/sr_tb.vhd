-- 
-- VHDL Test Bench Created by ISE for module: sr
--

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
            sdi            : in  std_logic;
            sdo            : out std_logic;
            clk            : in  std_logic;
            latch_or_shift : in  std_logic; -- 1=latch, 0=shift
            port_in        : in  std_ulogic_vector( port_count_in -1 downto 0);
            port_out       : out std_ulogic_vector( port_count_out-1 downto 0)
        );
    end component;
    

   --inputs
   signal sdi            : std_ulogic := '0';
   signal clk            : std_ulogic := '0';
   signal latch_or_shift : std_ulogic := '0';
   signal port_in        : std_ulogic_vector(3 downto 0) := (others => '0');

    --outputs
   signal sdo      : std_ulogic;
   signal port_out : std_ulogic_vector(9 downto 0);

   procedure clocking is
   begin
   end procedure;
 
begin

    port_in <= "1100";
 
    -- instantiate the unit under test (uut)
   uut: sr port map (
          sdi            => sdi,
          sdo            => sdo,
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
      sdi  <= '1';
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
