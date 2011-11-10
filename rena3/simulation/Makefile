#
# $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/hardware/board_sp605/simulation/Makefile $
# $Date: 2011-09-09 14:11:20 +0200 (Fr, 09. Sep 2011) $
# $Author: lange $
# $Revision: 1246 $
#

library      = rena3
top          = top_tb

library_list = $(shell cut --field 1 --delimiter=" " --only-delimited vhdl_files.txt | uniq)

compile: Makefile.msim
	#make --directory ../software | ccze -A
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
	@# vmk stuff
	make -f Makefile.msim clean
	rm -f Makefile.msim
	for lib in $(library_list); do rm -rf $$lib; done


# generate Makefile.msim with vmk
Makefile.msim: vhdl_files.txt
	for lib in $(library_list); do vlib $$lib; done
	vmk -t modelsim -O -w $(library) -F vhdl_files.txt
	
