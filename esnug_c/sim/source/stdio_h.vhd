-- file: stdio_h.vhd generated on Tue Jun  8 05:28:51 EDT 2004: stdio_h.sh --maxargs=1 
-- File: stdio_head_h.vhd
-- Version: 3.0 (June 6, 2004)
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
USE     std.textio.all;
LIBRARY ieee;
USE     ieee.std_logic_1164.all;
LIBRARY C;
USE     C.strings_h.all; --fputs:strlen
USE     C.regexp_h.all;  --sbufprintf:regmatch, sbufscanf:regmatch
USE     C.stdlib_h.all;  --sbufprintf:atoi

PACKAGE stdio_h IS
  FILE     streamfile4, streamfile5, streamfile6: TEXT;
  FILE     streamfile7, streamfile8, streamfile9: TEXT;
  CONSTANT streamNFILE: INTEGER:=9;

  TYPE     streamflags IS ARRAY(0 TO streamNFILE) OF BOOLEAN;
  SHARED   VARIABLE streambusy:   streamflags := (TRUE,TRUE,TRUE,TRUE,OTHERS=>FALSE);
  SHARED   VARIABLE streamlock:   BOOLEAN:=FALSE;
  SHARED   VARIABLE streamnulbuf: LINE; --should allows be null

  TYPE STREAMIOBUF IS
    RECORD
      fstat: FILE_OPEN_STATUS;
      fmode: FILE_OPEN_KIND;   --READ_MODE, WRITE_MODE, APPEND_MODE;
      buf:   LINE;
    END RECORD;

  TYPE       STREAMIOBUFS IS ARRAY(0 TO streamNFILE) OF STREAMIOBUF;
  SHARED     VARIABLE streamiob: STREAMIOBUFS :=
   ((STATUS_ERROR,READ_MODE,NULL), --null fid
    (OPEN_OK,WRITE_MODE,NULL),     --stdout
    (OPEN_OK,READ_MODE,NULL),      --stdin
    OTHERS=>(STATUS_ERROR,READ_MODE,NULL));

  SUBTYPE    CFILE    IS INTEGER;
  CONSTANT   stdin:   CFILE :=2; --UNIX filename "/dev/tty", DOS filename "CON"
  CONSTANT   stdout:  CFILE :=1; --UNIX filename "/dev/tty", DOS filename "CON"
  CONSTANT   stdnul:  CFILE :=3; --UNIX filename "/dev/null", DOS filename "NUL"
  CONSTANT   stderr:  CFILE :=1; --Not support by VHDL 93

  FUNCTION   pf(x: IN BIT)               RETURN STRING;
  FUNCTION   pf(x: IN BOOLEAN)           RETURN STRING;
  FUNCTION   pf(x: IN CHARACTER)         RETURN STRING;
  FUNCTION   pf(x: IN STD_ULOGIC)        RETURN STRING;
  FUNCTION   pf(x: IN STRING)            RETURN STRING;
  FUNCTION   pf(x: IN INTEGER)           RETURN STRING;
  FUNCTION   pf(x: IN BIT_VECTOR)        RETURN STRING;
  FUNCTION   pf(x: IN STD_ULOGIC_VECTOR) RETURN STRING;
  FUNCTION   pf(x: IN STD_LOGIC_VECTOR)  RETURN STRING;
  FUNCTION   pf(x: IN TIME)              RETURN STRING;
  FUNCTION   pf(x: IN REAL)              RETURN STRING;

  --              FILE *fopen(const char *filename, const char *mode);
  IMPURE FUNCTION       fopen(filename: IN STRING; mode: IN STRING) RETURN CFILE;
  --              int   fflush(FILE *stream);
  PROCEDURE             fflush(stream: IN CFILE);
  --              int   fclose(FILE *stream);
  PROCEDURE             fclose(stream: IN CFILE);

  --              int   fputc(int c, FILE *stream);
  PROCEDURE             fputc(c:   IN character; stream: IN CFILE);
  --              int   fputs(const char *s, FILE *stream);
  PROCEDURE             fputs(s:   IN    STRING; stream: IN CFILE);
  PROCEDURE             fputs(s:   INOUT LINE;   stream: IN CFILE); --will deallocate(s)
  --              int   putc(int c, FILE *stream);
  PROCEDURE             putc(c:    IN character; stream: IN CFILE);
  --              int   putchar(int c);
  PROCEDURE             putchar(c: IN character);
  --              int   puts(const char *s);
  PROCEDURE             puts(s:    IN    STRING);
  PROCEDURE             puts(s:    INOUT LINE); --will deallocate(s)

  --              int   feof(FILE *stream);
  IMPURE FUNCTION       feof(stream: IN CFILE) RETURN BOOLEAN;
  --              int   fgetc(FILE *stream);
  IMPURE FUNCTION       fgetc(stream: IN CFILE) RETURN CHARACTER;
  --              char *fgets(char *s, int size, FILE *stream);
  PROCEDURE             fgets(s: OUT  STRING; n: IN INTEGER; stream: IN CFILE);
  --              int   getc(FILE *stream);
  IMPURE FUNCTION       getc(stream: IN CFILE) RETURN CHARACTER;
  --              int   getchar(void);
  IMPURE FUNCTION       getchar RETURN CHARACTER;
  --              char *gets(char *s);
  PROCEDURE             gets(s: OUT STRING);
  --              int   ungetc(int c, FILE *stream);
  PROCEDURE             ungetc(c: IN character; stream: IN CFILE);

  PROCEDURE sbufprintf(fi:  INOUT INTEGER; sbuf: INOUT LINE; stream: IN CFILE;
                       fmt: IN STRING;     s:    IN STRING); --used only for testing package

  PROCEDURE sbufscanf(fi:  INOUT INTEGER; sbuf: INOUT LINE; stream: IN    CFILE;
                      fmt: IN    STRING;  s:    INOUT LINE); --used only for testing package

  PROCEDURE fprintf(stream: IN CFILE; format: IN STRING; a1: INOUT LINE);
  PROCEDURE printf(                   format: IN STRING; a1: INOUT LINE);
  PROCEDURE fscanf( stream: IN CFILE; format: IN string; a1: INOUT LINE);
  PROCEDURE scanf(                    format: IN string; a1: INOUT LINE);
  PROCEDURE sscanf( s:     IN string; format: IN string; a1: INOUT LINE);


  PROCEDURE fprintf(stream:  IN    CFILE;
                    format:  IN    STRING;
                    a1,  a2,  a3,  a4,  a5,  a6,  a7,  a8 : IN STRING := " ";
                    a9,  a10, a11, a12, a13, a14, a15, a16: IN STRING := " ");

  PROCEDURE fprintf(stream:  IN    CFILE;
                    format:  IN    STRING;
                    a1:      IN    STD_LOGIC_VECTOR;
                    a2,  a3,  a4,  a5,  a6,  a7,  a8      : IN STD_LOGIC_VECTOR := "U";
                    a9,  a10, a11, a12, a13, a14, a15, a16: IN STD_LOGIC_VECTOR := "U");

  PROCEDURE printf( format:  IN    STRING;
                    a1,  a2,  a3,  a4,  a5,  a6,  a7,  a8 : IN STRING := " ";
                    a9,  a10, a11, a12, a13, a14, a15, a16: IN STRING := " ");

  PROCEDURE printf( format:  IN    STRING;
                    a1:      IN    STD_LOGIC_VECTOR;
                    a2,  a3,  a4,  a5,  a6,  a7,  a8      : IN STD_LOGIC_VECTOR := "U";
                    a9,  a10, a11, a12, a13, a14, a15, a16: IN STD_LOGIC_VECTOR := "U");

  PROCEDURE sprintf(s: INOUT LINE;   format: IN STRING;  --Append to variable s
                    a1,  a2,  a3,  a4,  a5,  a6,  a7,  a8 : IN STRING := " ";
                    a9,  a10, a11, a12, a13, a14, a15, a16: IN STRING := " ");

  PROCEDURE sprintf(s: INOUT STRING; format: IN STRING;  --Overwrite variable s
                    a1,  a2,  a3,  a4,  a5,  a6,  a7,  a8 : IN STRING := " ";
                    a9,  a10, a11, a12, a13, a14, a15, a16: IN STRING := " ");

  PROCEDURE sprintf(s: INOUT STRING; format:  IN    STRING;
                    a1:      IN    STD_LOGIC_VECTOR;
                    a2,  a3,  a4,  a5,  a6,  a7,  a8      : IN STD_LOGIC_VECTOR := "U";
                    a9,  a10, a11, a12, a13, a14, a15, a16: IN STD_LOGIC_VECTOR := "U");


  PROCEDURE printf(format: IN string; a1: integer);

  PROCEDURE printf(format: IN string; a1: std_logic);

  PROCEDURE printf(format: IN string; a1: boolean);

  PROCEDURE printf(format: IN string; a1: bit);

  PROCEDURE printf(format: IN string; a1: bit_vector);

  PROCEDURE printf(format: IN string; a1: time);

  PROCEDURE printf(format: IN string; a1: real);

  PROCEDURE fprintf(stream: IN CFILE; format: IN string; a1: integer);

  PROCEDURE fprintf(stream: IN CFILE; format: IN string; a1: std_logic);

  PROCEDURE fprintf(stream: IN CFILE; format: IN string; a1: boolean);

  PROCEDURE fprintf(stream: IN CFILE; format: IN string; a1: bit);

  PROCEDURE fprintf(stream: IN CFILE; format: IN string; a1: bit_vector);

  PROCEDURE fprintf(stream: IN CFILE; format: IN string; a1: time);

  PROCEDURE fprintf(stream: IN CFILE; format: IN string; a1: real);

  PROCEDURE scanf(format: IN string; a1: INOUT string);

  PROCEDURE scanf(format: IN string; a1: INOUT integer);

  PROCEDURE scanf(format: IN string; a1: INOUT std_logic);

  PROCEDURE scanf(format: IN string; a1: INOUT std_logic_vector);

  PROCEDURE scanf(format: IN string; a1: INOUT boolean);

  PROCEDURE scanf(format: IN string; a1: INOUT bit);

  PROCEDURE scanf(format: IN string; a1: INOUT bit_vector);

  PROCEDURE scanf(format: IN string; a1: INOUT time);

  PROCEDURE scanf(format: IN string; a1: INOUT real);

  PROCEDURE fscanf(stream: IN CFILE; format: IN string; a1: INOUT string);

  PROCEDURE fscanf(stream: IN CFILE; format: IN string; a1: INOUT integer);

  PROCEDURE fscanf(stream: IN CFILE; format: IN string; a1: INOUT std_logic);

  PROCEDURE fscanf(stream: IN CFILE; format: IN string; a1: INOUT std_logic_vector);

  PROCEDURE fscanf(stream: IN CFILE; format: IN string; a1: INOUT boolean);

  PROCEDURE fscanf(stream: IN CFILE; format: IN string; a1: INOUT bit);

  PROCEDURE fscanf(stream: IN CFILE; format: IN string; a1: INOUT bit_vector);

  PROCEDURE fscanf(stream: IN CFILE; format: IN string; a1: INOUT time);

  PROCEDURE fscanf(stream: IN CFILE; format: IN string; a1: INOUT real);

  PROCEDURE sscanf(s: IN string; format: IN string; a1: INOUT string);

  PROCEDURE sscanf(s: IN string; format: IN string; a1: INOUT integer);

  PROCEDURE sscanf(s: IN string; format: IN string; a1: INOUT std_logic);

  PROCEDURE sscanf(s: IN string; format: IN string; a1: INOUT std_logic_vector);

  PROCEDURE sscanf(s: IN string; format: IN string; a1: INOUT boolean);

  PROCEDURE sscanf(s: IN string; format: IN string; a1: INOUT bit);

  PROCEDURE sscanf(s: IN string; format: IN string; a1: INOUT bit_vector);

  PROCEDURE sscanf(s: IN string; format: IN string; a1: INOUT time);

  PROCEDURE sscanf(s: IN string; format: IN string; a1: INOUT real);

