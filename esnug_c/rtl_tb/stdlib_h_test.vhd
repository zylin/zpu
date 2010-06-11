-- File:    stdlib_h_test.vhd
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
use     C.stdlib_h.all;

--Most primitive routines: do not use stdio_h!

entity stdlib_h_test is end;

architecture stdlib_h_test_arch of stdlib_h_test is
begin
  process
    variable s:    string(1 to 256);
    variable buf:  line;
    variable i, p: integer;
  begin
    write(buf, string'("--begin test;")); writeline(output, buf);

    write(buf, string'("hello, world: stdlib_h_test"));
    writeline(output, buf);

    p:=1; strtoul(i, "123", 1, p, 10);
    write(buf, string'("strtoul base=10 123=")); write(buf, i);
    write(buf, string'(" endptr= 4=")); write(buf, p);
    writeline(output, buf);

    p:=1; strtoul(i, "123", 1, p, 8);
    write(buf, string'("strtoul base=8   64=")); write(buf, i);
    write(buf, string'(" endptr= 4=")); write(buf, p);
    writeline(output, buf);

    p:=1; strtoul(i, "123", 1, p, 16);
    write(buf, string'("strtoul base=16 291=")); write(buf, i);
    write(buf, string'(" endptr= 4=")); write(buf, p);
    writeline(output, buf);

    p:=1; strtoul(i, "123g01", 1, p, 16);
    write(buf, string'("strtoul base=16 291=")); write(buf, i);
    write(buf, string'(" endptr= 4=")); write(buf, p);
    writeline(output, buf);

    p:=1; strtoul(i, "123g01", 1, p, 0);
    write(buf, string'("strtoul base=0  123=")); write(buf, i);
    write(buf, string'(" endptr= 4=")); write(buf, p);
    writeline(output, buf);

    p:=1; strtoul(i, "0123g01", 1, p, 0);
    write(buf, string'("strtoul base=0   83=")); write(buf, i);
    write(buf, string'(" endptr= 5=")); write(buf, p);
    writeline(output, buf);

    p:=1; strtoul(i, "0x123g01", 1, p, 0);
    write(buf, string'("strtoul base=0  291=")); write(buf, i);
    write(buf, string'(" endptr= 6=")); write(buf, p);
    writeline(output, buf);

    p:=1; strtoul(i, "0x123g01", p, 0);
    write(buf, string'("strtoul base=0  291=")); write(buf, i);
    write(buf, string'(" endptr= 6=")); write(buf, p);
    writeline(output, buf);

    i:=atoi("0123g01");
    write(buf, string'("atoi    base=10 123=")); write(buf, i);
    writeline(output, buf);

    i:=atoi("-0123g01");
    write(buf, string'("atoi    base=10 -123=")); write(buf, i);
    writeline(output, buf);

    i:=atoi("+0123g01");
    write(buf, string'("atoi    base=10 +123=")); write(buf, i);
    writeline(output, buf);

    write(buf, string'("--end test;")); writeline(output, buf);
    wait;
  end process;
end;

configuration stdlib_h_test_cfg of stdlib_h_test is
  for stdlib_h_test_arch
  end for;
end;

