#
# $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/hardware/board_sp605/simulation/Makefile $
# $Date: 2011-09-05 16:49:43 +0200 (Mo, 05. Sep 2011) $
# $Author: lange $
# $Revision: 1240 $
#

library      = work
top          = top

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
	rm -rf $(library) 
	rm -f transcript
	rm -f *.wlf
	rm -f wlf*
	@#
	make -f Makefile.msim clean
	rm -f Makefile.msim
	rm -f .stamp


# default patterns

lib:	$(library)

$(library):
	vlib $(library)


# generate Makefile.msim with vmk
Makefile.msim: vhdl_files.txt lib
	vlib work
	$(VMK) -t modelsim -O -w $(library) -F vhdl_files.txt
	
