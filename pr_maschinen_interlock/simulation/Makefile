
library      = work
#top          = system_tb
top          = channel_tb

library_list = $(shell cut --field 1 --delimiter=" " --only-delimited vhdl_files.txt | sort --unique)

# http://sourceforge.net/projects/vmk/
VMK = vmk

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
	@# vmk stuff
	make -f Makefile.msim clean
	rm -f Makefile.msim
	rm -rf $(library_list)


# generate Makefile.msim with vmk
Makefile.msim: vhdl_files.txt $(library_list)
	$(VMK) -t modelsim -O -w $(library) -F vhdl_files.txt

$(library_list):
	vlib $@
	
	
