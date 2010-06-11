-- File: endian_h.vhd
-- Version: 3.0 (June 6, 2004)
-- Source: http://bear.ces.cwru.edu/vhdl
-- Date: June 6, 2004 (Copyright)
-- Author: Francis G. Wolff   Email: fxw12@po.cwru.edu
-- Author: Michael J. Knieser Email: mjknieser@knieser.com
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 1, or (at your option)
-- any later version: http://www.gnu.org/licenses/gpl.html
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
--
LIBRARY ieee;
USE     ieee.std_logic_1164.all;

PACKAGE endian_h IS
  --to_bigendian(x=any endian) return only big endian (HIGH DOWNTO LOW);
  --to_littleendian(x=any endian) return only little endian (LOW TO HIGH);

  FUNCTION   to_bigendian_bit_vector(   x: IN BIT_VECTOR) RETURN BIT_VECTOR;
  FUNCTION   to_littleendian_bit_vector(x: IN BIT_VECTOR) RETURN BIT_VECTOR;
  FUNCTION   to_bigendian_bit_vector(   x: IN INTEGER; n: IN INTEGER:=32) RETURN BIT_VECTOR; --n bits
  FUNCTION   to_littleendian_bit_vector(   x: IN INTEGER; n: IN INTEGER:=32) RETURN BIT_VECTOR; --n bits

  FUNCTION   to_bigendian_std_logic_vector(   x: IN BIT_VECTOR)        RETURN STD_LOGIC_VECTOR;
  FUNCTION   to_littleendian_std_logic_vector(x: IN BIT_VECTOR)        RETURN STD_LOGIC_VECTOR;
  FUNCTION   to_bigendian_std_logic_vector(   x: IN STD_LOGIC_VECTOR)  RETURN STD_LOGIC_VECTOR;
  FUNCTION   to_littleendian_std_logic_vector(x: IN STD_LOGIC_VECTOR)  RETURN STD_LOGIC_VECTOR;
  FUNCTION   to_bigendian_std_logic_vector(   x: IN INTEGER; n: IN INTEGER:=32) RETURN std_logic_vector;
  FUNCTION   to_littleendian_std_logic_vector(x: IN INTEGER; n: IN INTEGER:=32) RETURN std_logic_vector;

  --This must be a seperate case because VHDL cannot distinguish between typeless STRING and BIT_VECTOR string
  FUNCTION   to_bigendian_bit_vector_string(x: IN STRING)        RETURN BIT_VECTOR; --"0101",o"05",x"5"
  FUNCTION   to_littleendian_bit_vector_string(x: IN STRING)        RETURN BIT_VECTOR; --"0101",o"05",x"5"
  FUNCTION   to_bigendian_std_logic_vector_string(x: IN STRING)  RETURN std_logic_vector;
  FUNCTION   to_littleendian_std_logic_vector_string(x: IN STRING)  RETURN std_logic_vector;

END endian_h;

