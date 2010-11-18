library      = s3estarter
top          = top_tb

rtl_files    = ../rtl/fpga_types.vhd \
	       ../rtl/fpga_components.vhd \
               ../rtl/*.vhd

rtl_tb_files = ../rtl_tb/*.vhd

verilogfiles = ../rtl_tb/ddr.v

vhdlfiles    = $(rtl_files) $(rtl_tb_files)


all: compile simulate

compile_others:
	#make --directory ../software/test/ test
	make --directory ../software/ethernet_speed
	make compile --directory ../../rena3/sim

compile: lib
	#vlog -work verilog "c:/Program_Files_BLa/Xilinx/12.2/ISE_DS/ISE/verilog/src/glbl.v"
	#vlog -work verilog +incdir+../rtl_tb/ +define+sg6 +define+x16 $(verilogfiles)
	vcom -2008 -work $(library) $(vhdlfiles) | ccze -A

simulate:
	export top=$(top); \
	vsim -quiet -gui $(library).$(top) -do run.do


clean:
	rm -rf $(library) 
	rm -f transcript
	rm -f *.wlf
	rm -f wlf*


# default patterns

lib:	$(library)

$(library):
	vlib $(library)
