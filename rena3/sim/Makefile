library      = rena3
#top          = rena3_model_tb
#top          = test_pulse_gen_tb
top          = test_board

rtl_files    = ../rtl/types_package.vhd \
               ../rtl/*.vhd

rtl_tb_files = ../rtl_tb/test_pulse_gen.vhd \
               ../rtl_tb/dds_model.vhd \
	       ../rtl_tb/rena3_model_types_package.vhd \
	       ../rtl_tb/rena3_model_component_package.vhd \
	       ../rtl_tb/*.vhd

vhdlfiles    = $(rtl_files) $(rtl_tb_files)


all: compile simulate

compile: lib
	make compile --directory ../../gaisler/sim
	make compile --directory ../../grlib/sim
	make compile --directory ../../tools/sim
	make --directory ../software/devel/ test
	make compile --directory ../../zpu/sim
	vcom -2008 -quiet -work $(library) $(vhdlfiles) | ccze -A

simulate:
	export top=$(top); \
	vsim -quiet -gui $(library).$(top) -do run.do


clean:
	rm -f transcript
	rm -f *.wlf
	rm -f wlf*
	rm -rf $(library) 


# default patterns

lib:	$(library)

$(library):
	vlib $(library)
