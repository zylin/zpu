#!/usr/bin/bash
# Why bash: because the source code is free and portable
# http://www.sunfreeware.com
#
# File:    test_sfxvhdl.bash
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
set -x
DUTVHDL="xxx"
DUT=""
LIBVHDL="C"
DIRVHDL="../../rtl"
DIRVHDLTB="../../rtl_tb"

case "--${SFXVHDL}" in
  "--ModelSimVcom" )
       rm -r ${LIBVHDL}; vlib ${LIBVHDL} #rm -r work; vlib work; vmap -c;  MODELSIM=.;
       ;;
  "--SynopsysVhdlan" ) 
       rm -r ${LIBVHDL}; mkdir ${LIBVHDL};
       rm -r WORK;	  mkdir WORK;
       ;;
  "--SymphonyEDAVhdlp" )
       rm -r ${LIBVHDL}.SYM; #mkdir ${LIBVHDL};
       rm -r WORK.SYM;       #mkdir WORK;
       ;;     
  * )
       echo "Error: Environmental variable SFXVHDL not set or unknown ${SFXVHDL}"
       echo "       cshell: setenv SFXVHDL ModelSimVcom"
       echo "       cshell: setenv SFXVHDL SynopsysVhdlan"
       echo "       cshell: setenv SFXVHDL SymphonyEDAVhdlp"
       exit
esac

while [ ! -z "${1}" ]; do
  DUTVHDL=""
  if [ "${1}" == "--dut" ]; then
    shift; DUTVHDL="${DIRVHDLTB}/${1}"; DT="${1}"; DUTLIB=""; DUT="${DUTVHDL}";
  else
    DUTVHDL="${DIRVHDL}/${1}"; DT="${1}"; DUTLIB="-work ${LIBVHDL}"
  fi

  case "--${SFXVHDL}" in
    "--ModelSimVcom"     ) vcom -93 -work ${LIBVHDL}  ${DUTVHDL}.vhd ;;
    "--SynopsysVhdlan"   ) vhdlan -NOEVENT ${DUTLIB}  ${DUTVHDL}.vhd ;;
    "--SymphonyEDAVhdlp" ) vhdlp -x ${DUTLIB}  ${DUTVHDL}.vhd ;;
    *                    ) echo "Error: variable SFXVHDL not set"; exit 2 ;;
  esac
  #E=$?; if [ $E != 0 ]; then exit $E; fi

  shift
done

if [ -z "${DUT}" ]; then echo "Error: missing --dut <test file>"; exit 1; fi

ee=0;
case "--${SFXVHDL}" in
  "--ModelSimVcom" )
       echo -ne "run\nquit\n" >vsim_temp_cmd.txt
       vsim -lib ${LIBVHDL} -l ${DT}_vsim_log.txt -c -do vsim_temp_cmd.txt ${LIBVHDL}.${DT}_cfg >${DT}_vsim_dut.txt
       rm vsim_temp_cmd.txt

      #version independant comparison
      sed -e '1,$s/^\# //;1,/--begin/d;/--end test/,$d' ${DT}_vsim_dut.txt >${DT}_vsim_dut_diff.txt
      sed -e '1,$s/^\# //;1,/--begin/d;/--end test/,$d' ${DT}_vsim_ate.txt >${DT}_vsim_ate_diff.txt
      if [ ! -s ${DT}_vsim_dut_diff.txt ]; then ee=1; fi
      if [ ! -s ${DT}_vsim_ate_diff.txt ]; then ee=1; fi
      diff ${DT}_vsim_dut_diff.txt ${DT}_vsim_ate_diff.txt
      if [ $? != 0 ]; then echo "*** ModelSim difference ERROR in file ${DUTVHDL}.vhd ***"; exit 1; fi 

      sed -e '1,/--begin/d;/--end test/,$d' ${DT}_vhdle_ate.txt >${DT}_vhdle_ate_diff.txt
      if [ ! -s ${DT}_vhdle_ate_diff.txt ]; then ee=1; fi
      diff ${DT}_vsim_dut_diff.txt ${DT}_vhdle_ate_diff.txt
      if [ $? != 0 -o $ee == 1 ]; then echo "*** vhdle (Synopsys) difference ERROR in file ${DUTVHDL}.vhd ***"; exit 1; fi
      ;;
  "--SynopsysVhdlan" )
      echo -ne "run\nquit\n" >vss_temp_cmd.txt
      vhdlsim -i vss_temp_cmd.txt -o ${DUTVHDL}_vss_dut.txt ${DUTVHDL}_cfg
      rm -fr WORK ${LIBVHDL} vss_temp_cmd.txt

      #version independant comparison
      sed -e '1,/--begin/d;/--end test/,$d' ${DUTVHDL}_vss_dut.txt >${DUTVHDL}_vss_dut_diff.txt
      sed -e '1,/--begin/d;/--end test/,$d' ${DUTVHDL}_vss_ate.txt >${DUTVHDL}_vss_ate_diff.txt
      if [ ! -s ${DUTVHDL}_vss_dut_diff.txt ]; then ee=1; fi
      if [ ! -s ${DUTVHDL}_vss_ate_diff.txt ]; then ee=1; fi
      diff ${DUTVHDL}_vss_dut_diff.txt ${DUTVHDL}_vss_ate_diff.txt
      if [ $? != 0 -o $ee == 1 ]; then echo "*** Synopsys difference ERROR in file ${DUTVHDL}.vhd ***"; exit 1; fi
      ;;
  "--SymphonyEDAVhdlp" )
      vhdle -work work ${DUTVHDL}_cfg >${DUTVHDL}_vhdle_dut.txt

      #version independant comparison
      sed -e '1,/--begin/d;/--end test/,$d' ${DUTVHDL}_vhdle_dut.txt >${DUTVHDL}_vhdle_dut_diff.txt
      sed -e '1,/--begin/d;/--end test/,$d' ${DUTVHDL}_vss_ate.txt >${DUTVHDL}_vss_ate_diff.txt
      if [ ! -s ${DUTVHDL}_vhdle_dut_diff.txt ]; then ee=1; fi
      if [ ! -s ${DUTVHDL}_vss_ate_diff.txt ]; then ee=1; fi
      diff ${DUTVHDL}_vhdle_dut_diff.txt ${DUTVHDL}_vss_ate_diff.txt
      if [ $? != 0 -o $ee == 1 ]; then echo "*** Synopsys difference ERROR in file ${DUTVHDL}.vhd ***"; exit 1; fi
      ;;
  *  ) echo "Error: variable SFXVHDL not set"; exit 2 ;;
esac

#vi ${DUTVHDL}.txt

