library      = gaisler
top          = 

rtl_files    = ../rtl/misc.vhd \
               ../rtl/uart.vhd \
               ../rtl/net.vhd \
               ../rtl/charrom_package.vhd \
               ../rtl/memctrl.vhd \
	       ../rtl/greth_pkg.vhd\
               ../rtl/*.vhd

rtl_tb_files = ../rtl_tb/*.vhd

vhdlfiles    = $(rtl_files) $(rtl_tb_files)


all: compile

remake: lib compile

compile:
	make compile --directory ../../techmap/sim
	vcom -quiet -2008 -work $(library) $(vhdlfiles)


clean:
	rm -f transcript
	rm -f *.wlf
	rm -f wlf*
	rm -rf $(library)
	rm -f Makefile.$(library)

# default patterns

$(library):
	vlib $(library)

lib:	$(library)

