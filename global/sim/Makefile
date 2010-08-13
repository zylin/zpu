library      = global

rtl_files    = ../rtl/*.vhd

vhdlfiles    = $(rtl_files)


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
