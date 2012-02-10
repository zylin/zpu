#
# $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/hardware/board_sp605/simulation/Makefile $
# $Date$
# $Author$
# $Revision$
#

library      = work
top          = top

library_list = $(shell cut --field 1 --delimiter=" " --only-delimited vhdl_files.txt | sort --unique)

# http://sourceforge.net/projects/vmk/
VMK = vmk

all: compile simulate


compile: Makefile.msim
	export ANAFLAGS="-quiet -2008"; \
	make -f Makefile.msim | ccze -A


simulate:
	export top=$(top); \
	vsim -quiet -gui $(library).$(top) -do run.do -nowlfmcl -l transcript.log


clean:
	rm -f transcript
	rm -f *.wlf
	rm -f wlf*
	@#
	make -f Makefile.msim clean
	rm -f Makefile.msim
	rm -f .stamp
	rm -rf $(library_list)


# generate Makefile.msim with vmk
Makefile.msim: vhdl_files.txt $(library_list)
	$(VMK) -t modelsim -O -w $(library) -F vhdl_files.txt
	
$(library_list):
	vlib $@
	
