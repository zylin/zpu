-- File: regexp_h.vhd
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
LIBRARY STD;
use     STD.textio.all;
LIBRARY C;
use     C.strings_h.all; --uses strcpy

package regexp_h is
  --AVOID: since shared variables will cause problems with multiple processes

  --INPUT  si = initial index into the string
  --INPUT   s = scan string terminated by NUL or length
  --INPUT   f = pattern matching format string (i.e. perl style, less typing than sed)

  --OUTPUT ai = 0 none, alternate match number = 1|2|3|4|...
  --OUTPUT si = next unmatch character
  --OUTPUT m1 = matched (string) =\1
  --OUTPUT m2 = matched (string) =\2

  --NOTES: . = match any character except NUL
  --           (differs from perl which is newline
  --            since pattern matching is limited to a line)
  -- ^$      = match an empty string (i.e. length=0 or first character=NUL)

  procedure regmatch(ai: OUT integer;
                     si: INOUT integer; s: IN string; f: IN string);

  procedure regmatch(ai: OUT integer;
                     si: INOUT integer; s: IN string;
                      f: IN    string;  m1: OUT string);

  procedure regmatch(ai: OUT integer;
                     si: INOUT integer; s: IN string;
                      f:  IN   string;  m1,m2: OUT string);

  procedure regmatch(ai: OUT integer;
                     si: INOUT integer; s: IN string;
                      f: IN    string;  m1,m2,m3: OUT string);

  procedure regmatch(ai: OUT integer;
                     si: INOUT integer; s: IN string;
                      f: IN string;     m1,m2,m3,m4: OUT string);

  function sedscanf(s: IN string) return string;

end;

