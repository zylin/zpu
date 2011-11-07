target remote :2331
monitor endian little
monitor flash download = 1
monitor flash device = STR912FAW44
load erase.o
monitor reset
quit
