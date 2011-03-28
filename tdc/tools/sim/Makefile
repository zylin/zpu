LIB=tools
TOP=

RTL_FILES=../rtl/*.vhd
RTL_TB_FILES=../rtl_tb/*.vhd

all:
	@echo "lib       - generate library" 
	@echo "compile   - compile all vhd files"
#	@echo "sim       - start simulation"

lib:    
	vlib ${LIB}

compile:
#	vcom -quiet -work ${LIB} ${RTL_FILES}
	vcom -quiet -work ${LIB} ${RTL_TB_FILES}

#sim:	compile
#	vsim -gui -quiet ${LIB}.${TOP} -do run.do
 
