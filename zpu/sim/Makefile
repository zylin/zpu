library      = zpu

rtl_files    = \
		../rtl_tb/txt_util.vhd \
		../rtl/zpu_config.vhd \
		../rtl/zpupkg.vhd \
		../rtl/zpu_wrapper_package.vhd \
		../rtl/*.vhd
rtl_tb_files = ../rtl_tb/*.vhd
vhdlfiles    = $(rtl_files) $(rtl_tb_files) 

help:
	@echo "defined targets:"
	@echo
	@echo "sim       - simulation"
	@echo "lib       - generate library"
	@echo "compile   - ..."
	@echo "clean     - clean up"
	@echo

remake: lib Makefile.$(library)

Makefile.$(library): $(vhdlfiles) $(library)
	vcom -quiet -2008 -work $(library) $(vhdlfiles)
	vmake $(library) > Makefile.$(library)
	# patch winpath -> cygpath
	sed -e 's/\(C:.*\)/$$(shell cygpath --unix "\1" | sed "s\/ \/\\\\\\\\ \/g" )/g' -i Makefile.$(library)


compile:
	make compile --directory ../../grlib/sim
	make -f Makefile.$(library)

sim:
	vsim -gui -do run.do

clean:
	rm -rf $(library) 
	rm -f transcript
	rm -f *.wlf
	rm -f trace.txt
	rm -f log.txt
	rm -f Makefile.$(library)

# default patterns

lib:	$(library)


$(library):
	vlib $(library)
