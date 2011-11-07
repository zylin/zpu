-------------------------------------------------------------------------------
-- Synthesis test for the floating point math package
-- This test is designed to be synthesizable and exercise much of the package.
-- Created for vhdl-200x by David Bishop (dbishop@vhdl.org)
-- --------------------------------------------------------------------
--   modification history : Last Modified $Date: 2006-06-08 10:50:32-04 $
--   Version $Id: float_synth.vhdl,v 1.1 2006-06-08 10:50:32-04 l435385 Exp $
-------------------------------------------------------------------------------
library ieee, ieee_proposed;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee_proposed.fixed_float_types.all;
use ieee_proposed.fixed_pkg.all;
use ieee_proposed.float_pkg.all;
use ieee.math_real.all;
entity float_synth is
  
  port (
    in1, in2   : in  std_logic_vector (31 downto 0);              -- inputs
    out1       : out std_logic_vector (31 downto 0);              -- output
    cmd : in std_logic_vector (3 downto 0);
    clk, rst_n : in  std_ulogic);       -- clk and reset

end entity float_synth;

architecture rtl of float_synth is
  subtype fp16 is float (6 downto -9);    -- 16 bit

  type cmd_type is array (1 to 15) of std_ulogic_vector (cmd'range);  -- cmd
  signal cmdarray : cmd_type;       -- command pipeline
  type cry_type is array (0 to 15) of float32;  -- arrays
  signal outx : cry_type;
  signal in1reg3, in2reg3 : float32;  -- register stages
  
begin  -- architecture rtl

  -- purpose: "0000" test the "+" operator
  cmd0reg: process (clk, rst_n) is
    variable outarray : cry_type;       -- array for output
  begin  -- process cmd0reg

    if rst_n = '0' then                 -- asynchronous reset (active low)
      outx(0) <= ( others => '0');      
      jrloop: for j in 0 to 7 loop
        outarray (j) := (others => '0');
      end loop jrloop;
    elsif rising_edge(clk) then         -- rising clock edge
      outx(0) <= outarray(7);
      jcloop: for j in 7 downto 1 loop
        outarray (j) := outarray(j-1);
      end loop jcloop;
      outarray(0) := in1reg3 + in2reg3;
    end if;

  end process cmd0reg;

  -- purpose: "0001" test the "-" operator
  cmd1reg: process (clk, rst_n) is
    variable outarray : cry_type;       -- array for output
  begin  -- process cmd1reg

    if rst_n = '0' then                 -- asynchronous reset (active low)
      outx(1) <= ( others => '0');      
      jrloop: for j in 0 to 7 loop
        outarray (j) := (others => '0');
      end loop jrloop;
    elsif rising_edge(clk) then         -- rising clock edge
      outx(1) <= outarray(7);
      jcloop: for j in 7 downto 1 loop
        outarray (j) := outarray(j-1);
      end loop jcloop;
      outarray(0) := in1reg3 - in2reg3;
    end if;

  end process cmd1reg;

  -- purpose: "0010" test the "*" operator
  cmd2reg: process (clk, rst_n) is
    variable outarray : cry_type;       -- array for output
  begin  -- process cmd2reg

    if rst_n = '0' then                 -- asynchronous reset (active low)
      outx(2) <= ( others => '0');      
      jrloop: for j in 0 to 7 loop
        outarray (j) := (others => '0');
      end loop jrloop;
    elsif rising_edge(clk) then         -- rising clock edge
      outx(2) <= outarray(7);
      jcloop: for j in 7 downto 1 loop
        outarray (j) := outarray(j-1);
      end loop jcloop;
      outarray(0) := in1reg3 * in2reg3;
    end if;

  end process cmd2reg;

  -- purpose: "0011" performs test the "/" operator
  cmd3reg: process (clk, rst_n) is
    variable outarray : cry_type;       -- array for output
  begin  -- process cmd1reg
    if rst_n = '0' then                 -- asynchronous reset (active low)
      outx(3) <= ( others => '0');      
      jrloop: for j in 0 to 7 loop
        outarray (j) := (others => '0');
      end loop jrloop;
    elsif rising_edge(clk) then         -- rising clock edge
      outx(3) <= outarray(7);
      jcloop: for j in 7 downto 1 loop
        outarray (j) := outarray(j-1);
      end loop jcloop;
      if (cmdarray(4) = "0011") then
        outarray(0) := in1reg3 / in2reg3;
      else
        outarray(0) := (others => '0');
      end if;
    end if;
  end process cmd3reg;

  -- purpose: "0100" test the "resize" function
  cmd4reg: process (clk, rst_n) is
    variable tmpfp161, tmpfp162 : fp16;  -- 16 bit fp number
    variable outarray : cry_type;       -- array for output
    variable tmpcmd : STD_LOGIC_VECTOR (2 downto 0);
  begin  -- process cmd1reg
    if rst_n = '0' then                 -- asynchronous reset (active low)
      outx(4) <= ( others => '0');      
      jrloop: for j in 0 to 7 loop
        outarray (j) := (others => '0');
      end loop jrloop;
    elsif rising_edge(clk) then         -- rising clock edge
      outx(4) <= outarray(7);
      jcloop: for j in 7 downto 1 loop
        outarray (j) := outarray(j-1);
      end loop jcloop;
      tmpcmd := to_slv (in2reg3 (in2reg3'low+2 downto in2reg3'low));
      case tmpcmd is
        when "000" =>
          tmpfp161 := resize ( arg => in1reg3,
                               exponent_width => tmpfp161'high,
                               fraction_width => -tmpfp161'low,
                               denormalize_in => true,
                               denormalize => false,
                               round_style => round_zero);
        when "001" =>
          tmpfp161 := resize ( arg => in1reg3,
--                               size_res => tmpfp161,
                               exponent_width => tmpfp161'high,
                               fraction_width => -tmpfp161'low,
                               denormalize_in => false,
                               denormalize => false);
        when "010" =>
          tmpfp161 := resize ( arg => in1reg3,
                               exponent_width => tmpfp161'high,
                               fraction_width => -tmpfp161'low,
                               denormalize_in => false,
                               denormalize => false);
        when "011" =>
          tmpfp161 := resize ( arg => in1reg3,
--                               size_res => tmpfp161,
                               exponent_width => tmpfp161'high,
                               fraction_width => -tmpfp161'low,
                               denormalize_in => true,
                               denormalize => false,
                               round_style => round_inf);
        when "100" =>
          tmpfp161 := resize ( arg => in1reg3,
                               exponent_width => tmpfp161'high,
                               fraction_width => -tmpfp161'low,
                               denormalize_in => true,
                               denormalize => false,
                               round_style => round_neginf);
        when "101" =>
          tmpfp161 := resize ( arg => in1reg3,
--                               size_res => tmpfp161,
                               exponent_width => tmpfp161'high,
                               fraction_width => -tmpfp161'low,
                               denormalize_in => true,
                               denormalize => false,
                               check_error => false,
                               round_style => round_zero);
        when "110" =>
          tmpfp161 := resize ( arg => in1reg3,
                               exponent_width => tmpfp161'high,
                               fraction_width => -tmpfp161'low);
        when "111" =>
          tmpfp161 := resize ( arg => in1reg3,
                               exponent_width => tmpfp161'high,
                               fraction_width => -tmpfp161'low
--                               size_res => tmpfp161
                               );
        when others => null;
      end case;
      outarray(0)(-8 downto -23) := tmpfp161;
      outarray(0)(8 downto 6) := float(tmpcmd);
      outarray(0)(6 downto -7) := (others => '0');
    end if;
  end process cmd4reg;

  -- purpose: "0101" Conversion function test
  cmd5reg: process (clk, rst_n) is
    variable uns : unsigned (15 downto 0);  -- unsigned number
    variable s : signed (15 downto 0);  -- signed number
    variable uf : ufixed (8 downto -7);  -- unsigned fixed
    variable sf : sfixed (8 downto -7);  -- signed fixed point
    variable outarray : cry_type;       -- array for output
    variable tmpcmd : STD_LOGIC_VECTOR (2 downto 0);
  begin  -- process cmd1reg
    if rst_n = '0' then                 -- asynchronous reset (active low)
      outx(5) <= ( others => '0');      
      jrloop: for j in 0 to 7 loop
        outarray (j) := (others => '0');
      end loop jrloop;
    elsif rising_edge(clk) then         -- rising clock edge
      outx(5) <= outarray(7);
      jcloop: for j in 7 downto 1 loop
        outarray (j) := outarray(j-1);
      end loop jcloop;
      tmpcmd := to_slv (in2reg3 (in2reg3'low+2 downto in2reg3'low));
      case tmpcmd is
        when "000" =>
          uns := to_unsigned (in1reg3, uns'length);
          outarray(0)(-8 downto -23) := float(std_logic_vector(uns));
        when "001" =>
          uns := to_unsigned (in1reg3, uns);
          outarray(0)(-8 downto -23) := float(std_logic_vector(uns));
        when "010" =>
          s := to_signed (in1reg3, s'length);
          outarray(0)(-8 downto -23) := float(std_logic_vector(s));
        when "011" =>
          s := to_signed (in1reg3, s);
          outarray(0)(-8 downto -23) := float(std_logic_vector(s));
        when "100" =>
          uf := to_ufixed (in1reg3, uf'high, uf'low);
          outarray(0)(-8 downto -23) := float(to_slv(uf));
        when "101" =>
          uf := to_ufixed (in1reg3, uf);
          outarray(0)(-8 downto -23) := float(to_slv(uf));
        when "110" =>
          sf := to_sfixed (in1reg3, sf'high, sf'low);
          outarray(0)(-8 downto -23) := float(to_slv(sf));
        when "111" =>
          sf := to_sfixed (in1reg3, sf);
          outarray(0)(-8 downto -23) := float(to_slv(sf));
        when others => null;
      end case;
      outarray(0)(8 downto 6) := float(tmpcmd);
      outarray(0)(5 downto -7) := (others => '0');
    end if;
  end process cmd5reg;

  -- purpose: "0110" to_float()
  cmd6reg: process (clk, rst_n) is
    variable uns : unsigned (15 downto 0);  -- unsigned number
    variable s : signed (15 downto 0);  -- signed number
    variable uf : ufixed (8 downto -7);  -- unsigned fixed
    variable sf : sfixed (8 downto -7);  -- signed fixed point
    variable outarray : cry_type;       -- array for output
    variable tmpcmd : STD_LOGIC_VECTOR (2 downto 0);
  begin  -- process cmd1reg
    if rst_n = '0' then                 -- asynchronous reset (active low)
      outx(6) <= ( others => '0');      
      jrloop: for j in 0 to 7 loop
        outarray (j) := (others => '0');
      end loop jrloop;
    elsif rising_edge(clk) then         -- rising clock edge
      outx(6) <= outarray(7);
      jcloop: for j in 7 downto 1 loop
        outarray (j) := outarray(j-1);
      end loop jcloop;
      tmpcmd := to_slv (in2reg3 (in2reg3'low+2 downto in2reg3'low));
      case tmpcmd is
        when "000" =>
          uns := UNSIGNED (to_slv (in1reg3(-8 downto -23)));
          outarray(0) := to_float(uns, 8, 23);
        when "001" =>
          uns := UNSIGNED (to_slv (in1reg3(-8 downto -23)));
          outarray(0) := to_float(uns, in1reg3);
        when "010" =>
          s := SIGNED (to_slv (in1reg3(-8 downto -23)));
          outarray(0) := to_float(s, 8, 23);
        when "011" =>
          s := SIGNED (to_slv (in1reg3(-8 downto -23)));
          outarray(0) := to_float(s, in1reg3);
        when "100" =>
          uf := to_ufixed (to_slv (in1reg3(-8 downto -23)), uf'high, uf'low);
          outarray(0) := to_float(uf, 8, 23);
        when "101" =>
          uf := to_ufixed (to_slv (in1reg3(-8 downto -23)), uf);
          outarray(0) := to_float(uf, in1reg3);
        when "110" =>
          sf := to_sfixed (to_slv (in1reg3(-8 downto -23)), sf'high, sf'low);
          outarray(0) := to_float(sf, 8, 23);
        when "111" =>
          sf := to_sfixed (to_slv (in1reg3(-8 downto -23)), sf);
          outarray(0) := to_float(sf, in1reg3);
        when others => null;
      end case;
    end if;
  end process cmd6reg;

  -- purpose: "0111" mod function
--  cmd7reg: process (clk, rst_n) is
--    variable tmpuns : unsigned (31 downto 0);  -- unsigned number
--    variable outarray : cry_type;       -- array for output
--  begin  -- process cmd1reg
--    if rst_n = '0' then                 -- asynchronous reset (active low)
--      outx(7) <= ( others => '0');      
--      jrloop: for j in 0 to 7 loop
--        outarray (j) := (others => '0');
--      end loop jrloop;
--    elsif rising_edge(clk) then         -- rising clock edge
--      outx(7) <= outarray(7);
--      jcloop: for j in 7 downto 1 loop
--        outarray (j) := outarray(j-1);
--      end loop jcloop;
--      outarray(0) := in1reg3 mod in2reg3;
--    end if;
--  end process cmd7reg;
  outx(7) <= (others => '0');

  -- purpose: "1000" rem function
--  cmd8reg: process (clk, rst_n) is
--    variable outarray : cry_type;       -- array for output
--  begin  -- process cmd2reg

--    if rst_n = '0' then                 -- asynchronous reset (active low)
--      outx(8) <= ( others => '0');      
--      jrloop: for j in 0 to 7 loop
--        outarray (j) := (others => '0');
--      end loop jrloop;
--    elsif rising_edge(clk) then         -- rising clock edge
--      outx(8) <= outarray(7);
--      jcloop: for j in 7 downto 1 loop
--        outarray (j) := outarray(j-1);
--      end loop jcloop;
--      outarray(0) := in1reg3 rem in2reg3;
--    end if;

--  end process cmd8reg;
  outx(8) <= (others => '0');

  -- purpose: "1001" to_float (constants) test
  cmd9reg: process (clk, rst_n) is
    variable outarray : cry_type;       -- array for output
    variable tmpcmd : STD_LOGIC_VECTOR (2 downto 0);
  begin  -- process cmd2reg

    if rst_n = '0' then                 -- asynchronous reset (active low)
      outx(9) <= ( others => '0');      
      jrloop: for j in 0 to 7 loop
        outarray (j) := (others => '0');
      end loop jrloop;
    elsif rising_edge(clk) then         -- rising clock edge
      outx(9) <= outarray(7);
      jcloop: for j in 7 downto 1 loop
        outarray (j) := outarray(j-1);
      end loop jcloop;
      tmpcmd := to_slv (in2reg3 (in2reg3'low+2 downto in2reg3'low));
      case tmpcmd is
        when "000" =>
          outarray(0) := to_float(0, 8, 23);
        when "001" =>
          outarray(0) := to_float(0.0, 8, 23);
        when "010" =>
          outarray(0) := to_float(8, in1reg3);
        when "011" =>
          outarray(0) := to_float(8.0, in1reg3);
        when "100" =>
          outarray(0) := to_float(-8, 8, 23);
        when "101" =>
          outarray(0) := to_float(-8.0, 8, 23);
        when "110" =>
          outarray(0) := to_float(27000, in2reg3);
        when "111" =>
--          outarray(0) := "01000000010010010000111111011011";
          outarray(0) := to_float(MATH_PI, in2reg3);
        when others => null;
      end case;
    end if;

  end process cmd9reg;

  -- purpose: "1010" data manipulation (+, -, scalb, etc)
  cmd10reg: process (clk, rst_n) is
    variable tmpcmd : STD_LOGIC_VECTOR (2 downto 0);
    variable s : SIGNED (7 downto 0);  -- signed number
    variable outarray : cry_type;       -- array for output
    constant posinf : float32 := "01111111100000000000000000000000";  -- +inf
    constant neginf : float32 := "11111111100000000000000000000000";  -- +inf
    constant onept5 : float32 := "00111111110000000000000000000000";  -- 1.5
  begin  -- process cmd2reg

    if rst_n = '0' then                 -- asynchronous reset (active low)
      outx(10) <= ( others => '0');      
      jrloop: for j in 0 to 7 loop
        outarray (j) := (others => '0');
      end loop jrloop;
    elsif rising_edge(clk) then         -- rising clock edge
      outx(10) <= outarray(7);
      jcloop: for j in 7 downto 1 loop
        outarray (j) := outarray(j-1);
      end loop jcloop;
      tmpcmd := to_slv (in2reg3 (in2reg3'low+2 downto in2reg3'low));
      case tmpcmd is
        when "000" =>
          outarray(0) := - in1reg3;
        when "001" =>
          outarray(0) := abs( in1reg3);
        when "010" =>
          if (cmdarray(4) = "1010") then
            s := resize (SIGNED (to_slv (in2reg3(8 downto 5))), s'length);
            outarray(0) := Scalb (in1reg3, s);
          else
            outarray(0) := (others => '0');
          end if;
        when "011" =>
          if (cmdarray(4) = "1010") then
            s := logb (in1reg3);
            outarray(0) := (others => '0');
            outarray(0)(-16 downto -23) := float(std_logic_vector(s));
          else
            outarray(0) := (others => '0');
          end if;
--        when "100" =>
--          outarray(0) := Nextafter ( in1reg3, onept5);
--        when "101" =>
--          outarray(0) := Nextafter ( in1reg3, -onept5);
--        when "110" =>
--          outarray(0) := Nextafter ( x => in1reg3, y => posinf,
--                                     check_error => false,
--                                     denormalize => false);
--        when "111" =>
--          outarray(0) := Nextafter (x => in1reg3, y => neginf,
--                                    check_error => false,
--                                    denormalize => false);
        when others =>
          outarray(0) := (others => '0');
      end case;
    end if;

  end process cmd10reg;

  -- purpose "1011" copysign
  cmd11reg: process (clk, rst_n) is
    variable outarray : cry_type;       -- array for output
  begin  -- process cmd2reg
    if rst_n = '0' then                 -- asynchronous reset (active low)
      outx(11) <= ( others => '0');      
      jrloop: for j in 0 to 7 loop
        outarray (j) := (others => '0');
      end loop jrloop;
    elsif rising_edge(clk) then         -- rising clock edge
      outx(11) <= outarray(7);
      jcloop: for j in 7 downto 1 loop
        outarray (j) := outarray(j-1);
      end loop jcloop;
      outarray(0) := Copysign (in1reg3, in2reg3);
    end if;
  end process cmd11reg;

  -- purpose "1100" compare test
  cmd12reg: process (clk, rst_n) is
    variable outarray : cry_type;       -- array for output
    constant fifteenpt5 : float32 := "01000001011110000000000000000000";-- 15.5
  begin  -- process cmd2reg

    if rst_n = '0' then                 -- asynchronous reset (active low)
      outx(12) <= ( others => '0');      
      jrloop: for j in 0 to 7 loop
        outarray (j) := (others => '0');
      end loop jrloop;
    elsif rising_edge(clk) then         -- rising clock edge
      outx(12) <= outarray(7);
      jcloop: for j in 7 downto 1 loop
        outarray (j) := outarray(j-1);
      end loop jcloop;
      outarray(0) := (others => '0');
      if (in1reg3 = in2reg3) then
        outarray(0)(outarray(0)'high) := '1';
      else
        outarray(0)(outarray(0)'high) := '0';
      end if;
      if (in1reg3 /= in2reg3) then
        outarray(0)(outarray(0)'high-1) := '1';
      else
        outarray(0)(outarray(0)'high-1) := '0';
      end if;
      if (in1reg3 > in2reg3) then
        outarray(0)(outarray(0)'high-2) := '1';
      else
        outarray(0)(outarray(0)'high-2) := '0';
      end if;
      if (in1reg3 < in2reg3) then
        outarray(0)(outarray(0)'high-3) := '1';
      else
        outarray(0)(outarray(0)'high-3) := '0';
      end if;
      if (in1reg3 >= in2reg3) then
        outarray(0)(outarray(0)'high-4) := '1';
      else
        outarray(0)(outarray(0)'high-4) := '0';
      end if;
      if (in1reg3 <= in2reg3) then
        outarray(0)(outarray(0)'high-5) := '1';
      else
        outarray(0)(outarray(0)'high-5) := '0';
      end if;
      outarray(0)(outarray(0)'high-6) := \?=\ (in1reg3, 15);
      outarray(0)(outarray(0)'high-7) := \?=\ (in1reg3, 15.5);
      if (Unordered (in1reg3, in2reg3)) then
        outarray(0)(outarray(0)'high-8) := '1';
      else
        outarray(0)(outarray(0)'high-8) := '0';        
      end if;
      if (Finite (in1reg3)) then
        outarray(0)(outarray(0)'high-9) := '1';
      else
        outarray(0)(outarray(0)'high-9) := '0';        
      end if;
      if (Isnan (in1reg3)) then
        outarray(0)(outarray(0)'high-10) := '1';
      else
        outarray(0)(outarray(0)'high-10) := '0';        
      end if;
    end if;

  end process cmd12reg;

  -- purpose "1101" boolean test
  cmd13reg: process (clk, rst_n) is
    variable tmpcmd : STD_LOGIC_VECTOR (2 downto 0);
    variable outarray : cry_type;       -- array for output
  begin  -- process cmd2reg

    if rst_n = '0' then                 -- asynchronous reset (active low)
      outx(13) <= ( others => '0');      
      jrloop: for j in 0 to 7 loop
        outarray (j) := (others => '0');
      end loop jrloop;
    elsif rising_edge(clk) then         -- rising clock edge
      outx(13) <= outarray(7);
      jcloop: for j in 7 downto 1 loop
        outarray (j) := outarray(j-1);
      end loop jcloop;
      tmpcmd := to_slv (in2reg3 (in2reg3'low+2 downto in2reg3'low));
      case tmpcmd is
        when "000" =>
          outarray(0) := not (in1reg3);
        when "001" =>
          outarray(0) := in1reg3 and in2reg3;
        when "010" =>
          outarray(0) := in1reg3 or in2reg3;
        when "011" =>
          outarray(0) := in1reg3 nand in2reg3;
        when "100" =>
          outarray(0) := in1reg3 nor in2reg3;
        when "101" =>
          outarray(0) := in1reg3 xor in2reg3;
        when "110" =>
          outarray(0) := in1reg3 xnor in2reg3;
        when "111" =>
          outarray(0) := in1reg3 xor '1';
        when others => null;
      end case;
    end if;

  end process cmd13reg;

  -- purpose "1110" reduce and vector test
  cmd14reg: process (clk, rst_n) is
    variable tmpcmd : STD_LOGIC_VECTOR (2 downto 0);
    variable outarray : cry_type;       -- array for output
  begin  -- process cmd2reg

    if rst_n = '0' then                 -- asynchronous reset (active low)
      outx(14) <= ( others => '0');      
      jrloop: for j in 0 to 7 loop
        outarray (j) := (others => '0');
      end loop jrloop;
    elsif rising_edge(clk) then         -- rising clock edge
      outx(14) <= outarray(7);
      jcloop: for j in 7 downto 1 loop
        outarray (j) := outarray(j-1);
      end loop jcloop;
      tmpcmd := to_slv (in2reg3 (in2reg3'low+2 downto in2reg3'low));
      case tmpcmd is
        when "000" =>
          outarray(0) := (others => '0');
          outarray(0)(outarray(0)'high) := and_reduce (in1reg3);
          outarray(0)(outarray(0)'high-1) := nand_reduce (in1reg3);
          outarray(0)(outarray(0)'high-2) := or_reduce (in1reg3);
          outarray(0)(outarray(0)'high-3) := nor_reduce (in1reg3);
          outarray(0)(outarray(0)'high-4) := xor_reduce (in1reg3);
          outarray(0)(outarray(0)'high-5) := xnor_reduce (in1reg3);
        when "001" => 
          outarray(0) := in1reg3 and in2reg3(in2reg3'high);
        when "010" => 
          outarray(0) := in1reg3 or in2reg3(in2reg3'high);
        when "011" => 
          outarray(0) := in1reg3 nand in2reg3(in2reg3'high);
        when "100" => 
          outarray(0) := in1reg3 nor in2reg3(in2reg3'high);
        when "101" => 
          outarray(0) := in2reg3(in2reg3'high) xor in1reg3;
        when "110" => 
          outarray(0) := in2reg3(in2reg3'high) xnor in1reg3;
        when "111" => 
          outarray(0) := in2reg3(in2reg3'high) and in1reg3;
        when others => null;
      end case;
    end if;

  end process cmd14reg;

  -- purpose "1111"  + constant
  cmd15reg: process (clk, rst_n) is
    variable tmpcmd : STD_LOGIC_VECTOR (2 downto 0);
    variable outarray : cry_type;       -- array for output
  begin  -- process cmd2reg

    if rst_n = '0' then                 -- asynchronous reset (active low)
      outx(15) <= ( others => '0');      
      jrloop: for j in 0 to 7 loop
        outarray (j) := (others => '0');
      end loop jrloop;
    elsif rising_edge(clk) then         -- rising clock edge
      outx(15) <= outarray(7);
      jcloop: for j in 7 downto 1 loop
        outarray (j) := outarray(j-1);
      end loop jcloop;
      tmpcmd := to_slv (in2reg3 (in2reg3'low+2 downto in2reg3'low));
      case tmpcmd is
        when "000" =>
          outarray(0) := in1reg3 + 1;
        when "001" =>
          outarray(0) := 1 + in1reg3;
        when "010" =>
          outarray(0) := in1reg3 + 1.0;
        when "011" =>
          outarray(0) := 1.0 + in1reg3;
        when "100" =>
          outarray(0) := in1reg3 * 1;
        when "101" =>
          outarray(0) := 1 * in1reg3;
        when "110" =>
          outarray(0) := in1reg3 * 1.0;
        when "111" =>
          outarray(0) := 1.0 * in1reg3;
        when others => null;
      end case;
    end if;

  end process cmd15reg;
  
  -- purpose: multiply floating point
  -- type   : sequential
  -- inputs : clk, rst_n, in1, in2
  -- outputs: out1
  cmdreg: process (clk, rst_n) is
    variable  outreg : float32;  -- register stages
    variable in1reg, in2reg : float32;  -- register stages
    variable in1reg2, in2reg2 : float32;  -- register stages
  begin  -- process mulreg

    if rst_n = '0' then                 -- asynchronous reset (active low)
      in1reg := ( others => '0');
      in2reg := ( others => '0');
      in1reg2 := ( others => '0');
      in2reg2 := ( others => '0');
      in1reg3 <= ( others => '0');
      in2reg3 <= ( others => '0');
      out1 <= ( others => '0');
      outreg := (others => '0');
      rcloop: for i in 1 to 15 loop
        cmdarray (i) <= (others => '0');
      end loop rcloop;
    elsif rising_edge(clk) then         -- rising clock edge
      out1 <= to_slv (outreg);
      outregc: case cmdarray (13) is
        when "0000" => outreg := outx (0);
        when "0001" => outreg := outx (1);
        when "0010" => outreg := outx (2);
        when "0011" => outreg := outx (3);
        when "0100" => outreg := outx (4);
        when "0101" => outreg := outx (5);
        when "0110" => outreg := outx (6);
        when "0111" => outreg := outx (7);
        when "1000" => outreg := outx (8);
        when "1001" => outreg := outx (9);
        when "1010" => outreg := outx (10);
        when "1011" => outreg := outx (11);
        when "1100" => outreg := outx (12);
        when "1101" => outreg := outx (13);
        when "1110" => outreg := outx (14);
        when "1111" => outreg := outx (15);
        when others => null;
      end case outregc;
      cmdpipe: for i in 15 downto 3 loop
        cmdarray (i) <= cmdarray (i-1);
      end loop cmdpipe;
      cmdarray (2) <= std_ulogic_vector(cmd);
      in1reg3 <= in1reg2;
      in2reg3 <= in2reg2;
      in1reg2 := in1reg;
      in2reg2 := in2reg;
      in1reg := to_float (in1, in1reg);
      in2reg := to_float (in2, in2reg);
    end if;

  end process cmdreg;

end architecture rtl;
