zpu-elf-gcc -Os -phi sumeria.c -o sumeria.elf -Wl,--relax -Wl,--gc-sections -lm -g
zpu-elf-objcopy -O binary sumeria.elf sumeria.bin
sh ../build/makefirmware.sh sumeria.bin sumeria.zpu
zpu-elf-gcc -Os -phi eliza/*.c -o eliza.elf -Wl,--relax -Wl,--gc-sections -lm -g
zpu-elf-objcopy -O binary eliza.elf eliza.bin
sh ../build/makefirmware.sh eliza.bin eliza.zpu

