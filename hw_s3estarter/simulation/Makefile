library      = s3estarter
top          = top_tb

verilogfiles = ../rtl_tb/ddr.v

software_dir = ../software/test
#software_dir = ../software/ethernet_speed



# http://sourceforge.net/projects/vmk/
VMK = vmk

# generate list of used libs
library_list = $(shell cut vhdl_files.txt --field 1 --delimiter=' ' | sort --unique)




all: compile simulate



compile: Makefile.msim 
	test ! -d $(software_dir) || make --directory $(software_dir) | ccze -A
	export ANAFLAGS="-quiet -2008"; \
	make -f Makefile.msim | ccze -A


simulate:
	export top=$(top); \
	vsim -quiet -gui $(library).$(top) -do run.do -l transcript.log


clean:
	@# sim stuff
	rm -f transcript.log
	rm -f *.wlf
	rm -f wlf*
	@# compile stuff
	-make -f Makefile.msim clean
	rm -rf $(library_list)
	rm -f Makefile.msim
	rm -f .stamp


# generate Makefile.msim with vmk
Makefile.msim: vhdl_files.txt $(library_list)
	$(VMK) -t modelsim -O -w $(library) -F vhdl_files.txt

$(library_list):
	vlib $@
	
