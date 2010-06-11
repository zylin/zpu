#!/usr/bin/bash
# Why bash: because the source code is free and portable
# http://www.sunfreeware.com
#
set -x

#use install program
#
#cd ../source_make
#./stdio_h.bash
#cd ../test

#if [ -f ../source_make/stdio_h.vhd]; then
#  rm -f ../source/stdio_h.vhd
#  cp ../source_make/stdio_h.vhd ../source/stdio_h.vhd
#fi

./test_sfxvhdl.bash strings_h ctype_h stdlib_h regexp_h stdio_h --dut stdio_h_test
