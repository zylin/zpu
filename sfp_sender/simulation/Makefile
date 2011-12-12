#
# $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/hardware/board_sp605/simulation/Makefile $
# $Date: 2011-09-09 14:11:20 +0200 (Fr, 09. Sep 2011) $
# $Author: lange $
# $Revision: 1246 $
#

library      = sfp_sender
top          = top_tb

# http://sourceforge.net/projects/vmk/
VMK = vmk

all: compile simulate


compile: Makefile.msim
	make --directory ../software | ccze -A
	export ANAFLAGS="-quiet -2008"; \
	make -f Makefile.msim | ccze -A


simulate:
	export top=$(top); \
	vsim -quiet  -gui work.$(top) -do run.do -nowlfmcl -l transcript.log


clean:
	rm -rf $(library) 
	rm -f transcript
	rm -f *.wlf
	rm -f wlf*
	@#
	make -f Makefile.msim clean
	rm -rf work
	rm -rf techmap
	rm -rf grlib
	rm -rf zpu
	rm -rf gaisler
	rm -rf opencores
	rm -f Makefile.msim
	rm -f .stamp


# generate Makefile.msim with vmk
Makefile.msim: vhdl_files.txt
	vlib work
	vlib techmap
	vlib grlib
	vlib zpu
	vlib gaisler
	vlib opencores
	$(VMK) -t modelsim -O -w $(library) -F vhdl_files.txt
	
