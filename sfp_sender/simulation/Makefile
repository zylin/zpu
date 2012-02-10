#
# $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/hardware/board_sp605/simulation/Makefile $
# $Date$
# $Author$
# $Revision$
#

library      = sfp_sender
top          = top_tb
software_dir = ../software

# http://sourceforge.net/projects/vmk/
VMK = vmk

# generate list of used libs
LIBS = $(shell cut vhdl_files.txt --field 1 --delimiter=' ' | uniq)



all: compile simulate


compile: Makefile.msim
	test -d $(software_dir) && make --directory $(software_dir) | ccze -A
	export ANAFLAGS="-quiet -2008"; \
	make -f Makefile.msim | ccze -A


simulate:
	export top=$(top); \
	vsim -quiet  -gui work.$(top) -do run.do -nowlfmcl -l transcript.log


clean:
	@# sim stuff
	rm -f transcript.log
	rm -f *.wlf
	rm -f wlf*
	@# compile stuff
	-make -f Makefile.msim clean
	@for LIB in $(LIBS) ; do rm -rf $$LIB ; done
	rm -f Makefile.msim
	rm -f .stamp


# generate Makefile.msim with vmk
Makefile.msim: vhdl_files.txt
	@for LIB in $(LIBS) ; do vlib $$LIB ; done
	$(VMK) -t modelsim -O -w $(library) -F vhdl_files.txt


