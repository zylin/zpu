library      = zpu

rtl_files    =  ../rtl_tb/txt_util.vhd \
		../rtl/zpu_config.vhd \
		../rtl/zpupkg.vhd \
		../rtl/zpu_wrapper_package.vhd \
		../rtl/trace.vhd \
		../rtl/zpu_wrapper.vhd \
		../rtl/dualport_ram.vhd \
		../rtl/zpu_ahb.vhd \
		../rtl/zpu_core.vhd \
		../rtl/timer.vhd \
		../rtl/zpu_bus_trace.vhd \
		../rtl/zpu_io.vhd

rtl_tb_files = ../rtl_tb/sim_small_fpga_top_noint.vhd

vhdlfiles    = $(rtl_files) $(rtl_tb_files) 
vhdltargets  := $(foreach n, $(vhdlfiles), ./$(library)/$(basename $(notdir $n))/_primary.dat)

help:
	@echo "defined targets:"
	@echo
	@echo "sim       - simulation"
	@echo "lib       - generate library"
	@echo "compile   - ..."
	@echo "clean     - clean up"
	@echo



compile: lib deplibs $(vhdltargets)

deplibs:
	make compile --directory ../../grlib/sim

$(vhdltargets): $(vhdlfiles)
	vcom -quiet -2008 -work $(library) $(vhdlfiles)


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
