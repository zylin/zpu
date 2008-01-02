zpu-elf-gcc test.c -o test.elf -phi 
zpu-elf-objcopy -O binary test.elf test.bin
sh ../build/makefirmware.sh ../build/ic300.bit test.zpu test.bin



