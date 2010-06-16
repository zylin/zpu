library      = rena3
#top          = rena3_model_tb
top          = test_pulse_gen_tb

#rtl_files    = ../rtl/*.vhd
rtl_tb_files = ../rtl_tb/*.vhd
vhdlfiles    = $(rtl_tb_files) $(rtl_files)


all: compile simulate

lib:	$(library)/_info
	vlib $(library)

compile: lib
	vcom -work $(library) $(vhdlfiles)

simulate:
	export top=$(top); \
	vsim -gui $(library).$(top) -do run.do


clean:
	rm -f transcript
	rm -f *.wlf
	rm -f wlf*
	rm -rf rena3
