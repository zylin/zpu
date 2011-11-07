-- Test vectors for the synthesis test for the fixed point math package
-- This test is designed to test fixed_synth and exercise much of the entity.
-- Created for vhdl-200x by David Bishop (dbishop@vhdl.org)
-- --------------------------------------------------------------------
--   modification history : Last Modified $Date: 2006-06-08 10:55:54-04 $
--   Version $Id: test_fixed_synth.vhdl,v 1.1 2006-06-08 10:55:54-04 l435385 Exp $
-- --------------------------------------------------------------------

entity test_fixed_synth is
  generic (
    quiet : boolean := false);  -- make the simulation quiet
end entity test_fixed_synth;

library ieee, ieee_proposed;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee_proposed.fixed_pkg.all;
architecture testbench of test_fixed_synth is

  procedure report_error (
    constant errmes : in string;  -- error message
    actual : in sfixed;  -- data from algorithm
    constant expected : in sfixed) is  -- reference data
  begin  -- function report_error
    assert actual = expected
      report errmes & CR
      & "Actual: " & to_string(actual)
      & " (" & real'image(to_real(actual)) & ")" & CR
      & "     /= " & to_string(expected)
      & " (" & real'image(to_real(expected)) & ")"
      severity error;
    return;
  end procedure report_error;
  
  -- Device under test.  Note that all inputs and outputs are std_logic_vector.
  --  This entity can be use both pre and post synthesis.
  component fixed_synth is
    port (
      in1, in2   : in  std_logic_vector (15 downto 0);  -- inputs
      out1       : out std_logic_vector (15 downto 0);  -- output
      cmd        : in  std_logic_vector (3 downto 0);
      clk, rst_n : in  std_ulogic);                     -- clk and reset
  end component fixed_synth;
  constant clock_period : time := 500 ns;  -- clock period
  subtype sfixed7 is sfixed (3 downto -3);  -- 7 bit
  subtype sfixed16 is sfixed (7 downto -8);  -- 16 bit
  signal stop_clock : boolean := false;  -- stop the clock
  signal clk, rst_n : std_ulogic;                      -- clk and reset
  signal in1slv, in2slv, out1slv : std_logic_vector(15 downto 0);
  signal in1, in2   : sfixed16;             -- inputs
  signal out1       : sfixed16;             -- output
  signal cmd : std_logic_vector (3 downto 0);  -- command string
