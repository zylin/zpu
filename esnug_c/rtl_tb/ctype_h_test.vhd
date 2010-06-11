-- File: ctype_h_test.vhd
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
use     C.ctype_h.all;

--Most primitive routines: do not use stdio_h!

entity ctype_h_test is end;

architecture ctype_h_test_arch of ctype_h_test is
begin
  process
    variable i:   integer;
    variable c:   character;
    variable buf: line;
  begin
    write(buf, string'("--begin test;")); writeline(output, buf);

    for i in 0 to 255 loop
      c:=character'val(i); 
      if isascii(c)  then write(buf, string'(" asc"));
                     else write(buf, string'("    ")); end if;
      if ispunct(c)  then write(buf, string'(" punct"));
                     else write(buf, string'("      ")); end if;
      if isalnum(c)  then write(buf, string'(" alnum"));
                     else write(buf, string'("      ")); end if;
      if isalpha(c)  then write(buf, string'(" Az"));
                     else write(buf, string'("   ")); end if;
      if isupper(c)  then write(buf, string'(" Up"));
                     else write(buf, string'("   ")); end if;
      if islower(c)  then write(buf, string'(" Low"));
                     else write(buf, string'("    ")); end if;
      if isdigit(c)  then write(buf, string'(" Num"));
                     else write(buf, string'("    ")); end if;
      if isxdigit(c) then write(buf, string'(" Hex"));
                     else write(buf, string'("    ")); end if;
      if isspace(c)  then write(buf, string'(" space"));
                     else write(buf, string'("      ")); end if;
      if iscntrl(c)  then write(buf, string'(" ctl"));
                     else write(buf, string'("    ")); end if;
      write(buf, string'(" i=")); write(buf, i);
      writeline(output, buf);
    end loop;

    write(buf, string'("--end test;")); writeline(output, buf);
    wait;
  end process;
end;

configuration ctype_h_test_cfg of ctype_h_test is
  for ctype_h_test_arch
  end for;
end;
