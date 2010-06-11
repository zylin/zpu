-- File:    strings_h_test.vhd
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
library STD;
use     STD.textio.all;
library C;
use     C.debugio_h.all;
use     C.strings_h.all;

--Most primative routines: do not use stdio_h!

entity strings_h_test is end;

architecture strings_h_test_arch of strings_h_test is

begin
  process
    variable s, s1, s2: string(1 to 256);
    variable n:   integer;
    variable buf: line;
  begin
    write(buf, string'("--begin test;")); writeline(output, buf);

    printf("hello, world: strings_h_test\n");

    n:=strlen("abcde"); printf("strlen('abcde'): 5==%d\n", n);
    
    n:=strlen("abcde", 4); printf("strlen('abcde'+4): 2==%d\n", n);
    
    printf("strlen('123'): 3==%d\n", strlen("123"));

    strcpy(s, ""); printf("strcpy(s, ''): []==[%s]\n", s); --test empty string

    strcpy(s, "abcdefgh"); printf("abcdefgh==%s\n", s); --test string constant

    strcpy(s, 4, "1234"); printf("abc1234==%s\n", s); --test string constant

    strcpy(s, "abcdefgh", 3); printf("cdefgh==%s\n", s);

    strcpy(s, "ab_cdefg_hi"); strcpy(s, 4, "ABCDE", 3); printf("ab_CDE==%s\n", s);

    strcpy(s, "abcd"); strcat(s, "123"); printf("strcat: abcd123==%s\n", s);

    strcpy(s, "abcd"); strcat(s, "123", 2); printf("strcat: abcd23==%s\n", s);

    strcpy(s, ""); strcat(s, "123"); printf("strcat: 123==%s\n", s);

    strcpy(s1, "hello, world"); printf("s[2..$]=%s\n", s1(2 to s1'length));

    n:=strlen(s1(4 to s1'length)); printf("strlen('lo, world'): 9==%d\n", n);

    strcpy(s, s1(4 to s1'length)); printf("s[2..$]='lo, world'==%s\n", s);

    strcpy(s, s1(8 to 9)); printf("s[2..$]='wo'==%s\n", s);

    strcpy(s, "hello, world"); strcpy(s(3 to s'length), "xyz");
    printf("s[2..$]='hexyz'==%s\n", s);

    write(buf, string'("--end test;")); writeline(output, buf);
    wait;
  end process;
end;

configuration strings_h_test_cfg of strings_h_test is
  for strings_h_test_arch
  end for;
end;

