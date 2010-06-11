#!/usr/bin/bash
# Why bash: because the source code is free and portable
# http://www.sunfreeware.com
#
# File: cleanup.bash
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
set -x
rm core
rm a.out
rm *_diff.txt 
rm *_log.txt 
rm *_dut.txt
rm *_temp_cmd.txt
rm xxx_*
rm pipe*
rm *.wlf
rm -r C
rm -r WORK     #synopsys
rm -r work     #modelsim
rm -r WORK.SYM #symphony eda
rm -r C.SYM    #symphony eda
