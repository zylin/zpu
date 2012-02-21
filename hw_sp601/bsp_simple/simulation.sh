#!/bin/sh

# need project files:
#    run.do
#    wave.do

# need ModelSim tools:
#    vlib
#    vcom
#    vsim


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