PACKAGE BODY endian_h IS

  FUNCTION to_bigendian_bit_vector(x: IN BIT_VECTOR) RETURN BIT_VECTOR IS
    VARIABLE y: BIT_VECTOR(x'HIGH DOWNTO x'LOW); --big endian: HIGH DOWNTO LOW
  BEGIN
    FOR i IN x'RANGE LOOP y(i) := x(i); END LOOP;
    RETURN y;
  END to_bigendian_bit_vector;

  FUNCTION to_littleendian_bit_vector(x: IN BIT_VECTOR) RETURN BIT_VECTOR IS
    VARIABLE y: BIT_VECTOR(x'LOW TO x'HIGH); --little endian: LOW TO HIGH
  BEGIN
    FOR i IN x'RANGE LOOP y(i) := x(i); END LOOP;
    RETURN y;
  END to_littleendian_bit_vector;

  FUNCTION to_littleendian_bit_vector(x: IN INTEGER; n: IN INTEGER:=32) RETURN BIT_VECTOR IS
    VARIABLE y: BIT_VECTOR(0 TO n-1); VARIABLE c: bit:='0'; --carry
    VARIABLE ax, j: INTEGER; 
  BEGIN
    ax:=x; IF ax<0 THEN ax:=-ax; c:='1'; END IF;
    FOR i IN y'LOW TO y'HIGH LOOP 
      j:=ax MOD 2; ax:=ax/2;
      IF x<0 THEN
        IF j=0 THEN y(i):='1'; ELSE y(i):=c; c:='0'; END IF;
      ELSE
        IF j=0 THEN y(i):='0'; ELSE y(i):='1'; END IF;
      END IF;
    END LOOP;
    ASSERT ax=0 AND c='0'
    REPORT "bit_vector_bigendian(x, n) bit length too small"
    SEVERITY WARNING;
    RETURN y;
  END to_littleendian_bit_vector;

  FUNCTION to_bigendian_bit_vector(x: IN INTEGER; n: IN INTEGER:=32) RETURN BIT_VECTOR IS
    VARIABLE v: BIT_VECTOR(0 TO n-1); VARIABLE y: BIT_VECTOR(n-1 DOWNTO 0);
  BEGIN
    v := to_littleendian_bit_vector(x, n);
    y := to_bigendian_bit_vector(v);
    RETURN y;
  END to_bigendian_bit_vector;

  FUNCTION to_bigendian_std_logic_vector(x: IN BIT_VECTOR) RETURN std_logic_vector IS
    VARIABLE y: std_logic_vector(x'HIGH DOWNTO x'LOW); --big endian: HIGH DOWNTO LOW
  BEGIN
    FOR i IN x'RANGE LOOP IF x(i)='1' THEN y(i):='1'; ELSE y(i):='0'; END IF; END LOOP;
    RETURN y;
  END to_bigendian_std_logic_vector;

  FUNCTION to_littleendian_std_logic_vector(x: IN BIT_VECTOR) RETURN std_logic_vector IS
    VARIABLE y: std_logic_vector(x'LOW TO x'HIGH); --little endian: LOW TO HIGH
  BEGIN
    FOR i IN x'RANGE LOOP IF x(i)='1' THEN y(i):='1'; ELSE y(i):='0'; END IF; END LOOP;
    RETURN y;
  END to_littleendian_std_logic_vector;

  FUNCTION to_bigendian_std_logic_vector(x: IN std_logic_vector) RETURN std_logic_vector IS
    VARIABLE y: std_logic_vector(x'HIGH DOWNTO x'LOW); --big endian: HIGH DOWNTO LOW
  BEGIN
    FOR i IN x'RANGE LOOP y(i) := x(i); END LOOP;
    RETURN y;
  END to_bigendian_std_logic_vector;

  FUNCTION to_littleendian_std_logic_vector(x: IN std_logic_vector) RETURN std_logic_vector IS
    VARIABLE y: std_logic_vector(x'LOW TO x'HIGH); --little endian: LOW TO HIGH
  BEGIN
    FOR i IN x'RANGE LOOP y(i) := x(i); END LOOP;
    RETURN y;
  END to_littleendian_std_logic_vector;

  FUNCTION to_littleendian_std_logic_vector(x: IN INTEGER; n: IN INTEGER:=32) RETURN STD_LOGIC_VECTOR IS
    VARIABLE v: BIT_VECTOR(0 TO n-1); VARIABLE y: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  BEGIN
    v := to_littleendian_bit_vector(x, n);
    y := to_littleendian_std_logic_vector(v);
    RETURN y;
  END to_littleendian_std_logic_vector;

  FUNCTION to_bigendian_std_logic_vector(x: IN INTEGER; n: IN INTEGER:=32) RETURN STD_LOGIC_VECTOR IS
    VARIABLE v: BIT_VECTOR(0 TO n-1); VARIABLE y: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  BEGIN
    v := to_littleendian_bit_vector(x, n);
    y := to_bigendian_std_logic_vector(v);
    RETURN y;
  END to_bigendian_std_logic_vector;



  FUNCTION to_bigendian_bit_vector_string(x: IN STRING) RETURN BIT_VECTOR IS
    VARIABLE y: BIT_VECTOR(x'LENGTH-1 DOWNTO 0); --big endian: HIGH DOWNTO LOW
  BEGIN
    FOR i IN x'RANGE LOOP
      IF x(i)='1' THEN y(x'LENGTH-i):='1'; ELSE y(x'LENGTH-i):='0'; END IF;
    END LOOP;
    RETURN y;
  END to_bigendian_bit_vector_string;

  FUNCTION to_littleendian_bit_vector_string(x: IN STRING) RETURN BIT_VECTOR IS
    VARIABLE y: BIT_VECTOR(0 TO x'LENGTH-1); --little endian: LOW TO HIGH
  BEGIN
    FOR i IN x'RANGE LOOP
      IF x(i)='1' THEN y(x'LENGTH-i):='1'; ELSE y(x'LENGTH-i):='0'; END IF;
    END LOOP;
    RETURN y;
  END to_littleendian_bit_vector_string;

  FUNCTION to_bigendian_std_logic_vector_string(x: IN STRING) RETURN std_logic_vector IS
    VARIABLE y: std_logic_vector(x'LENGTH-1 DOWNTO 0); VARIABLE s: std_logic;
  BEGIN
    FOR i IN x'RANGE LOOP
      CASE x(i) IS
          WHEN '1'    => s:='1'; WHEN '0'    => s:='0';
          WHEN 'X'|'x'=> s:='X';
          WHEN 'Z'|'z'=> s:='Z'; WHEN 'W'|'w'=> s:='W';
          WHEN 'H'|'h'=> s:='H'; WHEN 'L'|'l'=> s:='L';
          WHEN '-'    => s:='-'; WHEN others => s:='U';
      END CASE;
      y(x'LENGTH-i):=s;
    END LOOP;
    RETURN y;
  END to_bigendian_std_logic_vector_string;

  FUNCTION to_littleendian_std_logic_vector_string(x: IN STRING) RETURN std_logic_vector IS
    VARIABLE y: std_logic_vector(0 TO x'LENGTH-1); VARIABLE s: std_logic;
  BEGIN
    FOR i IN x'RANGE LOOP
      CASE x(i) IS
          WHEN '1'    => s:='1'; WHEN '0'    => s:='0';
          WHEN 'X'|'x'=> s:='X';
          WHEN 'Z'|'z'=> s:='Z'; WHEN 'W'|'w'=> s:='W';
          WHEN 'H'|'h'=> s:='H'; WHEN 'L'|'l'=> s:='L';
          WHEN '-'    => s:='-'; WHEN others => s:='U';
      END CASE;
      y(x'LENGTH-i):=s;
    END LOOP;
    RETURN y;
  END to_littleendian_std_logic_vector_string;

END endian_h;

