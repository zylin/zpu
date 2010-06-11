library      = rena3
top          = rena3_model_tb

#rtl_files    = ../rtl/*.vhd
rtl_tb_files = ../rtl_tb/*.vhd
vhdlfiles    = $(rtl_tb_files) $(rtl_files)


all: lib compile simulate

lib:
	vlib $(library)

compile:
	vcom -work $(library) $(vhdlfiles)

simulate:
	vsim -gui $(library).$(top) -do run.do
