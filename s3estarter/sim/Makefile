library      = s3estarter
top          = top_tb

rtl_files    = ../rtl/types.vhd \
	       ../rtl/fpga_components.vhd \
	       ../rtl/clk_gen.vhd \
	       ../rtl/dcm_ctrl_apb.vhd \
	       ../rtl/debug_con_apb.vhd \
	       ../rtl/box.vhd \
	       ../rtl/ibox_test.vhd \
	       ../rtl/top.vhd \
	       ../rtl/s3estarter.vhd

rtl_tb_files = ../rtl_tb/mt46v16m16.vhd \
	       ../rtl_tb/phy.vhd \
	       ../rtl_tb/top_tb.vhd

verilogfiles = ../rtl_tb/ddr.v

vhdlfiles    = $(rtl_files) $(rtl_tb_files)
vhdltargets  := $(foreach n, $(vhdlfiles), ./$(library)/$(basename $(notdir $n))/_primary.dat)


all: compile simulate



compile: lib deplibs $(vhdltargets)

deplibs:
	make --directory ../software/test/ test | ccze -A
	#make --directory ../software/ethernet_speed | ccze -A

	make compile --directory ../../zpu/sim     | ccze -A
	make compile --directory ../../global/sim  | ccze -A
	make compile --directory ../../gaisler/sim | ccze -A

$(vhdltargets): $(vhdlfiles)
	@echo "------------------------------------------------------------"
	vcom -quiet -2008 -work $(library) $(vhdlfiles) | ccze -A


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
