-- File:    strings_h.vhd
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

--c/c++ string is an array of integers and are variable in length
--cannot contain a zero byte, concession to computers with fast zero compare
--also no need to save length size
--cannot protect overwriting allocated size
--mixed endian, little endian string but big endian bytes

--vhdl  string is an array of enumerated types and are fixed in length
--..this makes it difficult to embed numeric characters
--..like in C (i.e. \0x0d )

package strings_h is
  --C language addressing: strlen(s+si);
  function  strlen(s: IN    string) return integer;
  function  strlen(s: IN    string; si: IN integer) return integer;
--function  strlen(s: INOUT line)   return integer; --use instead: strlen(s.all);

  --array constant still works "s": strcpy(s, "");
  --strcpy(d, s); strcpy(d, s+si); strcpy(d+di, s); strcpy(d+di, s+si);
  procedure strcpy(d: OUT   string;                 s: IN string);
  procedure strcpy(d: OUT   string;                 s: IN string; si: IN integer);
  procedure strcpy(d: INOUT string; di: IN integer; s: IN string);
  procedure strcpy(d: INOUT string; di: IN integer; s: IN string; si: IN integer);

  --element constant still works 'c': strcpy(s, '#');
  procedure strcpy(d: OUT   string; s: IN character);

  procedure strcat(d: INOUT line;                   s: IN string); --Due to ModelSim
  procedure strcat(d: INOUT string;                 s: IN string);
  procedure strcat(d: INOUT string;                 s: IN string; si: IN integer);
  procedure strcat(d: INOUT string; di: IN integer; s: IN string);
  procedure strcat(d: INOUT string; di: IN integer; s: IN string; si: IN integer);

  procedure strcat(d: INOUT string; s: IN character);

  function  strcmp(d: IN    string; s:  IN string) return integer;

  procedure strcpyij(d:  OUT  string; s: IN string; i, j: IN integer);

end strings_h;

