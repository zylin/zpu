-------------------------------------------------------------------------------
-- test routine for the post synthesis 32 bit multiply
-------------------------------------------------------------------------------

entity test_float_synth is
  generic (
    quiet : BOOLEAN := false);
end entity test_float_synth;

use std.textio.all;
library ieee, ieee_proposed;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee_proposed.fixed_float_types.all;
use ieee_proposed.fixed_pkg.all;
use ieee_proposed.float_pkg.all;

--library modelsim_lib;
--use modelsim_lib.util.all;

architecture testbench of test_float_synth is
  subtype fp16 is float (6 downto -9);  -- 16 bit
  function reverse (
    inpvec : STD_LOGIC_VECTOR (0 to 31))
    return float32 is
    variable result : float32;
  begin
    for i in 0 to 31 loop
      result (i-23) := inpvec(i);
    end loop;  -- i
    return result;
  end function reverse;

  -- purpose: converts an float32 into a std_logic_vector
--  function to_slv (
--    input : float32)                        -- float32 input
--    return std_logic_vector is
--    variable result : std_logic_vector (31 downto 0);  -- result
--  begin  -- function to_slv
--    floop: for i in float32'range loop
--      result (i + fp_fraction_width) := input (i);
--    end loop floop;
--    return result;
--  end function to_slv;

  -- purpose: converts a std_logic_vector to an float32
  function to_float32x (
    signal input : STD_LOGIC_VECTOR (31 downto 0))
    return float32 is
    variable result : float32;
  begin  -- function to_float32x
    return to_float (input, float32'high, -float32'low);
  end function to_float32x;

  procedure report_error (
    constant errmes   :    STRING;       -- error message
    actual            : in float32;      -- data from algorithm
    constant expected :    float32)  is  -- reference data
  begin  -- function report_error
    assert actual = expected
      report errmes & " miscompare" & CR &
      "Actual   " & to_string (actual) & " ("
      & REAL'image(to_real(actual))& ") /= " & CR &
      "Expected " & to_string (expected) & " ("
      & REAL'image(to_real(expected))& ")"
      severity error;
    return;
  end procedure report_error;
  procedure report_error16 (
    constant errmes   :    STRING;       -- error message
    actual            : in fp16;         -- data from algorithm
    constant expected :    fp16)  is     -- reference data
  begin  -- function report_error
    assert actual = expected
      report errmes & " miscompare" & CR &
      "Actual   " & to_string (actual) & " ("
      & REAL'image(to_real(actual))& ") /= " & CR &
      "Expected " & to_string (expected) & " ("
      & REAL'image(to_real(expected))& ")"
      severity error;
    return;
  end procedure report_error16;

  component float_synth is
    port (
      in1, in2   : in  STD_LOGIC_VECTOR(31 downto 0);  -- inputs
      out1       : out STD_LOGIC_VECTOR(31 downto 0);  -- output
      cmd        : in  STD_LOGIC_VECTOR (3 downto 0);
      clk, rst_n : in  STD_ULOGIC);     -- clk and reset
  end component float_synth;
  for all : float_synth
    use entity work.float_synth(rtl);
  constant clock_period          : TIME    := 500 ns;  -- clock period
  signal stop_clock              : BOOLEAN := false;   -- stop the clock
  signal out1real                : REAL;               -- real version
  signal in1, in2                : float32;            -- inputs
  signal out1                    : float32;            -- output
  constant zero0                 : float32 := (others => '0');     -- zero
  signal cmd                     : STD_LOGIC_VECTOR (3 downto 0);  -- command
  signal clk, rst_n              : STD_ULOGIC;         -- clk and reset
  signal in1slv, in2slv, out1slv : STD_LOGIC_VECTOR(31 downto 0);
  signal indelay                 : float32;            -- spied signal
begin  -- architecture testbench
  out1real <= to_real (out1);
  in1slv   <= to_slv(in1);
  in2slv   <= to_slv(in2);
  out1     <= to_float32x(out1slv);
  DUT : float_synth
    port map (
      in1   => in1slv,                  -- [in  float32] inputs
      in2   => in2slv,                  -- [in  float32] inputs
      out1  => out1slv,                 -- [out float32] output
      cmd   => cmd,
      clk   => clk,                     -- [in  std_ulogic] clk and reset
      rst_n => rst_n);                  -- [in std_ulogic] clk and reset

