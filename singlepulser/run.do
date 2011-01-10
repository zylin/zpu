vlib work
vcom singlepulser.vhd
vcom testbench.vhd
vsim -t ps testbench
do wave.do
run 250 ms
