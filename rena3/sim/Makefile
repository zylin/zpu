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

lib:	$(library)/_info

compile: lib
	make compile --directory ../../tools/sim
	make compile --directory ../../zpu/sim
	vcom -2008 -work $(library) $(vhdlfiles) | ccze -A

simulate:
	export top=$(top); \
	vsim -quiet -gui $(library).$(top) -do run.do


clean:
	rm -f transcript
	rm -f *.wlf
	rm -f wlf*
	rm -rf rena3


# default patterns

$(library)/_info:
	vlib $(library)
