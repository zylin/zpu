# Xilinx WebPack modelsim script
#
# cd C:/workspace/zpu/zpu/hdl/zpu4/src
# do simzpu_bram.do

set BreakOnAssertion 1
vlib work

vcom -93 -explicit  zpu_config_trace.vhd
vcom -93 -explicit  zpupkg.vhd
vcom -93 -explicit  txt_util.vhd
vcom -93 -explicit  sim_fpga_top.vhd
vcom -93 -explicit  zpu_core_bram.vhd
vcom -93 -explicit  bram_dmips.vhd
vcom -93 -explicit  timer.vhd
vcom -93 -explicit  io.vhd
vcom -93 -explicit  trace.vhd

# run ZPU
vsim fpga_top
view wave
add wave -recursive fpga_top/zpu/*
#add wave -recursive fpga_top/*
view structure
#view signals

# Enough to run tiny programs
run 1us
