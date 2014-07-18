#
# $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/hw_sp605/bsp_zpuahb/software/Makefile $
# $Date$
# $Author$
# $Revision$
#

COMPILER_OPTIONS=-ffunction-sections -fdata-sections -Iinclude
OBJCOPY_OPTIONS=--strip-debug --discard-locals

ZPU_SUPPORT_DIR=../../zpu/support
ZPU_ROM_GEN=$(ZPU_SUPPORT_DIR)/zpuromgen
AHB_ROM_GEN=../../gaisler/support/ahbrom


SVNPATH = ..
SVNREV = $(shell svnversion -n $(SVNPATH))

all: software

help:
	@echo "software  - build main software"
	@echo
	@echo "clean     - clean up"


startup = lib/crt0.S
objs    = lib/crt0.o 
lib_src = lib/premain.c lib/divmod.c lib/udivmodsi4.c
#ldflags = -nostartfiles -nostdlib -nodefaultlibs $(objs) -Wl,--relax -Wl,--gc-sections -Wl,-lhal -Wl,-Llibhal
ldflags = -nostartfiles $(objs) -Wl,--relax,--gc-sections,-lhal,-Llibhal


zpu_rom_vhdl = ../rtl/dualport_ram.vhd
ahb_rom_vhdl = ../rtl/ahbrom.vhd
c_files += main.c 
c_files += timestamp.c 
c_files += monitor.c 
c_files += schedule.c
c_files += ambainfo.c 
c_files += monitor_functions.c
c_files += $(lib_src)
h_files = *.h include/peripherie.h


software: $(zpu_rom_vhdl) $(ahb_rom_vhdl)


main.bin: $(c_files) $(h_files) $(objs)
	make --directory libhal
	@# normal compile command (emulate instructions)
	zpu-elf-gcc $(COMPILER_OPTIONS) -O3 -phi $(c_files) $(ldflags) -o main.elf 

	zpu-elf-size main.elf
	print_mem_zpu.sh main.elf
	zpu-elf-objdump -D -S main.elf > main.lst
	zpu-elf-objcopy $(OBJCOPY_OPTIONS) -O binary main.elf main.bin

$(zpu_rom_vhdl): main.bin $(ZPU_ROM_GEN)
	# concat parts
	cat > $(zpu_rom_vhdl) $(ZPU_SUPPORT_DIR)/dualport_ram.vhd_header
	$(ZPU_ROM_GEN) main.bin >> $(zpu_rom_vhdl)
	cat >> $(zpu_rom_vhdl) $(ZPU_SUPPORT_DIR)/dualport_ram.vhd_footer

$(ahb_rom_vhdl): main.bin $(AHB_ROM_GEN)
	$(AHB_ROM_GEN) main.bin $(ahb_rom_vhdl)


$(startup:.S=.o): $(startup)
	zpu-elf-gcc -c $< -o $@

clean:
	rm -f *.bin
	rm -f *.elf
	rm -f *.lst
	rm -f *.o
	rm -f lib/*.o


timestamp: timestamp.c
timestamp.c:
	@echo "updating $@ ($(SVNREV))"
	@rm -f $@
	@echo "const char* sw_svn_revision = \"$(SVNREV)\"; "  >> $@


# disable implicit rule for c files
.SUFFIXES:
%.c: %.w %.ch
