This is a test release of the ZPU.
ZPU is a 32 bits stack CPU. This package contains a VHDL implementation
suitable for FPGAs. It was tested using a Xilinx Spartan 3 1500 FPGA.

The author of the ZPU is Øyvind Harboe (oyvind.harboe zylin.com) and the
license is the BSD one. Portions of this package were developed by Salvador E.
Tropea (salvador inti.gob.ar) and others. Some portions are under the GPL
license.

Øyvind also added a ZPU target to the gcc/gdb.

For more information about the ZPU core please visit:
http://www.zylin.com/zpu.htm
http://www.opencores.org/projects.cgi/web/zpu/overview

What are the files?
-------------------

zpu_medium.vhdl
ZPU CPU, medium version.

zpu_pkg.vhdl
Package containing the declarations for the ZPU library.

devices/phi_io.vhdl
The very basic I/O peripherals needed for the standard C library. It includes a
timer (64 bits clock counter) and an UART (8N1 without FIFO).
This is known as the PHI I/O layout, this implementation isn't complete. Only
the above mentioned peripherals are available.

devices/timer.vhdl
64 bits clock counter maped by the PHI I/O.

devices/trace.vhdl
This is used for debug purposes. The ZPU have a debug port to connect this
module. It can generate an execution trace log during the simulation.

devices/txt_util.vhdl
Useful text handling routines for the simulation.

devices/br_gen.vhdl
Fixed baud rate generator for the UART.

devices/rx_unit.vhdl
UART Rx module.

devices/tx_unit.vhdl
UART Tx module.

roms/rom_pkg.vhdl
Package containing the declarations for the memories used by the small and
medium ZPU.

roms/dmips_bram.vhdl
A memory that maps to Xilinx BRAMs and contains the Dhrystone Benchmark,
Version 2.1 (Language: C). This memory can be connected to the ZPU for
simulation or hardware implementations. The code assumes a 50 MHz clock to
compute the benchmark. The minimum size for this block should be 32 kB.

roms/hello_bram.vhdl
A memory that maps to Xilinx BRAMs and contains a simple "Hello World!"
program (C compiled). This memory can be connected to the ZPU for
simulation or hardware implementations. The minimum size for this block
should be 16 kB.

helpers/zpu_med1.vhdl
This is a helper that connects a ZPU to its memory and the PHI I/O space.

testbenches/dmips_med1_tb.vhdl
A simple testbench to simulate the ZPU (behavior).

fpga/dmips_med1.vhdl
A wrapper to implement the ZPU in an FPGA. This example was designed for a
GR-XC3S board from Pender, but should be easily adapted to other boards.


ZPU library?
------------

The following files are part of a library I called ZPU:

zpu_pkg.vhdl, zpu_medium.vhdl, txt_util.vhdl, timer.vhdl, rx_unit.vhdl,
tx_unit.vhdl, br_gen.vhdl, phi_io.vhdl and trace.vhdl.

You should group them inside a library called zpu. This procedure is tool-chain
dependent. In the ISE tool you must add a library and them move these files to
the library.

If you don't know how to do it with your tools you can just replace all the:

library zpu;
use zpu.xxxxxx.all;

code by:

library work;
use work.xxxxxx.all;


Which files are needed for simulation?
--------------------------------------

You need all the files that compose the zpu library plus:
1) A memory containing a program, i.e.:
roms/rom_pkg.vhdl and roms/dmips_bram.vhdl
2) A testbench (including the memory and I/O interconnections):
aux/zpu_med1.vhdl and testbenches/dmips_med1_tb.vhdl


Which files are needed for synthesis?
-------------------------------------

This is similar to simulation, but:
1) You should avoid trace.vhdl.
2) The top level should connect to the FPGA pins, replace dmips_med1_tb.vhdl
by fpga/dmips_med1.vhdl or fpga/hello_med1.vhdl


What resources are needed in the FPGA?
--------------------------------------

The DMIPS benchmarks needs aprox (Xilinx Spartan 3):

Flip Flops:   498
LUTs:        1877
Slices:      1032
BRAMs:         16
Multipliers:    3

The hello world example needs less memory:

Flip Flops:   496
LUTs:        1872
Slices:      1027
BRAMs:          8
Multipliers:    3

The board should contain an RS-232 transceiver. A push button (active when
pressed) is also used, for reset.


Ok, I synthetized it and put in the FPGA, what now?
---------------------------------------------------

Connect the RS-232 board output to a terminal (a PC). Setup the terminal for
115200 8N1 reception and press the reset push button. You should get the
program output. You can change the baudrate in the toplevel VHDL.


Please tell me if you succeed or failed!
Enjoy, Salvador E. Tropea

