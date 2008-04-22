#!/bin/sh
. ghdl_options.sh

mkdir -p work
ghdl -i ${IMPORT_OPTIONS} ../../hdl/example/zpu_config.vhd
ghdl -i ${IMPORT_OPTIONS} ../../hdl/zpu4/src/zpupkg.vhd
ghdl -i ${IMPORT_OPTIONS} ../../hdl/example/helloworld.vhd
ghdl -i ${IMPORT_OPTIONS} ../../hdl/zpu4/src/txt_util.vhd
ghdl -i ${IMPORT_OPTIONS} ../../hdl/zpu4/src/trace.vhd
ghdl -i ${IMPORT_OPTIONS} ../../hdl/zpu4/src/zpu_core_small.vhd
ghdl -i ${IMPORT_OPTIONS} ../../hdl/zpu4/src/io.vhd
ghdl -i ${IMPORT_OPTIONS} ../../hdl/zpu4/src/timer.vhd
ghdl -i ${IMPORT_OPTIONS} ../../hdl/zpu4/src/sim_small_fpga_top.vhd
