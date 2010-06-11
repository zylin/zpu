#!/usr/bin/bash
# Why bash: because the source code is free and portable
# http://www.sunfreeware.com
#
set -x
# Warning for cshell users: 'setenv SFXVHDL ModelSimVcom' or 'setenv SFXVHDL SynopsysVhdlan'
./test_sfxvhdl.bash ctype_h --dut ctype_h_test