package body regexp_h is
-- For instance, `[^]0-9-]' means the set `everything except close
--     bracket, zero through nine, and hyphen'. 

  function mfalse(m: integer) return integer is
  begin
    if m=1 then return 0; elsif m=0 then return -2; else return m; end if;
  end;

  procedure regmatch(ai: OUT  integer;
                     si: INOUT integer; s: IN string;
                     f:  IN    string;  m1,m2,m3,m4: OUT string) is

    variable debug:     boolean:=false; --TRUE;

    type     tarray     is array(integer range <>) of bit;
    variable t:         tarray(0 to 256);
    variable tset:      bit;

    type     iarray     is array(integer range <>) of integer;
    variable fstack:    iarray(1 to 15); --stack of format pointer
    variable mstack:    iarray(1 to 15); --stack of match flags
    variable mistack:   iarray(1 to 15); --stack of mi match left parenthesis
    variable sstack:    iarray(1 to 15); --stack of string pointers
    variable sp:        integer;

    variable aii:       integer:=0;
    variable si_in:     integer;
    variable simax:     integer:=1; --debugging information
    variable fi:        integer;
    variable m:         integer; --=0 false, 1=true, -1=skip true, -2=skip false
    variable mi:        integer:=0;
    variable ms:        string(1 to 80);
    variable fb,mc,j:   integer;
    variable mr,mm,mn:  integer;
    variable mlast:     integer;
    variable b, c:      character;
    variable bi, ci:    integer;
    variable W:         line;
  begin
    if debug then
      write(W, string'("------------------------------------------"));
      write(W, string'("  string=")); write(W, s);
      write(W, string'("  si=")); write(W, si);
      write(W, string'("  string'length=")); write(W, s'length);
      write(W, string'("  format=")); write(W, f);
      writeline(output, W);
    end if;

    si_in:=si; --si:=1;
    fi:=0; sp:=1; m:=1; 
    sstack(1):=si; fstack(1):=1;  mstack(1):=1; mistack(1):=0;
    sstack(2):=si; fstack(2):=1;  mstack(2):=1; mistack(2):=0;
    loop
      fi:=fi+1; if fi>f'length then exit; end if;
      mc:=0; mr:=0; tset:='1'; t:=(others=>'0');

      if debug then
      write(W, string'(" loop:ai=")); write(W, aii);
      write(W, string'(" m="));  write(W, m);
      write(W, string'(" f(")); write(W, fi); write(W, string'(")="));
      write(W, f(fi));
      writeline(output, W);
      write(W, string'(" s(")); write(W, si); write(W, string'(")="));
      if si<=s'length then write(W, s(si)); else write(W, string'("UUU")); end if;
      write(W, string'(" mstack(")); write(W, sp); write(W, string'(")=")); write(W, mstack(sp));
      write(W, string'(" sstack(")); write(W, sp); write(W, string'(")=")); write(W, sstack(sp));
      writeline(output, W);
      end if;

      case f(fi) is
      when '^' => --Match beginning of line
        if si/=si_in then m:=mfalse(m); end if;

      when '$' => --Match end of line
        if    si<=s'length then if s(si)/=NUL then m:=mfalse(m); end if;
        elsif si/=(s'length+1) then  m:=mfalse(m); end if;

      when '*' => --Match last expression 0 or more times
        if    m=1 then fi:=fstack(sp+1)-1;
        elsif m=0 then
          m:=mstack(sp+1); si:=sstack(sp+1);
          if si>simax then simax:=si; end if;
        end if;

      when '?' => --Match last expression 0 or 1 times
        if    m= 0 then
          m:=mstack(sp+1); si:=sstack(sp+1); --ab?c\(def?g?h\)?
          if si>simax then simax:=si; end if;
--      elsif m=-1 then m:=-1;                             --looking for right parenthesis
--      elsif m=-2 then m:=-2;                             --looking for alternate-bar or right
        end if;

      --[character pattern]
      --Examples: [abc], []], [^abc], [0-9-], [^]], [^]abc], [^^]
      when '[' =>
        mc:=1; if m=1 then fstack(sp+1):=fi; end if; --needed for 0 or more operator
        fb:=fi;
        loop
          fi:=fi+1; if fi>f'length then exit; end if;

          if debug then
          write(W, string'(" [char pattern]:f(")); write(W, fi);
          write(W, string'(")="));  write(W, f(fi));
          writeline(output, W);
          end if;

          b:=c; c:=f(fi);

          --To include a close bracket in the set,
          --make it the first character after the open bracket
          --or the circumflex; any other position will end the set.
          --Examples: []] or the NOT cases: [^]] or [^]abc] or [^^]

          if c='\' then
            fi:=fi+1; if fi>f'length then exit; end if;

            case f(fi) is
              when 'a'    => t(character'pos(BEL)):=tset;
              when 'b'    => t(character'pos(BS)):=tset;
              when 'f'    => t(character'pos(FF)):=tset;
              when 'n'    => t(character'pos(LF)):=tset;
              when 'r'    => t(character'pos(CR)):=tset;
              when 't'    => t(character'pos(HT)):=tset;
              when 'v'    => t(character'pos(VT)):=tset;
              when '\'    => t(character'pos('\')):=tset;
              when others => t(character'pos(f(fi))):=tset;
            end case;

          elsif c='^' then
            if fb+1=fi then tset:='0'; t:=(others=>'1'); 
                      else t(character'pos(c)):=tset; end if;

          elsif c=']' then
            if (fb+1=fi and tset='1') or (fb+2=fi and tset='0') then
              t(character'pos(c)):=tset;
            else
              exit;
            end if;

          elsif c='-' then
            fi:=fi+1; if fi>f'length then exit; end if; --lookahead

            -- To include a hyphen, make it the last character
            -- before the final close bracket: [9-] or [---] or [-9].
            if f(fi)=']' then
              t(character'pos(c)):=tset; fi:=fi-1;
            else
              bi:=character'pos(b); ci:=character'pos(f(fi));
              for ti in bi to ci loop t(ti):=tset; end loop;
            end if;
          else
            t(character'pos(c)):=tset;
          end if; 
        end loop;

      when NUL    => aii:=aii+1; exit;

      when '(' => sp:=sp+1;
                  sstack(sp):=si; fstack(sp):=fi-1; mstack(sp):=m;
                  mi:=mi+1; mistack(sp):=mi;

      when ')' => 
                  if m=1 then
                    strcpyij(ms, s, sstack(sp), si-1);
                    case mistack(sp) is
                      when 1 => strcpy(m1, ms);
                      when 2 => strcpy(m2, ms);
                      when 3 => strcpy(m3, ms);
                      when 4 => strcpy(m4, ms);
                      when others =>
                    end case;
                  end if;

                  if debug then
                    write(W, string'(" (Right):store: m=")); write(W, m);
                    write(W, string'(" ms=")); write(W, ms);
                    write(W, string'(" mistack(sp)=")); write(W, mistack(sp));
                    write(W, string'(" sstack(")); write(W, sp);
                    write(W, string'(")=")); write(W, sstack(sp));
                    write(W, string'(" si=")); write(W, si);
                    writeline(output, W);
                  end if;

                  sp:=sp-1;
                  if    m=-1        then m:=1; --implies an alternate-bar was encountered
                  elsif m=0 or m=-2 then
                    m:=0; si:=sstack(sp);
                    if si>simax then simax:=si; end if;
                  end if;
                    
      when '{' =>
      when '}' =>
      when '|' => if m=1 then
                    strcpyij(ms, s, sstack(sp), si-1);
                    case mistack(sp) is
                      when 1 => strcpy(m1, ms);
                      when 2 => strcpy(m2, ms);
                      when 3 => strcpy(m3, ms);
                      when 4 => strcpy(m4, ms);
                      when others =>
                    end case;
                  end if;

                  if debug then
                    write(W, string'(" Bar|:store: m=")); write(W, m);
                    write(W, string'(" ms=")); write(W, ms);
                    write(W, string'(" mistack(sp)=")); write(W, mistack(sp));
                    write(W, string'(" sstack(")); write(W, sp); 
                    write(W, string'(")=")); write(W, sstack(sp));
                    write(W, string'(" si=")); write(W, si);
                    writeline(output, W);
                  end if;

                  if sp=1 then
                    mi:=0; aii:=aii+1; if m=1 then exit; end if; --break out early
                  end if;

                  if    m=1         then m:=-1; --looking for next grouping parenthesis
                  elsif m=0 or m=-2 then
                    m:=mstack(sp); si:=sstack(sp);
                    if si>simax then simax:=si; end if;
                  end if;

      when '\'    =>
        fi:=fi+1; if fi>f'length then exit; end if;

        if debug then
          write(W, string'("    f("));  write(W, fi);
          write(W, string'(")=")); write(W, f(fi));
          writeline(output, W);
        end if;

        case f(fi) is
        when others =>
          t(character'pos(f(fi))):='1';
          mc:=1; if m=1 then fstack(sp+1):=fi; end if;
        end case;

      when '.' => --match any character except NUL
        t:=(others=>'1'); --t(character'pos(LF)):='0'; --differ from sed
        mc:=1; if m=1 then fstack(sp+1):=fi; end if;

      when others =>
        t(character'pos(f(fi))):='1';
        mc:=1; if m=1 then fstack(sp+1):=fi; end if;

      end case;

      if mc=1 then
        if    m=0 then m:=-2; --skip characters
        elsif m=1 then
          sstack(sp+1):=si; mstack(sp+1):=m;

          t(character'pos(NUL)):='0';
          if si<=s'length then
            if debug then
              write(W, string'("match: s(")); write(W, si);
              write(W, string'(")="));        write(W, s(si));
              write(W, string'(" with t(s(si))=")); write(W, t(character'pos(s(si))));
              writeline(output, W);
            end if;

            if t(character'pos(s(si)))='1' then si:=si+1; else m:=0; end if;
            if si>simax then simax:=si; end if;
          else
            m:=0;
          end if;
        end if;
      end if;
    end loop;

    --next unmatched character: si
    if m=1 or m=-1 then ai:=aii; else ai:=0; si:=si_in; end if;
--
--    si:=-simatch; --last good character before it went bad
--    if si>simax then simatch:=-si; else simatch:=-simax; end if;
--
  end;

  procedure regmatch(ai: OUT integer; si: INOUT integer; s: IN string; f: IN string) is
    variable m1,m2,m3,m4: string(1 to 80);
  begin
    regmatch(ai, si, s, f, m1, m2, m3, m4);
  end;

  procedure regmatch(ai: OUT integer;
                     si:      INOUT integer; s: IN string; f: IN string; m1: OUT string) is
    variable m2,m3,m4: string(1 to 80);
  begin
    regmatch(ai, si, s, f, m1, m2, m3, m4);
  end;

  procedure regmatch(ai: OUT integer;
                     si:      INOUT integer; s: IN string; f: IN string; m1,m2: OUT string) is
    variable m3,m4: string(1 to 80);
  begin
    regmatch(ai, si, s, f, m1, m2, m3, m4);
  end;

  procedure regmatch(ai: OUT integer;
                     si:      INOUT integer; s: IN string; f: IN string; m1,m2,m3: OUT string) is
    variable m4: string(1 to 80);
  begin
    regmatch(ai, si, s, f, m1, m2, m3, m4);
  end;

  --conversion of scanf to sed
  function sedscanf(s: IN string) return string is
    variable i: integer:=0;
    variable white: string(1 to 8):= "[ \t\n]*"; --zero or more white space
    variable r: string(1 to 256);
  begin
    strcpy(r, NUL);
    loop
      i:=i+1;
      if i>s'length then exit; end if;
      if s(i)=NUL   then exit; end if;

      if s(i)='%' then
        i:=i+1;
        if i>s'length then exit; end if;
        if s(i)=NUL   then exit; end if;

        case s(i) is
        when 'x' => 
          strcat(r, white); strcat(r, "\(0[xX][0-9A-Fa-f][0-9A-Fa-f]*\|[0-9A-Fa-f][0-9A-Fa-f]*\)");
        when 'o' =>
          strcat(r, white); strcat(r, "\(0[0-7][0-7]*\)");
        when 'd' =>
          strcat(r, white); strcat(r, "\([0-9][0-9]*\)");
        when 's' =>
          strcat(r, white); strcat(r, "\([^ \t\n]*\)");
        when '%' =>
          strcat(r, "%");
        when others =>
        end case;

      elsif s(i)=' ' then strcat(r, white);
      else
        strcat(r, s(i));
      end if;
    end loop;    
    return r;
  end;
end;
