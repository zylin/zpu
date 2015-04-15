The FreeRTOS port was contributed by
Antonio Anton <antonio.anton@anro-ingenieros.com>.

Some of the files state that someone else is copyright
holder, but I believe that to be copy and paste laziness
and that, in fact, Antonio did this port.

The port needs work, but is committed to ZPU git repository
to get things started.

Post questions to the zylin-zpu mailing list.

Øyvind Harboe
14/9-2009

From Antonio:

Ported version: 5.3.0
Port goes to folder ${FREERTOS_ROOT}/Source/portable/GCC/ZPU

portmacro.h : macro definitions for this port
portasm.s   : contains code for context switch, interrupt handler and
other initializations
port.c      : other initialization functions that not need to be
assembly code.

(please note that #include <device.h> in port.c is specific for my ZPU
port; it contains the definitions my peripherals)

Each FreeRTOS application is compiled with the FreeRTOS port itself
(source code).

2nd file contains a sample application which includes the Makefile in
order to compile & link against FreeRTOS port. It will link against some
specific library (-lio) and specific linker file (sram-zpu.ld) which are
not included. You must adapt these to your peripheral and memory
configuration.

At the moment there is no documentation but the source code is quite
commented.
