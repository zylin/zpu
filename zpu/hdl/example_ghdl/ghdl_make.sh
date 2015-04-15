#!/bin/sh
. ghdl_options.sh

ghdl -m ${MAKE_OPTIONS} fpga_top
