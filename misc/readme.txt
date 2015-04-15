These files are provided as is under a FreeBSD license.

Patches most gratefully accepted to document this better.

These are parts of the VHDL code that went into ZY2000 that
can be used on other FPGA brands and with other parts than
went into ZY2000.

http://www.zylin.com/protoboard.htm

The long term plan is to split out these from the ZPU project
into a DDR controller and ARM7 wishbone bridge
project on OpenCores.org and document them.

Directories
===========
arm7 - ARM7 wishbone interface
ddsdram - a generic ddr ram controller. Implemented for Xilinx + mt46v16m16 but
can be adapted to other FPGA brands and DRAM chips
wishbone - atomic 32 bit wishbone access inside FPGA and in ARM7 SW, over a 16 bit CPU databus