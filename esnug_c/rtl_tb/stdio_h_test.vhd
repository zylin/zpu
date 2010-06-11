-- File:    stdio_h_test.vhd
-- Version: 3.0 (June 6, 2004)
-- Source:  http://bear.ces.cwru.edu/vhdl
-- Date:    June 6,2004 (Copyright)
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
-- along with this program; if not, WRITE to the Free Software
-- Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
--
USE     STD.TEXTIO.ALL;
Library IEEE;
USE     IEEE.std_logic_1164.all;
LIBRARY C;
USE     C.stdio_h.all;
USE     C.strings_h.all;

entity stdio_h_test is
end;

architecture stdio_h_test_arch of stdio_h_test is
begin
  process
    variable v16: std_logic_vector(15 downto 0);
    variable i32:            integer:=0;
    variable fi, n:          integer;            --int  fi, n;
    variable W, X:           line;               --char *W, *X;
    variable s, s1, s2:      string(1 to 256);   --char s[256], s1[256], s2[256];
    variable m1, m2, m3, m4: string(1 to 256);

    variable si,i: integer;
    variable bool: boolean;
    variable bit1: bit;
    variable x07:  bit_vector       (0 to 7)    :="01111111"; --little endian == -2
    variable x16:  bit_vector       (0 to 15)   :="0111000000000000"; --little endian == -2
    variable z16:  bit_vector       (0 to 15)   :="0000000000000000"; --little endian == -2
    variable b07:  bit_vector       (0 to 7)    :="00110101"; --little endian
    variable b70:  bit_vector       (7 downto 0):="11001010"; --big endian
    variable sl1:  std_logic:='1';
    variable v07:  std_logic_vector (0 to 7)    :="0LWXU1Z-"; --little endian
    variable v70:  std_logic_vector (7 downto 0):="-Z1UXWL0"; --big endian

    variable fout: CFILE;              --FILE fout: text; --FILE *fout;
    variable fin:  CFILE;              --FILE fin:  text; --FILE *fin;
    variable fout1:CFILE;              --FILE fout1:text;
    variable fout2:CFILE;              --FILE fout2:text;
    variable buf, fbuf1: LINE;         --char    *buf, *fbuf1;
    variable f, g:       REAL :=3.14159; --float f, g;
  begin
    WRITE(buf, string'("--begin test;")); WRITELINE(OUTPUT, buf);
    printf("abc "); 
    printf("def\n"); --non line printf code

    printf("x07 signed   decimal %%d=%d == -2\n",x07);
    printf("x16 unsigned hex     %%x=%x == e\n", x16); 
    printf("z16 unsigned hex     %%x=%x == 0\n\n", z16); 

    printf("b07(7)=%s ",  b07(7));
    printf("b07(6)=%s ",  b07(6));
    printf("b07(5)=%s ",  b07(5));
    printf("b07(4)=%s ",  b07(4));
    printf("b07(3)=%s ",  b07(3));
    printf("b07(2)=%s ",  b07(2));
    printf("b07(1)=%s ",  b07(1));
    printf("b07(0)=%s\n", b07(0));

    printf("b07 unsigned string  %%s=%s == 10101100 (print as big endian)\n", b07);
    printf("b07 unsigned hex     %%x=%x == ac\n", b07); 
    printf("b07 unsigned octal   %%o=%o == 254\n",b07);
    printf("b07 unsigned decimal %%u=%u == 172\n",b07);
    printf("b07 signed   decimal %%d=%d == -84\n",b07);
    printf("b07 %%5x=[%5x] == [   ac]\n",         b07);
    printf("b07 %%05x=%05x == 000ac\n",           b07);
    printf("b07 %%#x=%#x == 0xac\n",              b07);
    printf("b07 %%X=%X == AC\n",                  b07);
    printf("b07 %%#X=[%#X] == [0XAC]\n",          b07);
    printf("b07 %%#1X=[%#1X] == [0XAC]\n",        b07);
    printf("b07 %%#5X=[%#5X] == [ 0XAC]\n",       b07);
    printf("b07 %%#9X=[%#9X] == [     0XAC]\n",   b07);
    printf("b07 %%-#9X=[%-#9X] == [0XAC     ]\n", b07);
    printf("b07 %%-#09X=[%-#9X] == [0XAC     ]\n",b07);
    printf("b07 %%#05X=[%#05X] == [0X0AC]\n",     b07);
    printf("b07 %%#09X=[%#09X] == [0X00000AC]\n", b07);
    printf("b07 %%-x=%-x == ac\n",                b07);
    printf("b07 %%+x=%+x == ac\n",                b07);
    printf("b07 %%1d=[%1d] == [-84]\n",           b07);
    printf("b07 %%5d=[%5d] == [  -84]\n",         b07);
    printf("b07 %%9d=[%9d] == [      -84]\n",     b07);
    printf("b07 %%-9d=[%-9d] == [-84      ]\n",   b07);
    printf("b07 %%09d=[%09d] == [-00000084]\n",   b07);

    printf("\nvariable b70: bit_vector(7 downto 0):=11001010; --initialize as big endian\n");
    printf("b70(7)=%s b70(6)=%s b70(5)=%s b70(4)=%s b70(3)=%s b70(2)=%s b70(1)=%s b70(0)=%s\n",
            pf(b70(7)), pf(b70(6)), pf(b70(5)), pf(b70(4)),
            pf(b70(3)), pf(b70(2)), pf(b70(1)), pf(b70(0)));

    printf("b70 %%#s=%#s == 11001010\n", b70);
    printf("b70 %%#x=%#x == 0xca\n",     b70);
    printf("b70 %%#o=%#o == 0312\n",     b70);
    printf("b70 %%#d=%#d == -54\n",      b70);
    printf("\n");

    b07:=bit_vector'("00110101"); 
    printf("b07:=bit_vector'(00110101); == bit_vector'(b0,...,b6,b7)\n");
    printf("b07      =[%s] == [10101100] == [b7,b6,...,b0]\n\n", b07);

    b70:=bit_vector'("11001010");
    printf("b70:=bit_vector'(11001010); == bit_vector'(b7,...,b1,b0)\n");
    printf("b70      =[%s] == [11001010] == [b7,b6,...,b0]\n\n", b70);

    v07:=std_logic_vector'("0LWXU1Z-");
    printf("v07:=std_logic_vector'(0LWXU1Z-); == std_logic_vector'(v0,...,v6,v7)\n");
    printf("v07      =[%s] == [-Z1UXWL0] == [v7,v6,...,v0]\n\n", v07);

    v70:=std_logic_vector'("-Z1UXWL0");
    printf("v70:=std_logic_vector'(-Z1UXWL0); == std_logic_vector'(v7,...,v1,v0)\n");
    printf("v70      =[%s] == [-Z1UXWL0] == [v7,v6,...,v0]\n\n", v70);

    printf("variable b07: bit_vector(0 to 7):=00110101; --initialize as little endian\n");
    b70 := b07;
    printf("\nb70 := b07; --effects of mis-matched endian copy\n");
    printf("b70(7 DOWNTO 0):= b07(0 TO 7); --same as b70:=b07;\n\n");
    printf("b70(7)=%s b70(6)=%s b70(5)=%s b70(4)=%s b70(3)=%s b70(2)=%s b70(1)=%s b70(0)=%s\n",
            pf(b70(7)), pf(b70(6)), pf(b70(5)), pf(b70(4)), 
            pf(b70(3)), pf(b70(2)), pf(b70(1)), pf(b70(0)));
    printf("b70 %%s=%s\n",  b70);
    printf("b70 %%x=%x\n",  b70);
 
    sscanf("12AF", "%x", v16); printf("std_logic_vector(15 downto 0)=12AF=%s\n", v16);
    sscanf("12A",  "%x", v16); printf("std_logic_vector(15 downto 0)=012A=%s\n", v16);
    sscanf("27",   "%d", i32); printf("integer=%d==27\n", i32);

    strcpy(s, "  hello, world "); sscanf(s, "%s", s1); printf("%%s=[%s]=[hello,]\n", s1);
    strcpy(s, "  12ab 456   ");  printf("scanf([%s]==[  12ab 456],...);;\n", s);
    strcpy(s, "  12ab 456   "); sscanf(s, "%d", n); printf("%%d=%d==12\n", n);
    strcpy(s, "  12ab 456   "); sscanf(s, "%x", n); printf("%%x=%x==12ab\n", n);
    strcpy(s, "  12ab 456   "); sscanf(s, "%x", s1); printf("%%s=%s==00001001010101011\n", s1);
    strcpy(s, "  12ab 456   "); sscanf(s, "%o", n); printf("%%o=%o==12\n", n);
 
    -- all scanf vectors are little endian but will reverse for big endian vectors
    -- all printf vectors are printed as big endian
    strcpy(s, "  01001100 456   "); printf("scanf([%s]==[  01001100 456   ],...);\n", s);
    sscanf(s, "%s", bool); printf("bool %%s=%s==0\n", bool); printf("bool %%x=%x==0\n", bool);
    sscanf(s, "%s", bit1); printf("bit %%s=%s==0\n", bit1); printf("bit %%x=%x==0\n", bit1);
    strcpy(s, "  11001100 456   "); printf("scanf([%s]==[  11001100 456   ],...);\n", s);
    sscanf(s, "%s", bool); printf("bool %%s=%s==1\n", bool); printf("bool %%x=%x==1\n", bool);
    sscanf(s, "%s", bit1); printf("bit %%s=%s==1\n", bit1); printf("bit %%x=%x==1\n", bit1);
    sscanf(s, "%s", b07);  printf("b07 %%s=%s==11111100\n", b07); printf("b07 %%x=%x==fc\n", b07);
    sscanf(s, "%s", b70);  printf("b70 %%s=%s==11111100\n", b70); printf("b70 %%x=%x==fc\n", b70);
 
    strcpy(s, "  H10Xhlwu 456   "); printf("scanf([%s]==[  H10Xhlwu 456   ],...);\n", s);
    sscanf(s, "%s", sl1); printf("std_logic %%s=%s==H\n", sl1); printf("sl1 %%x=%x==0\n", sl1);

    -- all scanf vectors are little endian but will reverse for big endian vectors
    sscanf(s, "%s", v07); printf("v07 %%s=%s==H10XHLWU\n", v07); printf("v07 %%x=%x==40\n", v07);
    sscanf(s, "%s", v70); printf("v70 %%s=%s==H10XHLWU\n", v70); printf("v70 %%x=%x==40\n", v70);

    printf("\n");
    printf("----------------begin FILE I/O tests-----------------\n");
    fout:=fopen("xxx_out.txt", "w");    --file_open(fout, "xxx_out.txt", WRITE_MODE);
    printf("fopen(xxx_out.txt) fout=%d == 4\n", fout);
    if fout=0 then
      printf("cannot open file=xxx_out.txt\n");
    else
      --mixing fprintf, fputc, fputs with incomplete lines
      fprintf(fout, "  hello,");
      fprintf(fout, "  world\n 123 9bc\n");
      fputc('%', fout);
      fputs("xyz++abc" & LF, fout); --"\n" will not work here!
      fprintf(fout, "***");
      fputc('%', fout);
      fputs("...def 555" & LF, fout);
      fclose(fout);
    end if;
 
    fout1:=fopen("xxx_fout1.txt", "w"); --file_open(fout1, "xxx_fout1.txt", WRITE_MODE);
    printf("fopen(xxx_fout1.txt) fout1=%d == 4\n", fout1);
    fout2:=fopen("xxx_fout2.txt", "w"); --file_open(fout2, "xxx_fout2.txt", WRITE_MODE);
    printf("fopen(xxx_fout2.txt) fout2=%d == 5\n", fout2);
    if fout1=0 OR fout2=0 then
      printf("fopen(): cannot open xxx_fout1.txt OR xxx_fout2.txt\n");
    else
      fprintf(fout1, "  file1: ");      --fprintf(fbuf1, fout1,  "	file1: ");
      fprintf(fout2, "  file2: ");      --fprintf(fbuf2, fout2, "  file2: ");
      fprintf(fout1, "  Hello, World\n 123\n 9bc ");
      fprintf(fout2, "  Hallo, Welt\n 123\n 9bc "); 
      fclose(fout1); --fclose(fbuf1, fout1);
      fclose(fout2); --fclose(fbuf2, fout2);
    end if;

    fin:=fopen("xxx_out.txt", "r");     --file_open(fin, "xxx_out.txt", READ_MODE);
    printf("fopen(xxx_out.txt) fin=%d == 4\n", fin);
    if fin=0 then
      printf("stdio_h_test.vhd: cannot fopen file=[xxx_out.txt] for read\n");
    else
      fscanf(fin, "%3s", s); printf("s=hel==%s\n", s);

      s(1):=fgetc(fin); --fgetc(s(1), fin); 
      s(2):=fgetc(fin); --fgetc(s(2), fin); 
      s(3):=fgetc(fin); --fgetc(s(3), fin); 
      s(4):=fgetc(fin); --fgetc(s(4), fin); 
      s(5):=NUL;        --end of string

      printf("fgetc(1..5)=[lo, ]==[%s]\n", s);
      fscanf(fin, "%s", s); printf("s=world==%s\n", s);
      fscanf(fin, "%d", n); printf("s=123==%d\n", n);
      fscanf(fin, "%x", n); printf("s=9bc==%x\n", n);
      fclose(fin); --file_close(fin);
    end if;
    fin:=fopen("/dev/tty", "r");
    printf("fopen(/dev/tty, r) fin=%d == 2\n", fin);
    fout:=fopen("/dev/tty", "w");
    printf("fopen(/dev/tty, w) fout=%d == 1\n", fout);
    fclose(fin); --optional and harmless
    fclose(fout);
    fout:=fopen("/dev/null", "w");
    printf("fopen(/dev/null) fout=%d == 3\n", fout);
    fprintf(fout, "writing to null output (i.e. switch between debug and normal\n");
    fprintf(fout, "i=%d\n\n", 1945);
    fclose(fout); 
    fin:=fopen("CON", "r");
    printf("fopen(CON, r) fin=%d == 2\n", fin);
    fout:=fopen("CON", "w");
    printf("fopen(CON, w) fout=%d == 1\n", fout);
    fin:=fopen("NUL", "r");
    printf("fopen(NUL, r) fin=%d == 3\n", fin);
    fout:=fopen("NUL", "w");
    printf("fopen(NUL, w) fout=%d == 3\n", fout);

    strcpy(s, "stdio_inlet_test_file.txt");
    fin:=fopen(s, "r"); --file_open(fin, "inlet_test_file.txt", READ_MODE);
    printf("fopen(stdio_inlet_test_file.txt) fin=%d ==4\n", fin);
    if fin=0 then
      printf("stdio_h_test.vhd: cannot fopen file=%s for read\n", s);
    else
      for i in 1 to 5 loop
        fscanf(fin, "%s", s);                   --readline(fin, fscanf_buffer);
        printf("vhdl external input: s=%s\n", s); --writeline(output, fscanf_buffer);
      end loop;
      fclose(fin); --file_close(fin);
    end if;

    fin:=fopen("unknown.txt", "r"); --symphonyeda 2.3#8 bug: file_close does not clear STATUS_ERROR
    printf("fopen(unknown.txt) fin=%d == 0\n", fin); --synopsys/modelsim works properly

    printf("----------------end FILE I/O tests-----------------\n\n");

    printf("----------------begin REAL FLOATING POINT tests-----------------\n");
    printf("real float f=%f == 3.141590e+00\n", f);
    printf("real float %f == 2.953000e+01\n", 29.53);
    sscanf(" 365.25 ", "%f", g);
    printf("sscanf( 365.25 , %%f, g); g=%f == 3.652500e+02\n", g);
    printf("----------------end REAL FLOATING POINT tests-----------------\n\n");

    printf("--string'(little endian), std_logic_vector'(little_endian), bit_vector'(little endian)\n");

    printf("std_logic_vector'(H1001XL)=[%s] == [LX1001H]\n", std_logic_vector'("H1001XL"));
    printf("std_logic=%s == 1\n", std_logic'('1'));
    fprintf(stdout, "Note using pf(): pf(std_logic_vector)=[%-10s] == [01001X0   ]\n",
            pf(std_logic_vector'("0X10010"))); 
    fprintf(stdout, "std_logic_vector=[%-10s]==[01001X0   ]\n",
            std_logic_vector'("0X10010")); --alternate
    fprintf(stdout, "std_logic=[%-10s]==[1         ]\n", pf(std_logic'('1')));

    strcpy(s, "hello, world");
    printf("%%+ #-0.0s=[%+ #-0.0s] == []\n", s);
    printf("%%0.0s   =[%0.0s] == []\n", s);
    printf("%%10s    =[%10s] == [hello, world]\n", s);
    printf("%%10.0s  =[%10.0s] == [          ]\n", s);
    printf("%%.10s   =[%.10s] == [hello, wor]\n", s);
    printf("%%0.10s  =[%0.10s] == [hello, wor]\n", s);
    printf("%%-10s   =[%-10s] == [hello, world]\n", s);
    printf("%%-10.0s =[%-10.0s] == [          ]\n", s);
    printf("%%.15s   =[%.15s] == [hello, world]\n", s);
    printf("%%0.15s  =[%0.15s] == [hello, world]\n", s);
    printf("%%-15s   =[%-15s] == [hello, world   ]\n", s);
    printf("%%-15.0s =[%-15.0s] == [               ]\n", s);
    printf("%%15.10s =[%15.10s] == [     hello, wor]\n", s);
    printf("%%-15.10s=[%-15.10s] == [hello, wor     ]\n", s);
    printf("%%-5.10s =[%-15.10s] == [hello, wor     ]\n", s);
    printf("true     =[%s] == [1]\n", true);
    printf("false    =[%s] == [0]\n", false);
    printf("std_logic=[%s] == [H]\n", sl1);
    printf("%%s      =[%s] == [0] == 0\n", 0);
    printf("%%s      =[%s] == [11] == -1 (minimum number of bits)\n", -1);
    printf("%%d      =[%d] == [-1] == -1\n", -1);
    printf("%%s      =[%s] == [1001] == -7\n", -7);
    printf("%%u      =[%u] == [9] == -7 (unsigned =9)\n", -7);
    printf("%%d      =[%d] == [-7] == -7\n", -7);
    printf("%%s      =[%s] == [10001] == -15\n", -15);
    printf("%%s      =[%s] == [01111] == 15\n", 15);
    printf("%%d      =[%d] == [15] == 15\n", 15);
    printf("%%#3d    =[%#3d] == [1945]\n",  1945);
    printf("%% 3d    =[% 3d] == [ 1945]\n",  1945);
    printf("%% +3d   =[% +3d] == [+1945]\n", 1945);
    printf("%%+ 3d   =[%+ 3d] == [+1945]\n", 1945);
    printf("%%+3d    =[%+3d] == [+1945]\n",  1945);
    printf("%%3d     =[%3d] == [1945]\n",   1945);
    printf("%%3d     =[%3d] == [-1945]\n",  -1945);
    printf("%%10x    =[%10x] == [       799] == 1945\n",  1945);
    printf("%%#10x   =[%#10x] == [     0x799] == 1945\n", 1945);
    printf("%%#10o   =[%#10o] == [     03631] == 1945\n", 1945);
    printf("%%s      =[%s] == [0011110011001] == 1945 (first bit is sign)\n", 1945);
    printf("%%10x    =[%10x] == [      1867] == -1945\n", -1945);
    printf("%%10x    =[%#10x] == [    0x1867] == -1945\n",-1945);
    printf("%%s      =[%s] == [1100001100111] == -1945 (first bit is sign)\n",-1945);
    printf("%%10d    =[%10d] == [      1945]\n",    1945);
    printf("%%10d    =[%10d] == [     -1945]\n",   -1945);
    printf("%%010d   =[%010d] == [0000001945]\n",   1945);
    printf("%%010d   =[%010d] == [-000001945]\n",  -1945);
    printf("%% 010d  =[% 010d] == [0000001945]\n",  1945);
    printf("%% 010d  =[% 010d] == [-000001945]\n", -1945);
    printf("%%+010d  =[%+010d] == [+000001945]\n",  1945);
    printf("%%+010d  =[%+010d] == [-000001945]\n", -1945);

    printf("\n");
    printf("--big endian x'799'  is same as little endian bit_vector'(x'99e');\n"); 
    printf("--big endian o'3631' is same as little endian bit_vector'(o'4636');\n"); 
    printf("--use vhdl library endian_h to avoid these difficulties\n");
    printf("bit_vector       %%s    =[%s] == [11110011001]==1945\n",  bit_vector'("100110011110"));
    printf("bit_vector       %%s    =[%s] == [11110011001]==1945\n",  bit_vector'(x"99e"));
    printf("bit_vector       %%s    =[%s] == [11110011001]==1945\n",  bit_vector'(o"4636"));
    printf("bit_vector       %%12s  =[%12s] == [11110011001]==1945\n",bit_vector'(x"99e"));
    printf("bit_vector       %%d    =[%d] == 1945\n",                 bit_vector'(o"4636"));
    printf("std_logic_vector %%d    =[%d] == [1945]\n",   std_logic_vector'("100110011110"));
    printf("std_logic_vector %%10d  =[%10d] == [      1945]\n", std_logic_vector'("100110011110"));
    printf("std_logic_vector %%u    =[%u] == [1945]\n",   std_logic_vector'("100110011110"));
    printf("std_logic_vector %%10u  =[%10u] == [      1945]\n", std_logic_vector'("100110011110"));
    printf("std_logic_vector %%x    =[%x] == [799]\n",   std_logic_vector'("100110011110"));
    printf("std_logic_vector %%#x   =[%x] == [799]\n",   std_logic_vector'("100110011110"));
    printf("std_logic_vector %%10x  =[%10x] == [       799]\n", std_logic_vector'("100110011110"));
    printf("std_logic_vector %%o    =[%o] == [3631]\n",   std_logic_vector'("100110011110"));
    printf("std_logic_vector %%#o   =[%o] == [3631]\n",   std_logic_vector'("100110011110"));
    printf("std_logic_vector %%10o  =[%10o] == [      3631]\n", std_logic_vector'("100110011110"));

    printf("-------------Bug Fix for Version 22---------------\n");
    printf("printf(%%d = %d == 3);\n", 3);
    printf("printf(%%s = %s == 011);\n", 3);
    printf("printf(%%x = %x == 3);\n", 3);
    printf("printf(%%s = %s == 0100);\n", 4);
    printf("printf(%%x = %x == 4);\n", 4);
    printf("printf(%%s = %s == 0101);\n", 5);
    printf("printf(%%x = %x == 5);\n", 5);
    printf("printf(%%s = %s == 010011);\n", 19);
    printf("printf(%%x = %x == 13);\n", 19);
    sscanf("12", "%d", i);  printf("scanf(12, %%d,i);  printf(%%d = %d == 12);\n", i);
    sscanf("12", "%d", i);  printf("scanf(12, %%d,i);  printf(%%s = %s == 01100);\n", i);
    sscanf("12", "%d", i);  printf("scanf(12, %%d,i);  printf(%%x = %x == c);\n", i);
    sscanf("12", "%x", i);  printf("scanf(12, %%x,i);  printf(%%d = %d == 18);\n", i);
    sscanf("12", "%x", i);  printf("scanf(12, %%x,i);  printf(%%s = %s == 010010);\n", i);
    sscanf("12", "%x", i);  printf("scanf(12, %%x,i);  printf(%%x = %x == 12);\n", i);
    sscanf("80", "%x", i);  printf("scanf(80, %%x,i);  printf(%%s = %s == 010000000);\n", i);
    sscanf("80", "%x", i);  printf("scanf(80, %%x,i);  printf(%%x = %x == 80);\n", i);
    sscanf("80", "%x", i);  printf("scanf(80, %%x,i);  printf(%%d = %d == 128);\n", i);
    sscanf("128", "%d", i); printf("scanf(128,%%d,i);  printf(%%x = %x == 80);\n", i);
    sscanf("128", "%d", i); printf("scanf(128,%%d,i);  printf(%%d = %d == 128);\n", i);
    printf("printf(%%x = %x == 7f, 127);\n", 127);
    printf("printf(%%x = %o == 177, 127);\n", 127);
    printf("printf(%%d = %d == 127, 127);\n", 127);

    --printf,fprintf,sprintf can always handle upto 16 std_logic_vectors in a row
    printf("v1=%s v2=%s v3=%s v4=%s\n",
      std_logic_vector'("1001"), std_logic_vector'("100110"),
      std_logic_vector'("100110011"), std_logic_vector'("11110011001"));

    printf("time is %d ==5 ns\n", 5 ns);
    printf("time is now %d ==0 ns\n", now);

    printf("-------------checking stdio_h internal functions---------------\n");
    -- special debugging stdio_h internal functions
    -- Not part of standard VHDL usage: Synopsys & ModelSim hack
    -- should use WRITELINE(output,...) not WRITE(output,...);
    -- WRITE(output, string'("helloX")); --Synopsys "helloX\n"; ModelSim: "helloX";
    -- WRITE(output, string'("helloY"));

    printf("--copy line to string\n");
    w:=NEW string'("Konnichi wa");
    strcpy(s, w.all); printf("strcpy(s, w.all); s=[%s] w.all=[%s]\n", s, w.all);
    DEALLOCATE(w);

    printf("--copy string line\n");
    w:=NEW string'("Bonjour"); --copy string to line
    printf("w:=NEW string'(Bonjour); --copy string to line\n");
    strcpy(w.all, s); printf("strcpy(w.all, s); w.all=[%s]==[Konnich] s=[%s]==[Konnichi wa]\n", w.all, s);
    DEALLOCATE(w);

    WRITE(W, string'("Konnichi "));--strcat(w, "Konnichi ");
    WRITE(W, string'("Wa"));       --strcat(w, "Wa");
    printf("write(w, string'(Konnichi )); write(w, string'(Wa));\n");
    printf("--similar to strcat(w, Konnichi ); strcat(w, Wa);\n");
    printf("s=(%s) == (Konnichi Wa) --printf(s=(%%s)\\n, *w);\n", w.all);
    printf("w'length=%d==11 --strlen(*w);\n", w'length);

    DEALLOCATE(W); --free(w);
    -- stdio_h tests limited to --maxarg=1
    fi:=1; sbufprintf(fi, W, stdout, "hello1\nhello2\n", " "); --WRITE to stdout
    printf("fi=%d==17\n", fi);
    --Symphony EDA 1.5 cannot handle w'length=0 for DEALLOCATEd w
    --Synopsys and ModelSim can!
    --printf("w'length==0==%d", w'length); printf(" (%s)\n", w.all);

    DEALLOCATE(W);
    fi:=1; sbufprintf(fi, W, -1, "hello3\nhello4\n", " "); --WRITE to string line W
    printf("sprintf=(%s)=(hello3\\nhello4\\n)\n", w.all);
    printf("strlen(w)=w'length=%d==14\n", w'length);
    printf("fi=%d==17\n", fi);
    W:=null; DEALLOCATE(W); --**Error: vhdlsim,10: Null access value dereferenced.
    DEALLOCATE(W);
    DEALLOCATE(W);

    WRITE(X, string'(" 123abch  456  "));
    fi:=1; sbufscanf(fi, X, -1, "%s", W); --char *W <= "%s" <= char *X
    printf("sscanf matched=(%s) == (123abch)\n", w.all);
    printf("sscanf unused =(%s) == (  456  )\n", x.all);
    printf("strlen(w)=%d==7\n", w'length);
    printf("fi=%d==3\n", fi);
   
    DEALLOCATE(X); DEALLOCATE(W);
    WRITE(X, string'(" 123abch  456  "));
    fi:=1; sbufscanf(fi, X, -1, "%2s", W); --char *W <= "%2s" <= char *X
    printf("sscanf matched=(%s) == (12)\n", w.all);
    printf("sscanf unused =(%s) == (3abch  456  )\n", x.all);
    printf("strlen(w)=%d==2\n", w'length);
    printf("fi=%d==4\n", fi);

    DEALLOCATE(X); DEALLOCATE(W);
    WRITE(X, string'(" 123abch  456   "));
    fi:=1; sbufscanf(fi, X, -1, "%d", W); --char *W <= "%d" <= char *X
    printf("sscanf matched=(%s) == (001111011) == 123\n", w.all);
    printf("sscanf unused =(%s) == (abch  456   )\n", x.all);
    printf("strlen(w)=%d==9\n", w'length);
    printf("fi=%d==3\n", fi);

    DEALLOCATE(X); DEALLOCATE(W);
    WRITE(X, string'(" 123abch   456   "));
    fi:=1; sbufscanf(fi, X, -1, "%x", W); --char *W <= "%x" <= char *X
    printf("sscanf matched=(%s) == (0000100100011101010111100)\n", w.all);
    printf("sscanf matched=(%x) == (123abc)\n", w.all);
    printf("sscanf unused =(%s) == (h   456   )\n", x.all);
    printf("strlen(w)=%d==25\n", w'length);
    printf("fi=%d==3\n", fi);

    printf("  hello,");
    printf("  world\n 123 9bc\n");
    putchar('%');
    puts("xyz++abc"); --LF added
    printf("***");
    putchar('%');
    puts("...def 555");

    WRITE(buf, string'("--end test;")); WRITELINE(output, buf);
    wait;
  end process;
end;

configuration stdio_h_test_cfg of stdio_h_test is
  for stdio_h_test_arch
  end for;
end;
