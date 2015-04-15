#!/bin/sh

# ise build stuff
rm -rf build
rm -f top.bit

# modelsim compile stuff
rm -rf work
rm -rf zpu

# modelsim simulation stuff
rm -f vsim.wlf
rm -f transcript
rm -f zpu_trace.log
rm -f zpu_med1_io.log
rm -f zpu_small1_io.log
