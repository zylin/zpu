library      = zpu

rtl_files    = \
		../rtl_tb/txt_util.vhd \
		../rtl/zpu_config.vhd \
		../rtl/zpupkg.vhd \
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

sim:
	vsim -gui -do run.do


lib:	$(library)/_info

compile: lib
	make compile --directory ../../grlib/sim
	vcom -quiet -2008 -work $(library) $(vhdlfiles) | ccze -A

clean:
	rm -rf zpu
	rm -f transcript
	rm -f *.wlf
	rm -f trace.txt
	rm -f log.txt


# default patterns

$(library)/_info:
	vlib $(library)
