#!/bin/sh

IMPORT_OPTIONS="--std=93 --ieee=synopsys --workdir=work"
MAKE_OPTIONS="${IMPORT_OPTIONS} -Wl,-s -fexplicit --syn-binding"

if test ! -e work; then
    echo "Building work library..."
    mkdir work
    ghdl -i ${IMPORT_OPTIONS} ../../hdl/example/zpu_config.vhd
    ghdl -i ${IMPORT_OPTIONS} ../../hdl/zpu4/core/zpupkg.vhd
    ghdl -i ${IMPORT_OPTIONS} ../../hdl/zpu4/src/txt_util.vhd
    ghdl -i ${IMPORT_OPTIONS} ../../hdl/example/sim_small_fpga_top.vhd
    ghdl -i ${IMPORT_OPTIONS} ../../hdl/zpu4/core/zpu_core_small.vhd
    ghdl -i ${IMPORT_OPTIONS} ../../hdl/example/bram_dmips.vhd
    ghdl -i ${IMPORT_OPTIONS} ../../hdl/zpu4/src/timer.vhd
    ghdl -i ${IMPORT_OPTIONS} ../../hdl/zpu4/src/io.vhd
    ghdl -i ${IMPORT_OPTIONS} ../../hdl/zpu4/src/trace.vhd
fi

echo "Compiling design..."
if ghdl -m ${MAKE_OPTIONS} fpga_top; then
    echo "Compilation finished, start simulation with"
    echo "  ./fpga_top --stop-time=1ms"
fi
