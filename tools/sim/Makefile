library      = tools
top          = image_pkg

#rtl_files    = ../rtl/*.vhd
rtl_tb_files = ../rtl_tb/fio_pkg.vhd ../rtl_tb/*.vhd
vhdlfiles    = $(rtl_tb_files) $(rtl_files)


all: lib compile

lib:	$(library)/_info
	vlib $(library)

compile:
	vcom -work $(library) $(vhdlfiles)

simulate:
	vsim -gui $(library).$(top) -do run.do


clean:
	rm -rf tools
