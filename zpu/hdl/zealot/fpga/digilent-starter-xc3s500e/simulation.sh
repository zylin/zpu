#!/bin/sh

# need project files:
#    run.do
#    wave.do

# need ModelSim tools:
#    vlib
#    vcom
#    vsim


echo "###############"
echo "compile zpu lib"
echo "###############"
vlib zpu
vcom -work zpu ../../roms/hello_dbram.vhdl
vcom -work zpu ../../roms/hello_bram.vhdl
#vcom -work zpu ../../roms/dmips_dbram.vhdl
#vcom -work zpu ../../roms/dmips_bram.vhdl

vcom -work zpu ../../roms/rom_pkg.vhdl
vcom -work zpu ../../zpu_pkg.vhdl
vcom -work zpu ../../zpu_small.vhdl
vcom -work zpu ../../zpu_medium.vhdl
vcom -work zpu ../../helpers/zpu_small1.vhdl
vcom -work zpu ../../helpers/zpu_med1.vhdl
vcom -work zpu ../../devices/txt_util.vhdl
vcom -work zpu ../../devices/phi_io.vhdl
vcom -work zpu ../../devices/timer.vhdl
vcom -work zpu ../../devices/gpio.vhdl
vcom -work zpu ../../devices/rx_unit.vhdl
vcom -work zpu ../../devices/tx_unit.vhdl
vcom -work zpu ../../devices/br_gen.vhdl
vcom -work zpu ../../devices/trace.vhdl


echo "################"
echo "compile work lib"
echo "################"
vlib work
vcom top.vhd
vcom top_tb.vhd


echo "###################"
echo "start simulator gui"
echo "###################"
vsim -gui top_tb -do simulation_config/run.do
