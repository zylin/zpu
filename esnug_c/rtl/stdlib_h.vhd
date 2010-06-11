-- File:    stdlib_h.vhd
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
LIBRARY C;
use     C.ctype_h.all;

package stdlib_h is
  procedure strtoul(result:  OUT   integer; --natural
                    s:       IN    string;  si:  IN integer;
                    endptr:  INOUT integer; base:IN integer);

  procedure strtoul(result:  OUT   integer; --natural
                    s:       IN    string;
                    endptr:  INOUT integer; base:IN integer);

  procedure strtol(result:   OUT   integer; --natural
                    s:       IN    string;  si:  IN integer;
                    endptr:  INOUT integer; base:IN integer);

  procedure strtol(result:   OUT   integer; --natural
                    s:       IN    string;
                    endptr:  INOUT integer; base:IN integer);

  function atoi(s: IN string) return integer;

  function atol(s: IN string) return integer;

end stdlib_h;

package body stdlib_h is
  procedure strtoul(result:  OUT   integer; --natural
                    s:       IN    string;  si:  IN integer;
                    endptr:  INOUT integer; base:IN integer) IS

    variable p: integer:=si;
    variable f: integer:=0; --actual digits flag hit
    variable d: integer;
    variable b: integer:=base;
    variable r: integer;
  begin
    r:=0;
    while p<=s'length loop
      if isspace(s(p)) then p:=p+1; else exit; end if;
    end loop;

    if b=0 then --auto detect base
      if p<=s'length then
        if s(p)='0' then
          p:=p+1;
          if p<=s'length then
            if s(p)='x' OR s(p)='X' then
              p:=p+1; b:=16;
            else
              f:=1; b:=8;
            end if;
          end if;
        else
          b:=10;
        end if;
      end if;
    elsif b=16 then
      if p<s'length then
        if s(p)='0' AND (s(p+1)='x' OR s(p+1)='X') then p:=p+2; end if;
      end if;
    end if;

    while p<=s'length loop
      if not isalnum(s(p)) then exit; end if;
      if isdigit(s(p)) then d:=character'pos(s(p))-48;
                       else d:=character'pos(toupper(s(p)))-55;
      end if;
      if d>=b then exit; end if;
      r:=(b*r)+d; f:=1; p:=p+1;
    end loop;

    if f=0 then p:=si; end if;

    if endptr/=0 then endptr:=p; end if;

    result:=r;
  end strtoul;

  procedure strtoul(result:  OUT   integer; --natural
                    s:       IN    string;
                    endptr:  INOUT integer; base:IN integer) IS
  begin
    strtoul(result, s, 1, endptr, base);
  end strtoul;

  procedure strtol(result:   OUT   integer; --natural
                    s:       IN    string;  si:  IN integer;
                    endptr:  INOUT integer; base:IN integer) IS
    variable r: integer:=0;
    variable p: integer:=si;
  begin
    while p<=s'length loop
      if isspace(s(p)) then p:=p+1; else exit; end if;
    end loop;

    if p<=s'length then
      if    s(p)='-' then
	p:=p+1; strtoul(r, s, p, endptr, base); result:= -r;

      else
        if s(p)='+' then p:=p+1; end if;
        strtoul(r, s, p, endptr, base); result:=r;
      end if;
    end if;

    if r=0 AND endptr/=0 AND endptr=p then endptr:=si; end if;
  end strtol;

  procedure strtol(result:   OUT   integer; --natural
                    s:       IN    string;
                    endptr:  INOUT integer; base:IN integer) IS
  begin
    strtol(result, s, 1, endptr, base);
  end strtol;

  function atoi(s: IN string) return integer is
    variable result, p: integer:=0;
  begin
    strtol(result, s, 1, p, 10); return result;
  end atoi;

  function atol(s: IN string) return integer is
    variable result, p: integer:=0;
  begin
    strtol(result, s, 1, p, 10); return result;
  end atol;

end stdlib_h;
