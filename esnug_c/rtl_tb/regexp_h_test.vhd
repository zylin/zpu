-- File:    regexp_h_test.vhd
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
Library STD;
use     STD.textio.all; --defines line & output
Library IEEE;
use IEEE.std_logic_1164.all; --defines std_logic_vector
Library C;
use     C.strings_h.all; --defines strcpy(), strlen(), strcat()
use     C.stdlib_h.all;  --define atoi()
use     C.regexp_h.all;

-- WARNING! WARNING!
-- Since printf/scanf uses regexp_h
-- This test bench must not use stdio_h!
-- Simulation model only. Do not synthesize!

entity regexp_h_test is end regexp_h_test;

architecture regexp_h_test_arch of regexp_h_test is

  type     pf_bit_vector_type is    array(bit) of character;
  constant pf_bit_vector:           pf_bit_vector_type:= ('0', '1');

  type     pf_std_logic_vector_type is array(std_ulogic) of character;
  constant pf_std_logic_vector:        pf_std_logic_vector_type
             := ('U', 'X', '0', '1', 'Z', 'W', 'L', 'H', '-');

  type     pf_hex_type is array(0 to 15) of character;
  constant pf_hex: pf_hex_type
        := ('0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f');

  procedure xprintf(fmt: IN string; s1: IN string) is
    variable debug:               boolean:=false; --true;
    variable buf:                 line;
    variable t1:                  string(1 to s1'length):=s1;
    variable c, d:                character;
    variable n, m, p:             integer;
    variable ai, i, j, ax, ap:    integer;
    variable fi, fj:              integer:=1;
    variable lflag, aflag, zflag: boolean;
    variable nflag, pflag, sflag: boolean;
    variable m1, m2, m3, m4:      string(1 to 64);
    variable t:                   string(1 to 128);
  begin
    fi:=1;
    loop
	fj:=fi;
	regmatch(ai, fi, fmt,
	"^$|([^%\\][^%\\]*)|\\n|\\0(\\[0-7][0-7]?[0-7]?)|%([^scdioxXufeEgGpn%\\]*)(.)|\\(.)", m1, m2);

	if debug then
          writeline(output, buf);
          write(buf, string'(" ai="));  write(buf, ai);
          write(buf, string'(" fi="));  write(buf, fi);
          write(buf, string'(" strlen(fmt)=")); write(buf, strlen(fmt));
          writeline(output, buf);
          write(buf, string'(" strlen(m1)=")); write(buf, strlen(m1));
          write(buf, string'(" m1=")); write(buf, m1, LEFT, strlen(m1));
          writeline(output, buf);
          write(buf, string'(" strlen(m2)=")); write(buf, strlen(m2));
          write(buf, string'(" m2=")); write(buf, m2);
          writeline(output, buf);
          write(buf, string'("---------------------------------------------------"));
          writeline(output, buf);
	end if;

	case ai is
	when 1 => exit;
	when 2 => write(buf, m1(1 to strlen(m1))); --20030507 ModelSim Fix
	when 3 => writeline(output, buf);
	when 4 =>
            case m1(1) is
		when 'a'    => c:=BEL;
		when 'b'    => c:=BS;
		when 'f'    => c:=FF;
		when 'n'    => c:=LF; --will never happen
		when 'r'    => c:=CR;
		when 't'    => c:=HT;
		when 'v'    => c:=VT;
		when others => c:=m1(1);
            end case;
	when 5 =>
            c:=m2(1);
            m1(1):=NUL; m2(1):=NUL; m3(1):=NUL; m4(1):=NUL;
            regmatch(ai, fj, fmt,
                     "%([ 0#+-]*)([0-9]*)\.?([0-9]*).", m1, m2, m3, m4);

            --<m1:flags><m2:min print width>.<m3:precision:max strlen><modifier>
            lflag:=false; aflag:=false;
            nflag:=false; pflag:=false; sflag:=false; zflag:=false;


            for i in 1 to m1'length loop
              if m1(i)='-' then lflag:=true; end if;
              if m1(i)='+' then pflag:=true; end if;
              if m1(i)=' ' then sflag:=true; end if;
              if m1(i)='0' then zflag:=true; end if;
              if m1(i)='#' then aflag:=true; end if; --ignored in decimal
              if m1(i)=NUL then exit;        end if;
            end loop;
            if m2(1)=NUL then m:=0; else m:=atoi(m2); end if;

            if debug then
              writeline(output, buf);
              write(buf, string'(" min width="));  write(buf, m);
              write(buf, string'(" m1_flags=")); write(buf, m1);
              write(buf, string'(" m2_min_width=")); write(buf, m2);
              write(buf, string'(" m3_precision=")); write(buf, m3);
              writeline(output, buf);
            end if;

            if c='x' or c='o' then --unlimited string length
              if c='x' then ap:=4; else ap:=3; end if;

              ax:=0; n:=0; i:=0;
              for j in 1 to s1'length loop
                if s1(j)=NUL then exit; end if;
                if s1(j)=' ' then exit; end if;
                if s1(j)='1' then ax:=2*ax+1; else ax:=2*ax; end if; 
                n:=n+1;
                if n=ap then i:=i+1; m1(i):=pf_hex(ax); ax:=0; n:=0; end if;
              end loop;
              if n>0             then i:=i+1; m1(i):=pf_hex(ax); end if;
              if c='x' and aflag then i:=i+1; m1(i):='x'; i:=i+1; m1(i):='0'; end if;
              if c='0' and aflag then i:=i+1; m1(i):='0'; end if;

              for j in 1 to i loop t1(j):=m1(i-j+1); end loop;
              i:=i+1; t1(i):=NUL; c:='s';

            elsif c='d' or c='u' then
              ax:=0; d:=' ';
              for i in 1 to s1'length loop
                if s1(i)=NUL then exit;                 end if;
                if s1(i)=' ' then exit;                 end if;
                if i=1       then ap:=1; else ap:=ap*2; end if;
                if s1(i)='1' then ax:=ax+ap;            end if;
                d:=s1(i);
              end loop;
              if c='d' and d='1' then nflag:=true; ax:=ap -(ax-ap); end if;

              i:=0;
              loop
                n:=ax mod 10;
                if i<m1'length then i:=i+1; m1(i):=pf_hex(n); end if;
                ax:=ax/10;
                if ax=0 then exit; end if;
              end loop;
              if zflag and not lflag then
                while i<m-1 loop i:=i+1; m1(i):='0'; end loop;
              end if; 
              if nflag                             then i:=i+1; m1(i):='-'; end if;
              if pflag and not nflag               then i:=i+1; m1(i):='+'; end if;
              if sflag and not pflag and not nflag then
                i:=i+1; if zflag then m1(i):='0'; else m1(i):=' '; end if;
              end if;
              if zflag and not lflag and i<m       then i:=i+1; m1(i):='0'; end if;

              for j in 1 to i loop t1(j):=m1(i-j+1); end loop;

              i:=i+1; t1(i):=NUL; c:='s';
	      --write(buf, string'(" i=")); write(buf, n);
              --writeline(output, buf);
            end if;

            if c='%' then write(buf, '%'); end if;

            if c='s' then
              n:=strlen(t1);
              if m3(1)=NUL then p:=n; else p:=atoi(m3); end if;

	      if debug then
                writeline(output, buf);
                write(buf, string'(" lflag=")); write(buf, lflag);
	        write(buf, string'(" min width="));  write(buf, m);
                write(buf, string'(" precision="));  write(buf, p);
                writeline(output, buf);
              end if;

              if not lflag AND p<m then
                write(buf, string'(" "), LEFT, m-p);
              end if;
                
              if n<=p then write(buf, t1(1 to n)); --no truncation
              else         write(buf, t1(1 to p)); end if;

              if lflag AND p<m then
                write(buf, string'(" "), LEFT, m-p);
              end if;
            end if;
	when others =>
	end case;
    end loop;
  end xprintf;


  function pf(a1: IN bit) return string is
    variable s: string(1 to 1);
  begin
    s(1):=pf_bit_vector(a1); return s;
  end pf;

  function pf(a1: IN boolean) return string is
    variable s: string(1 to 1);
  begin
    if a1 then s(1):='1'; else s(1):='0'; end if;
    return s;
  end pf;

  function pf(a1: IN character) return string is
    variable s: string(1 to 1);
  begin
    s(1):=a1; return s;
  end pf;

  function pf(a1: IN std_ulogic) return string is
    variable s: string(1 to 1);
  begin
    s(1):=pf_std_logic_vector(a1); return s;
  end pf;

  function pf(a1: IN string) return string is
  begin
    return a1;
  end pf;

  function pf2(s: IN string) return string is
    variable t: string(1 to s'length):=s;
    variable c: boolean:=true;
    variable i: integer:=1;
  begin --2's complement
    while i <= s'length loop
      if    s(i)='0' then
        if c then t(i):='0'; else t(i):='1'; c:=false; end if; 
      elsif s(i)='1' then
        if c then t(i):='1'; else t(i):='0'; end if; c:=false;
      elsif s(i)=NUL then
         exit;
      end if;
      i:=i+1;
    end loop;
    if i<=t'length AND not c then t(i):='1'; i:=i+1; end if;
    if i<=t'length           then t(i):=NUL; end if;
    return t;
  end pf2;

  function pf(a1: IN integer) return string is
    variable ax, j: integer:=0;
    variable r:     string(1 to 64);
  begin
    j:=0; ax:=a1;
    if a1<0 then ax:=-a1; else ax:=a1; end if;
    loop
      if j<r'length     then j:=j+1; else exit; end if;
      if (ax mod 2) = 0 then r(j):='0'; else r(j):='1'; end if;
      ax:=ax/2; if ax=0 then exit; end if;
    end loop;
    --underscore not dash (see std_logic)
    if j<r'length          then j:=j+1; r(j):=NUL; end if;
    if a1<0                then r:=pf2(r); else r(j):='0'; j:=j+1; r(j):=NUL; end if;
    return r;
  end pf;

  function pf(a1: IN bit_vector) return string is
    variable r: string(1 to a1'length);
    variable j: integer:=1;
  begin
    if a1'left <= a1'right then --little endian
      for i in a1'left to a1'right loop
        r(j) := pf_bit_vector(a1(i)); j:=j+1;
      end loop;
    else
      for i in a1'right to a1'left loop
        r(j) := pf_bit_vector(a1(i)); j:=j+1;
      end loop;
    end if;
    return r;
  end pf;

  --type conversion --keep little endian format
  function pf(a1: std_ulogic_vector) return string is
    variable r: string(1 to a1'length);
    variable j: integer:=1;
  begin
    if a1'left <= a1'right then --little endian
      for i in a1'left to a1'right loop
        r(j) := pf_std_logic_vector(a1(i)); j:=j+1;
      end loop;
    else
      for i in a1'right to a1'left loop
        r(j) := pf_std_logic_vector(a1(i)); j:=j+1;
      end loop;
    end if;
    return r;
  end pf;

  --type conversion --keep endian format
  function pf(a1: std_logic_vector) return string is
    variable r: string(1 to a1'length);
    variable j: integer:=1;
  begin
    if a1'left <= a1'right then --little endian
      for i in a1'left to a1'right loop
        r(j) := pf_std_logic_vector(a1(i)); j:=j+1;
      end loop;
    else
      for i in a1'right to a1'left loop
        r(j) := pf_std_logic_vector(a1(i)); j:=j+1;
      end loop;
    end if;
    return r;
  end pf;

begin
  process
    variable s, s1, s2: string(1 to 256);
    variable m1, m2, m3, m4: string(1 to 256);
    variable b: boolean;
    variable si, i: integer;
    variable vu1:    std_ulogic_vector(0     to 7):="0LWXU1Z-"; --little endian
    variable v1:     std_logic_vector (0     to 7):="0LWXU1Z-"; --little endian
    variable v2:     std_logic_vector (7 downto 0):="-Z1UXWL0"; --big endian
    variable b1:     bit_vector       (0     to 7):="00110101";
    variable b2:     bit_vector       (7 downto 0):="11001010";
    variable sl1:    std_logic:='1';
    variable su1:    std_ulogic:='0';
    variable buf:    line;
  begin
    write(buf, string'("--begin test;")); writeline(output, buf);

    strcpy(s, "hello, world");
    xprintf("%%+ #-0.0s    :%+ #-0.0s:\n", s); 
    xprintf("0.0s    :%0.0s:\n", s);
    xprintf("10s     :%10s:\n", s);
    xprintf("10.0s   :%10.0s:\n", s);
    xprintf(".10s    :%.10s:\n", s);
    xprintf("0.10s   :%0.10s:\n", s);
    xprintf("-10s    :%-10s:\n", s);
    xprintf("-10.0s  :%-10.0s:\n", s);
    xprintf(".15s    :%.15s:\n", s);
    xprintf("0.15s   :%0.15s:\n", s);
    xprintf("-15s    :%-15s:\n", s);
    xprintf("-15.0s  :%-15.0s:\n", s);
    xprintf("15.10s  :%15.10s:\n", s);
    xprintf("-15.10s :%-15.10s:\n", s);
    xprintf("-5.10s  :%-15.10s:\n", s);
    xprintf("true=%s\n", pf(true));
    xprintf("false=%s\n", pf(false));
    xprintf("bit=%s\n", pf(b2(1)));
    xprintf("b1=%s\n", pf(b1));
    xprintf("b2=%s\n", pf(b2));
    xprintf("vu1=%s\n", pf(vu1));
    xprintf("v1=%s\n", pf(v1));
    xprintf("v2=%s\n", pf(v2));
    xprintf("std_logic=%s\n", pf(sl1));
    xprintf("std_ulogic=%s\n", pf(su1));
    xprintf("-15  =:%s:\n",    pf(-15));
    xprintf("-1   =:%s:\n",    pf(-1));
    xprintf("-1   =:%d:\n",    pf(-1));
    xprintf("s  -7=:%s:\n",  pf(-7));
    xprintf("u  -7=:%u:\n",  pf(-7));
    xprintf("d  -7=:%d:\n",  pf(-7));
    xprintf("+15  =:%s:\n",    pf(15));
    xprintf("d    =:%d:\n",    pf(15));
    xprintf("#3d  =:%#3d:\n",  pf(1945));
    xprintf(" 3d  =:% 3d:\n",  pf(1945));
    xprintf(" +3d =:% +3d:\n", pf(1945));
    xprintf("+ 3d =:%+ 3d:\n", pf(1945));
    xprintf("+3d  =:%+3d:\n",  pf(1945));
    xprintf("3d   =:%3d:\n",   pf(1945));
    xprintf("3d   =:%3d:\n",   pf(-1945));
    xprintf("10x  =:%10x:\n",  pf(1945));
    xprintf("10x  =:%10x:\n",  pf(-1945));
    xprintf("10x  =:%#10x:\n",  pf(1945));
    xprintf("10x  =:%#10x:\n",  pf(-1945));
    xprintf("-1945=:%s:\n",     pf(-1945));
    xprintf("10d  =:%10d:\n",  pf(1945));
    xprintf("10d  =:%10d:\n",  pf(-1945));
    xprintf("010d =:%010d:\n",  pf(1945));
    xprintf("010d =:%010d:\n",  pf(-1945));
    xprintf(" 010d=:% 010d:\n",  pf(1945));
    xprintf(" 010d=:% 010d:\n",  pf(-1945));
    xprintf("+010d=:%+010d:\n",  pf(1945));
    xprintf("+010d=:%+010d:\n",  pf(-1945));
    xprintf("s    =:%s:\n",   pf(bit_vector'("10011001111"))); -- =1945
    xprintf("10s  =:%10s:\n", pf(bit_vector'("10011001111"))); -- =1945
    xprintf("  d  =:%d:\n",   pf(bit_vector'("10011001111")));
    xprintf("10d  =:%10d:\n", pf(bit_vector'("10011001111")));

    write(buf, string'("--end test;")); writeline(output, buf);
    wait;
  end process;

end;

configuration regexp_h_test_cfg of regexp_h_test is
  for regexp_h_test_arch
  end for;
end;
