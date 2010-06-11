#!/usr/bin/bash
# Why bash: because the source code is free and portable
# http://www.sunfreeware.com
#
set -x
# Warning for cshell users: 'setenv SFXVHDL ModelSimVcom' or 'setenv SFXVHDL SynopsysVhdlan'
./test_sfxvhdl.bash ctype_h debugio_h strings_h stdlib_h regexp_h --dut regexp_h_test
