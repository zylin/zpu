library      = tools
top          = image_pkg

#rtl_files    = ../rtl/*.vhd
rtl_tb_files = ../rtl_tb/fio_pkg.vhd ../rtl_tb/*.vhd
vhdlfiles    = $(rtl_tb_files) $(rtl_files)


all: lib compile

remake: lib Makefile.$(library)

Makefile.$(library): $(vhdlfiles) $(library)
	vcom -quiet -2008 -work $(library) $(vhdlfiles)
	vmake $(library) > Makefile.$(library)
	# patch winpath -> cygpath
	sed -e 's/\(C:.*\)/$$(shell cygpath --unix "\1" | sed "s\/ \/\\\\\\\\ \/g" )/g' -i Makefile.$(library)


compile:
	make -f Makefile.$(library)

simulate:
	vsim -gui $(library).$(top) -do run.do


clean:
	rm -rf tools
	rm -f Makefile.$(library)


# default patterns

lib:    $(library)

$(library):
	vlib $(library)

