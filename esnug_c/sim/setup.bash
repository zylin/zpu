#!/usr/bin/bash
# Why bash: because the source code is free and portable
# http://www.sunfreeware.com
# http://cnswww.cns.cwru.edu/~chet/bash/bashtop.html
#
# File:    setup.bash
# Version: 3.0 (June 6, 2004)
# Source:  http://bear.ces.cwru.edu/vhdl
# Date:    June 6, 2004 (Copyright)
# Author:  Francis G. Wolff   Email: fxw12@po.cwru.edu
# Author:  Michael J. Knieser Email: mjknieser@knieser.com
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 1, or (at your option)
# any later version: http://www.gnu.org/licenses/gpl.html
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#set -x  # remove comment to debug script
if [ "#$1" == "----msdos" -a ! -x /usr/bin/bash.exe ]; then
  echo "Error: bash shell must be located in directory /usr/bin"
  read -p "Make directory and copy bash.exe (y=default/n/q)? "
  if [ "--$REPLY" == "--q" ]; then exit 1; fi;
  if [ "--$REPLY" == "--y" ]; then
    mkdir /usr; mkdir /usr/bin; cp bash.exe /usr/bin
  fi
fi
#echo "$PATH"

#echo "Select VHDL simulator:"
#echo "  1) Synopsys: vhdlan, vhdlsim"
#echo "  2) ModelSim: vcom, vsim"
#echo "  3) Symphony EDA: vhdlp, vhdle"
#echo "  E) quit"
#read -p "Enter number (1/2/3/q): "
#case "--$REPLY" in
#  --1 ) export SFXVHDL="SynopsysVhdlan";;   #for children only! not parents
#  --2 ) export SFXVHDL="ModelSimVcom";;     #for children only! not parents
#  --3 ) export SFXVHDL="SymphonyEDAVhdlp";; #for children only! not parents
#  *   ) echo "quiting"; exit 1;;
#esac
export SFXVHDL="ModelSimVcom"


read -p "Test library files (a=all at once, y=one at a time)? (a/y/n/q): " fin; fin2="y"
if [ "--$fin" == "--y"  -o "--$fin" == "--a" ]; then
  for TLIB in ctype debugio strings endian stdlib regexp ; do
     if [ "--$fin"  == "--y" ]; then read -p "Test library file ${TLIB}_h.vhd? (y=default/n): " fin2; fi
     if [ "--$fin2" == "--q" ]; then exit 1; fi
     if [ "--$fin2" == "--y" -o "--$fin2" == "--" ]; then
        cd test; ./${TLIB}_h_test.bash; E=$?; cd .. 
        if [ "$E" == "0" ]; then echo "passed";
        else
          echo "-------------------------------------------------------"
          echo "failed: see file=./test/${TLIB}_h_test_xxx_dut_diff.txt";
          echo "-------------------------------------------------------"
          read -p "continue (y/n)? "; if [ "--$REPLY" == "--n" ]; then exit 1; fi
        fi
     fi
  done
fi

echo -n  "Last stdio_h version "
grep 'generated on' ./source/stdio_h.vhd
echo
read -p "Generate a new stdio_h.vhd file? (y/n=default/q): "
if [ "--$REPLY" == "--q" ]; then exit 1; fi
if [ "--$REPLY" == "--y" ]; then

  read -p "Maximum args to for printf(format, arg1, arg2, ...); (1=default): " maxargs
  if [ "--$maxargs" == "--q" ]; then exit 1; fi
  if [ "--$maxargs" == "--"  ]; then maxargs=1; fi

  debugf="";
  read -p "Enable stdio_h.vhd file debugging flags (y/n=default)? "
  if [ "--$REPLY" == "--q" ]; then exit 1; fi
  if [ "--$REPLY" == "--y" ]; then debugf="--debug"; fi

  cd source_make; ./stdio_h.bash --maxargs=$maxargs $debugf ; cd ..
  cp -p source_make/stdio_h.vhd source
fi
read -p "Test stdio_h.vhd file? (y=default/n): "
if [ "--$REPLY" == "--q" ]; then exit 1; fi
if [ "--$REPLY" == "--y" -o "--$REPLY" == "--" ]; then
  cd test; ./stdio_h_test.bash; E=$?; cd ..
  if [ "$E" == "0" ]; then echo "passed"; else echo "failed: see file=stdio_h_test_xxx_diff.txt"; exit 1; fi
fi 

if [ "--$1" != "----msdos" ]; then
  read -p "Optional(requires mkfifo, ps, kill): Test pipes using inlet.c file? (y/n=default): "
  if [ "--$REPLY" == "--q" ]; then exit 1; fi
  if [ "--$REPLY" == "--y" ]; then
    cd test; ./inlet_test.bash; E=$?; cd ..
    if [ "$E" == "0" ]; then echo "passed"; else echo "failed: see file=inlet_test_xxx_diff.txt"; exit 1; fi
  fi 
fi

echo
echo "Warning: cleanup uses the powerful 'rm' command in ./test/cleanup.bash"
echo "If you are not sure then clean up the files yourself in ./test"
read -p "cleanup temporary files generated during test (y/n=default)? "
if [ "--$REPLY" == "--q" ]; then exit 1; fi
if [ "--$REPLY" == "--y" ]; then cd test; ./cleanup.bash; cd ..; fi

