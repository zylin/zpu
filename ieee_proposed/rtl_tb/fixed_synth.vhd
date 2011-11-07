-- Synthesis test for the fixed point math package
-- This test is designed to be synthesizable and exercise much of the package.
-- Created for vhdl-200x by David Bishop (dbishop@vhdl.org)
-- --------------------------------------------------------------------
--   modification history : Last Modified $Date: 2006-06-08 10:49:35-04 $
--   Version $Id: fixed_synth.vhdl,v 1.1 2006-06-08 10:49:35-04 l435385 Exp $
-- --------------------------------------------------------------------


library ieee, ieee_proposed;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee_proposed.fixed_float_types.all;
use ieee_proposed.fixed_pkg.all;
entity fixed_synth is
  
  port (
    in1, in2   : in  STD_LOGIC_VECTOR (15 downto 0);  -- inputs
    out1       : out STD_LOGIC_VECTOR (15 downto 0);  -- output
    cmd        : in  STD_LOGIC_VECTOR (3 downto 0);
    clk, rst_n : in  STD_ULOGIC);                     -- clk and reset

end entity fixed_synth;

architecture rtl of fixed_synth is

  subtype sfixed7 is sfixed (3 downto -3);                            -- 7 bit
  subtype sfixed16 is sfixed (7 downto -8);                           -- 16 bit
  type cmd_type is array (1 to 15) of STD_ULOGIC_VECTOR (cmd'range);  -- cmd
  signal cmdarray : cmd_type;           -- command pipeline
--  type cry_type is array (0 to 4) of sfixed16;                        -- arrays
  signal outarray0, outarray1, outarray2, outarray3, outarray4,
    outarray5, outarray6, outarray7, outarray8, outarray9, outarray10,
    outarray11, outarray12, outarray13, outarray14, outarray15 : sfixed16;
  signal in1reg3, in2reg3 : sfixed16;   -- register stages
begin  -- architecture rtl

  -- purpose: "0000" test the "+" operator
  cmd0reg : process (clk, rst_n) is
    variable in1pin2 : sfixed (SFixed_high(7, -8, '+', 7, -8) downto
                               SFixed_low(7, -8, '+', 7, -8));
--    variable outarray           : cry_type;  -- array for output
--    variable in1array, in2array : cry_type;  -- array for input
  begin  -- process cmd0reg
    if rst_n = '0' then                      -- asynchronous reset (active low)
      outarray0 <= (others => '0');
--      jrloop : for j in 0 to 4 loop
--        outarray (j) := (others => '0');
--        in1array (j) := (others => '0');
--        in2array (j) := (others => '0');
--      end loop jrloop;
    elsif rising_edge(clk) then              -- rising clock edge
--      outarray0 <= outarray(4);
--      jcloop : for j in 4 downto 1 loop
--        outarray (j) := outarray(j-1);
--      end loop jcloop;
--      j1loop : for j in 3 downto 1 loop
--        in1array (j) := in1array(j-1);
--      end loop j1loop;
--      j2loop : for j in 3 downto 1 loop
--        in2array (j) := in2array(j-1);
--      end loop j2loop;
--      in1array(0) := in1reg3;
--      in2array(0) := in2reg3;
      in1pin2     := in1reg3 + in2reg3;
      outarray0 <= resize (in1pin2, outarray0);
    end if;
  end process cmd0reg;

  -- purpose: "0001" test the "-" operator
  cmd1reg : process (clk, rst_n) is
--    variable outarray           : cry_type;  -- array for output
--    variable in1array, in2array : cry_type;  -- array for input
--    variable in1min2 : sfixed (SFixed_high(in1reg3, '-', in2reg3) downto
--                               SFixed_low(in1reg3, '-', in2reg3));
    variable in1min2 : sfixed (SFixed_high(7, -8, '-', 7, -8) downto
                               SFixed_low(7, -8, '-', 7, -8));
  begin  -- process cmd0reg
    if rst_n = '0' then                      -- asynchronous reset (active low)
      outarray1 <= (others => '0');
--      jrloop : for j in 0 to 4 loop
--        outarray (j) := (others => '0');
--        in1array (j) := (others => '0');
--        in2array (j) := (others => '0');
--      end loop jrloop;
    elsif rising_edge(clk) then              -- rising clock edge
--      outarray1 <= outarray(4);
--      jcloop : for j in 4 downto 1 loop
--        outarray (j) := outarray(j-1);
--      end loop jcloop;
--      j1loop : for j in 3 downto 1 loop
--        in1array (j) := in1array(j-1);
--      end loop j1loop;
--      j2loop : for j in 3 downto 1 loop
--        in2array (j) := in2array(j-1);
--      end loop j2loop;
--      in1array(0) := in1reg3;
--      in2array(0) := in2reg3;
      in1min2     := in1reg3 - in2reg3;
      outarray1 <= resize (in1min2, outarray1);
    end if;
  end process cmd1reg;

  -- purpose: "0010" test the "*" operator
  cmd2reg : process (clk, rst_n) is
--    variable in1min2 : sfixed (SFixed_high(in1reg3, '*', in2reg3) downto
--                               SFixed_low(in1reg3, '*', in2reg3));
    variable in1min2 : sfixed (SFixed_high(7, -8, '*', 7, -8) downto
                               SFixed_low(7, -8, '*', 7, -8));
--    variable outarray           : cry_type;  -- array for output
--    variable in1array, in2array : cry_type;  -- array for input
  begin  -- process cmd0reg
    if rst_n = '0' then                      -- asynchronous reset (active low)
      outarray2 <= (others => '0');
--      jrloop : for j in 0 to 4 loop
--        outarray (j) := (others => '0');
--        in1array (j) := (others => '0');
--        in2array (j) := (others => '0');
--      end loop jrloop;
    elsif rising_edge(clk) then              -- rising clock edge
--      outarray2 <= outarray(4);
--      jcloop : for j in 4 downto 1 loop
--        outarray (j) := outarray(j-1);
--      end loop jcloop;
--      j1loop : for j in 3 downto 1 loop
--        in1array (j) := in1array(j-1);
--      end loop j1loop;
--      j2loop : for j in 3 downto 1 loop
--        in2array (j) := in2array(j-1);
--      end loop j2loop;
--      in1array(0) := in1reg3;
--      in2array(0) := in2reg3;
      in1min2     := in1reg3 * in2reg3;
      outarray2 <= resize (in1min2, outarray2);
    end if;
  end process cmd2reg;

  -- purpose: "0011" test the "/" operator
--  cmd3reg : process (clk, rst_n) is
--    variable in1min2 : sfixed (SFixed_high(in1reg3'high, in1reg3'low,
--                                           '/', in2reg3'high, in2reg3'low)
--                               downto
--                               SFixed_low(in1reg3'high, in1reg3'low,
--                                          '/', in2reg3'high, in2reg3'low));
--    variable outarray           : cry_type;  -- array for output
--    variable in1array, in2array : cry_type;  -- array for input
--  begin  -- process cmd3reg
--    if rst_n = '0' then                      -- asynchronous reset (active low)
--      outarray3 <= (others => '0');
--      jrloop : for j in 0 to 4 loop
--        outarray (j) := (others => '0');
--        in1array (j) := (others => '0');
--        in2array (j) := to_sfixed(1, in2array(0));
--      end loop jrloop;
--    elsif rising_edge(clk) then              -- rising clock edge
--      outarray3 <= outarray(4);
--      jcloop : for j in 4 downto 1 loop
--        outarray (j) := outarray(j-1);
--      end loop jcloop;
--      j1loop : for j in 3 downto 1 loop
--        in1array (j) := in1array(j-1);
--      end loop j1loop;
--      j2loop : for j in 3 downto 1 loop
--        in2array (j) := in2array(j-1);
--      end loop j2loop;
--      in1array(0) := in1reg3;
--      if (in2reg3 = 0) then
--        in2array(0) := to_sfixed(1, in2array(0));
--      else
--        in2array(0) := in2reg3;
--      end if;
--      in1min2     := in1array(3) / in2array(3);
--      outarray(0) := resize (in1min2, outarray(0));
--    end if;
--  end process cmd3reg;
  outarray3 <= (others => '0');

  -- purpose: "0100" test the "+" operator
  cmd4reg : process (clk, rst_n) is
    variable in1pin2 : ufixed (uFixed_high(7, -8, '+', 7, -8) downto
                               uFixed_low(7, -8, '+', 7, -8));
--    variable outarray           : cry_type;  -- array for output
--    variable in1array, in2array : cry_type;  -- array for input
  begin  -- process cmd0reg
    if rst_n = '0' then                      -- asynchronous reset (active low)
      outarray4 <= (others => '0');
--      jrloop : for j in 0 to 4 loop
--        outarray (j) := (others => '0');
--        in1array (j) := (others => '0');
--        in2array (j) := (others => '0');
--      end loop jrloop;
    elsif rising_edge(clk) then              -- rising clock edge
--      outarray4 <= outarray(4);
--      jcloop : for j in 4 downto 1 loop
--        outarray (j) := outarray(j-1);
--      end loop jcloop;
--      j1loop : for j in 3 downto 1 loop
--        in1array (j) := in1array(j-1);
--      end loop j1loop;
--      j2loop : for j in 3 downto 1 loop
--        in2array (j) := in2array(j-1);
--      end loop j2loop;
--      in1array(0) := in1reg3;
--      in2array(0) := in2reg3;
      in1pin2     := ufixed(in1reg3) + ufixed(in2reg3);
      outarray4 <= sfixed (resize (in1pin2, outarray4'high, outarray4'low));
    end if;
  end process cmd4reg;

  -- purpose: "0101" test the "-" operator
  cmd5reg : process (clk, rst_n) is
    variable in1min2 : ufixed (uFixed_high(7, -8, '-', 7, -8) downto
                               uFixed_low(7, -8, '-', 7, -8));
--    variable outarray           : cry_type;  -- array for output
--    variable in1array, in2array : cry_type;  -- array for input
  begin  -- process cmd0reg
    if rst_n = '0' then                      -- asynchronous reset (active low)
      outarray5 <= (others => '0');
--      jrloop : for j in 0 to 4 loop
--        outarray (j) := (others => '0');
--        in1array (j) := (others => '0');
--        in2array (j) := (others => '0');
--      end loop jrloop;
    elsif rising_edge(clk) then              -- rising clock edge
--      outarray5 <= outarray(4);
--      jcloop : for j in 4 downto 1 loop
--        outarray (j) := outarray(j-1);
--      end loop jcloop;
--      j1loop : for j in 3 downto 1 loop
--        in1array (j) := in1array(j-1);
--      end loop j1loop;
--      j2loop : for j in 3 downto 1 loop
--        in2array (j) := in2array(j-1);
--      end loop j2loop;
--      in1array(0) := in1reg3;
--      in2array(0) := in2reg3;
      in1min2     := ufixed(in1reg3) - ufixed(in2reg3);
      outarray5 <= sfixed(resize (in1min2, outarray5'high, outarray5'low));
    end if;
  end process cmd5reg;

  -- purpose: "0110" test the "*" operator
  cmd6reg : process (clk, rst_n) is
    variable in1min2 : ufixed (uFixed_high(7, -8, '*', 7, -8) downto
                               uFixed_low(7, -8, '*', 7, -8));
--    variable outarray           : cry_type;  -- array for output
--    variable in1array, in2array : cry_type;  -- array for input
  begin  -- process cmd0reg
    if rst_n = '0' then                      -- asynchronous reset (active low)
      outarray6 <= (others => '0');
--      jrloop : for j in 0 to 4 loop
--        outarray (j) := (others => '0');
--        in1array (j) := (others => '0');
--        in2array (j) := (others => '0');
--      end loop jrloop;
    elsif rising_edge(clk) then              -- rising clock edge
--      outarray6 <= outarray(4);
--      jcloop : for j in 4 downto 1 loop
--        outarray (j) := outarray(j-1);
--      end loop jcloop;
--      j1loop : for j in 3 downto 1 loop
--        in1array (j) := in1array(j-1);
--      end loop j1loop;
--      j2loop : for j in 3 downto 1 loop
--        in2array (j) := in2array(j-1);
--      end loop j2loop;
--      in1array(0) := in1reg3;
--      in2array(0) := in2reg3;
      in1min2     := ufixed(in1reg3) * ufixed(in2reg3);
      outarray6 <= sfixed(resize (in1min2, outarray6'high, outarray6'low));
    end if;
  end process cmd6reg;

  -- purpose: "0111" test the "/" operator
--  cmd7reg : process (clk, rst_n) is
--    variable in1min2 : ufixed (uFixed_high(7, -8, '/', 7, -8) downto
--                               uFixed_low(7, -8, '/', 7, -8));
--    variable outarray           : cry_type;  -- array for output
--    variable in1array, in2array : cry_type;  -- array for input
--  begin  -- process cmd0reg
--    if rst_n = '0' then                      -- asynchronous reset (active low)
--      outarray7 <= (others => '0');
--      jrloop : for j in 0 to 4 loop
--        outarray (j) := (others => '0');
--        in1array (j) := (others => '0');
--        in2array (j) := sfixed(to_ufixed(1, in2reg3'high, in2reg3'low));
--      end loop jrloop;
--    elsif rising_edge(clk) then              -- rising clock edge
--      outarray7 <= outarray(4);
--      jcloop : for j in 4 downto 1 loop
--        outarray (j) := outarray(j-1);
--      end loop jcloop;
--      j1loop : for j in 3 downto 1 loop
--        in1array (j) := in1array(j-1);
--      end loop j1loop;
--      j2loop : for j in 3 downto 1 loop
--        in2array (j) := in2array(j-1);
--      end loop j2loop;
--      in1array(0) := in1reg3;
--      if (in2reg3 = 0) then
--        in2array(0) := sfixed(to_ufixed(1, in2reg3'high, in2reg3'low));
--      else
--        in2array(0) := in2reg3;
--      end if;
--      in1min2     := ufixed(in1array(3)) / ufixed(in2array(3));
--      outarray(0) := sfixed(resize (in1min2, outarray7'high, outarray7'low));
--    end if;
--  end process cmd7reg;
  outarray7 <= (others => '0');

  -- purpose: "1000" test the resize test
  cmd8reg : process (clk, rst_n) is
    variable tmpfp71, tmpfp72   : sfixed7;   -- 8 bit fp number
--    variable outarray           : cry_type;  -- array for output
--    variable in1array, in2array : cry_type;  -- array for input
  begin  -- process cmd0reg
    if rst_n = '0' then                      -- asynchronous reset (active low)
      outarray8 <= (others => '0');
--      jrloop : for j in 0 to 4 loop
--        outarray (j) := (others => '0');
--        in1array (j) := (others => '0');
--        in2array (j) := (others => '0');
--      end loop jrloop;
    elsif rising_edge(clk) then              -- rising clock edge
--      outarray8 <= outarray(4);
--      jcloop : for j in 4 downto 1 loop
--        outarray (j) := outarray(j-1);
--      end loop jcloop;
--      j1loop : for j in 3 downto 1 loop
--        in1array (j) := in1array(j-1);
--      end loop j1loop;
--      j2loop : for j in 3 downto 1 loop
--        in2array (j) := in2array(j-1);
--      end loop j2loop;
--      in1array(0) := in1reg3;
--      in2array(0) := in2reg3;
      -- Resize test Convert inputs into two 8 bit numbers
      tmpfp71 := resize (in1reg3, tmpfp71'high, tmpfp71'low,
                         fixed_wrap, fixed_truncate);
      tmpfp72 := resize (in2reg3, tmpfp72'high, tmpfp72'low,
                         fixed_saturate, fixed_round);
      outarray8 <= (others => '0');
      fx1 : for i in tmpfp71'range loop
        outarray8(i+4) <= tmpfp71(i);
      end loop fx1;
      fx2 : for i in tmpfp72'range loop
        outarray8(i-4) <= tmpfp72(i);
      end loop fx2;
    end if;
  end process cmd8reg;

  -- purpose: "1001" test the to_signed/unsigned test
  cmd9reg : process (clk, rst_n) is
    variable tmp                : STD_LOGIC_VECTOR (1 downto 0);  -- temp
    variable tmpsig             : SIGNED (7 downto 0);     -- signed number
    variable tmpuns             : UNSIGNED (15 downto 0);  -- unsigned number
    variable tmpint             : INTEGER;
--    variable outarray           : cry_type;                -- array for output
--    variable in1array, in2array : cry_type;                -- array for input
  begin  -- process cmd0reg
    if rst_n = '0' then                 -- asynchronous reset (active low)
      outarray9 <= (others => '0');
--      jrloop : for j in 0 to 4 loop
--        outarray (j) := (others => '0');
--        in1array (j) := (others => '0');
--        in2array (j) := (others => '0');
--      end loop jrloop;
    elsif rising_edge(clk) then         -- rising clock edge
--      outarray9 <= outarray(4);
--      jcloop : for j in 4 downto 1 loop
--        outarray (j) := outarray(j-1);
--      end loop jcloop;
--      j1loop : for j in 3 downto 1 loop
--        in1array (j) := in1array(j-1);
--      end loop j1loop;
--      j2loop : for j in 3 downto 1 loop
--        in2array (j) := in2array(j-1);
--      end loop j2loop;
--      in1array(0) := in1reg3;
--      in2array(0) := in2reg3;
      tmp         := to_slv (in2reg3(in2reg3'high downto in2reg3'high-1));
      if (tmp = "00") then
        -- Signed to sfixed and back
        tmpsig      := to_signed (in1reg3, tmpsig'length);
        outarray9 <= to_sfixed (tmpsig, outarray9);
      elsif (tmp = "01") then
        -- unsigned to ufixed and back
        tmpuns := to_unsigned (ufixed(in1reg3), tmpuns'length);
        outarray9 <= sfixed(to_ufixed (tmpuns, outarray9'high,
                                         outarray9'low));
      elsif (tmp = "10") then
        tmpint      := to_integer (in1reg3);
        outarray9 <= to_sfixed (tmpint, outarray9);
      else
        tmpint := to_integer (ufixed(in1reg3));
        outarray9 <= sfixed(to_ufixed (tmpint, outarray9'high,
                                         outarray9'low));

      end if;
    end if;
  end process cmd9reg;

  -- purpose: "1010" test the reciprocal, abs, - test
--  cmd10reg : process (clk, rst_n) is
--    variable tmp       : STD_LOGIC_VECTOR (1 downto 0);  -- temp
--    variable in1recip  : sfixed (-in1reg3'low+1 downto -in1reg3'high);
--    variable uin1recip : ufixed (-in1reg3'low downto -in1reg3'high-1);
--    variable in1pin2 : sfixed (SFixed_high(7, -8, '+', 7, -8) downto
--                               SFixed_low(7, -8, '+', 7, -8));
--    variable outarray           : cry_type;              -- array for output
--    variable in1array, in2array : cry_type;              -- array for input
--  begin  -- process cmd0reg
--    if rst_n = '0' then                 -- asynchronous reset (active low)
--      outarray10 <= (others => '0');
--      jrloop : for j in 0 to 4 loop
--        outarray (j) := (others => '0');
--        in1array (j) := to_sfixed(1, in1reg3);
--        in2array (j) := (others => '0');
--      end loop jrloop;
--    elsif rising_edge(clk) then         -- rising clock edge
--      outarray10 <= outarray(4);
--      jcloop : for j in 4 downto 1 loop
--        outarray (j) := outarray(j-1);
--      end loop jcloop;
--      j1loop : for j in 3 downto 1 loop
--        in1array (j) := in1array(j-1);
--      end loop j1loop;
--      j2loop : for j in 3 downto 1 loop
--        in2array (j) := in2array(j-1);
--      end loop j2loop;
--      if (in1reg3 = 0) then
--        in1array(0) := to_sfixed(1, in1reg3);
--      else
--        in1array(0) := in1reg3;
--      end if;
--      in2array(0) := in2reg3;
--      tmp         := to_slv (in2array(3)(in2reg3'high downto in2reg3'high-1));
--      if (tmp = "00") then
--        in1recip := reciprocal (in1reg3);
--        outarray(0) := resize (in1recip, outarray(0)'high,
--                               outarray(0)'low);
--      elsif (tmp = "01") then
--        uin1recip := reciprocal (ufixed(in1reg3));
--        outarray(0) := sfixed(resize (uin1recip, outarray(0)'high,
--                                      outarray(0)'low));            
--      elsif (tmp = "10") then
--        -- abs
--        in1pin2 := abs(in1reg3);
--        outarray(0) := resize (in1pin2,
--                               outarray(0)'high,
--                               outarray(0)'low);
--      else
--        -- -
--        in1pin2 := - in1reg3;
--        outarray(0) := resize (in1pin2,
--                               outarray(0)'high,
--                               outarray(0)'low);
--      end if;
--    end if;
--  end process cmd10reg;
  outarray10 <= (others => '0');

  -- purpose: "1011" test the mod operator
--  cmd11reg : process (clk, rst_n) is
--    variable in1min2 : sfixed (SFixed_high(7, -8, 'M', 7, -8) downto
--                               SFixed_low(7, -8, 'm', 7, -8));
--    variable outarray           : cry_type;  -- array for output
--    variable in1array, in2array : cry_type;  -- array for input
--  begin  -- process cmd0reg
--    if rst_n = '0' then                      -- asynchronous reset (active low)
--      outarray11 <= (others => '0');
--      jrloop : for j in 0 to 4 loop
--        outarray (j) := (others => '0');
--        in1array (j) := (others => '0');
--        in2array (j) := to_sfixed(1, in2array(0));
--      end loop jrloop;
--    elsif rising_edge(clk) then              -- rising clock edge
--      outarray11 <= outarray(4);
--      jcloop : for j in 4 downto 1 loop
--        outarray (j) := outarray(j-1);
--      end loop jcloop;
--      j1loop : for j in 3 downto 1 loop
--        in1array (j) := in1array(j-1);
--      end loop j1loop;
--      j2loop : for j in 3 downto 1 loop
--        in2array (j) := in2array(j-1);
--      end loop j2loop;
--      in1array(0) := in1reg3;
--      if (in2reg3 = 0) then
--        in2array(0) := to_sfixed(1, in2array(0));
--      else
--        in2array(0) := in2reg3;
--      end if;
--      in1min2     := in1reg3 mod in2array(3);
--      outarray(0) := resize (in1min2, outarray(0));
--    end if;
--  end process cmd11reg;
  outarray11 <= (others => '0');

  -- purpose: "1100" test the rem operator
--  cmd12reg : process (clk, rst_n) is
--    variable in1min2 : sfixed (SFixed_high(7, -8, 'R', 7, -8) downto
--                               SFixed_low(7, -8, 'r', 7, -8));
--    variable outarray           : cry_type;  -- array for output
--    variable in1array, in2array : cry_type;  -- array for input
--  begin  -- process cmd0reg
--    if rst_n = '0' then                      -- asynchronous reset (active low)
--      outarray12 <= (others => '0');
--      jrloop : for j in 0 to 4 loop
--        outarray (j) := (others => '0');
--        in1array (j) := (others => '0');
--        in2array (j) := to_sfixed(1, in2array(0));
--      end loop jrloop;
--    elsif rising_edge(clk) then              -- rising clock edge
--      outarray12 <= outarray(4);
--      jcloop : for j in 4 downto 1 loop
--        outarray (j) := outarray(j-1);
--      end loop jcloop;
--      j1loop : for j in 3 downto 1 loop
--        in1array (j) := in1array(j-1);
--      end loop j1loop;
--      j2loop : for j in 3 downto 1 loop
--        in2array (j) := in2array(j-1);
--      end loop j2loop;
--      in1array(0) := in1reg3;
--      if (in2reg3 = 0) then
--        in2array(0) := to_sfixed(1, in2array(0));
--      else
--        in2array(0) := in2reg3;
--      end if;
--      in1min2     := in1reg3 rem in2array(3);
--      outarray(0) := resize (in1min2, outarray(0));
--    end if;
--  end process cmd12reg;
  outarray12 <= (others => '0');

  -- purpose: "1101" test the srl operator
  cmd13reg : process (clk, rst_n) is
--    variable outarray           : cry_type;  -- array for output
--    variable in1array, in2array : cry_type;  -- array for input
  begin  -- process cmd0reg
    if rst_n = '0' then                      -- asynchronous reset (active low)
      outarray13 <= (others => '0');
--      jrloop : for j in 0 to 4 loop
--        outarray (j) := (others => '0');
--        in1array (j) := (others => '0');
--        in2array (j) := (others => '0');
--      end loop jrloop;
    elsif rising_edge(clk) then              -- rising clock edge
--      outarray13 <= outarray(4);
--      jcloop : for j in 4 downto 1 loop
--        outarray (j) := outarray(j-1);
--      end loop jcloop;
--      j1loop : for j in 3 downto 1 loop
--        in1array (j) := in1array(j-1);
--      end loop j1loop;
--      j2loop : for j in 3 downto 1 loop
--        in2array (j) := in2array(j-1);
--      end loop j2loop;
--      in1array(0) := in1reg3;
--      in2array(0) := in2reg3;
      outarray13 <= in1reg3 srl to_integer(in2reg3);
    end if;
  end process cmd13reg;

  -- purpose: "1110" test the sra operator
  cmd14reg : process (clk, rst_n) is
--    variable outarray           : cry_type;  -- array for output
--    variable in1array, in2array : cry_type;  -- array for input
  begin  -- process cmd0reg
    if rst_n = '0' then                      -- asynchronous reset (active low)
      outarray14 <= (others => '0');
--      jrloop : for j in 0 to 4 loop
--        outarray (j) := (others => '0');
--        in1array (j) := (others => '0');
--        in2array (j) := (others => '0');
--      end loop jrloop;
    elsif rising_edge(clk) then              -- rising clock edge
--      outarray14 <= outarray(4);
--      jcloop : for j in 4 downto 1 loop
--        outarray (j) := outarray(j-1);
--      end loop jcloop;
--      j1loop : for j in 3 downto 1 loop
--        in1array (j) := in1array(j-1);
--      end loop j1loop;
--      j2loop : for j in 3 downto 1 loop
--        in2array (j) := in2array(j-1);
--      end loop j2loop;
--      in1array(0) := in1reg3;
--      in2array(0) := in2reg3;
      outarray14 <= in1reg3 sra to_integer(in2reg3);
    end if;
  end process cmd14reg;

  -- purpose: "1111" test the sra operator
  cmd15reg : process (clk, rst_n) is
    constant match_data         : sfixed16 := "01HL----10HL----";  -- for ?= command
--    variable outarray           : cry_type;  -- array for output
--    variable in1array, in2array : cry_type;  -- array for input
  begin  -- process cmd0reg
    if rst_n = '0' then                 -- asynchronous reset (active low)
      outarray15 <= (others => '0');
--      jrloop : for j in 0 to 4 loop
--        outarray (j) := (others => '0');
--        in1array (j) := (others => '0');
--        in2array (j) := (others => '0');
--      end loop jrloop;
    elsif rising_edge(clk) then         -- rising clock edge
--      outarray15 <= outarray(4);
--      jcloop : for j in 4 downto 1 loop
--        outarray (j) := outarray(j-1);
--      end loop jcloop;
--      j1loop : for j in 3 downto 1 loop
--        in1array (j) := in1array(j-1);
--      end loop j1loop;
--      j2loop : for j in 3 downto 1 loop
--        in2array (j) := in2array(j-1);
--      end loop j2loop;
--      in1array(0) := in1reg3;
--      in2array(0) := in2reg3;
      -- compare test
      if (in1reg3 = in2reg3) then
        outarray15(-8) <= '1';
      else
        outarray15(-8) <= '0';
      end if;
      if (in1reg3 /= in2reg3) then
        outarray15(-7) <= '1';
      else
        outarray15(-7) <= '0';
      end if;
      if (in1reg3 < in2reg3) then
        outarray15(-6) <= '1';
      else
        outarray15(-6) <= '0';
      end if;
      if (in1reg3 > in2reg3) then
        outarray15(-5) <= '1';
      else
        outarray15(-5) <= '0';
      end if;
      if (in1reg3 <= in2reg3) then
        outarray15(-4) <= '1';
      else
        outarray15(-4) <= '0';
      end if;
      if (in1reg3 >= in2reg3) then
        outarray15(-3) <= '1';
      else
        outarray15(-3) <= '0';
      end if;
      if (in1reg3 = 45) then
        outarray15(-2) <= '1';
      else
        outarray15(-2) <= '0';
      end if;
      if (in1reg3 = 3.125) then
        outarray15(-1) <= '1';
      else
        outarray15(-1) <= '0';
      end if;
      -- add integer and real
      outarray15(0) <= \?=\ (in1reg3, in2reg3 + 45);
      if (in1reg3 = in2reg3 + 3.125) then
        outarray15(1) <= '1';
      else
        outarray15(1) <= '0';
      end if;
      if (std_match (in1reg3, match_data)) then
        outarray15(2) <= '1';
      else
        outarray15(2) <= '0';
      end if;
      outarray15(3) <= nor_reduce (in1reg3 or in2reg3);
      outarray15(4) <= xnor_reduce (in1reg3 xor in2reg3);
      outarray15(5) <= nand_reduce (not in1reg3);
      outarray15(6) <= or_reduce ('1' and ufixed(in1reg3));
      if find_leftmost(in1reg3, '1') = 3 then
        outarray15(7) <= '1';
      else
        outarray15(7) <= '0';
      end if;
    end if;
  end process cmd15reg;

  -- purpose: register the inputs and the outputs
  -- type   : sequential
  -- inputs : clk, rst_n, in1, in2
  -- outputs: out1
  cmdreg : process (clk, rst_n) is
    variable outreg           : sfixed16;  -- register stages
    variable in1reg, in2reg   : sfixed16;  -- register stages
    variable in1reg2, in2reg2 : sfixed16;  -- register stages
  begin  -- process mulreg
    if rst_n = '0' then                    -- asynchronous reset (active low)
      in1reg  := (others => '0');
      in2reg  := (others => '0');
      in1reg2 := (others => '0');
      in2reg2 := (others => '0');
      in1reg3 <= (others => '0');
      in2reg3 <= (others => '0');
      out1    <= (others => '0');
      outreg  := (others => '0');
      rcloop : for i in 1 to 15 loop
        cmdarray (i) <= (others => '0');
      end loop rcloop;
    elsif rising_edge(clk) then            -- rising clock edge
      out1 <= to_slv (outreg);
      outregc : case cmdarray (13) is
        when "0000" => outreg := outarray0;
        when "0001" => outreg := outarray1;
        when "0010" => outreg := outarray2;
        when "0011" => outreg := outarray3;
        when "0100" => outreg := outarray4;
        when "0101" => outreg := outarray5;
        when "0110" => outreg := outarray6;
        when "0111" => outreg := outarray7;
        when "1000" => outreg := outarray8;
        when "1001" => outreg := outarray9;
        when "1010" => outreg := outarray10;
        when "1011" => outreg := outarray11;
        when "1100" => outreg := outarray12;
        when "1101" => outreg := outarray13;
        when "1110" => outreg := outarray14;
        when "1111" => outreg := outarray15;
        when others => null;
      end case outregc;
      cmdpipe : for i in 15 downto 3 loop
        cmdarray (i) <= cmdarray (i-1);
      end loop cmdpipe;
      cmdarray (2) <= STD_ULOGIC_VECTOR(cmd);
      in1reg3      <= in1reg2;
      in2reg3      <= in2reg2;
      in1reg2      := in1reg;
      in2reg2      := in2reg;
      in1reg       := to_sfixed (in1, in1reg);
      in2reg       := to_sfixed (in2, in2reg);
    end if;
  end process cmdreg;

end architecture rtl;
