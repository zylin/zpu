library      = techmap

rtl_files    = ../rtl/*.vhd \
               ../rtl/*.vhd

rtl_tb_files = ../rtl_tb/*.vhd

vhdlfiles    = $(rtl_files)


all: compile

compile: lib
	vcom -2008 -work $(library) $(vhdlfiles) | ccze -A

#simulate:
#	export top=$(top); \
#	vsim -quiet -gui $(library).$(top) -do run.do


clean:
	rm -f transcript
	rm -f *.wlf
	rm -f wlf*
	rm -rf $(library) 


# default patterns

lib:	$(library)

$(library):
	vlib $(library)
