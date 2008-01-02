zpu-elf-gcc -DTIME $ZPUDIR/dhrystone/dhry_*.c -O3 -Wl,--gc-sections -Wl,--relax -abel -o dmips.elf
zpu-elf-objdump --disassemble-all >dmips.dis dmips.elf
zpu-elf-objcopy -O binary dmips.elf dmips.bin
