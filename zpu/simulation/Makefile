library      = zpu


# http://sourceforge.net/projects/vmk/
VMK = vmk

# generate list of used libs
library_list = $(shell cut --field 1 --delimiter=" " --only-delimited vhdl_files.txt | grep --invert "\#" | sort --unique)


help:
	@echo "defined targets:"
	@echo
	@echo "simulate  - simulation"
	@echo "compile   - ..."
	@echo "clean     - clean up"
	@echo



compile: Makefile.msim
	export ANAFLAGS="-quiet -2008"; \
	make -f Makefile.msim | ccze -A

simulate:
	export top=$(top); \
	vsim -quiet -gui -do run.do  -l transcript.log

clean:
	rm -f transcript.log
	rm -f *.wlf
	rm -f trace.txt
	rm -f log.txt
	-make -f Makefile.msim clean
	rm -rf $(library_list)
	rm -f Makefile.msim
	rm -f .stamp

# generate Makefile.msim with vmk
Makefile.msim: vhdl_files.txt $(library_list)
	$(VMK) -t modelsim -O -w $(library) -F vhdl_files.txt

$(library_list):
	vlib $@
	
	
