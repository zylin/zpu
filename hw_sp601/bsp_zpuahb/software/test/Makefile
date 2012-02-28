
COMPILER_OPTIONS=-ffunction-sections -fdata-sections -I../include
OBJCOPY_OPTIONS=--strip-debug --discard-locals
ZPU_ROM_GEN=../../../../zpu/support/zpuromgen
AHB_ROM_GEN=../../../../gaisler/support/ahbrom
DIR=..
include $(DIR)/include.mak

all: software

help:
	@echo "software  - build main software"
	@echo
	@echo "clean     - clean up"


startup = ../lib/crt0.S
objs    = ../lib/crt0.o 
LIBS    = ../libhal/libhal.a
LIBDIR  = ../libhal/
lib_src = ../lib/premain.c ../lib/divmod.c ../lib/udivmodsi4.c
ldflags = -nostartfiles $(objs) -Wl,--relax,--gc-sections,-L${LIBDIR},-lhal

zpu_rom_vhdl = ../../rtl/dualport_ram.vhd
ahb_rom_vhdl = ../../rtl/ahbrom.vhd
c_files  += main.c 
c_files  += $(lib_src)
h_files = ../include/peripherie.h


software: $(zpu_rom_vhdl) $(ahb_rom_vhdl)


main.elf: $(c_files) $(h_files) $(objs)
	make --directory $(LIBDIR)
	@# normal compile command (emulate instructions)
	$(CC) $(COMPILER_OPTIONS) -O3 -phi $(c_files) $(ldflags) -o $@ 

	$(SIZE) $@
	$(OBJDUMP) -D -S $@ > main.lst

%.bin: %.elf
	$(OBJCOPY) $(OBJCOPY_OPTIONS) -O binary $< $@  


$(zpu_rom_vhdl): main.bin $(ZPU_ROM_GEN)
	# concat parts
	cat >  $(zpu_rom_vhdl) $(shell dirname $(ZPU_ROM_GEN))/dualport_ram.vhd_header
	$(ZPU_ROM_GEN) main.bin >> $(zpu_rom_vhdl)
	cat >> $(zpu_rom_vhdl) $(shell dirname $(ZPU_ROM_GEN))/dualport_ram.vhd_footer

$(ahb_rom_vhdl): main.bin $(AHB_ROM_GEN)
	$(AHB_ROM_GEN) main.bin $(ahb_rom_vhdl)


$(startup:.S=.o): $(startup)
	$(CC) -c $< -o $@

clean:
	rm -f *.lst
	rm -f *.o
	rm -f *.elf
	rm -f *.bin

# disable implicit rule for c files
.SUFFIXES:
%.c: %.w %.ch

