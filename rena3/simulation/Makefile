#
# $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/hardware/board_sp605/simulation/Makefile $
# $Date$
# $Author$
# $Revision$
#

library      = rena3
top          = top_tb

software_dir = ../software


# http://sourceforge.net/projects/vmk/
VMK = vmk

# generate list of used libs
library_list = $(shell cut --field 1 --delimiter=" " --only-delimited vhdl_files.txt | sort --unique)


all: compile simulate

software:
	test ! -d $(software_dir) || make --directory $(software_dir) | ccze -A

compile: Makefile.msim
	export ANAFLAGS="-quiet -2008"; \
	make -f Makefile.msim | ccze -A


simulate:
	export top=$(top); \
	vsim -quiet  -gui $(library).$(top) -do run.do -l transcript.log


clean:
	@# modelsim stuff
	rm -f transcript.log
	rm -f *.wlf
	rm -f wlf*
	@# compile stuff
	-make -f Makefile.msim clean
	rm -rf $(library_list)
	rm -f Makefile.msim
	rm -f .stamp


# generate Makefile.msim with vmk
Makefile.msim: software vhdl_files.txt $(library_list)
	$(VMK) -t modelsim -O -w $(library) -F vhdl_files.txt

$(library_list):
	vlib $@
	