end stdio_h;
 
-- File:    stdio_h_tail.vhd
-- Version: 3.0 (June 6, 2004)
-- Source:  http://bear.ces.cwru.edu/vhdl
-- Date:    June 6, 2004 (Copyright)
-- Author:  Francis G. Wolff   Email: fxw12@po.cwru.edu
-- Author:  Michael J. Knieser Email: mjknieser@knieser.com
--
-- This program IS free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 1, or (at your option)
-- any later version: http://www.gnu.org/licenses/gpl.html
--
-- This program IS distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the
-- GNU General Public License FOR more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
--
PACKAGE BODY stdio_h IS
  TYPE     pf_std_logic_vector_type IS array(std_ulogic) OF CHARACTER;
  CONSTANT pf_std_logic_vector:        pf_std_logic_vector_type
             := ('U', 'X', '0', '1', 'Z', 'W', 'L', 'H', '-');

  TYPE     pf_hex_type IS array(0 to 15) OF CHARACTER;
  CONSTANT pf_hex: pf_hex_type
        := ('0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f');
  CONSTANT pf_hexx: pf_hex_type
        := ('0','1','2','3','4','5','6','7','8','9','A','B','C','C','E','F');

  TYPE     pf_hex2_type IS array(0 to 15) of STRING(1 to 4);
  CONSTANT pf_hex2: pf_hex2_type
        := ("0000","0001","0010","0011","0100","0101","0110","0111",  --fix 20030425 
            "1000","1001","1010","1011","1100","1101","1110","1111"); --fix 20030425


  FUNCTION pf(x: IN bit) RETURN STRING IS
    VARIABLE s: STRING(1 TO 1);
  BEGIN
    IF x='1' THEN s(1):='1'; ELSE s(1):='0'; END IF; RETURN s;
  END pf;

  FUNCTION pf(x: IN BOOLEAN) RETURN STRING IS
    VARIABLE s: STRING(1 TO 1);
  BEGIN
    IF x THEN s(1):='1'; ELSE s(1):='0'; END IF; RETURN s;
  END pf;

  FUNCTION pf(x: IN CHARACTER) RETURN STRING IS
    VARIABLE s: STRING(1 TO 1);
  BEGIN
    s(1):=x; RETURN s;
  END pf;

  FUNCTION pf(x: IN std_ulogic) RETURN STRING IS
    VARIABLE s: STRING(1 TO 1);
  BEGIN
    s(1):=pf_std_logic_vector(x); RETURN s;
  END pf;

  FUNCTION pf(x: IN STRING) RETURN STRING IS
  BEGIN
    RETURN x;
  END pf;

  FUNCTION pf(x: IN INTEGER) RETURN STRING IS
    VARIABLE y: STRING(1 TO 128);
    VARIABLE c: CHARACTER:='0'; --carry
    VARIABLE a, b, i, n: INTEGER; --n:=bit length+sign bit
  BEGIN
    a:=x; IF a<0 THEN a:=-a; c:='1'; END IF;
    n:=1; WHILE a/=0 LOOP a:=a/2; n:=n+1; END LOOP;
    a:=x; IF n>y'HIGH THEN n:=y'HIGH; END IF;
    FOR i IN n DOWNTO 1 LOOP  --big endian
      b:=a MOD 2; a:=a/2; 
      IF x<0 THEN --2's complement
        IF b=0 THEN y(i):='1'; ELSE y(i):=c; c:='0'; END IF;
      ELSE
        IF b=0 THEN y(i):='0'; ELSE y(i):='1'; END IF;
      END IF;
    END LOOP;
    ASSERT a=0 AND c='0'
    REPORT "pf(x: IN INTEGER) bit length too small" SEVERITY WARNING;
    RETURN y(1 TO n); --return minimum number of bits to descibe integer
  END pf;

  FUNCTION sf(s: IN STRING) RETURN INTEGER IS
    VARIABLE i, ax, n, p: INTEGER;  VARIABLE nflag: BOOLEAN:=FALSE;
  BEGIN
    ax:=0; n:=0; p:=1; --IF f='u' THEN p:=0; ELSE p:=1; END IF;
    FOR i IN 1 TO s'LENGTH LOOP
      CASE s(i) IS
        WHEN NUL    => EXIT; WHEN ' '|HT => --ignore blanks
        WHEN '1'    => IF p=1 THEN p:=0; nflag:=TRUE; --begin 2's complement
                       ELSE
                         IF nflag THEN ax:=2*ax;   ELSE ax:=2*ax+1; END IF;
                       END IF;
        WHEN OTHERS => IF p=1 THEN p:=0;
                       ELSE
                         IF nflag THEN ax:=2*ax+1; ELSE ax:=2*ax; END IF;
                       END IF;
      END CASE;
    END LOOP;
    IF nflag THEN ax:=ax+1; END IF; --2's complement ax:=(NOT ax)+1;
    RETURN ax;
  END sf;

  FUNCTION pf(x: IN REAL) RETURN STRING IS
    VARIABLE s: LINE; VARIABLE i, n: INTEGER; VARIABLE y: STRING(1 TO 128);
  BEGIN
    y(1):='0'; n:=1; --assume default
    write(s, x);     --use internal function
    IF s/=NULL THEN
      IF s'LENGTH>0 THEN
        i:=1; WHILE i<=s'LENGTH LOOP
          IF i<=y'LENGTH THEN y(i):=s(i); n:=i; END IF; i:=i+1;
        END LOOP;
      END IF;
    END IF;
    DEALLOCATE(s); RETURN y(1 TO n); --wish list: return ieee bit string
  END pf;
        
  FUNCTION pf(x: IN bit_vector) RETURN STRING IS
    VARIABLE y: STRING(1 TO x'LENGTH); VARIABLE j: INTEGER:=1;
  BEGIN
    FOR i IN x'HIGH DOWNTO x'LOW LOOP
      IF x(i)='1' THEN y(j):='1'; ELSE y(j):='0'; END IF; j:=j+1;
    END LOOP;
    RETURN y;
  END pf;

  FUNCTION pf(x: IN std_ulogic_vector) RETURN STRING IS
    VARIABLE y: STRING(1 TO x'LENGTH); VARIABLE j: INTEGER:=1;
  BEGIN
    FOR i IN x'HIGH DOWNTO x'LOW LOOP
      y(j) := pf_std_logic_vector(x(i)); j:=j+1;
    END LOOP;
    RETURN y;
  END pf;

  FUNCTION pf(x: IN std_logic_vector) RETURN STRING IS
    VARIABLE y: STRING(1 TO x'LENGTH); VARIABLE j: INTEGER:=1;
  BEGIN
    FOR i IN x'HIGH DOWNTO x'LOW LOOP
      y(j) := pf_std_logic_vector(x(i)); j:=j+1;
    END LOOP;
    RETURN y;
  END pf;

  FUNCTION pf(x: IN time) RETURN STRING IS
  BEGIN
    RETURN pf(INTEGER(x / 1 ns));   
  END pf;

  IMPURE FUNCTION fopen(filename: IN STRING; mode: IN STRING) RETURN CFILE IS
    VARIABLE buf:   LINE;
    VARIABLE m:     INTEGER:=0;
    VARIABLE fid:   CFILE:=0;
    VARIABLE fmode: FILE_OPEN_KIND; --READ_MODE, WRITE_MODE, APPEND_MODE;
    VARIABLE fstat: FILE_OPEN_STATUS:=NAME_ERROR; --OPEN_OK, STATUS_ERROR, NAME_ERROR, MODE_ERROR;
  BEGIN
    IF streamlock THEN --handle concurrent calls to fopen
      write(buf, STRING'("fopen: streamlock")); writeline(OUTPUT, buf);
      WHILE streamlock LOOP m:=0; END LOOP; --symphonyeda has bug, cannot have empty loop
    END IF;
    streamlock:=TRUE;

    FOR i IN mode'RANGE LOOP
      CASE mode(i) IS
        WHEN 'r'    => fmode:=READ_MODE;   m:=m+1;
        WHEN 'w'    => fmode:=WRITE_MODE;  m:=m+1;
        WHEN 'a'    => fmode:=APPEND_MODE; m:=m+1;
        WHEN NUL    => EXIT;
        WHEN OTHERS => m:=-1; EXIT;
      END CASE;
    END LOOP;

    IF m=1 THEN
      IF strcmp(filename,"/dev/tty")=0 OR strcmp(filename,"CON")=0 THEN
        CASE fmode IS       --unix shell commands also use the dash, "-"
          WHEN READ_MODE   => fid:=stdin; fstat:=OPEN_OK;
          WHEN WRITE_MODE  => fid:=stdout;fstat:=OPEN_OK;
          WHEN APPEND_MODE => fid:=stdout;fstat:=OPEN_OK;
          WHEN OTHERS      => fstat:=NAME_ERROR;
        END CASE;
      ELSIF strcmp(filename,"/dev/null")=0 OR strcmp(filename,"NUL")=0 THEN
        fid:=stdnul; fstat:=OPEN_OK;
      ELSE
        fid:=0; m:=strlen(filename);
        FOR i IN streambusy'RANGE LOOP
          IF NOT streambusy(i) THEN fid:=i; EXIT; END IF;
        END LOOP;
        CASE fid IS
        WHEN 4      => file_open(fstat, streamfile4, filename(1 TO m), fmode);
        WHEN 5      => file_open(fstat, streamfile5, filename(1 TO m), fmode);
        WHEN 6      => file_open(fstat, streamfile6, filename(1 TO m), fmode);
        WHEN 7      => file_open(fstat, streamfile7, filename(1 TO m), fmode);
        WHEN 8      => file_open(fstat, streamfile8, filename(1 TO m), fmode);
        WHEN 9      => file_open(fstat, streamfile9, filename(1 TO m), fmode);
        WHEN OTHERS => fstat:=NAME_ERROR;
        END CASE;
      END IF;
    ELSE
      fstat:=MODE_ERROR;
    END IF;

    IF fstat=OPEN_OK THEN
      streambusy(fid):=TRUE;
    ELSE
      CASE fid IS      --totally unexpected: must do for fstat error
        WHEN 4      => file_close(streamfile4);
        WHEN 5      => file_close(streamfile5);
        WHEN 6      => file_close(streamfile6);
        WHEN 7      => file_close(streamfile7);
        WHEN 8      => file_close(streamfile8);
        WHEN 9      => file_close(streamfile9);
        WHEN OTHERS => 
      END CASE;
      fid:=0;
    END IF;
    streamiob(fid).fstat:=fstat; streamiob(fid).fmode:=fmode;

    streamlock:=FALSE;
    --write(buf, STRING'("fopen: file=")); write(buf, filename);
    --write(buf, STRING'(" fid=")); write(buf, fid); writeline(OUTPUT, buf);
    RETURN fid;
  END fopen;

  PROCEDURE fflush(stream: IN CFILE) IS
  BEGIN
    ASSERT stream>0 AND stream<=streamNFILE
    REPORT "fflush()/fclose(): passed in bad CFILE stream id" SEVERITY FAILURE;
    IF streamiob(stream).fstat=OPEN_OK AND streamiob(stream).buf/=NULL THEN
      IF (streamiob(stream).fmode=WRITE_MODE
          OR streamiob(stream).fmode=APPEND_MODE) THEN
        CASE stream IS --buf'LENGTH==0 is a newline
          WHEN stdout => writeline(output, streamiob(stream).buf);
          WHEN 3      => --/dev/null
          WHEN 4      => writeline(streamfile4, streamiob(stream).buf);
          WHEN 5      => writeline(streamfile5, streamiob(stream).buf);
          WHEN 6      => writeline(streamfile6, streamiob(stream).buf);
          WHEN 7      => writeline(streamfile7, streamiob(stream).buf);
          WHEN 8      => writeline(streamfile8, streamiob(stream).buf);
          WHEN 9      => writeline(streamfile9, streamiob(stream).buf);
          WHEN OTHERS =>
        END CASE;
        DEALLOCATE(streamiob(stream).buf);
      END IF;
    END IF;
  END fflush;

  PROCEDURE fclose(stream: IN CFILE) IS
  BEGIN
    fflush(stream);
    ASSERT streamiob(stream).fstat=OPEN_OK AND streambusy(stream)=TRUE
    REPORT "fclose(): CFILE stream id is already closed" SEVERITY FAILURE;
    CASE stream IS
      WHEN 4      => file_close(streamfile4); streambusy(stream):=FALSE;
      WHEN 5      => file_close(streamfile5); streambusy(stream):=FALSE;
      WHEN 6      => file_close(streamfile6); streambusy(stream):=FALSE;
      WHEN 7      => file_close(streamfile7); streambusy(stream):=FALSE;
      WHEN 8      => file_close(streamfile8); streambusy(stream):=FALSE;
      WHEN 9      => file_close(streamfile9); streambusy(stream):=FALSE;
      WHEN OTHERS => 
    END CASE;
  END fclose;

  PROCEDURE fputc(c: IN CHARACTER; stream: IN CFILE) IS
    VARIABLE fid: INTEGER;
  BEGIN
    ASSERT stream>0 AND stream<=streamNFILE
    REPORT "fputc(): passed in bad CFILE stream id" SEVERITY FAILURE;
    IF stream/=stdnul THEN
      IF c=LF THEN fflush(stream); ELSE write(streamiob(stream).buf, c); END IF;
    END IF;
  END fputc;

  PROCEDURE fputs(s: IN STRING; stream: IN CFILE) IS
    VARIABLE i: INTEGER; VARIABLE n: INTEGER:=strlen(s);
  BEGIN --inline fputc code FOR simulator efficiency
    IF stream/=stdnul THEN
      ASSERT stream>0 AND stream<=streamNFILE
      REPORT "fputs(): passed in bad CFILE stream id" SEVERITY FAILURE;
      FOR i IN 1 TO n LOOP
        IF s(i)=LF THEN write(streamiob(stream).buf, string'("")); fflush(stream);
                   ELSE write(streamiob(stream).buf, s(i)); END IF;
      END LOOP;
    END IF;
  END fputs;

  PROCEDURE fputs(s: INOUT LINE; stream: IN CFILE) IS
    VARIABLE i: INTEGER; VARIABLE n: INTEGER:=0;
  BEGIN
    ASSERT stream>0 AND stream<=streamNFILE
    REPORT "fputs(): passed in bad CFILE stream id" SEVERITY FAILURE;
    IF stream/=stdnul THEN
      IF s/=NULL THEN n:=strlen(s.all); END IF; --avoids Null access value dereferenced
      FOR i IN 1 TO n LOOP
        IF s(i)=LF THEN write(streamiob(stream).buf, string'("")); fflush(stream);
                   ELSE write(streamiob(stream).buf, s(i));
        END IF;
      END LOOP;
    END IF;
    DEALLOCATE(s); --same behavior as write(FILE, LINE);
  END fputs;

  PROCEDURE putc(c: IN CHARACTER; stream: IN CFILE) IS
  BEGIN
    fputc(c, stream);
  END putc;

  PROCEDURE putchar(c: IN CHARACTER) IS
  BEGIN
     fputc(c, stdout);
  END putchar;

  PROCEDURE puts(s: IN STRING) IS
  BEGIN
    fputs(s, stdout); fputc(LF, stdout);
  END puts;

  PROCEDURE puts(s: INOUT LINE) IS
  BEGIN
    fputs(s, stdout); fputc(LF, stdout);
  END puts;

  IMPURE FUNCTION feof(stream: IN CFILE) RETURN BOOLEAN IS
    VARIABLE eof: BOOLEAN:=TRUE;
  BEGIN
    IF stream>0 AND stream<=streamNFILE THEN
      IF streamiob(stream).fstat=OPEN_OK THEN
        CASE stream IS
          WHEN stdin  => eof:=ENDFILE(INPUT);
          WHEN 4      => eof:=ENDFILE(streamfile4);
          WHEN 5      => eof:=ENDFILE(streamfile5);
          WHEN 6      => eof:=ENDFILE(streamfile6);
          WHEN 7      => eof:=ENDFILE(streamfile7);
          WHEN 8      => eof:=ENDFILE(streamfile8);
          WHEN 9      => eof:=ENDFILE(streamfile9);
          WHEN OTHERS => eof:=TRUE;
        END CASE;
      END IF;
    END IF;
    RETURN eof;
  END feof;

  IMPURE FUNCTION fgetc(stream: IN CFILE) RETURN CHARACTER IS
    VARIABLE more: BOOLEAN:=FALSE; VARIABLE c: CHARACTER:=NUL;
    VARIABLE b:    LINE; --workaround for SymphonyEDA 2.3#8
  BEGIN
    ASSERT stream>0 AND stream<=streamNFILE
    REPORT "fgetc(): passed in bad CFILE stream id" SEVERITY FAILURE;
    IF stream>0 AND stream<=streamNFILE THEN
      IF    streamiob(stream).buf=NULL THEN more:=TRUE;
      ELSE
        b:=streamiob(stream).buf; IF b'LENGTH<=0 THEN more:=TRUE; END IF;
      END IF;
      IF more AND streamiob(stream).fstat=OPEN_OK THEN
        more:=feof(stream);
        IF NOT more THEN
          CASE stream IS
          WHEN stdin => readline(input, streamiob(stream).buf);
          WHEN 4     => readline(streamfile4, streamiob(stream).buf);
          WHEN 5     => readline(streamfile5, streamiob(stream).buf);
          WHEN 6     => readline(streamfile6, streamiob(stream).buf);
          WHEN 7     => readline(streamfile7, streamiob(stream).buf);
          WHEN 8     => readline(streamfile8, streamiob(stream).buf);
          WHEN 9     => readline(streamfile9, streamiob(stream).buf);
          WHEN OTHERS =>
          END CASE;
          write(streamiob(stream).buf, LF);
        END IF;
      END IF;

      IF streamiob(stream).buf/=NULL THEN
        b:=streamiob(stream).buf;
        IF b'LENGTH>0 THEN read(streamiob(stream).buf, c); END IF;
      END IF;
    END IF;
    RETURN c;
  END fgetc;

  --The fgets() function reads CHARACTERs from the stream into the STRING s,
  --  until n-1 bytes are read,
  --  or a newline CHARACTER IS read and transferred to s,
  --  or an end-of-file condition IS encountered.
  --  The STRING IS then terminated with a NULL byte.
  --
  PROCEDURE fgets(s: OUT  STRING; n: IN INTEGER; stream: IN CFILE) IS
    VARIABLE i: INTEGER:=1; VARIABLE c: CHARACTER;
  BEGIN
    WHILE i<n AND i<s'LENGTH AND NOT feof(stream) LOOP
      c:=fgetc(stream); s(i):=c; i:=i+1;
      IF c=LF OR c=NUL THEN EXIT; END IF; --fgets(): newline CHARACTER IS not discarded
    END LOOP;
    IF i<s'LENGTH THEN s(i):=NUL; END IF;
  END fgets;

  IMPURE FUNCTION getc(stream: IN CFILE) RETURN CHARACTER IS
  BEGIN
    RETURN fgetc(stream);
  END getc;

  IMPURE FUNCTION getchar RETURN CHARACTER IS
  BEGIN
    RETURN fgetc(stdin);
  END getchar;

  PROCEDURE gets(s: OUT STRING) IS --used FOR console or stdin
    VARIABLE i: INTEGER:=1; VARIABLE c: CHARACTER;
  BEGIN
    WHILE i<s'LENGTH AND NOT feof(stdin) LOOP
      IF c=LF OR c=NUL THEN EXIT; END IF; --gets(): newline CHARACTER IS discarded
      c:=fgetc(stdin); s(i):=c; i:=i+1;
    END LOOP;
    IF i<s'LENGTH THEN s(i):=NUL; END IF;
  END gets;

  PROCEDURE ungetc(c: IN CHARACTER; stream: IN CFILE) IS
    VARIABLE t: LINE;  VARIABLE b: LINE; --workaround for SymphonyEDA 2.3#8
  BEGIN
    ASSERT   stream>0 AND stream<=streamNFILE
    REPORT   "ungetc(): passed in bad CFILE stream id" SEVERITY FAILURE; 
    IF stream/=stdnul THEN
      write(t, c); 
      IF streamiob(stream).buf/=NULL THEN
        b:=streamiob(stream).buf;
        IF b'LENGTH>0 THEN write(t, streamiob(stream).buf.all); END IF;
      END IF;
      DEALLOCATE(streamiob(stream).buf);
      streamiob(stream).buf:=t; --copy pointer
    END IF;
  END ungetc;

  PROCEDURE sbufprintf(fi:  INOUT INTEGER; sbuf: INOUT LINE; stream: IN CFILE;
                       fmt: IN STRING; s: IN STRING) IS

    CONSTANT zero:                CHARACTER:='0';
    VARIABLE c, d, f:             CHARACTER;
    VARIABLE sn, n, m, p, z:      INTEGER;
    VARIABLE ai, i, j, ax:        INTEGER;
    VARIABLE fj:                  INTEGER:=1;
    VARIABLE lflag, aflag, zflag: BOOLEAN;
    VARIABLE nflag, pflag, sflag: BOOLEAN;
    VARIABLE fmtflag:             BOOLEAN:=FALSE;
    VARIABLE m1, m2, m3, m4:      STRING(1 to 256);
    VARIABLE w, buf, wbuf:        LINE;
    VARIABLE wflag:               BOOLEAN:=FALSE;
  BEGIN
    IF stream/=stdnul THEN
    ASSERT   stream=-1 OR (sbuf=NULL AND stream>0 AND stream<=streamNFILE)
    REPORT   "fprintf/printf/sprintf error: passed in bad CFILE stream id or string"
    SEVERITY FAILURE; 
    LOOP
        fj:=fi;
	regmatch(ai, fi, fmt,
	  "^$|\\n|([^%\\][^%\\]*)|%([^scdioxXufeEgGpn%\\]*)(.)|\\0(\\[0-7][0-7]?[0-7]?)|\\(.)",
          m1, m2);


        CASE ai IS --preprocess STRING
          WHEN 5 => ai:=3;
            ax:=0;
            FOR i in 1 to m1'LENGTH LOOP
              ax:=ax*8;
              CASE m1(i) IS
                WHEN '0'=> ax:=ax+0; when '1'=> ax:=ax+1;
                WHEN '2'=> ax:=ax+2; when '3'=> ax:=ax+3;
                WHEN '4'=> ax:=ax+4; when '5'=> ax:=ax+5;
                WHEN '6'=> ax:=ax+6; when '7'=> ax:=ax+7;
                WHEN others =>
              END CASE;
            END LOOP;
            m1(1):=CHARACTER'val(ax);

          WHEN 6 => ai:=3;
            CASE m1(1) IS
		WHEN 'a'=> m1(1):=BEL; when 'b'=> m1(1):=BS;
		WHEN 'f'=> m1(1):=FF;  when 'n'=> m1(1):=LF;
		WHEN 'r'=> m1(1):=CR;  when 't'=> m1(1):=HT;
		WHEN 'v'=> m1(1):=VT;  when others => 
            END CASE;
          WHEN others =>
        END CASE;

	CASE ai IS
	WHEN 1 => EXIT;
	WHEN 2 => write(buf, LF); IF stream>0 THEN fputs(buf, stream); END IF;
	WHEN 3 => write(buf, m1(1 to strlen(m1)));
	WHEN 4 =>
            if fmtflag then fi:=fj; EXIT; end if;
            f:=m2(1); m1(1):=NUL; m2(1):=NUL; m3(1):=NUL; m4(1):=NUL;
            regmatch(ai, fj, fmt,
                     "%([ 0#+-]*)([0-9]*)\.?([0-9]*).", m1, m2, m3, m4);

            --<m1:flags><m2:min print width>.<m3:precision:max strlen><modifier>
            lflag:=FALSE; aflag:=FALSE;
            nflag:=FALSE; pflag:=FALSE; sflag:=FALSE; zflag:=FALSE;

            FOR i in 1 to m1'LENGTH LOOP
              if m1(i)='-' then lflag:=TRUE; end if;
              if m1(i)='+' then pflag:=TRUE; end if;
              if m1(i)=' ' then sflag:=TRUE; end if;
              if m1(i)='0' then zflag:=TRUE; end if;
              if m1(i)='#' then aflag:=TRUE; end if; --ignored in decimal
              if m1(i)=NUL then EXIT;        end if;
            END LOOP;
            if m2(1)=NUL then m:=0; else m:=atoi(m2); end if;


            IF f='x' OR f='o' OR f='X' THEN --unlimited STRING LENGTH
              z:=0; sn:=s'LENGTH; ax:=0; j:=1; n:=0;
              FOR i IN 1 TO s'LENGTH LOOP --skip leading zeros
                IF z=0 AND s(i)='1' THEN z:=i; END IF;
                IF s(i)=NUL         THEN EXIT; END IF; sn:=i;
              END LOOP;
              IF z/=0 THEN
                IF f='o' THEN p:=8; ELSE p:=16; END IF; --fix 20030425
                FOR i IN sn DOWNTO z LOOP --fix 20040528 big endian
                  CASE s(i) IS
                  WHEN ' '|HT => --ignore white space
                  WHEN '1'    => ax:=j+ax; j:=2*j;
                  WHEN OTHERS => j:=2*j;  --0, X, H, L, U, ...
                  END CASE;
                  IF j=p THEN
                    IF f='x' THEN write(w, pf_hex(ax));
                             ELSE write(w, pf_hexx(ax)); END IF; --fix 20040528
                    ax:=0; j:=1; n:=n+1;
                  END IF;
                END LOOP;
              END IF;
              IF ax>0 OR n=0 THEN --residue
                IF f='x' THEN write(w, pf_hex(ax)); ELSE write(w, pf_hexx(ax)); END IF;
                n:=n+1;
              END IF;

              IF zflag AND NOT lflag THEN
                p:=0; IF aflag THEN IF f='o' THEN p:=1; ELSE p:=2; END IF; END IF;
                WHILE n<m-p LOOP write(w, zero); n:=n+1; END LOOP;
              END IF; 
              IF aflag THEN --remember string IS reversed
                IF f='x' OR f='X' THEN write(w, f); n:=n+1; END IF;
                write(w, zero); n:=n+1; --hex or octal
              END IF;
              wflag:=TRUE; --continue on as a STRING
            END IF;

            IF f='d' OR f='i' OR f='u' THEN --big endian signed/unsigned string
              ax:=0; n:=0; IF f='u' THEN p:=0; ELSE p:=1; END IF;
              FOR i IN 1 TO s'LENGTH LOOP
                CASE s(i) IS
                  WHEN NUL    => EXIT; WHEN ' '|HT => --ignore blanks
                  WHEN '1'    => IF p=1 THEN p:=0; nflag:=TRUE; --begin 2's complement
                                 ELSE 
                                   IF nflag THEN ax:=2*ax;   ELSE ax:=2*ax+1; END IF;
                                 END IF;
                  WHEN OTHERS => IF p=1 THEN p:=0;
                                 ELSE 
                                   IF nflag THEN ax:=2*ax+1; ELSE ax:=2*ax; END IF;
                                 END IF;
                END CASE;
              END LOOP;
              IF nflag THEN ax:=ax+1; END IF; --2's complement ax:=(NOT ax)+1;

              LOOP --convert to base 10
                j:=ax MOD 10; write(w, pf_hex(j)); n:=n+1;
                ax:=ax/10; IF ax=0 THEN EXIT; END IF;
              END LOOP;
          
              IF zflag AND NOT lflag THEN
                WHILE n<m-1 LOOP write(w, zero); n:=n+1; END LOOP;
              END IF; 
              IF nflag                             THEN write(w, '-'); n:=n+1; END IF;
              IF pflag AND NOT nflag               THEN write(w, '+'); n:=n+1; END IF;
              IF sflag AND NOT pflag AND NOT nflag THEN
                IF zflag THEN write(w, zero); ELSE write(w, ' '); END IF; n:=n+1;
              END IF;
              IF zflag AND NOT lflag AND n<m       THEN write(w, zero); n:=n+1; END IF;

              wflag:=TRUE;
            END IF;

            IF f='%' THEN write(buf, '%'); END IF;

            IF f='s' OR f='f' OR wflag THEN
              IF f='s' OR f='f' THEN
                n:=strlen(s); write(w, s(1 TO n));
              ELSE --reverse string to big endian
                i:=1; j:=n; WHILE i<j LOOP c:=w(i); w(i):=w(j); w(j):=c; i:=i+1; j:=j-1; END LOOP;
              END IF;

              IF w=NULL    THEN n:=0; ELSE n:=w'LENGTH; END IF;
              IF m3(1)=NUL THEN p:=n; ELSE p:=atoi(m3); END IF;


              IF NOT lflag AND p<m THEN
                write(buf, STRING'(" "), LEFT, m-p);
              END IF;
              IF n<=p    THEN i:=n; ELSE i:=p; END IF;
              IF w/=NULL THEN write(buf, w(1 to i)); END IF;

              IF lflag AND p<m THEN
                write(buf, STRING'(" "), LEFT, m-p);
              END IF;
            END IF;
            IF f/='%' THEN fmtflag:=TRUE; END IF;
	WHEN OTHERS =>
	END CASE;
        DEALLOCATE(w); wflag:=FALSE;
    END LOOP;
    IF stream<0 THEN sbuf:=buf;
    ELSE 
      fputs(buf, stream); DEALLOCATE(buf); DEALLOCATE(sbuf);
    END IF;
    END IF; --NOT stdnul
  END sbufprintf;

  PROCEDURE fprintf2(buf:   INOUT LINE;
                    stream: IN    CFILE;
                    format: IN    STRING;
                    a1,  a2,  a3,  a4,  a5,  a6,  a7,  a8 : in STRING := " ";
                    a9,  a10, a11, a12, a13, a14, a15, a16: in STRING := " "
            ) IS
    VARIABLE fi: INTEGER:=1;
  BEGIN
    ASSERT stream>0 AND stream<=streamNFILE
    REPORT "sprintf/fprintf: passed in bad CFILE stream id" SEVERITY FAILURE;
    if stream/=stdnul THEN
      sbufprintf(fi, buf, stream, format,  a1);
      if  fi<=format'LENGTH then sbufprintf(fi, buf, stream, format,  a2);
      if  fi<=format'LENGTH then sbufprintf(fi, buf, stream, format,  a3);
      if  fi<=format'LENGTH then sbufprintf(fi, buf, stream, format,  a4);
      if  fi<=format'LENGTH then sbufprintf(fi, buf, stream, format,  a5);
      if  fi<=format'LENGTH then sbufprintf(fi, buf, stream, format,  a6);
      if  fi<=format'LENGTH then sbufprintf(fi, buf, stream, format,  a7);
      if  fi<=format'LENGTH then sbufprintf(fi, buf, stream, format,  a8);
      if  fi<=format'LENGTH then sbufprintf(fi, buf, stream, format,  a9);
      if  fi<=format'LENGTH then sbufprintf(fi, buf, stream, format,  a10);
      if  fi<=format'LENGTH then sbufprintf(fi, buf, stream, format,  a11);
      if  fi<=format'LENGTH then sbufprintf(fi, buf, stream, format,  a12);
      if  fi<=format'LENGTH then sbufprintf(fi, buf, stream, format,  a13);
      if  fi<=format'LENGTH then sbufprintf(fi, buf, stream, format,  a14);
      if  fi<=format'LENGTH then sbufprintf(fi, buf, stream, format,  a15);
      if  fi<=format'LENGTH then sbufprintf(fi, buf, stream, format,  a16);
      end if; end if; end if; end if; end if; end if; end if; end if;
      end if; end if; end if; end if; end if; end if; end if;
    END IF;
  END fprintf2;

  PROCEDURE fprintf(stream:  IN CFILE;
                    format:  IN STRING;
                    a1,  a2,  a3,  a4,  a5,  a6,  a7,  a8 : in STRING := " ";
                    a9,  a10, a11, a12, a13, a14, a15, a16: in STRING := " "
             ) IS 
  BEGIN
    fprintf2(streamnulbuf, stream, format, a1,  a2,  a3,  a4,  a5,  a6,  a7,  a8,
                                 a9,  a10, a11, a12, a13, a14, a15, a16);
  END fprintf;

  PROCEDURE fprintf(stream:  IN CFILE;
                    format:  IN STRING;
                    a1:      IN std_logic_vector;
                    a2,  a3,  a4,  a5,  a6,  a7,  a8:        IN std_logic_vector := "U";
                    a9,  a10, a11, a12, a13, a14, a15, a16:  IN std_logic_vector := "U"
             ) IS
  BEGIN
    fprintf2(streamnulbuf, stream, format, pf(a1),pf(a2),pf(a3),pf(a4),pf(a5),pf(a6),pf(a7),pf(a8),
                                 pf(a9),pf(a10),pf(a11),pf(a12),pf(a13),pf(a14),pf(a15),pf(a16));
  END fprintf;

  PROCEDURE printf( format:  IN    STRING;
                    a1,  a2,  a3,  a4,  a5,  a6,  a7,  a8:   IN STRING := " ";
                    a9,  a10, a11, a12, a13, a14, a15, a16:  IN STRING := " "
             ) IS
  begin
    fprintf2(streamnulbuf, stdout, format, a1,a2,a3,a4,a5,a6,a7,a8,
                                     a9,a10,a11,a12,a13,a14,a15,a16);
  END printf;

  PROCEDURE printf( format:  IN    STRING;
                    a1:      IN    std_logic_vector;
                    a2,  a3,  a4,  a5,  a6,  a7,  a8:        IN std_logic_vector := "U";
                    a9,  a10, a11, a12, a13, a14, a15, a16:  IN std_logic_vector := "U"
             ) IS
  begin
    fprintf2(streamnulbuf, stdout, format, pf(a1),pf(a2),pf(a3),pf(a4),pf(a5),pf(a6),pf(a7),pf(a8),
                                     pf(a9),pf(a10),pf(a11),pf(a12),pf(a13),pf(a14),pf(a15),pf(a16));
  END printf;

  PROCEDURE fprintf(stream: IN CFILE; format:  IN    STRING; a1: INOUT LINE) IS
    VARIABLE fi: INTEGER:=1;
  BEGIN
    IF a1/=NULL THEN sbufprintf(fi, streamnulbuf, stream, format, a1.all);
                ELSE sbufprintf(fi, streamnulbuf, stream, format, STRING'("")); END IF;
  END fprintf;

  PROCEDURE printf( format:  IN    STRING; a1: INOUT LINE) IS
    VARIABLE fi: INTEGER:=1;
  BEGIN
    IF a1/=NULL THEN sbufprintf(fi, streamnulbuf, stdout, format, a1.all);
                ELSE sbufprintf(fi, streamnulbuf, stdout, format, STRING'("")); END IF;
  END printf;

  PROCEDURE sprintf(s: INOUT LINE; format: IN STRING; --Appends to LINE variable s by default
                   a1,  a2,  a3,  a4,  a5,  a6,  a7,  a8 : in STRING := " ";
                   a9,  a10, a11, a12, a13, a14, a15, a16: in STRING := " "
           ) IS
  BEGIN
    fprintf2(s, -1, format, a1,  a2,  a3,  a4,  a5,  a6,  a7,  a8,
                            a9,  a10, a11, a12, a13, a14, a15, a16);
  END sprintf;

  PROCEDURE sprintf(s: INOUT STRING; format: IN STRING;
                    a1,  a2,  a3,  a4,  a5,  a6,  a7,  a8 : in STRING := " ";
                    a9,  a10, a11, a12, a13, a14, a15, a16: in STRING := " "
             ) IS
    variable W: LINE; variable i: INTEGER;
  BEGIN
    fprintf2(W, -1, format, a1,  a2,  a3,  a4,  a5,  a6,  a7,  a8,
                            a9,  a10, a11, a12, a13, a14, a15, a16);
    
    i:=1; WHILE i<=w'LENGTH LOOP
      if i<s'LENGTH then s(i):=w(i); i:=i+1; end if;
    END LOOP;
    if i<s'LENGTH then s(i):=NUL; end if;
    DEALLOCATE(W);
  END sprintf;

  PROCEDURE sprintf(s: INOUT STRING; format:  IN    STRING;
                    a1:      IN    std_logic_vector;
                    a2,  a3,  a4,  a5,  a6,  a7,  a8:        IN std_logic_vector := "U";
                    a9,  a10, a11, a12, a13, a14, a15, a16:  IN std_logic_vector := "U"
             ) IS
  BEGIN
    sprintf(s, format, pf(a1),pf(a2),pf(a3),pf(a4),pf(a5),pf(a6),pf(a7),pf(a8),
                       pf(a9),pf(a10),pf(a11),pf(a12),pf(a13),pf(a14),pf(a15),pf(a16));
  END sprintf;

  PROCEDURE sfgetc(c: OUT CHARACTER; stream: IN CFILE; buf: INOUT LINE) IS
  BEGIN
    IF    stream>=0     THEN c:=fgetc(stream);
    ELSIF buf=NULL      THEN c:=NUL;
    ELSIF buf'LENGTH<=0 THEN c:=NUL;
    ELSE                     read(buf, c);
    END IF;
  END sfgetc;

  PROCEDURE sbufscanf(fi:  INOUT INTEGER; sbuf: INOUT LINE; stream: IN    CFILE;
                      fmt: IN    STRING;  s:    INOUT LINE) IS
    VARIABLE xbuf:          LINE;
    VARIABLE c, d, f:       CHARACTER;
    VARIABLE n, m, ms:      INTEGER;
    VARIABLE ai, i, j, ax:  INTEGER;
    VARIABLE fj:            INTEGER:=1;
    VARIABLE sflag, mflag:  BOOLEAN;
    VARIABLE fmtflag:       BOOLEAN:=FALSE;
    VARIABLE m1, m2, m3, m4:STRING(1 to 256);
  BEGIN
    IF stream/=stdnul THEN
    ASSERT   stream=-1 OR (sbuf=NULL AND stream>0 AND stream<=streamNFILE)
    REPORT   "fscanf/scanf/sscanf error: passed in bad CFILE stream id or string"
    SEVERITY FAILURE; 
    sfgetc(c, stream, sbuf);
    LOOP
        fj:=fi; m1(1):=NUL; m2(1):=NUL;
	regmatch(ai, fi, fmt,
          "^$|%%|([^%\\])|%([^scdioxXufeEgGpn%\\]*)(.)|\\0(\\[0-7][0-7]?[0-7]?)|\\(.)",
          m1, m2);


        CASE ai IS
          WHEN 2 => ai:=2; m1(1):='%'; m1(2):=NUL;

          WHEN 5 => ai:=2;
            ax:=0;
            FOR i in 1 to m1'LENGTH LOOP
              ax:=ax*8;
              CASE m1(i) IS
                WHEN '0'=> ax:=ax+0; when '1'=> ax:=ax+1;
                WHEN '2'=> ax:=ax+2; when '3'=> ax:=ax+3;
                WHEN '4'=> ax:=ax+4; when '5'=> ax:=ax+5;
                WHEN '6'=> ax:=ax+6; when '7'=> ax:=ax+7;
                WHEN others =>
              END CASE;
            END LOOP;
            m1(1):=CHARACTER'val(ax); m1(2):=NUL;

          WHEN 6 => ai:=2;
            CASE m1(1) IS
		WHEN 'a'=> m1(1):=BEL; when 'b'=> m1(1):=BS;
		WHEN 'f'=> m1(1):=FF;  when 'n'=> m1(1):=LF;
		WHEN 'r'=> m1(1):=CR;  when 't'=> m1(1):=HT;
		WHEN 'v'=> m1(1):=VT;  when others => 
            END CASE;
            m1(2):=NUL;
          WHEN others =>
        END CASE;

	CASE ai IS
	WHEN 1 => EXIT;
	WHEN 3 => 
            if c/=m1(1) then EXIT; end if;
            WHILE c=' ' LOOP
              sfgetc(c, stream, sbuf);
            END LOOP;
	WHEN 4 =>
            if fmtflag then fi:=fj; EXIT; end if;

            f:=m2(1); m1(1):=NUL; m2(1):=NUL; m3(1):=NUL; m4(1):=NUL;
            regmatch(ai, fj, fmt, "%([*]*)([0-9]*)([lLh]).", m1, m2, m3, m4);

            --<m1:flags><m2:max scanf width><modifier><conversion type>
            sflag:=FALSE;
            FOR i in 1 to m1'LENGTH LOOP
              if m1(i)='*' then sflag:=TRUE; end if; --assignment suppression
              if m1(i)=NUL then EXIT;        end if;
            END LOOP;
            if m2(1)=NUL then m:=0; else m:=atoi(m2); end if;


            if f/='c' then
              WHILE c=' ' OR c=LF OR c=HT OR c=CR OR c=VT LOOP
                sfgetc(c, stream, sbuf);
              END LOOP;
            end if;

            IF f='x' OR f='o' OR f='d' THEN
              if f='x' or f='o' then write(s, STRING'("0")); end if; --20040529, sign bit

              i:=0; ax:=0; ms:=1;
              LOOP
                if m/=0 AND i>=m then EXIT; end if;
                if    i=0 and c='+' then ms:=1;
                elsif i=0 and c='-' then ms:=-1;
                else
                  CASE c IS
                    WHEN '0'    => n:=0;  when '1'    => n:=1;
                    WHEN '2'    => n:=2;  when '3'    => n:=3;
                    WHEN '4'    => n:=4;  when '5'    => n:=5;
                    WHEN '6'    => n:=6;  when '7'    => n:=7;
                    WHEN '8'    => n:=8;  when '9'    => n:=9;
                    WHEN 'a'|'A'=> n:=10; when 'b'|'B'=> n:=11;
                    WHEN 'c'|'C'=> n:=12; when 'd'|'D'=> n:=13;
                    WHEN 'e'|'E'=> n:=14; when 'f'|'F'=> n:=15;
                    WHEN others => EXIT;
                  END CASE;
                  if f='d' then
                    if n>9 then EXIT; else ax:=ax*10+n; end if;
                  else 
                    m1(1 to 4):=pf_hex2(n);
                    if f='o' and n>7 then EXIT; end if;
                    if f='o' and not sflag then write(s, m1(2 to 4)); end if;
                    if f='x' and not sflag then write(s, m1(1 to 4)); end if;
                  end if;
                end if;
                i:=i+1; sfgetc(c, stream, sbuf);
              END LOOP;

              IF f='d' THEN
                strcat(s, pf(ms*ax));
                --m1:=pf(ms*ax); n:=strlen(m1); write(s, m1(1 to n));
                --m1'LENGTH /= pf()'LENGTH
                --mismatched array sizes are a problem in vhdl
                --strcat, strcpy solves the mismatched array size problem
              END IF;
            END IF;

            --if f='%' then write(buf, '%'); end if;

            IF f='s' OR f='f' THEN
              i:=0;
              WHILE c/=' ' AND c/=LF AND c/=HT AND c/=CR AND c/=VT AND c/=NUL LOOP
                if m/=0 AND i>=m then EXIT; end if;
                if not sflag then write(s, c); end if;
                i:=i+1; sfgetc(c, stream, sbuf);
              END LOOP;

            END IF;
            if c/='%' AND not sflag then fmtflag:=TRUE; end if;
	WHEN others =>
	END CASE;
    END LOOP;
    IF stream=-1 THEN --put CHARACTER back into stream
      write(xbuf, c); write(xbuf, sbuf.all); 
      DEALLOCATE(sbuf); sbuf:=xbuf;
    ELSE
      ungetc(c, stream);
    END IF;
    END IF; --NOT stdnul
  END sbufscanf;

  PROCEDURE pf(buf: INOUT LINE; s: INOUT REAL) IS
  BEGIN
    if buf/=NULL then if buf'LENGTH>0 then read(buf, s); end if; end if;
    DEALLOCATE(buf);
  END pf;

  PROCEDURE pf(buf: INOUT LINE; s: INOUT INTEGER) IS
  BEGIN
    if buf/=NULL then if buf'LENGTH>0 then s:=sf(buf.all); end if; end if;
    DEALLOCATE(buf);
  END pf;

  PROCEDURE pf(buf: INOUT LINE; s:  INOUT time) IS
  BEGIN
    if buf/=NULL then if buf'LENGTH>0 then s:=sf(buf.all)*1 ns; end if; end if;
    DEALLOCATE(buf);
  END pf;

  PROCEDURE pf(buf: INOUT LINE; s:  INOUT CHARACTER) IS
  BEGIN
    if buf/=NULL then if buf'LENGTH>0 then s:=buf(1); end if; end if;
    DEALLOCATE(buf);
  END pf;

  PROCEDURE pf(buf: INOUT LINE; s:  INOUT STRING) IS
    VARIABLE i: INTEGER:=1;
  BEGIN
    IF buf/=NULL THEN
      WHILE i<=buf'LENGTH LOOP
        IF i<s'LENGTH THEN s(i):=buf(i); i:=i+1; END IF;
      END LOOP;
    END IF;
    IF i<s'LENGTH THEN s(i):=NUL; END IF;
    DEALLOCATE(buf);
  END pf;

  PROCEDURE pf(buf: INOUT LINE; s:  INOUT bit) IS
  BEGIN
    if buf/=NULL then 
      if buf'LENGTH>0 then if buf(1)='1' then s:='1'; else s:='0'; end if; end if;
    end if;
    DEALLOCATE(buf); 
  END pf;

  PROCEDURE pf(buf: INOUT LINE; s:  INOUT BOOLEAN) IS
  BEGIN
    IF buf/=NULL THEN
      IF buf'LENGTH>0 THEN IF buf(1)='1' THEN s:=TRUE; ELSE s:=FALSE; END IF; END IF;
    END IF;
    DEALLOCATE(buf);
  END pf;

  PROCEDURE pf(buf: INOUT LINE; s:  INOUT bit_vector) IS
    VARIABLE i, j: INTEGER; VARIABLE b: BIT:='0';
  BEGIN
    IF buf/=NULL THEN  --scanf will not alter unread variables
      j:=buf'HIGH;
      FOR i IN s'LOW TO s'HIGH LOOP
        IF j>=buf'LOW THEN IF buf(j)='1' THEN b:='1'; END IF; j:=j-1; END IF;
        s(i):=b; --last b will be for signed extention
      END LOOP;
      DEALLOCATE(buf);
    END IF;
  END pf;

  PROCEDURE pf(buf: INOUT LINE; s:  INOUT std_logic) IS
  BEGIN
    IF buf/=NULL THEN
      IF buf'LENGTH>0 THEN 
        CASE buf(1) IS
          WHEN '1'    => s:='1';
          WHEN '0'    => s:='0';
          WHEN '-'    => s:='-';
          WHEN 'X'|'x'=> s:='X';
          WHEN 'Z'|'z'=> s:='Z';
          WHEN 'H'|'h'=> s:='H';
          WHEN 'L'|'l'=> s:='L';
          WHEN 'W'|'w'=> s:='W';
          WHEN others => s:='U';
        END CASE;
      END IF;
    END IF;
    DEALLOCATE(buf);
  END pf;

  PROCEDURE pf(buf: INOUT LINE; s:  INOUT std_logic_vector) IS
    VARIABLE i, j: INTEGER; VARIABLE b: CHARACTER:='0'; --signed extention bit
  BEGIN
    IF buf/=NULL THEN --scanf will not alter unread variables
      j:=buf'HIGH;
      FOR i IN s'LOW TO s'HIGH LOOP
        IF j>=buf'LOW THEN b:=buf(j); j:=j-1; END IF;
        CASE b IS
          WHEN '1'    => s(i):='1';
          WHEN '0'    => s(i):='0';
          WHEN '-'    => s(i):='-';
          WHEN 'X'|'x'=> s(i):='X';
          WHEN 'Z'|'z'=> s(i):='Z';
          WHEN 'H'|'h'=> s(i):='H';
          WHEN 'L'|'l'=> s(i):='L';
          WHEN 'W'|'w'=> s(i):='W';
          WHEN others => s(i):='U';
        END CASE;
      END LOOP;
      DEALLOCATE(buf);
    END IF;
  END pf;

  PROCEDURE fscanf(stream: IN CFILE; format: IN string; a1: INOUT LINE) IS
    VARIABLE fi: INTEGER:=1;
  BEGIN
    sbufscanf(fi, streamnulbuf, stream, format, a1);
  END fscanf;

  PROCEDURE scanf(format: IN string; a1: INOUT LINE) IS
    VARIABLE fi: INTEGER:=1;
  BEGIN
    sbufscanf(fi, streamnulbuf, stdin, format, a1);
  END scanf;

  PROCEDURE sscanf(s: IN string; format: IN string; a1: INOUT LINE) IS
    VARIABLE fi: INTEGER:=1; VARIABLE w: line:=NEW string'(s);
  BEGIN
    sbufscanf(fi, w, -1, format, a1); deallocate(w);
  END sscanf;

  PROCEDURE printf(format: IN string; a1: string) IS
    VARIABLE fi: INTEGER:=1;
  BEGIN
    sbufprintf(fi, streamnulbuf, stdout, format, pf(a1));
  END printf;

  PROCEDURE printf(format: IN string; a1: integer) IS
    VARIABLE fi: INTEGER:=1;
  BEGIN
    sbufprintf(fi, streamnulbuf, stdout, format, pf(a1));
  END printf;

  PROCEDURE printf(format: IN string; a1: std_logic) IS
    VARIABLE fi: INTEGER:=1;
  BEGIN
    sbufprintf(fi, streamnulbuf, stdout, format, pf(a1));
  END printf;

  PROCEDURE printf(format: IN string; a1: std_logic_vector) IS
    VARIABLE fi: INTEGER:=1;
  BEGIN
    sbufprintf(fi, streamnulbuf, stdout, format, pf(a1));
  END printf;

  PROCEDURE printf(format: IN string; a1: boolean) IS
    VARIABLE fi: INTEGER:=1;
  BEGIN
    sbufprintf(fi, streamnulbuf, stdout, format, pf(a1));
  END printf;

  PROCEDURE printf(format: IN string; a1: bit) IS
    VARIABLE fi: INTEGER:=1;
  BEGIN
    sbufprintf(fi, streamnulbuf, stdout, format, pf(a1));
  END printf;

  PROCEDURE printf(format: IN string; a1: bit_vector) IS
    VARIABLE fi: INTEGER:=1;
  BEGIN
    sbufprintf(fi, streamnulbuf, stdout, format, pf(a1));
  END printf;

  PROCEDURE printf(format: IN string; a1: time) IS
    VARIABLE fi: INTEGER:=1;
  BEGIN
    sbufprintf(fi, streamnulbuf, stdout, format, pf(a1));
  END printf;

  PROCEDURE printf(format: IN string; a1: real) IS
    VARIABLE fi: INTEGER:=1;
  BEGIN
    sbufprintf(fi, streamnulbuf, stdout, format, pf(a1));
  END printf;

  PROCEDURE fprintf(stream: IN CFILE; format: IN string; a1: integer) IS
    VARIABLE fi: INTEGER:=1;
  BEGIN
    sbufprintf(fi, streamnulbuf, stream, format, pf(a1));
  END fprintf;

  PROCEDURE fprintf(stream: IN CFILE; format: IN string; a1: std_logic) IS
    VARIABLE fi: INTEGER:=1;
  BEGIN
    sbufprintf(fi, streamnulbuf, stream, format, pf(a1));
  END fprintf;

  PROCEDURE fprintf(stream: IN CFILE; format: IN string; a1: boolean) IS
    VARIABLE fi: INTEGER:=1;
  BEGIN
    sbufprintf(fi, streamnulbuf, stream, format, pf(a1));
  END fprintf;

  PROCEDURE fprintf(stream: IN CFILE; format: IN string; a1: bit) IS
    VARIABLE fi: INTEGER:=1;
  BEGIN
    sbufprintf(fi, streamnulbuf, stream, format, pf(a1));
  END fprintf;

  PROCEDURE fprintf(stream: IN CFILE; format: IN string; a1: bit_vector) IS
    VARIABLE fi: INTEGER:=1;
  BEGIN
    sbufprintf(fi, streamnulbuf, stream, format, pf(a1));
  END fprintf;

  PROCEDURE fprintf(stream: IN CFILE; format: IN string; a1: time) IS
    VARIABLE fi: INTEGER:=1;
  BEGIN
    sbufprintf(fi, streamnulbuf, stream, format, pf(a1));
  END fprintf;

  PROCEDURE fprintf(stream: IN CFILE; format: IN string; a1: real) IS
    VARIABLE fi: INTEGER:=1;
  BEGIN
    sbufprintf(fi, streamnulbuf, stream, format, pf(a1));
  END fprintf;

  PROCEDURE scanf(format: IN string; a1: INOUT string) IS
    VARIABLE fi: INTEGER:=1; VARIABLE t: LINE;
  BEGIN
    sbufscanf(fi, streamnulbuf, stdin, format, t); pf(t, a1);
  END scanf;

  PROCEDURE scanf(format: IN string; a1: INOUT integer) IS
    VARIABLE fi: INTEGER:=1; VARIABLE t: LINE;
  BEGIN
    sbufscanf(fi, streamnulbuf, stdin, format, t); pf(t, a1);
  END scanf;

  PROCEDURE scanf(format: IN string; a1: INOUT std_logic) IS
    VARIABLE fi: INTEGER:=1; VARIABLE t: LINE;
  BEGIN
    sbufscanf(fi, streamnulbuf, stdin, format, t); pf(t, a1);
  END scanf;

  PROCEDURE scanf(format: IN string; a1: INOUT std_logic_vector) IS
    VARIABLE fi: INTEGER:=1; VARIABLE t: LINE;
  BEGIN
    sbufscanf(fi, streamnulbuf, stdin, format, t); pf(t, a1);
  END scanf;

  PROCEDURE scanf(format: IN string; a1: INOUT boolean) IS
    VARIABLE fi: INTEGER:=1; VARIABLE t: LINE;
  BEGIN
    sbufscanf(fi, streamnulbuf, stdin, format, t); pf(t, a1);
  END scanf;

  PROCEDURE scanf(format: IN string; a1: INOUT bit) IS
    VARIABLE fi: INTEGER:=1; VARIABLE t: LINE;
  BEGIN
    sbufscanf(fi, streamnulbuf, stdin, format, t); pf(t, a1);
  END scanf;

  PROCEDURE scanf(format: IN string; a1: INOUT bit_vector) IS
    VARIABLE fi: INTEGER:=1; VARIABLE t: LINE;
  BEGIN
    sbufscanf(fi, streamnulbuf, stdin, format, t); pf(t, a1);
  END scanf;

  PROCEDURE scanf(format: IN string; a1: INOUT time) IS
    VARIABLE fi: INTEGER:=1; VARIABLE t: LINE;
  BEGIN
    sbufscanf(fi, streamnulbuf, stdin, format, t); pf(t, a1);
  END scanf;

  PROCEDURE scanf(format: IN string; a1: INOUT real) IS
    VARIABLE fi: INTEGER:=1; VARIABLE t: LINE;
  BEGIN
    sbufscanf(fi, streamnulbuf, stdin, format, t); pf(t, a1);
  END scanf;

  PROCEDURE fscanf(stream: IN CFILE; format: IN string; a1: INOUT string) IS
    VARIABLE fi: INTEGER:=1; VARIABLE t: LINE;
  BEGIN
    sbufscanf(fi, streamnulbuf, stream, format, t); pf(t, a1);
  END fscanf;

  PROCEDURE fscanf(stream: IN CFILE; format: IN string; a1: INOUT integer) IS
    VARIABLE fi: INTEGER:=1; VARIABLE t: LINE;
  BEGIN
    sbufscanf(fi, streamnulbuf, stream, format, t); pf(t, a1);
  END fscanf;

  PROCEDURE fscanf(stream: IN CFILE; format: IN string; a1: INOUT std_logic) IS
    VARIABLE fi: INTEGER:=1; VARIABLE t: LINE;
  BEGIN
    sbufscanf(fi, streamnulbuf, stream, format, t); pf(t, a1);
  END fscanf;

  PROCEDURE fscanf(stream: IN CFILE; format: IN string; a1: INOUT std_logic_vector) IS
    VARIABLE fi: INTEGER:=1; VARIABLE t: LINE;
  BEGIN
    sbufscanf(fi, streamnulbuf, stream, format, t); pf(t, a1);
  END fscanf;

  PROCEDURE fscanf(stream: IN CFILE; format: IN string; a1: INOUT boolean) IS
    VARIABLE fi: INTEGER:=1; VARIABLE t: LINE;
  BEGIN
    sbufscanf(fi, streamnulbuf, stream, format, t); pf(t, a1);
  END fscanf;

  PROCEDURE fscanf(stream: IN CFILE; format: IN string; a1: INOUT bit) IS
    VARIABLE fi: INTEGER:=1; VARIABLE t: LINE;
  BEGIN
    sbufscanf(fi, streamnulbuf, stream, format, t); pf(t, a1);
  END fscanf;

  PROCEDURE fscanf(stream: IN CFILE; format: IN string; a1: INOUT bit_vector) IS
    VARIABLE fi: INTEGER:=1; VARIABLE t: LINE;
  BEGIN
    sbufscanf(fi, streamnulbuf, stream, format, t); pf(t, a1);
  END fscanf;

  PROCEDURE fscanf(stream: IN CFILE; format: IN string; a1: INOUT time) IS
    VARIABLE fi: INTEGER:=1; VARIABLE t: LINE;
  BEGIN
    sbufscanf(fi, streamnulbuf, stream, format, t); pf(t, a1);
  END fscanf;

  PROCEDURE fscanf(stream: IN CFILE; format: IN string; a1: INOUT real) IS
    VARIABLE fi: INTEGER:=1; VARIABLE t: LINE;
  BEGIN
    sbufscanf(fi, streamnulbuf, stream, format, t); pf(t, a1);
  END fscanf;

  PROCEDURE sscanf(s: IN string; format: IN string; a1: INOUT string) IS
    VARIABLE fi: INTEGER:=1; VARIABLE t: line; VARIABLE w: line:=NEW string'(s);
  BEGIN
    sbufscanf(fi, w, -1, format, t); pf(t, a1);
    deallocate(w);
  END sscanf;

  PROCEDURE sscanf(s: IN string; format: IN string; a1: INOUT integer) IS
    VARIABLE fi: INTEGER:=1; VARIABLE t: line; VARIABLE w: line:=NEW string'(s);
  BEGIN
    sbufscanf(fi, w, -1, format, t); pf(t, a1);
    deallocate(w);
  END sscanf;

  PROCEDURE sscanf(s: IN string; format: IN string; a1: INOUT std_logic) IS
    VARIABLE fi: INTEGER:=1; VARIABLE t: line; VARIABLE w: line:=NEW string'(s);
  BEGIN
    sbufscanf(fi, w, -1, format, t); pf(t, a1);
    deallocate(w);
  END sscanf;

  PROCEDURE sscanf(s: IN string; format: IN string; a1: INOUT std_logic_vector) IS
    VARIABLE fi: INTEGER:=1; VARIABLE t: line; VARIABLE w: line:=NEW string'(s);
  BEGIN
    sbufscanf(fi, w, -1, format, t); pf(t, a1);
    deallocate(w);
  END sscanf;

  PROCEDURE sscanf(s: IN string; format: IN string; a1: INOUT boolean) IS
    VARIABLE fi: INTEGER:=1; VARIABLE t: line; VARIABLE w: line:=NEW string'(s);
  BEGIN
    sbufscanf(fi, w, -1, format, t); pf(t, a1);
    deallocate(w);
  END sscanf;

  PROCEDURE sscanf(s: IN string; format: IN string; a1: INOUT bit) IS
    VARIABLE fi: INTEGER:=1; VARIABLE t: line; VARIABLE w: line:=NEW string'(s);
  BEGIN
    sbufscanf(fi, w, -1, format, t); pf(t, a1);
    deallocate(w);
  END sscanf;

  PROCEDURE sscanf(s: IN string; format: IN string; a1: INOUT bit_vector) IS
    VARIABLE fi: INTEGER:=1; VARIABLE t: line; VARIABLE w: line:=NEW string'(s);
  BEGIN
    sbufscanf(fi, w, -1, format, t); pf(t, a1);
    deallocate(w);
  END sscanf;

  PROCEDURE sscanf(s: IN string; format: IN string; a1: INOUT time) IS
    VARIABLE fi: INTEGER:=1; VARIABLE t: line; VARIABLE w: line:=NEW string'(s);
  BEGIN
    sbufscanf(fi, w, -1, format, t); pf(t, a1);
    deallocate(w);
  END sscanf;

  PROCEDURE sscanf(s: IN string; format: IN string; a1: INOUT real) IS
    VARIABLE fi: INTEGER:=1; VARIABLE t: line; VARIABLE w: line:=NEW string'(s);
  BEGIN
    sbufscanf(fi, w, -1, format, t); pf(t, a1);
    deallocate(w);
  END sscanf;

end stdio_h;
