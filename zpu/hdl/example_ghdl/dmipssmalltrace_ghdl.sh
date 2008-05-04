#!/bin/sh

UNISIM_DIR="'location of GHDL objects for unisim library'/unisim_v93"
IMPORT_OPTIONS="--std=93 --ieee=synopsys --workdir=work -P${UNISIM_DIR}"
MAKE_OPTIONS="${IMPORT_OPTIONS} -Wl,-s -fexplicit --syn-binding"

if test ! -e work; then
    echo "Building work library..."
    mkdir work
    ghdl -i ${IMPORT_OPTIONS} zpu_config_trace.vhd
    ghdl -i ${IMPORT_OPTIONS} zpupkg.vhd
    ghdl -i ${IMPORT_OPTIONS} txt_util.vhd
    ghdl -i ${IMPORT_OPTIONS} sim_fpga_top.vhd
    ghdl -i ${IMPORT_OPTIONS} zpu_core_small.vhd
    ghdl -i ${IMPORT_OPTIONS} bram_dmips.vhd
    ghdl -i ${IMPORT_OPTIONS} dram_dmips.vhd
    ghdl -i ${IMPORT_OPTIONS} timer.vhd
    ghdl -i ${IMPORT_OPTIONS} io.vhd
    ghdl -i ${IMPORT_OPTIONS} trace.vhd
fi

echo "Compiling design..."
if ghdl -m ${MAKE_OPTIONS} fpga_top; then
    echo "Compilation finished, start simulation with"
    echo "  ./fpga_top --stop-time=1ms"
fi