begin  -- architecture testbench

  -- From fixed point to Std_logic_vector
  in1slv <= to_slv(in1);
  in2slv <= to_slv(in2);
  -- Std_logic_vector to fixed point.
  out1 <= to_sfixed(out1slv, out1'high, out1'low);
  DUT: fixed_synth
    port map (
      in1   => in1slv,     -- [in  std_logic_vector (15 downto 0)] inputs
      in2   => in2slv,     -- [in  std_logic_vector (15 downto 0)] inputs
      out1  => out1slv,    -- [out std_logic_vector (15 downto 0)] output
      cmd   => cmd,                     -- [in  std_logic_vector (2 downto 0)]
      clk   => clk,                     -- [in  std_ulogic] clk and reset
      rst_n => rst_n);                  -- [in std_ulogic] clk and reset
  
  -- purpose: clock driver
  clkprc: process is
  begin  -- process clkprc
    if (not stop_clock) then
      clk <= '0';
      wait for clock_period/2.0;
      clk <= '1';
      wait for clock_period/2.0;
    else
      wait;
    end if;
  end process clkprc;

  -- purpose: reset driver
  reset_proc: process is
  begin  -- process reset_proc
    rst_n <= '0';
    wait for clock_period * 2.0;
    rst_n <= '1';
    wait;
  end process reset_proc;

  -- purpose: main test loop
  tester: process is
  begin  -- process tester
    cmd <= "0000";                       -- add mode
    in1 <= (others => '0');
    in2 <= (others => '0');
    wait for clock_period;
    wait for clock_period;
    wait for clock_period;
    wait for clock_period;
    in1 <= "0000011010000000";  -- 6.5
    in2 <= "0000001100000000";  -- 3
    wait for clock_period;
    cmd <= "0001";                        -- subtract mode
    in1 <= "0000011010000000";  -- 6.5
    in2 <= "0000001100000000";  -- 3
    wait for clock_period;
    cmd <= "0010";                        -- multiply mode
    in1 <= "0000011010000000";  -- 6.5
    in2 <= "0000001100000000";  -- 3
    wait for clock_period;
    cmd <= "0000";                       -- add mode
    in1 <= "0000000010000000";          -- 0.5
    in2 <= "0000000010000000";          -- 0.5
    wait for clock_period;
    in1 <= to_sfixed (3.14, sfixed16'high, sfixed16'low);
    in2 <= "0000001100000000";  -- 3
    wait for clock_period;
    cmd <= "0011";                       -- divide
    in1 <= "0000000010000000";          -- 0.5
    in2 <= "0000000010000000";          -- 0.5
    wait for clock_period;
    in1 <= to_sfixed (-0.5, sfixed16'high, sfixed16'low);          -- -0.5
    in2 <= "0000000010000000";          -- 0.5
    wait for clock_period;
    cmd <= "0100";                      -- unsigned add
    in1 <= "0000011010000000";  -- 6.5
    in2 <= "0000001100000000";  -- 3
    wait for clock_period;
    cmd <= "0101";                        -- subtract mode
    in1 <= "0000011010000000";  -- 6.5
    in2 <= "0000001100000000";  -- 3
    wait for clock_period;
    cmd <= "0110";                        -- multiply mode
    in1 <= "0000011010000000";  -- 6.5
    in2 <= "0000001100000000";  -- 3
    wait for clock_period;
    cmd <= "0100";                       -- add mode
    in1 <= "0000000010000000";          -- 0.5
    in2 <= "0000000010000000";          -- 0.5
    wait for clock_period;
    in1 <= to_sfixed (3.14, sfixed16'high, sfixed16'low);
    in2 <= "0000001100000000";  -- 3
    wait for clock_period;
    cmd <= "0111";                       -- divide
    in1 <= "0000000010000000";          -- 0.5
    in2 <= "0000000010000000";          -- 0.5
    wait for clock_period;
    in1 <= to_sfixed (6.5, sfixed16'high, sfixed16'low);          -- 6.5
    in2 <= "0000000010000000";          -- 0.5
    wait for clock_period;
    -- resize
    cmd <= "1000";
    in1 <= to_sfixed (5.25, in1);
    in2 <= to_sfixed (-5.25, in2);
    wait for clock_period;
    in1 <= to_sfixed (21.125, in1);
    in2 <= to_sfixed (21.125, in2);
    wait for clock_period;
    in2 <= (in2'high => '0', in2'high-1 => '0', others => '0');
    cmd <= "1001";                      -- SIGNED
    in1 <= to_sfixed (6.25, in1);
    wait for clock_period;
    in2 <= (in2'high => '0', in2'high-1 => '1', others => '0');
    cmd <= "1001";                      -- UNSIGNED
    in1 <= to_sfixed (7.25, in1);
    wait for clock_period;
    in2 <= (in2'high => '1', in2'high-1 => '0', others => '0');
    cmd <= "1001";                      -- SIGNED
    in1 <= to_sfixed (6.25, in1);
    wait for clock_period;
    in2 <= (in2'high => '1', in2'high-1 => '1', others => '0');
    cmd <= "1001";                      -- UNSIGNED
    in1 <= to_sfixed (7.25, in1);
    wait for clock_period;
    cmd <= "1010";
    in2 <= (in2'high => '0', in2'high-1 => '0', others => '0');
    in1 <= to_sfixed (3, in1);
    wait for clock_period;
    cmd <= "1010";
    in2 <= (in2'high => '0', in2'high-1 => '1', others => '0');
    in1 <= to_sfixed (5, in1);
    wait for clock_period;
    cmd <= "1010";
    in2 <= (in2'high => '1', in2'high-1 => '0', others => '0');
    in1 <= to_sfixed (-5.5, in1);
    wait for clock_period;
    cmd <= "1010";
    in2 <= (in2'high => '1', in2'high-1 => '1', others => '0');
    in1 <= to_sfixed (7.25, in1);    
    wait for clock_period;
    cmd <= "1010";                      -- abs (mod)
    in2 <= (in2'high => '1', in2'high-1 => '0', others => '0');
    in1 <= to_sfixed (-42, in1);
    wait for clock_period;
    cmd <= "1011";                      -- mod
    in1 <= to_sfixed (6.25, in1);
    in2 <= to_sfixed (6, in2);
    wait for clock_period;
    cmd <= "1100";                      -- REM
    in1 <= to_sfixed (6.25, in1);
    in2 <= to_sfixed (6, in2);
    wait for clock_period;
    cmd <= "1101";                      -- srl
    in1 <= to_sfixed (5.25, in1);
    in2 <= to_sfixed (-1, in2);
    wait for clock_period;
    cmd <= "1110";                      -- sra
    in1 <= to_sfixed (-7.25, in1);
    in2 <= to_sfixed (1, in2);
    wait for clock_period;
    cmd <= "1111";                      -- compare
    in1 <= to_sfixed (42, in1);
    in2 <= to_sfixed (42, in1);
    wait for clock_period;
    in1 <= to_sfixed (45, in1);
    in2 <= to_sfixed (90, in1);
    wait for clock_period;
    in1 <= to_sfixed (3.125, in1);
    in2 <= (others => '0');
    wait for clock_period;
    in1 <= "0110111110101111";
    in2 <= "1111111111111111";
    wait for clock_period;
    in1 <= (others => '0');
    in2 <= (others => '0');
    wait for clock_period;
    in1 <= "0000111000000000";
    in2 <= "0000111000000000";
    wait for clock_period;
    in1 <= (others => '1');
    in2 <= (others => '1');
    wait for clock_period;
    wait for clock_period;

    wait for clock_period;
    cmd <= "0000";                       -- add mode
    in1 <= (others => '0');
    in2 <= (others => '0');
    wait for clock_period;
    wait for clock_period;
    wait for clock_period;
    wait for clock_period;
    wait for clock_period;
    wait for clock_period;
    wait for clock_period;
    wait for clock_period;
    wait;
  end process tester;

  -- purpose: check the output of the tester
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  checktest: process is
    constant fxzero : sfixed16 := (others => '0');  -- zero
    variable chks16 : sfixed16;         -- variable
    variable sm1, sm2 : sfixed7;        -- small fixed point
  begin  -- process checktest
    wait for clock_period/2.0;
    wait for clock_period;
    wait for clock_period;
    waitloop: while (out1 = fxzero) loop
      wait for clock_period;
    end loop waitloop;
    chks16 := to_sfixed ((3.0+6.5), sfixed16'high, sfixed16'low);
    report_error ( "3.0 + 6.5 error",
                   out1,
                   chks16);
    wait for clock_period;
    chks16 := to_sfixed ((6.5 - 3.0), sfixed16'high, sfixed16'low);
    report_error ( "6.5 - 3.0 error",
                   out1,
                   chks16);
    wait for clock_period;
    chks16 := to_sfixed ((6.5 * 3.0), sfixed16'high, sfixed16'low);
    report_error ( "6.5 * 3.0 error",
                   out1,
                   chks16);
    wait for clock_period;
    chks16 := to_sfixed (1, sfixed16'high, sfixed16'low);
    report_error ( "0.5 + 0.5 error",
                   out1,
                   chks16);
    wait for clock_period;
    chks16 := to_sfixed (6.14, sfixed16'high, sfixed16'low);
    report_error ( "3.14 + 3 error",
                   out1,
                   chks16);
    wait for clock_period;
    chks16 := "0000000100000000";
    report_error ( "0.5/0.5 error",
                   out1,
                   chks16);
    wait for clock_period;
    chks16 := to_sfixed (-1, sfixed16'high, sfixed16'low);
    report_error ( "-0.5/0.5 error",
                   out1,
                   chks16);
    wait for clock_period;
    chks16 := to_sfixed ((3.0+6.5), sfixed16'high, sfixed16'low);
    report_error ( "3.0 + 6.5 error",
                   out1,
                   chks16);
    wait for clock_period;
    chks16 := to_sfixed ((6.5 - 3.0), sfixed16'high, sfixed16'low);
    report_error ( "6.5 - 3.0 error",
                   out1,
                   chks16);
    wait for clock_period;
    chks16 := to_sfixed ((6.5 * 3.0), sfixed16'high, sfixed16'low);
    report_error ( "6.5 * 3.0 error",
                   out1,
                   chks16);
    wait for clock_period;
    chks16 := to_sfixed (1, sfixed16'high, sfixed16'low);
    report_error ( "0.5 + 0.5 error",
                   out1,
                   chks16);
    wait for clock_period;
    chks16 := to_sfixed (6.14, sfixed16'high, sfixed16'low);
    report_error ( "3.14 + 3 error",
                   out1,
                   chks16);
    wait for clock_period;
    chks16 := "0000000100000000";
    report_error ( "0.5/0.5 error",
                   out1,
                   chks16);
    wait for clock_period;
    chks16 := to_sfixed (13, sfixed16'high, sfixed16'low);
    report_error ( "6.5/0.5 error",
                   out1,
                   chks16);
    wait for clock_period;
    -- resize test
    sm1 := out1 (7 downto 1);
    sm2 := to_sfixed (5.25, sm2);
    report_error ( "resize 1 error", sm1, sm2);
    sm1 := out1 (-1 downto -7);
    sm2 := to_sfixed (-5.25, sm2);
    report_error ( "resize 2 error", sm1, sm2);
    wait for clock_period;
    sm1 := out1 (7 downto 1);
    sm2 := "0101001";                   -- wrapped
