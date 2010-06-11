-- File:    endian_h_test.vhd
-- Version: 3.0 (June 6, 2004)
-- Source:  http://bear.ces.cwru.edu/vhdl
-- Date:    June 6, 2004 (Copyright)
-- Author:  Francis G. Wolff   Email: fxw12@po.cwru.edu
-- Author:  Michael J. Knieser Email: mjknieser@knieser.com
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
LIBRARY STD;
USE     STD.textio.all;            --write(buf, bit_vector);
LIBRARY ieee;
USE     ieee.std_logic_1164.all;   --define std_logic_vector;
USE     ieee.std_logic_textio.ALL; --write(buf, std_logic_vector);
LIBRARY C;
USE     C.endian_h.all;

ENTITY endian_h_test IS END;

ARCHITECTURE endian_h_test_arch OF endian_h_test IS

BEGIN
  PROCESS
    VARIABLE b07: BIT_VECTOR(0 TO 7)          :="00111111";
    VARIABLE b70: BIT_VECTOR(7 DOWNTO 0)      :="11000000";
    VARIABLE v07: STD_LOGIC_VECTOR(0 TO 7)    :="0LWXUZH1";
    VARIABLE v70: STD_LOGIC_VECTOR(7 DOWNTO 0):="1UX-HWZ0";
    VARIABLE buf:   LINE;
  BEGIN
    write(buf, string'("--begin test;")); writeline(output, buf);

    write(buf, string'("VARIABLE b07: BIT_VECTOR(0 TO 7):=00111111;")); writeline(output, buf);
    write(buf, string'("write(buf, b07)=")); write(buf, b07);
    write(buf, string'("==00111111")); writeline(output, buf);
    write(buf, string'("to_littleendian_bit_vector(b07)="));
    write(buf, to_littleendian_bit_vector(b07));
    write(buf, string'("==00111111")); writeline(output, buf);
    write(buf, string'("to_bigendian_bit_vector(b07)="));
    write(buf, to_bigendian_bit_vector(b07));
    write(buf, string'("==11111100")); writeline(output, buf); writeline(output, buf);

    write(buf, string'("VARIABLE b70: BIT_VECTOR(7 DOWNTO 0):=11000000;")); writeline(output, buf);
    write(buf, string'("write(but, b70)=")); write(buf, b70);
    write(buf, string'("==11000000")); writeline(output, buf);
    write(buf, string'("to_littleendian_bit_vector(b70)="));
    write(buf, to_littleendian_bit_vector(b70));
    write(buf, string'("==00000011")); writeline(output, buf);
    write(buf, string'("to_bigendian_bit_vector(b70)="));
    write(buf, to_bigendian_bit_vector(b70));
    write(buf, string'("==11000000")); writeline(output, buf); writeline(output, buf);

    write(buf, string'("VARIABLE v07: STD_LOGIC_VECTOR(0 TO 7):=0LWXUZH1;")); writeline(output, buf);
    write(buf, string'("write(buf, v07)=")); write(buf, v07);
    write(buf, string'("==0LWXUZH1")); writeline(output, buf);
    write(buf, string'("to_littleendian_std_logic_vector(v07)="));
    write(buf, to_littleendian_std_logic_vector(v07));
    write(buf, string'("==0LWXUZH1")); writeline(output, buf);
    write(buf, string'("to_bigendian_std_logic_vector(v07)="));
    write(buf, to_bigendian_std_logic_vector(v07));
    write(buf, string'("==1HZUXWL0")); writeline(output, buf); writeline(output, buf);

    write(buf, string'("VARIABLE v70: STD_LOGIC_VECTOR(7 DOWNTO 0):=1UX-HWZ0;")); writeline(output, buf);
    write(buf, string'("write(but, v70)=")); write(buf, v70);
    write(buf, string'("==1UX-HWZ0")); writeline(output, buf);
    write(buf, string'("to_littleendian_std_logic_vector(v70)="));
    write(buf, to_littleendian_std_logic_vector(v70));
    write(buf, string'("==0ZWH-XU1")); writeline(output, buf);
    write(buf, string'("to_bigendian_std_logic_vector(v70)="));
    write(buf, to_bigendian_std_logic_vector(v70));
    write(buf, string'("==1UX-HWZ0")); writeline(output, buf); writeline(output, buf);

    write(buf, string'("to_bigendian_std_logic_vector(1945,16)="));
    hwrite(buf, to_bigendian_std_logic_vector(1945,16));
    write(buf, string'(" == 0799")); writeline(output, buf); 
    write(buf, string'("to_littleendian_std_logic_vector(1945,16)="));
    hwrite(buf, to_littleendian_std_logic_vector(1945,16));
    write(buf, string'(" == 99E0")); writeline(output, buf); writeline(output, buf);

    write(buf, string'("to_bigendian_bit_vector_string(x'F0E8')="));
    write(buf, to_bigendian_bit_vector_string(x"F0E8"));
    write(buf, string'(" == 1111000011101000")); writeline(output, buf); 
    write(buf, string'("to_littleendian_bit_vector_string(x'F0E8')="));
    write(buf, to_littleendian_bit_vector_string(x"F0E8"));
    write(buf, string'(" == 0001011100001111")); writeline(output, buf); writeline(output, buf);

    write(buf, string'("to_bigendian_std_logic_vector_string(11110000)="));
    write(buf, to_bigendian_std_logic_vector_string("11110000"));
    write(buf, string'(" == 11110000")); writeline(output, buf); 
    write(buf, string'("to_littleendian_std_logic_vector_string(11110000)="));
    write(buf, to_littleendian_std_logic_vector_string("11110000"));
    write(buf, string'(" == 00001111")); writeline(output, buf); writeline(output, buf);

    write(buf, string'("to_bigendian_std_logic_vector_string(x'F0E8')="));
    hwrite(buf, to_bigendian_std_logic_vector_string(x"F0E8"));
    write(buf, string'(" == F0E8")); writeline(output, buf); 
    write(buf, string'("to_littleendian_std_logic_vector_string(x'F0E8')="));
    hwrite(buf, to_littleendian_std_logic_vector_string(x"F0E8"));
    write(buf, string'(" == 170F")); writeline(output, buf); writeline(output, buf);

    write(buf, string'("--end test;")); writeline(output, buf);
    wait;
  END PROCESS;
END;

CONFIGURATION endian_h_test_cfg OF endian_h_test IS
  FOR endian_h_test_arch
  END FOR;
END;