package body strings_h is

  --Added Because ModelSim write(buf, s); will copy beyond NUL until s'length
  procedure strcat(d: INOUT line; s: IN string) is
    variable sj: integer:=s'left;
  begin 
    if s'length>0 then
      loop
        if s(sj)=NUL then exit; end if;
        write(d, s(sj));

        if ( s'left > s'right ) then
          if sj<=s'right then exit; end if;
          sj:=sj-1;
        else
          if sj>=s'right then exit; end if;
          sj:=sj+1;
        end if;
      end loop;
    end if;
  end strcat;

  procedure strcpy(d: OUT string; s: IN string) is
    variable dj: integer:=d'left;
    variable sj: integer:=s'left;
    --variable W : line;
  begin 
    --write(W,string'("strcpy: "));
    --write(W,string'(" s=")); write(W,s);
    --write(W,string'(" s'left=")); write(W,s'left);
    --write(W,string'(" s'right=")); write(W,s'right);
    --write(W,string'(" s'length=")); write(W,s'length);
    --write(W,string'(" d'left=")); write(W,d'left);
    --write(W,string'(" d'right=")); write(W,d'right);
    --write(W,string'(" d'length=")); write(W,d'length);
    --writeline(output, W);

    if s'length<=0 then
      if d'length>=1 then d(d'left):=NUL; end if;
    else
      loop
        --write(W,string'(" s(")); write(W,sj);
        --write(W,string'(")=")); write(W,s(sj));
        --write(W,string'(" dj=")); write(W,dj);
        --writeline(output,W);

        if s(sj)=NUL then d(dj):=NUL; exit; end if;
        d(dj):=s(sj);
        if ( d'left > d'right ) then
          if dj<=d'right then exit; end if;
          dj:=dj-1;
        else
          if dj>=d'right then exit; end if;
          dj:=dj+1;
        end if;
        if ( s'left > s'right ) then
          if sj<=s'right then d(dj):=NUL; exit; end if;
          sj:=sj-1;
        else
          if sj>=s'right then d(dj):=NUL; exit; end if;
          sj:=sj+1;
        end if;
      end loop;
    end if;
  end strcpy;

  procedure strcpy(d: OUT string; s: IN string; si: IN integer) is
    variable dj: integer:=d'left;
    variable sj: integer:=si; --Synopsys does not support BUFFER (pass by value)
  begin
    loop
      if dj>d'right  then d(d'right):=NUL; exit; end if;
      if sj>s'right  then d(dj):=NUL; exit; end if;
      if s(sj)=NUL   then d(dj):=NUL; exit; end if;
      d(dj):=s(sj); dj:=dj+1; sj:=sj+1;
    end loop;
  end strcpy; -- procedure; johan


  procedure strcpy(d: INOUT string; di: IN integer; s: IN string) is
  begin strcpy(d, di, s, 1); end strcpy; -- procedure; johan

  --Make it easy to translate back to C: strcpy(d+di, s+si)
  procedure strcpy(d: INOUT string; di: IN integer; s: IN string; si: IN integer) is
    variable dj: integer:=di; --Synopsys does not support BUFFER
    variable sj: integer:=si; --Synopsys does not support BUFFER (pass by value)
  begin
    loop
      if dj>d'right   then d(d'right):=NUL; exit; end if;
      if sj>s'right   then d(dj):=NUL; exit; end if;
      if s(sj)=NUL    then d(dj):=NUL; exit; end if;
      d(dj):=s(sj); dj:=dj+1; sj:=sj+1;
    end loop;
  end strcpy; -- procedure; johan


  procedure strcat(d: INOUT string; di: IN integer; s: IN string; si: IN integer) is
    variable dj: integer:=di;
    variable sj: integer:=si;
  begin
    --strcpy(d, strlen(d)+1, s, si);
    loop
      if dj>d'right  then d(d'right):=NUL; exit; end if;
      if d(dj)=NUL   then exit; end if;
      dj:=dj+1;
    end loop;

    loop
      if dj>d'right  then d(d'right):=NUL; exit; end if;
      if sj>s'right  then d(dj):=NUL; exit; end if;
      if s(sj)=NUL   then d(dj):=NUL; exit; end if;
      d(dj):=s(sj); dj:=dj+1; sj:=sj+1;
    end loop;
  end strcat; -- procedure; johan

  procedure strcat(d: INOUT string; di: IN integer; s: IN string) is
  begin     strcat(d, di, s, 1); end strcat;

  procedure strcat(d: INOUT string; s: IN string; si: IN integer) is
  begin     strcat(d, 1, s, si); end strcat;

  procedure strcat(d: INOUT string; s: IN string) is
  begin     strcat(d, 1, s, 1); end strcat;


  function strcmp(d: IN string; s: IN string) return integer is
    variable i: integer:=1; variable dc, sc: character;
  begin
    loop
      if i<=d'right  then dc:=d(i); else dc:=NUL; end if;
      if i<=s'right  then sc:=s(i); else sc:=NUL; end if;


      if dc/=sc or dc=NUL then
        return character'pos(dc) - character'pos(sc);
      else
        i:=i+1;
      end if;
    end loop;
  end strcmp;

  function strlen(s: IN string) return integer is
    variable n: integer:=0; variable sj: integer:=s'left;
  begin
    loop
      if    sj>s'right then exit;
      elsif s(sj)=NUL  then exit; --sequential if protects sj > length
      else                  sj:=sj+1; n:=n+1;
      end if;
    end loop;
    return n;
  end strlen;

  function strlen(s: IN string; si: IN integer) return integer is
    variable n: integer:=0; variable sj: integer:=si;
  begin
    loop
      if    sj>s'right  then exit;
      elsif s(sj)=NUL   then exit; --sequential if protects sj > length
      else              sj:=sj+1; n:=n+1;
      end if;
    end loop;
    return n;
  end strlen;

  procedure strcpy( d:  OUT   string; s: IN character) is
    variable cs: string(1 to 2);
  begin
    cs(1):=s; cs(2):=NUL; strcpy(d, cs);
  end strcpy; -- johan

  procedure strcat( d:  INOUT string; s: IN character) is
    variable cs: string(1 to 2);
  begin
    cs(1):=s; cs(2):=NUL; strcat(d, cs);
  end strcat; -- strcat

  -- d(1 to j-i+1):=s(i to j) 
  -- strcpy(d, s(i to j));
  procedure strcpyij(d: OUT string; s: IN string; i, j: IN integer) is
    variable di: integer:=1;
    variable si: integer:=i;
  begin
    loop
      if di>d'right  then d(d'right):=NUL; exit; end if;
      if si>s'right  then d(di):=NUL; exit; end if;
      if s(si)=NUL   then d(di):=NUL; exit; end if;
      if si>j        then d(di):=NUL; exit; end if; --added on to strcpy
      d(di):=s(si); di:=di+1; si:=si+1;
    end loop;
  end strcpyij; -- procedure; johan

end strings_h; -- johan
