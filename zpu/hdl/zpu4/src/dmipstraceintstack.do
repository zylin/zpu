set BreakOnAssertion 1
vlib work

vcom -93 -explicit  zpu_config_trace.vhd
vcom -93 -explicit  zpupkg.vhd
vcom -93 -explicit  txt_util.vhd
vcom -93 -explicit  sim_fpga_top.vhd
vcom -93 -explicit  zpu_core_intstack.vhd
vcom -93 -explicit  dram_dmips.vhd
vcom -93 -explicit  timer.vhd
vcom -93 -explicit  io.vhd
vcom -93 -explicit  trace.vhd


vsim fpga_top
view wave

add wave -recursive fpga_top/zpu/*
#--add wave -recursive fpga_top/ioMap/*
#add wave -recursive fpga_top/*
view structure


# run ZPU
run 5 ms
