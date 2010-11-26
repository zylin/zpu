library      = s3estarter
top          = top_tb

rtl_files    = ../rtl/fpga_types.vhd \
	       ../rtl/fpga_components.vhd \
               ../rtl/*.vhd

rtl_tb_files = ../rtl_tb/*.vhd

verilogfiles = ../rtl_tb/ddr.v

vhdlfiles    = $(rtl_files) $(rtl_tb_files)


all: compile simulate

remake: lib Makefile.$(library)

Makefile.$(library): $(vhdlfiles) $(library)
	vcom -quiet -2008 -work $(library) $(vhdlfiles)
	vmake $(library) > Makefile.$(library)
	# patch winpath -> cygpath
	sed -e 's/\(C:.*\)/$$(shell cygpath --unix "\1" | sed "s\/ \/\\\\\\\\ \/g" )/g' -i Makefile.$(library)


compile:
	make -f Makefile.$(library)

compile_others:
	make --directory ../software/test/ test | ccze -A
	make compile --directory ../../zpu/sim | ccze -A
	#make --directory ../software/ethernet_speed

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
