zpu-elf-gcc -DTIME ../../../../../../roadshow/dhrystone/dhry_*.c -O3 -Wl,--gc-sections -Wl,--relax -phi -o dmips.elf
zpu-elf-objdump --disassemble-all >dmips.dis dmips.elf
zpu-elf-objcopy -O binary dmips.elf dmips.bin
java -classpath ../../../../sw/simulator/zpusim.jar com.zylin.zpu.simulator.tools.MakeRam dmips.bin >dmips.ram
