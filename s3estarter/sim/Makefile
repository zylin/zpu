library      = s3estarter
top          = top

rtl_files    = ../rtl/fpga_types.vhd \
               ../rtl/*.vhd

rtl_tb_files = ../rtl_tb/*.vhd

vhdlfiles    = $(rtl_files) 


all: compile simulate

compile: lib
	vcom -2008 -work $(library) $(vhdlfiles) | ccze -A

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
