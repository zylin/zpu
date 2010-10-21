/*
-- File:    inlet.c
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
*/

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <strings.h>

int aflag=0, pflag=2, vflag=0;
int ropen(char *fname) {
  int  fin;
  if    (vflag) { fprintf(stderr, "inlet: fin=open(\"%s\", O_RDONLY, 0);\n", fname); }
  fin = open(fname, O_RDONLY, 0); if (vflag) { fprintf(stderr, "inlet: fin=%d\n", fin); }
  if (fin<0) {
    fprintf(stderr, "inlet: open(%s, O_RDONLY, 0) error\n", fname); exit(1);
  }
  return fin;
}
int wopen(char *fname) {
  int fout;
  if    (vflag) { fprintf(stderr, "inlet: fout=open(\"%s\", O_WRONLY, 0666);\n", fname); }

  fout=(!strcmp(fname, "-"))?1:open(fname, O_WRONLY, 0666); 
  if (vflag) { fprintf(stderr, "inlet: fout=%d\n", fout); }
  if (fout<0) {
    fprintf(stderr, "inlet: open(%s, O_WRONLY, 0666) error\n", fname); exit(1);
  }
  return fout;
}
int main(int argc, char *argv[]) {
  int fin=-1, fout=-1, f=0; char buf[8192], xstring[128]="";
  int rlen, wlen, blen=512, argi, r=0, w=0;

  for(argi=1; argi<argc || argc==1; argi++) {
    if (argc==1 || !strcmp(argv[argi], "--help")) {
      fprintf(stderr, "inlet    [-v|-a|-bN|-p1|-p2|--help] <pipename1 in> [-|<pipename2 out>]\n");
      fprintf(stderr, "Flags:   -v=verbose; -bN=N byte buffer (i.e. -b512); -pN=open pipe N first\n");
      fprintf(stderr, "         -a=always reopen p1 even if p1 closes (note: p2 will never close)\n");
      fprintf(stderr, "Info:    inlet reads from pipe1 to pipe2; if pipe1 closes it is reopened automatically.\n"); 
      fprintf(stderr, "Purpose: Trick an application into believing that it is reading from a single file (i.e. pipe2):\n");
      fprintf(stderr, "           1) when in fact multiple writers are dynamically opening and closing to pipe1.\n"); 
      fprintf(stderr, "           2) or from a remote shell (i.e. rsh) or remote machine\n"); 
      fprintf(stderr, "         while pipe2 is always kept open by the inlet program.\n"); 
      fprintf(stderr, "Notes:   Pipes can be created by the mkfifo command.\n"); 
      fprintf(stderr, "         Each pipe open is sequentially suspended (i.e. blocked) until another task accesses it.\n"); 
      fprintf(stderr, "         O_NDELAY and O_NONBLOCK are not used by inlet (see unix \"man -s 2 open\")\n");
      fprintf(stderr, "Example: mkfifo p1 p2; inlet -v -a p1 p2 & ; cat p2 & ; echo hello >p1; echo Konichiwa >p1;\n"); 
      fprintf(stderr, "\n"); 
      exit(1);
    }
    else if (!strcmp(argv[argi],  "-v"))    {  vflag=1; }
    else if (!strcmp(argv[argi],  "-a"))    {  aflag=1; }
    else if (!strncmp(argv[argi], "-b", 2)) {  blen=atoi(argv[argi]+2);  }
    else if (!strcmp(argv[argi],  "-p1"))   {  pflag=1; }
    else if (!strcmp(argv[argi],  "-p2"))   {  pflag=2; }
    else if ( strncmp(argv[argi], "-",  1) || strlen(argv[argi])>1) {
      if      (f==0) { f++; r=argi; }
      else if (f==1) { f++; w=argi; }
      else           { fprintf(stderr, "inlet: unexpected pipename or filename \"%s\"\n", argv[argi]); exit(1); }
    }
  } 
  if (f!=2) { fprintf(stderr, "inlet: missing in or out pipe names\n"); exit(1); }

  if    (vflag) { fprintf(stderr, "inlet: bufsize=%d (-b%d)\n", blen, blen); }

  if (pflag==1) { fin=ropen(argv[r]);  fout=wopen(argv[w]); }
  else          { fout=wopen(argv[w]); fin=ropen(argv[r]); }

  if (vflag) { 
    fprintf(stderr, "inlet: start reading pipe \"%s\" writing to \"%s\"\n", argv[r], argv[w]);
  }
  for(;;) {
    rlen = read(fin, buf, blen);
    if (vflag) { fprintf(stderr, "inlet: %d=read(\"%s\",buf,%d bytes);\n", rlen, argv[r], blen); }

    if      (rlen==0) { close(fin); if (aflag) { fin=ropen(argv[r]); } else { break; } /* eof on pipe1 */ }
    else if (rlen<0) { 
      if (vflag) { fprintf(stderr, "inlet: read error from \"%s\"\n", rlen, argv[r]); }
      perror("inlet: read"); return 1; 
    }

    wlen=write(fout, buf, rlen);
    if (vflag) { fprintf(stderr, "inlet: %d=write(\"%s\",buf,%d bytes);\n", wlen, argv[w], rlen); }
    if (wlen != rlen) {
      if (vflag) { fprintf(stderr, "inlet: write(\"%s\") length %d != read length %d\n", argv[w], wlen, rlen); }
      perror("inlet: write"); return 1;
    }
  }
  return 0;
}