--    sm2 := to_sfixed (21.125, sm2, 0, false, false);  -- wrap, no round
    report_error ( "resize 1 error", sm1, sm2);
    sm1 := out1 (-1 downto -7);
    sm2 := "0111111";  -- saturate
    report_error ( "resize 2 error", sm1, sm2);
    wait for clock_period;
    -- to_signed and back
    report_error ("to_signed(6.25)", out1, to_sfixed (6, out1));
    wait for clock_period;
    -- to_unsigned and back
    report_error ("to_unsigned(7.25)", out1, to_sfixed (7, out1));
    wait for clock_period;
        -- to_integer and back
    report_error ("to_signed(6.25)", out1, to_sfixed (6, out1));
    wait for clock_period;
    -- to_integer(ufixed) and back
    report_error ("to_unsigned(7.25)", out1, to_sfixed (7, out1));
    wait for clock_period;
    report_error ("1/3", out1, to_sfixed (1.0/3.0, out1'high, -7));
    wait for clock_period;
    report_error ("unsigned 1/5", out1, to_sfixed (1.0/5.0, out1));
    wait for clock_period;
    report_error ("abs (-5.5)", out1, to_sfixed (5.5, out1));
    wait for clock_period;
    report_error ("-7.25", out1, to_sfixed (-7.25, out1));
    wait for clock_period;
    report_error ("abs(-42)", out1, to_sfixed (42, out1));
    wait for clock_period;
    report_error ("6.25 mod 6", out1, to_sfixed (0.25, out1));
    wait for clock_period;
    report_error ("6.25 rem 6", out1, to_sfixed (0.25, out1));
    wait for clock_period;
    chks16 := "0000101010000000";
    report_error ("5.25 srl -1", out1, chks16);
    wait for clock_period;
    chks16 := "1111110001100000";
    report_error ("-7.25 sra 1", out1, chks16);
    wait for clock_period;
    --         7654321012345678
    chks16 := "0111000000110001";
    assert (std_match (out1, chks16))
      report "42=42 compare " & CR
      & "Actual   " & to_string(out1) & CR
      & "Expected " & to_string(chks16) severity error;
    wait for clock_period;
    chks16 := "------0001010110";
    assert (std_match (out1, chks16))
      report "45=90 compare " & CR
      & "Actual   " & to_string(out1) & CR
      & "Expected " & to_string(chks16) severity error;
    wait for clock_period;
    chks16 := "------1010101010";
    assert (std_match (out1, chks16))
      report "3.125=0 compare " & CR
      & "Actual   " & to_string(out1) & CR
      & "Expected " & to_string(chks16) severity error;
    wait for clock_period;
    --         7654321012345678
    chks16 := "0--1010000101010";
    assert (std_match (out1, chks16))
      report "pattern1 compare " & CR
      & "Actual   " & to_string(out1) & CR
      & "Expected " & to_string(chks16) severity error;
    wait for clock_period;
    --         7654321012345678
    chks16 := "0001100000110001";
    assert (std_match (out1, chks16))
      report "zero = zero " & CR
      & "Actual   " & to_string(out1) & CR
      & "Expected " & to_string(chks16) severity error;
    wait for clock_period;
    --         7654321012345678
    chks16 := "1111000000110001";
    assert (std_match (out1, chks16))
      report "pattern2 compare " & CR
      & "Actual   " & to_string(out1) & CR
      & "Expected " & to_string(chks16) severity error;
    wait for clock_period;
    --         7654321012345678
    chks16 := "0111000000110001";
    assert (std_match (out1, chks16))
      report "-1 = -1 " & CR
      & "Actual   " & to_string(out1) & CR
      & "Expected " & to_string(chks16) severity error;
    wait for clock_period;
    wait for clock_period;
    wait for clock_period;
    wait for clock_period;
    wait for clock_period;
    assert (false) report "Testing complete" severity note;
    stop_clock <= true;
    wait;    
  end process checktest;
end architecture testbench;
