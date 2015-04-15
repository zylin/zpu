zpu-elf-gcc -nostdlib test.S -o test.elf 
zpu-elf-objcopy -O binary test.elf test.bin
sh makefirmware.sh ic300.bit test.zpu test.bin



