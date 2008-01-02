vlib zylin
vcom -93 -explicit -work zylin ../ddrsdram/src/ddr_pkg.vhd
vcom -93 -explicit -work zylin ../ddrsdram/src/ddr_top.vhd
vcom -93 -explicit -work zylin ../ddrsdram/src/mt46v16m16.vhd
vcom -93 -explicit -work zylin ../ddrsdram/src/ddr_tb.vhd
vlib work
vsim -t 1ps  zylin.ddr_tb
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