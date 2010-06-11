-- File:    inlet_test.vhd
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
USE     STD.TEXTIO.ALL;
Library IEEE;
USE     IEEE.std_logic_1164.all;
LIBRARY C;
USE     C.strings_h.all;
USE     C.stdio_h.all;

entity inlet_test is
end;

architecture inlet_test_arch of inlet_test is
begin
  process
    variable s, s1, s2:      string(1 to 256);
    variable fout:           CFILE; --FILE fout: text;
    variable fin:            CFILE; --FILE fin:  text;
    variable buf:  line;
  begin

    --fp:=fopen("pipe1", "w");
    --  fprintf(fout, "  hello,");
    --  fprintf(fout, "  world\n 123 9bc\n");
    --  fputc('%', fout);
    --  fputs("xyz++abc" & LF, fout); --"\n" will not work here!
    --  fprintf(fout, "***");
    --  fputc('%', fout);
    --  fputs("...def 555" & LF, fout);
    --fclose(fout);

    --mkfifo pipe1
    --mkfifo pipe2
    --inlet pipe1 pipe2
    --in another window run the data driver application: netpackets >pipe1
    --for a simple interactive example: cat >pipe1
    --run simulation
    --ps -a | grep inlet
    --kill -9 <inlet process id>
   
    printf("--begin test;\n"); 
    fout:=fopen("CON", "w");
    printf("fin:=fopen(inlet_out, w); fout=%d\n", fout);
    --fin:=fopen("inlet_test_file.txt", "r"); --file_open(fin, "pipe2", READ_MODE);
    fin:=fopen("pipe2", "r"); --file_open(fin, "pipe2", READ_MODE);
    printf("fin:=fopen(pipe2, r); fin=%d\n", fin);
    if fin=0 then
      printf("fopen(pipe2, r): could not open pipe2\n");
    else
      for i in 1 to 4 loop --even though there are 5 items in the pipe
        fscanf(fin, "%s", s);
        fprintf(fout, "vhdl external input: s=%s\n", s);
        if feof(fin) then
          printf("*** Premature EOF on input file fin has occurred ***\n");
          printf("*** This simulator version may not have properly implemented pipes ***\n");
          exit;
        end if;
      end loop;
      fclose(fin);
      fclose(fout);
    end if;
    printf("--end test;\n"); 

    wait;
  end process;
end;

configuration inlet_test_cfg of inlet_test is
  for inlet_test_arch
  end for;
end;
