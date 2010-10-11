library      = grlib
top          = 

rtl_files    = ../rtl/version.vhd \
               ../rtl/stdlib.vhd \
               ../rtl/amba.vhd \
               ../rtl/devices.vhd \
               ../rtl/*.vhd

rtl_tb_files = ../rtl_tb/*.vhd

vhdlfiles    = $(rtl_files) $(rtl_tb_files)


all: compile

compile: lib
	vcom -quiet -2008 -work $(library) $(vhdlfiles) | ccze -A


clean:
	rm -f transcript
	rm -f *.wlf
	rm -f wlf*
	rm -rf $(library)


# default patterns

lib:	$(library)

$(library):
	vlib $(library)
