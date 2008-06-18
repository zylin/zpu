vlib work
vcom -93 -explicit ../src/ddr_pkg.vhd
vcom -93 -explicit ../src/ddr_top.vhd
vcom -93 -explicit ../src/mt46v16m16.vhd
vcom -93 -explicit ../simsrc/ddr_tb.vhd
vsim -t 1ps ddr_tb
view wave
view signals
radix hex
add wave *
add wave sim:/ddr_tb/ddr_ctrl/*
force -freeze sim:/ddr_tb/areset 1 0
run 10 ns
force -freeze sim:/ddr_tb/areset 0 0
when sim:/ddr_tb/break_out stop
run 10 ms