--  spy_process : process
--  begin
--    signal_force ("/DUT/in2reg3", "00000000000000000000000000000000",
--                  500 ns, freeze, 5000 ns, 1);
--    wait;
--  end process spy_process;

  -- purpose: clock driver
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  clkprc : process is

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
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  reset_proc : process is

  begin  -- process reset_proc

    rst_n <= '0';
    wait for clock_period * 2.0;
    rst_n <= '1';
    wait;
  end process reset_proc;

  -- purpose: main test loop
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  tester : process is

  begin  -- process tester
    cmd <= "0110";                      -- 16 bit to float32 mode
    in1 <= "10000000000000000000001000101111";           -- 4.33 ufixed
    in2 <= "00000000000000000000000000000100";           -- 4
    floop1: for i in 1 to 100 loop
      wait for clock_period;
    end loop floop1;
    cmd <= "0110";                      -- 16 bit to float32 mode
    in1 <= "10000000000000000000001000101011";           -- 4.33 ufixed
    in2 <= "00000000000000000000000000000100";           -- 4
    floop2: for i in 1 to 100 loop
      wait for clock_period;
    end loop floop2;
    cmd <= "0010";
    in1 <= reverse("00000000000000000000101100000010");  -- 6.5
    in2 <= reverse("00000000000000000001010001000010");  -- 42
    wait for clock_period;
    in1 <= reverse("00000000000000000001010001000010");  -- 42
    in2 <= reverse("00000000000000000000101100000010");  -- 6.5
    wait for clock_period;
    in1 <= reverse("00000000000000000000101100000010");  -- 6.5
    in2 <= reverse("00000000000000000000101100000010");  -- 6.5
    wait for clock_period;
    in1 <= reverse("00000000000000000001010001000010");  -- 42
    in2 <= "01000000000000000000000000000000";           -- 2
    wait for clock_period;
    in1 <= "00111110101010101010101010101011";           -- 1/3
    in2 <= "01000000000000000000000000000000";           -- 2
    wait for clock_period;
    in1 <= reverse("00000000000000000001010001000010");  -- 42
    in2 <= reverse("00000000000000000000101100000011");  -- -6.5
    wait for clock_period;
    in1 <= reverse("10000000000000000000000000000000");  -- 2**-149
    in2 <= "11000000000000000000000000000000";           -- -2.0
    wait for clock_period;
    in1 <= reverse("00000000000000000000001000000000");  -- 2**-127
    in2 <= "00111110100000000000000000000000";           -- 0.25
    wait for clock_period;
    in1 <= reverse("00000000000000000001010001000010");  -- 42
    in2 <= reverse("00000000000000000000101100000010");  -- 6.5
    wait for clock_period;
    cmd <= "0001";                      -- subtract mode
    in2 <= "01001011111001110011000110011011";           -- 30303030
    in1 <= "01001011111001110011000110011100";           -- 30303033
    wait for clock_period;
    in1 <= reverse("00000000000000000000101100000010");  -- 6.5
    in2 <= "01000000100000000000000000000000";           -- 4
    wait for clock_period;
    in2 <= reverse("00000000000000000000101100000010");  -- 6.5
    in1 <= "01000000100000000000000000000000";           -- 4
    wait for clock_period;
    in1 <= "01000000100010101010101010101011";           -- 4.333333
    in2 <= "00111110101010101010101010101011";           -- 1/3
    wait for clock_period;
    cmd <= "0000";                      -- add mode
    in1 <= "00111110101010101010101010101011";           -- 1/3
    in2 <= "01000000000000000000000000000000";           -- 2
    wait for clock_period;
    in2 <= "00111110101010101010101010101011";           -- 1/3
    in1 <= "01000000000000000000000000000000";           -- 2
    wait for clock_period;
    in1 <= "00000000100000000000000000000001";           -- 2**-126
    in2 <= "01000000100000000000000000000001";           -- 4+
    wait for clock_period;
    cmd <= "0011";                      -- divide mode
    in1 <= "00111111100000000000000000000000";           -- 1.0
    in2 <= "01000000010000000000000000000000";           -- 3.0
    wait for clock_period;
    in1 <= "01001100000011001011110001001111";           -- 36892987
    in2 <= "00000000010000000000000000000000";           -- 2**-127
    wait for clock_period;
    in1 <= "10111110101010101010101010101011";           -- -1/3
    in2 <= "01000000000000000000000000000000";           -- 2
    wait for clock_period;
    cmd <= "0100";                      -- 32 to 16 conversion mode
    in1 <= "00111111100000000000000000000000";           -- 1.0
    in2 <= (others => '0');
    wait for clock_period;
    in1 <= "10111110101010101010101010101011";           -- -1/3, no round
    wait for clock_period;
    in1 <= "10111110101010101010101010101011";           -- -1/3
    in2 <= "00000000000000000000000000000001";           -- opcode 1
    wait for clock_period;
    cmd <= "0101";                      -- conversion mode
    in1 <= "00111111100000000000000000000000";           -- 1.0
    in2 <= "01000000000000000000000000000000";           -- opcode zero
    wait for clock_period;
    in1 <= "01000010001010000000000000000000";           -- 42.0
    in2 <= "00000000000000000000000000000001";           -- opcode 1
    wait for clock_period;
    in1 <= "10111111100000000000000000000000";           -- -1.0
    in2 <= "00000000000000000000000000000010";           -- 2
    wait for clock_period;
    in1 <= "00111111100000000000000000000000";           -- 1.0
    in2 <= "00000000000000000000000000000011";           -- 3
    wait for clock_period;
    in1 <= "01000000100010101010101010101011";           -- 4.333333
    in2 <= "00000000000000000000000000000100";           -- 4
    wait for clock_period;
    in1 <= "00111111100000000000000000000000";           -- 1.0
    in2 <= "00000000000000000000000000000101";           -- 5
    wait for clock_period;
    in1 <= "11000000100010101010101010101011";           -- -4.333333
    in2 <= "00000000000000000000000000000110";           -- 6 to_sfixed
    wait for clock_period;
    in1 <= "00111111100000000000000000000000";           -- 1.0
    in2 <= "00000000000000000000000000000111";           -- 7 to_sfixed
    wait for clock_period;
    cmd <= "0110";                      -- 16 bit to float32 mode
    in1 <= "00000000000000000000000000000011";           -- 3
    in2 <= "01000000000000000000000000000000";           -- mode 0
    wait for clock_period;
    in1 <= "00000000000000000000000000000100";           -- 4
    in2 <= "01000000000000000000000000000001";           -- 1
    wait for clock_period;
    in1 <= "00000000000000001111111111111110";           -- -2
    in2 <= "01000000000000000000000000000010";           -- 2 to_float(signed)
    wait for clock_period;
    in1 <= "00000000000000000000000000000100";           -- 4
    in2 <= "01000000000000000000000000000011";           -- mode 3
    wait for clock_period;
    in1 <= "10000000000000000000001000101011";           -- 4.33 ufixed
    in2 <= "00000000000000000000000000000100";           -- 4
    wait for clock_period;
    in1 <= "10100000000000000000000010000000";           -- 1.0 ufixed
    in2 <= "00000000000000000000000000000101";           -- 5
    wait for clock_period;
    in1 <= "11000000000000001111110111010101";           -- -4.333 sfixed
    in2 <= "00000000000000000000000000000110";           -- 6
    wait for clock_period;
    in1 <= "10100000000000000000000010000000";           -- 1.0 sfixed
    in2 <= "00000000000000000000000000000111";           -- 7
    wait for clock_period;
    cmd <= "0111";                      -- Mod
    in1 <= "00000000000000000000000000000011";           -- 
    in2 <= "00000000000000000000000000000011";           -- 
    wait for clock_period;
    in1 <= "00000010001100101111000100111011";           -- 36892987
    in2 <= "00000010001100101111000100111011";           -- 36892987
    wait for clock_period;
    in1 <= "11000000100010101010101010101011";           -- -4.333333
    in2 <= "01000000100000000000000000000000";           -- 4
    wait for clock_period;
    cmd <= "1000";                      -- rem
    in1 <= "00000000000000000000000000000011";           -- 
    in2 <= "00000000000000000000000000000011";           -- 
    wait for clock_period;
    in1 <= "00000010001100101111000100111011";           -- 36892987
    in2 <= "00000010001100101111000100111011";           -- 36892987
    wait for clock_period;
    in1 <= "11000000100010101010101010101011";           -- -4.333333
    in2 <= "01000000100000000000000000000000";           -- 4
    wait for clock_period;
    cmd <= "1001";                      -- constants conversion
    in2 <= "11000000000000000000000000000000";           -- command 0
    wait for clock_period;
    in2 <= "11000000000000000000000000000001";           -- command 1
    wait for clock_period;
    in2 <= "11000000000000000000000000000010";           -- command 2
    wait for clock_period;
    in2 <= "11000000000000000000000000000011";           -- command 3
    wait for clock_period;
    in2 <= "11000000000000000000000000000100";           -- command 4
    wait for clock_period;
    in2 <= "11000000000000000000000000000101";           -- command 5
    wait for clock_period;
    in2 <= "11000000000000000000000000000110";           -- command 6
    wait for clock_period;
    in2 <= "11000000000000000000000000000111";           -- command 7
    wait for clock_period;
    cmd <= "1010";                      -- conversions
    in1 <= to_float (1, in1);
    in2 <= "11000000000000000000000000000000";           -- command 0
    wait for clock_period;
    in1 <= to_float (-2, in1);
    wait for clock_period;
    in2 <= "11000000000000000000000000000001";           -- command 1
    wait for clock_period;
    in1 <= to_float (1, in1);
    wait for clock_period;
    in2 <= "00010000000000000000000000000010";           -- command 2 scalb
    in1 <= to_float (1, in1);
    wait for clock_period;
    in2 <= "11110000000000000000000000000010";           -- command 2 scalb
    in1 <= to_float (1, in1);
    wait for clock_period;
    in2 <= "11000000000000000000000000000011";           -- command 3 logb
    in1 <= to_float (1, in1);
    wait for clock_period;
    in2 <= "11000000000000000000000000000011";           -- command 3 logb
    in1 <= to_float (0.25, in1);
    wait for clock_period;
    in2 <= "11000000000000000000000000000100";           -- 4 nextafter
    in1 <= to_float (1, in1);
    wait for clock_period;
    in1 <= to_float (4, in1);
    wait for clock_period;
    in2 <= "11000000000000000000000000000101";           -- 5 nextafter
    in1 <= to_float (1, in1);
    wait for clock_period;
    in1 <= to_float (-4, in1);
    wait for clock_period;
    in2 <= "11000000000000000000000000000110";           -- 6 nextafter
    in1 <= to_float (1, in1);
    wait for clock_period;
    in1 <= to_float (4, in1);
    wait for clock_period;
    in2 <= "11000000000000000000000000000111";           -- 7 nextafter
    in1 <= to_float (1, in1);
    wait for clock_period;
    in1 <= to_float (-4, in1);
    wait for clock_period;
    cmd <= "1011";                      -- copy sign
    in1 <= to_float (2, in1);
    in2 <= to_float (2, in1);
    wait for clock_period;
    in1 <= to_float (-3, in1);
    in2 <= to_float (3, in1);
    wait for clock_period;
    in1 <= to_float (4, in1);
    in2 <= to_float (-4, in1);
    wait for clock_period;
    in1 <= to_float (-5, in1);
    in2 <= to_float (-5, in1);
    wait for clock_period;
    cmd <= "1100";                      -- compare test
    in1 <= to_float (15, in1);
    in2 <= to_float (15, in1);
    wait for clock_period;
    in1 <= to_float (15.5, in1);
    in2 <= to_float (-2, in1);
    wait for clock_period;
    in1 <= to_float (-2, in1);
    in2 <= to_float (2, in1);
    wait for clock_period;
    in1 <= "01111111100000000000000000000000";           -- + inf
    in2 <= to_float (-2, in1);
    wait for clock_period;
    in1 <= "01111111100000000000000000000001";           -- NAN
    in2 <= to_float (-2, in1);
    wait for clock_period;
    cmd <= "1101";                      -- boolean test
    in1 <= "01111111100000000000000000000000";           -- + inf
    in2 <= "00111111100000000000000000000000";           -- command 0 , not
    wait for clock_period;
    in1 <= "01111111100000000000000000000000";           -- + inf
    in2 <= "00111111100000000000000000000001";           -- command 1, and
    wait for clock_period;
    in1 <= "01111111000000000000000000000000";           -- + inf
    in2 <= "00111111000000000000000000000010";           -- command 2, or
    wait for clock_period;
    in1 <= "01111111100000000000000000000000";           -- + inf
    in2 <= "00111111100000000000000000000011";           -- command 3, nand
    wait for clock_period;
    in1 <= "01111111100000000000000000000000";           -- + inf
    in2 <= "00111111100000000000000000000100";           -- command 4, nor
    wait for clock_period;
    in1 <= "01111111100000000000000000000000";           -- + inf
    in2 <= "00111111100000000000000000000101";           -- command 5, xor
    wait for clock_period;
    in1 <= "01111111100000000000000000000000";           -- + inf
    in2 <= "00111111100000000000000000000110";           -- command 6, xnor
    wait for clock_period;
    in1 <= "01111111100000000000000000000000";           -- + inf
    in2 <= "00111111100000000000000000000111";           -- command 7, xor '1'
    wait for clock_period;
    cmd <= "1110";                      -- reduce and vector test test
    in1 <= "01111111100000000000000000000000";           -- + inf
    in2 <= "00111111100000000000000000000000";           -- command 0, 
    wait for clock_period;
    in1 <= "11111111111111111111111111111111";           -- all 1
    wait for clock_period;
    in1 <= "10000000000000000000000000000000";           -- -0
    wait for clock_period;
    in1 <= "00000000000000000000000000000000";           -- 0
    wait for clock_period;
    in1 <= "01111111100000000000000000000000";           -- + inf
    in2 <= "00111111100000000000000000000001";           -- command 1, and '0'
    wait for clock_period;
    in2 <= "10111111100000000000000000000001";           -- command 1, and '1'
    wait for clock_period;
    in2 <= "00111111100000000000000000000010";           -- command 2, or '0'
    wait for clock_period;
    in2 <= "10111111100000000000000000000010";           -- command 2, or '1'
    wait for clock_period;
    in2 <= "00111111100000000000000000000011";           -- command 3, nand '0'
    wait for clock_period;
    in2 <= "10111111100000000000000000000011";           -- command 3, nand '1'
    wait for clock_period;
    in2 <= "00111111100000000000000000000100";           -- command 4, nor '0'
    wait for clock_period;
    in2 <= "10111111100000000000000000000100";           -- command 4, nor '1'
    wait for clock_period;
    in2 <= "00111111100000000000000000000101";           -- command 5, xor '0'
    wait for clock_period;
    in2 <= "10111111100000000000000000000101";           -- command 5, xor '1'
    wait for clock_period;
    in2 <= "00111111100000000000000000000110";           -- command 6, xnor '0'
    wait for clock_period;
    in2 <= "10111111100000000000000000000110";           -- command 6, xnor '1'
    wait for clock_period;
    in2 <= "00111111100000000000000000000111";           -- command 7, and '0'
    wait for clock_period;
    in2 <= "10111111100000000000000000000111";           -- command 7, and '1'
    wait for clock_period;
    cmd <= "1111";                      -- add and mult by constant
    in2 <= "10111111100000000000000000000000";           -- command 0,  + 1
    in1 <= to_float (2, in1);
    wait for clock_period;
    in2 <= "10111111100000000000000000000001";           -- command 1, 1 +
    wait for clock_period;
    in2 <= "10111111100000000000000000000010";           -- command 2,  + 1.0
    wait for clock_period;
    in2 <= "10111111100000000000000000000011";           -- command 3, 1.0 +
    wait for clock_period;
    in2 <= "10111111100000000000000000000100";           -- command 4, * 1
    wait for clock_period;
    in2 <= "10111111100000000000000000000101";           -- command 5, 1 *
    wait for clock_period;
    in2 <= "10111111100000000000000000000110";           -- command 6, * 1.0
    wait for clock_period;
    in2 <= "10111111100000000000000000000111";           -- command 7, 1.0 *
    wait for clock_period;


    wait for clock_period;
    cmd <= "0000";                      -- add mode
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
  checktest : process is
    variable out16, out16t : fp16;      -- 16 bit fp variables
    variable out1t, out2t  : float32;   -- 32 bit float
    variable s16, s16t     : SIGNED(7 downto 0);        -- 7 bit SIGNED
    variable latency : INTEGER := 0;
  begin  -- process checktest
    wait for clock_period/2.0;
    floop3: for i in 1 to 100 loop
      wait for clock_period;
    end loop floop3;
    latency := 0;
    out2t := "01000000100010101100000000000000";
    wl1: while out1 /= out2t loop
        wait for clock_period;
        latency := latency + 1;
        assert latency /= 100 report "After 100 loops, pattern never found"
          severity failure;
    end loop wl1;
    report "Latency was " & INTEGER'image(latency) severity note;
    floop4: for i in 1 to 100 loop
      wait for clock_period;
    end loop floop4;
    report_error ("42 * 6.5 error",
                   out1,
                   to_float (273, out1));
    wait for clock_period;
    report_error ("6.5 * 42 error",
                   out1,
                   to_float (273, out1'high, -out1'low));
    wait for clock_period;
    report_error ("Multiply 42.25 miscompare",
                  out1,
                  "01000010001010010000000000000000");  -- 42.25
    wait for clock_period;
    report_error ("Multiply 84 miscompare",
                  out1,
                  "01000010101010000000000000000000");  -- 84
    wait for clock_period;
    report_error ("Multiply 2/3 miscompare",
                  out1,
                  "00111111001010101010101010101011");  -- 2/3
    wait for clock_period;
    report_error ("Multiply -273 miscompare",
                  out1,
                  "11000011100010001000000000000000");  -- -273
    wait for clock_period;
    report_error ("mult 2**-148 test miscompare",
                  out1,
                  reverse("01000000000000000000000000000001"));  -- -2*-148
    wait for clock_period;
    report_error ("Multiply 2**-129 miscompare",
                  out1,
                  reverse("00000000000000000000100000000000"));  -- 2**-129
    wait for clock_period;
    report_error ("6.5 * 42 error",
                   out1,
                   to_float (273, out1));
    wait for clock_period;
    report_error ("Subtract 30303033 - 30303030 miscompare",
                  out1,
                  "01000000000000000000000000000000");  -- 2 (not 3, rounding)
    wait for clock_period;
    report_error ("Subtract 6.5 - 4 miscompare",
                  out1,
                  "01000000001000000000000000000000");  -- 2.5
    wait for clock_period;
    report_error ("Subtract 4 - 6.5 miscompare",
                  out1,
                  "11000000001000000000000000000000");  -- -2.5
    wait for clock_period;
    report_error ("Subtract 4.333 - 1/3 miscompare",
                  out1,
                  "01000000100000000000000000000000");  -- 4
    wait for clock_period;
    report_error ("Add 2.333 miscompare",
                  out1,
                  "01000000000101010101010101010101");  -- 2.333333
    wait for clock_period;
    report_error ("Add 2.333 rev miscompare",
                  out1,
                  "01000000000101010101010101010101");  -- 2.333333
    wait for clock_period;
    report_error ("Add 4 + miscompare",
                  out1,
                  "01000000100000000000000000000001");  -- 4
    wait for clock_period;
    report_error ("div 1/3 test miscompare",
                  out1,
                  "00111110101010101010101010101011");  -- 1/3
    wait for clock_period;
    report_error ("div 369297/2**-126 test miscompare",
                  out1,
                  "01111111100000000000000000000000");
    wait for clock_period;
    report_error ("-1/6 test miscompare",
                  out1, "10111110001010101010101010101011");     -- -1/6
    wait for clock_period;
    -- resize function
    out16  := to_float (to_slv (out1(-8 downto -23)), 6, 9);
    out16t := to_float (1, out16t);
    report_error16 ("1.0  fp16 converserion",
                    out16, out16t);
    wait for clock_period;
    out16 := to_float (to_slv (out1(-8 downto -23)), 6, 9);
    out16t := to_float (arg         => -1.0/3.0, size_res => out16t,
                        round_style => round_zero);
    report_error16 ("-1/3 not rounded  fp16 converserion",
                    out16, out16t);
    wait for clock_period;
    out16  := to_float (to_slv (out1(-8 downto -23)), 6, 9);
    out16t := to_float (-1.0/3.0, out16t);
    report_error16 ("-1/3  fp16 converserion",
                    out16, out16t);
    -- conversion test
    wait for clock_period;
    report_error ("1.0 to unsigned miscompare",
                  out1, "00000000000000000000000000000001");
    wait for clock_period;
    report_error ("42 to unsigned miscompare",
                  out1, "00100000000000000000000000101010");
    wait for clock_period;
    report_error ("-1.0 to signed miscompare",
                  out1, "01000000000000001111111111111111");
    wait for clock_period;
    report_error ("1.0 to signed miscompare",
                  out1, "01100000000000000000000000000001");
    wait for clock_period;
    report_error ("4.33 to ufixed miscompare",
                  out1, "10000000000000000000001000101011");
    wait for clock_period;
    report_error ("1.0 to ufixed miscompare",
                  out1, "10100000000000000000000010000000");
    wait for clock_period;
    report_error ("4.333 to sfixed miscompare",
                  out1, "11000000000000001111110111010101");
    wait for clock_period;
    report_error ("1.0 to sfixed miscompare",
                  out1, "11100000000000000000000010000000");
    wait for clock_period;
    report_error ("unsigned 3 to float miscompare",
                  out1, to_float(3, out1));
    wait for clock_period;
    report_error ("unsigned 4 to float miscompare",
                  out1, to_float(4, out1));
    wait for clock_period;
    report_error ("signed -2 to float miscompare",
                  out1, to_float(-2, out1));
    wait for clock_period;
    report_error ("signed 4 to float miscompare",
                  out1, to_float(4, out1));
    wait for clock_period;
    report_error ("ufixed 4.333 to float miscompare",
                  out1, "01000000100010101100000000000000");     -- 4.333333   
    wait for clock_period;
    report_error ("ufixed 1.0 to float miscompare",
                  out1, "00111111100000000000000000000000");     -- 1.0    
    wait for clock_period;
    report_error ("sfixed -4.333 to float miscompare",
                  out1, "11000000100010101100000000000000");     -- -4.333333
    wait for clock_period;
    report_error ("sfixed 1.0 to float miscompare",
                  out1, "00111111100000000000000000000000");     -- 1.0
    wait for clock_period;
    report_error ("denormal mod denormal  miscompare",
                  out1, zero0);
    wait for clock_period;
    report_error ("large mod large  miscompare",
                  out1, zero0);
    wait for clock_period;
    report_error ("-4.333 mod 4  miscompare",
                  out1,
                  from_string ("01000000011010101010101010101010", out1));
    wait for clock_period;
    report_error ("denormal rem denormal  miscompare",
                  out1, zero0);
    wait for clock_period;
    report_error ("large rem large  miscompare",
                  out1, zero0);
    wait for clock_period;
    out1t := "10111110101010101010101010110000";
    report_error ("-4.333 rem 4  miscompare",
                  out1, out1t);
    wait for clock_period;
    report_error ("to_float(0)  miscompare",
                  out1, zero0);
    wait for clock_period;
    report_error ("to_float(0.0)  miscompare",
                  out1, zero0);
    wait for clock_period;
    report_error ("to_float(8)  miscompare",
                  out1, to_float(8.0, out1));
    wait for clock_period;
    report_error ("to_float(8.0)  miscompare",
                  out1, to_float(8, out1));    
    wait for clock_period;
    report_error ("to_float(-8)  miscompare",
                  out1, to_float(-8.0, out1));
    wait for clock_period;
    report_error ("to_float(-8.0)  miscompare",
                  out1, to_float(-8, out1));    
    wait for clock_period;
    report_error ("to_float(27000)  miscompare",
                  out1, to_float(27000.0, out1));
    wait for clock_period;
    report_error ("to_float(PI)  miscompare",
                  out1, to_float(3.141592653589, out1));
    -- Conversion test
    wait for clock_period;
    report_error ("-1 miscompare",
                  out1, to_float(-1, out1));
    wait for clock_period;
    report_error ("-(-2)  miscompare",
                  out1, to_float(2, out1));
    wait for clock_period;
    report_error ("abs(-2)  miscompare",
                  out1, to_float(2, out1));
    wait for clock_period;
    report_error ("abs(1)  miscompare",
                  out1, to_float(1, out1));
    wait for clock_period;
    report_error ("scalb (1, 1) miscompare",
                  out1, to_float(2, out1));
    wait for clock_period;
    report_error ("scalb (1, -1) miscompare",
                  out1, to_float(0.5, out1));
    wait for clock_period;
    s16 := SIGNED (to_slv (out1(-16 downto -23)));
    assert (s16 = 0) report "logb (1) returned "
      & to_string(to_sfixed(s16)) severity error;
    wait for clock_period;
    s16 := SIGNED (to_slv (out1(-16 downto -23)));
    assert (s16 = -2) report "logb (0.25) returned "
      & to_string(to_sfixed(s16)) severity error;
    wait for clock_period;
    out1t := "00111111100000000000000000000001";
    report_error ("nextafter (1, 1.5)", out1, out1t);
    wait for clock_period;
    out1t := "01000000011111111111111111111111";
    report_error ("nextafter (4, 1.5)", out1, out1t);
    wait for clock_period;
    out1t := "00111111011111111111111111111111";
    report_error ("nextafter (1, -1.5)", out1, out1t);
    wait for clock_period;
    out1t := "11000000011111111111111111111111";
    report_error ("nextafter (-4, -1.5)", out1, out1t);
    wait for clock_period;
    out1t := "00111111100000000000000000000001";
    report_error ("nextafter (1, inf)", out1, out1t);
    wait for clock_period;
    out1t := "01000000100000000000000000000001";
    report_error ("nextafter (4, inf)", out1, out1t);
    wait for clock_period;
    out1t := "00111111011111111111111111111111";
    report_error ("nextafter (1, neginf)", out1, out1t);
    wait for clock_period;
    out1t := "11000000100000000000000000000001";
    report_error ("nextafter (-4, neginf)", out1, out1t);
    wait for clock_period;
    report_error ("Copysign (2,2)", out1, to_float(2, out1));
    wait for clock_period;
    report_error ("Copysign (-3,3)", out1, to_float(3, out1));
    wait for clock_period;
    report_error ("Copysign (4,-4)", out1, to_float(-4, out1));
    wait for clock_period;
    report_error ("Copysign (-5,-5)", out1, to_float(-5, out1));
    wait for clock_period;
    out1t := "10001110000000000000000000000000";
    report_error ("compare test 15, 15", out1, out1t);
    wait for clock_period;
    out1t := "01101001000000000000000000000000";
    report_error ("compare test 15.5, -2", out1, out1t);
    wait for clock_period;
    out1t := "01010100000000000000000000000000";
    report_error ("compare test -2, 2", out1, out1t);
    wait for clock_period;
    out1t := "01101000010000000000000000000000";
    report_error ("compare test inf, -2", out1, out1t);
    wait for clock_period;
    out1t := "01000000101000000000000000000000";
    report_error ("compare test NAN, -2", out1, out1t);
    wait for clock_period;
    out1t := "10000000011111111111111111111111";        -- not + inf
    report_error ("not +inf", out1, out1t);
    wait for clock_period;
    out1t := "00111111100000000000000000000000";        -- and
    report_error ("and +inf", out1, out1t);
    wait for clock_period;
    out1t := "01111111000000000000000000000010";        -- or
    report_error ("or +inf", out1, out1t);
    wait for clock_period;
    out1t := "11000000011111111111111111111111";        -- nand
    report_error ("nand +inf", out1, out1t);
    wait for clock_period;
    out1t := "10000000011111111111111111111011";        -- nor
    report_error ("nor +inf", out1, out1t);
    wait for clock_period;
    out1t := "01000000000000000000000000000101";        -- xor
    report_error ("xor +inf", out1, out1t);
    wait for clock_period;
    out1t := "10111111111111111111111111111001";        -- xnor
    report_error ("xnor +inf", out1, out1t);
    wait for clock_period;
    out1t := "10000000011111111111111111111111";        -- xnor '1'
    report_error ("+inf xor '1'", out1, out1t);
    wait for clock_period;
    out1t := "01100100000000000000000000000000";        -- reduce test
    report_error ("_reduce test", out1, out1t);
    wait for clock_period;
    out1t := "10100100000000000000000000000000";        -- reduce test
    report_error ("_reduce all 1 test", out1, out1t);
    wait for clock_period;
    out1t := "01101000000000000000000000000000";        -- reduce test
    report_error ("_reduce -0 test", out1, out1t);
    wait for clock_period;
    out1t := "01010100000000000000000000000000";        -- reduce test
    report_error ("_reduce 0 test", out1, out1t);
    wait for clock_period;
    out1t := "00000000000000000000000000000000";        -- 0
    report_error ("and 0 test", out1, out1t);
    wait for clock_period;
    out1t := "01111111100000000000000000000000";        -- + inf
    report_error ("and 1 test", out1, out1t);
    wait for clock_period;
    out1t := "01111111100000000000000000000000";        -- + inf
    report_error ("or 0 test", out1, out1t);
    wait for clock_period;
    out1t := "11111111111111111111111111111111";        -- all 1
    assert (to_slv (out1) = to_slv (out1t))
      report "or 1 test error " & to_string (out1) & " /= "
      & to_string (out1t) severity error;
    wait for clock_period;
    out1t := "11111111111111111111111111111111";        -- all 1
    assert (to_slv (out1) = to_slv (out1t))
      report "nand 0 test error " & to_string (out1) & " /= "
      & to_string (out1t) severity error;
    wait for clock_period;
    out1t := "10000000011111111111111111111111";        -- - denormal
    report_error ("nand 1 test", out1, out1t);
    wait for clock_period;
    out1t := "10000000011111111111111111111111";        -- - denormal
    report_error ("nor 0 test", out1, out1t);
    wait for clock_period;
    out1t := "00000000000000000000000000000000";        -- 0
    report_error ("nor 1 test", out1, out1t);
    wait for clock_period;
    out1t := "01111111100000000000000000000000";        -- + inf
    report_error ("xor 0 test", out1, out1t);
    wait for clock_period;
    out1t := "10000000011111111111111111111111";        -- - denormal
    report_error ("xor 1 test", out1, out1t);
    wait for clock_period;
    out1t := "10000000011111111111111111111111";        -- - denormal
    report_error ("xnor 0 test", out1, out1t);
    wait for clock_period;
    out1t := "01111111100000000000000000000000";        -- + inf
    report_error ("xnor 1 test", out1, out1t);
    wait for clock_period;
    out1t := "00000000000000000000000000000000";        -- 0
    report_error ("and 0 test", out1, out1t);
    wait for clock_period;
    out1t := "01111111100000000000000000000000";        -- + inf
    report_error ("and 1 test", out1, out1t);
    wait for clock_period;
    out1t := to_float(3, out1t);
    report_error ("2 + 1 test", out1, out1t);
    wait for clock_period;
    report_error ("1 + 2 test", out1, out1t);
    wait for clock_period;
    report_error ("2 + 1.0 test", out1, out1t);
    wait for clock_period;
    report_error ("1.0 + 2 test", out1, out1t);
    wait for clock_period;
    out1t := to_float(2, out1t);
    report_error ("2 * 1 test", out1, out1t);
    wait for clock_period;
    report_error ("1 * 2 test", out1, out1t);
    wait for clock_period;
    report_error ("2 * 1.0 test", out1, out1t);
    wait for clock_period;
    report_error ("1.0 * 2 test", out1, out1t);

    wait for clock_period;
    assert (false) report "Testing complete" severity note;
    stop_clock <= true;
    wait;
  end process checktest;
end architecture testbench;
