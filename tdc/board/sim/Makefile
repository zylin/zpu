LIB=work
TOP=fpga_top

RTL_FILES= ../rtl/tdline_pack.vhd ../rtl/*.vhd 

all:
	@echo "lib       - generate library" 
	@echo "compile   - compile all vhd files"
	@echo "clean     - clean up"

lib:    
	vlib ${LIB}

compile:
	vcom -quiet -work ${LIB} ${RTL_FILES}

clean:
	rm -f *.wlf
	rm -f *.log
	rm -f transcript
	rm -rf ${LIB}
