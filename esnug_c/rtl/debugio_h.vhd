-- File: debugio_h.vhd
-- Version: 3.0	 (June 6, 2004)
-- Source: http://bear.ces.cwru.edu/vhdl
-- Date:   June 6, 2004 (Copyright)
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
library STD;
use     STD.textio.all; --defines line, output

--Most primitive routines: do not use stdio_h!
package debugio_h is

  procedure printf(fmt: string; s0, s1, s2: string; i0: integer);
  procedure printf(fmt: string);
  procedure printf(fmt: string; s1: string);
  procedure printf(fmt: string; s1, s2: string);
  procedure printf(fmt: string; i1: integer);
  procedure printf(fmt: string; i1: integer; s2: string);
  procedure printf(fmt: string; i1: integer; s2, s3: string);

  function  pf(arg1: in boolean) return string;
end debugio_h;

package body debugio_h is

  procedure printf(fmt: string; s0, s1, s2: string; i0: integer) is
    variable W: line; variable i, fi, di: integer:=0;
  begin loop
      --write(W, string'("n=")); write(W, s0'length);
      --write(W, string'(" L=")); write(W, s0'left);
      --write(W, string'(" R=")); write(W, s0'right);
      --writeline(output, W);
      fi:=fi+1; if fi>fmt'length then exit; end if;
      if fmt(fi)='%' then
        fi:=fi+1; if fi>fmt'length then exit; end if;
        if fmt(fi)='s' then
          case di is
          when 0 => i:=s0'left;
                    while i<=s0'right loop
                      if s0(i)=NUL then exit; end if;
                      write(W, s0(i)); i:=i+1;
                    end loop;
          when 1 => i:=s1'left;
                    while i<=s1'right loop
                      if s1(i)=NUL then exit; end if;
                      write(W, s1(i)); i:=i+1;
                    end loop;
          when 2 => i:=s2'left;
                    while i<=s2'length loop
                      if s2(i)=NUL then exit; end if;
                      write(W, s2(i)); i:=i+1;
                    end loop;
          when others =>
          end case;
          di:=di+1;
        elsif fmt(fi)='d' then
	  case di is
          when 0 => write(W, i0); when others => end case;
          di:=di+1;
        end if;
      elsif fmt(fi)='\' then
        fi:=fi+1; if fi>fmt'length then exit; end if;
        case fmt(fi) is
          when 'n'    => writeline(output, W);
          when others => write(W, fmt(fi));
        end case;
      else write(W, fmt(fi));
      end if;
  end loop; end printf;

  procedure printf(fmt: string) is
    begin printf(fmt, "", "", "", 0); end printf;
  procedure printf(fmt: string; s1: string) is
    begin printf(fmt, s1, "", "", 0); end printf;
  procedure printf(fmt: string; s1, s2: string) is
    begin printf(fmt, s1, s2, "", 0); end printf;
  procedure printf(fmt: string; i1: integer) is
    begin printf(fmt, "", "", "", i1); end printf; 
  procedure printf(fmt: string; i1: integer; s2: string) is
    begin printf(fmt, "", s2, "", i1); end printf; 
  procedure printf(fmt: string; i1: integer; s2, s3: string) is
    begin printf(fmt, "", s2, s3, i1); end printf; 

  function pf(arg1: in boolean) return string is
  begin
    if arg1 then return "true"; else return "false"; end if;
  end pf;

end debugio_h;

