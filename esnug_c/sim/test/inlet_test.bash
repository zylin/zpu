#!/usr/bin/bash
# Why bash: because the source code is free and portable
# http://www.sunfreeware.com
#
set -x
VHDL_TEST="inlet_test"
VHDL_LIB_DEFAULT="C"

if [   -e pipe1         ]; then rm -f pipe1; fi
if [   -e pipe2         ]; then rm -f pipe2; fi

gcc ../source/inlet.c -o ../test/inlet

#Is pipe1 a fifo pipe?
if [ ! -p "./pipe1" ]; then mkfifo pipe1; fi
if [ ! -p "./pipe2" ]; then mkfifo pipe2; fi

./inlet ./pipe1 ./pipe2 &

cat inlet_test_file.txt > pipe1 &

# Warning for cshell users: 'setenv SFXVHDL ModelSimVcom' or 'setenv SFXVHDL SynopsysVhdlan'
./test_sfxvhdl.bash ctype_h strings_h stdlib_h regexp_h stdio_h --dut inlet_test

#kill the pipe
### solaris specific command "ps -af"
/usr/bin/ps -af
kill -9 `/usr/bin/ps -af | grep 'inlet [^p]*pipe1 [^p]*pipe2' | awk '{ print $2 }'`
rm -f pipe1 pipe2
rm -f ./inlet

