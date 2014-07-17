#
# $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/trunk/hardware/board_prototyp1/simulation/Makefile $
# $Date: 2013-08-26 14:18:45 +0200 (Mo, 26. Aug 2013) $
# $Author: lange $
# $Revision: 2646 $
#

library      = work
top          = top_tb

software_dir = ../software


# http://sourceforge.net/projects/vmk/
VMK = vmk

# generate list of used libs
library_list = $(shell cut --field 1 --delimiter=" " --only-delimited ../vhdl_files.txt | grep --invert "\#" | sort --unique)
#library_list += $(shell cut --field 1 --delimiter=" " --only-delimited ../verilog_files.txt | grep --invert "\#" | sort --unique)

# list of verilog files
#vlog_list = $(shell cut --field 3 --delimiter=" " --only-delimited ../verilog_files.txt | grep --invert "\#" | sort --unique)


all: compile

software:
	test ! -d $(software_dir) || make --directory $(software_dir) | ccze -A

hw_timestamp:
	test ! -f ../rtl/Makefile || make --directory ../rtl

compile: hw_timestamp Makefile.msim
	@# compile DDR3 memory model stuff
	#vlog -work nanya +define+x16 +define+sg15f +incdir++../rtl_tb $(vlog_list)
	@# normal vhdl compile
	export ANAFLAGS="-quiet -2008"; \
	make -f Makefile.msim | ccze -A
	@echo "Start the simulation with \"make simulate\" now."


simulate:
	#mkdir -p data
	export top=$(top); \
	vsim -quiet -novopt -gui $(library).$(top) -do run.do -l transcript.log


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
Makefile.msim: software ../vhdl_files.txt $(library_list)
	$(VMK) -t modelsim -O -w $(library) -F ../vhdl_files.txt

$(library_list):
	vlib $@
	
