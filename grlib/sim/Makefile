library      = grlib
top          = 

rtl_files    = ../rtl/version.vhd \
               ../rtl/devices.vhd \
               ../rtl/stdlib.vhd \
               ../rtl/*.vhd

rtl_tb_files = 
#	       ../rtl_tb/*.vhd

vhdlfiles    = $(rtl_files) $(rtl_tb_files)


all: compile

lib:	$(library)/_info

compile: lib
	vcom -quiet -2008 -work $(library) $(vhdlfiles) | ccze -A


clean:
	rm -f transcript
	rm -f *.wlf
	rm -f wlf*


# default patterns

$(library)/_info:
	vlib $(library)
