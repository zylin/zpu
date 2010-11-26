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

remake: lib Makefile.$(library)

Makefile.$(library): $(vhdlfiles) $(library)
	vcom -quiet -2008 -work $(library) $(vhdlfiles)
	vmake $(library) > Makefile.$(library)
	# patch winpath -> cygpath
	sed -e 's/\(C:.*\)/$$(shell cygpath --unix "\1" | sed "s\/ \/\\\\\\\\ \/g" )/g' -i Makefile.$(library)


compile:
	make -f Makefile.$(library)


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
