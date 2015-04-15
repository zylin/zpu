# Xilinx WebPack modelsim script
#
# cd C:/workspace/zpu/zpu/hdl/example_medium
# do simzpu_medium.do

set BreakOnAssertion 1
vlib work

vcom -93 -explicit  zpu_config_trace.vhd
vcom -93 -explicit  ../zpu4/core/zpupkg.vhd
vcom -93 -explicit  ../zpu4/src/txt_util.vhd
vcom -93 -explicit  sim_fpga_top.vhd
vcom -93 -explicit  ../zpu4/core/zpu_core.vhd
vcom -93 -explicit  dram_hello.vhd
vcom -93 -explicit  ../zpu4/src/timer.vhd
vcom -93 -explicit  ../zpu4/src/io.vhd
vcom -93 -explicit  ../zpu4/src/trace.vhd

# run ZPU
vsim fpga_top
view wave
add wave -recursive fpga_top/zpu/*
#add wave -recursive fpga_top/*
view structure
#view signals

# Enough to run tiny programs
run 1000 ms
