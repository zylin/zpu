library      = techmap

rtl_files    = ../rtl/gencomp.vhd \
	       ../rtl/allddr.vhd \
               ../rtl/*.vhd

#               ../rtl/ddr_unisim.vhd \

rtl_tb_files = ../rtl_tb/*.vhd

vhdlfiles    = $(rtl_files)


all: compile


remake: lib compile


compile:
	make compile --directory ../../grlib/sim
	vcom -quiet -2008 -work $(library) $(vhdlfiles)


clean:
	rm -f transcript
	rm -f *.wlf
	rm -f wlf*
	rm -rf $(library) 
	rm -f Makefile.$(library)


# default patterns

lib:	$(library)

$(library):
	vlib $(library)
