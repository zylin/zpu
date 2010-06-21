library      = rena3
top          = rena3_model_tb
#top          = test_pulse_gen_tb
#top          = test_board

#rtl_files    = ../rtl/*.vhd
rtl_tb_files =  ../rtl_tb/test_pulse_gen.vhd \
		../rtl_tb/dds_model.vhd \
	       ../rtl_tb/rena3_model_types_package.vhd \
	       ../rtl_tb/rena3_model_component_package.vhd \
	       ../rtl_tb/*.vhd
vhdlfiles    = $(rtl_tb_files) $(rtl_files)


all: compile simulate

lib:	$(library)/_info

compile: lib
	vcom -2008 -work $(library) $(vhdlfiles)

simulate:
	export top=$(top); \
	vsim -gui $(library).$(top) -do run.do


clean:
	rm -f transcript
	rm -f *.wlf
	rm -f wlf*
	rm -rf rena3


# default patterns

$(library)/_info:
	vlib $(library)
