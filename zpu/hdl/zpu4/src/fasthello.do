set BreakOnAssertion 1
vlib work

vcom -93 -explicit  zpu_config_fastsim.vhd
vcom -93 -explicit  zpupkg.vhd
vcom -93 -explicit  txt_util.vhd
vcom -93 -explicit  sim_fpga_top.vhd
vcom -93 -explicit  zpu_core.vhd
vcom -93 -explicit  dram_hello.vhd
vcom -93 -explicit  timer.vhd
vcom -93 -explicit  io.vhd
vcom -93 -explicit  trace.vhd


vsim fpga_top
view wave

# run ZPU
run 60000 ms
