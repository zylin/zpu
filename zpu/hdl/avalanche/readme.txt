This ZPU implementation, codenamed "avalanche" was
contributed by Antonio Anton <antonio.anton@anro-ingenieros.com>.

It's most interesting aspects are it's implementation using
microcode, small size, reduced code size overhead and that
it's implemented in Verilog.

Please direct any questions to the zylin-zpu mailing list.

The most urgently needed patches would be to provide working
simulation examples and improved documentation.


Øyvind Harboe


Notes from Antonio:

Hi,

attached goes my zpu implementation in verilog in case anybody is
interested in. Code is quite commented. Also microcode and opcodes are
exhaustive commented (and more accurate that the HTML documentation in
some cases :-) ).

At the moment I have no time to send a working environment but I will
get some time in next days and prepare a clean environment
(software/hardware) and send to the list. The target HW is spartan3
starter kit board (all peripherals working: vga, sram, uarts, etc.).

Feel free to ask any question to the list I will do my best to answer
quickly.

Regards
Antonio

Hi,

the zpu_core is complete and lot of bugs has been solved in the past but
extensive testing and a complete test program has not been
defined/executed; anyway I'm quite confident it works: this core
executes eCos, FreeRTOS, Forth and other applications.

Regarding FPGA resources for a "balanced" implementation (not the
smallest, not the fastest):

-cpu+alu+microcode rom: 671 LUT + 239 FF + 1 BRAM (50% of LUT is ALU)
-complete soc (cpu, vga, uart, memory controller, interrupt controller,
timers, gpio, spi, etc.): 1317 LUT + 716 FF + 1 BRAM

Regarding "modelsim hello world"; I'm sorry but I don't modelsim;
instead I use Icarus Verilog & gtkwave. The core has a "debug" facility
which displays all opcode and registers (memory changes, sp, pc, etc..)
during simulation execution.

Regards
Antonio

	
> > Regarding FPGA resources for a "balanced" implementation (not the
> > smallest, not the fastest):
> >
> > -cpu+alu+microcode rom: 671 LUT + 239 FF + 1 BRAM (50% of LUT is ALU)
>
> Are there any emulated instructions not implemented in
> microcode?
>

*All* zpu opcodes are microcoded. For some opcodes (like  *shift*),
there are two versions; 32 bit barrel shift in HDL (up to 32 clocks) or
1 bit shift in HDL microcode drived (up to ~130 clocks). They are
selectable via `DEFINES in the zpu_core_defines.v

Other opcodes like mult and div are 32 bit HDL only at the moment (there
are enough room in microcode memory to implement as microcode) and
software emulable as well.

For the above figures (671 LUT + 239 FF): *shift* are 32 bit HDL and
mult/div are software implemented.

There are new opcodes (as per my needs) like memory bulk copy (sncpy,
wcpy, wset) and ip checksum calculation (ipsum). There are room in
microccode memory to define new opcodes using the holes in the ISA (for
a complete list of opcodes and its function please see
zpu_core_defines.v).

Some future ideas (easy to implement in microcode)
-on-chip debug
-microcode update via software

Regards
