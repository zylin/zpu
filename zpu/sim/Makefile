library      = zpu

rtl_files   +=  ../rtl_tb/txt_util.vhd
rtl_files   +=	../rtl/zpu_config.vhd
rtl_files   +=	../rtl/zpupkg.vhd
rtl_files   +=	../rtl/zpu_wrapper_package.vhd
rtl_files   +=	../rtl/trace.vhd
rtl_files   +=	../rtl/zpu_wrapper.vhd
rtl_files   +=	../rtl/dualport_ram.vhd
rtl_files   +=	../rtl/dualport_ram_ahb_wrapper.vhd
rtl_files   +=	../rtl/zpu_ahb.vhd
rtl_files   +=	../rtl/zpu_core_small.vhd
rtl_files   +=	../rtl/zpu_core_medium.vhd
rtl_files   +=	../rtl/timer.vhd
rtl_files   +=	../rtl/zpu_bus_trace.vhd
rtl_files   +=	../rtl/zpu_io.vhd

rtl_tb_files += ../rtl_tb/sim_small_fpga_top_noint.vhd

vhdlfiles    = $(rtl_files) $(rtl_tb_files) 
vhdltargets  := $(foreach n, $(vhdlfiles), ./$(library)/$(basename $(notdir $n))/_primary.dat)

STAMPS += ../../../../grlib/sim/.stamp


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
	@touch .stamp

./$(library)/%/_primary.dat:  ../rtl/%.vhd $(STAMPS)
	vcom -quiet -2008 -work $(library) $<
	@touch .stamp

./$(library)/%/_primary.dat:  ../rtl_tb/%.vhd $(STAMPS)
	vcom -quiet -2008 -work $(library) $<



sim:
	vsim -gui -do run.do

clean:
	rm -rf $(library) 
	rm -f transcript
	rm -f *.wlf
	rm -f trace.txt
	rm -f log.txt
	rm -f Makefile.$(library)
	rm -f .stamp

# default patterns

lib:	$(library)


$(library):
	vlib $(library)
