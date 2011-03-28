LIB=tdc
TOP=tdc_tb
#TOP=thermometer_coder_tb
TOPTIME=tdc_timesim_tb

RTL_FILES=../rtl/types.vhd ../rtl/components.vhd  ../rtl/*.vhd 
RTL_TB_FILES=../rtl_tb/*.vhd

all:
	@echo "lib       - generate library" 
	@echo "compile   - compile all vhd files"
	@echo "sim       - start simulation"
	@echo "clean     - clean up"

lib:    
	vlib ${LIB}

compile:
	vcom -quiet -work ${LIB} ${RTL_FILES}
	vcom -quiet -work ${LIB} ${RTL_TB_FILES}

sim:	compile
	vsim -t ps -novopt -gui -quiet ${LIB}.${TOP} -do run_${TOP}.do
 
timesim:	compile
	vcom -quiet -work ${LIB} ../syn/xst/netgen/par/my_tdc_timesim.vhd
	vsim  -t 1ps -sdfmax "/tdc_timesim_i0=../syn/xst/netgen/par/my_tdc_timesim.sdf"  -novopt -gui -quiet ${LIB}.${TOPTIME} -do run_tdc_timesim_tb.do -l ${TOPTIME}.log
 
clean:
	rm -f *.wlf
	rm -f *.log
	rm -f transcript
	rm -rf ${LIB}
