set complaints 1
set output-radix 16
set input-radix 16
set prompt (arm-gdb) 
target remote localhost:3333
monitor reset init
monitor halt
#   16 = 450 bytes/sec
#   32 = 870 bytes/sec 
#   64 = 1   kbyte/sec   c bleibt nicht stehen
#  127 = 2  kbyte/sec    c bleibt nicht stehen
#  250 = 4  kbyte/sec
#  500 = 5  kbyte/sec
# 1000 = 7  kbyte/sec
# 2000 = 8  kbyte/sec
# 3000 = 8  kbyte/sec
monitor jtag_rclk 3000
monitor str9x flash_config 0 4 2 0x00000 0x80000
monitor flash protect 0 0 7 off
monitor flash protect_check 0
pwd
load main.elf
file main.elf
#monitor jtag_rclk 3000
