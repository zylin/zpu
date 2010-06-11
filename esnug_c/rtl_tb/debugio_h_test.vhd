-- File:    debugio_h_test.vhd
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

--.synopsys_vss.setup: PROMPT_STD_INPUT    = TRUE

library STD;
use     STD.textio.all;
library C;
use     C.debugio_h.all;
use     C.ctype_h.all;

--Most primitive routines: do not use stdio_h!

entity debugio_h_test is end;

architecture debugio_h_test_arch of debugio_h_test is

begin
  process
    variable s, s1, s2: string(1 to 256);
    variable i:    integer;
    variable c:    character;
    variable buf:  line;
    FILE     fin:  text OPEN READ_MODE  IS "debugio_h_test.vhd";
    FILE     fout: text OPEN WRITE_MODE IS "pipe1xx";

  begin
    write(buf, string'("--begin test;")); writeline(output, buf);

    printf("hello, world\n");
    printf("abc=%s \n", "abc");
    printf("5==(%d)\n", 5);
    i:=-25; printf("-25==[%d]\n", i);
    printf("123==%s 456==%s\n", "123", "456");

    i:=5; write(buf, string'("i=")); write(buf, i);
    writeline(fout, buf);

    i:=7; write(buf, string'("i=")); write(buf, i);
    writeline(fout, buf);

    write(buf, string'("--end test;")); writeline(output, buf);
    wait;
  end process;
end;

configuration debugio_h_test_cfg of debugio_h_test is
  for debugio_h_test_arch
  end for;
end;

