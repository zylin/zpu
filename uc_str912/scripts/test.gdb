set complaints 1
set output-radix 16
set input-radix 16
set prompt (arm-gdb)
target remote localhost:3333
monitor reset
monitor jtag_rclk 1000
#monitor arm7_9 dcc_downloads enable
#monitor arm7_9 fast_memory_access enable
monitor poll
monitor halt
#bbsr = FMI_BBSR
#nbsr = FMI_NBBSR
# info lt. RM0006
# BBSIZE
# 0000 = 32 kB
# 0001 = 64 kB
# 1011 = 64 MByte
# NBBSIZE
# 0000 = 8 kB
# 0001 = 16 kB
# 1011 = 64 MByte
monitor str9x flash_config 0 4 2 0x00000 0x80000
monitor flash protect 0 0 7 off
monitor flash protect_check 0
monitor flash info 0

set remotetimeout 10000

pwd

#monitor flash write_image erase ../main.elf 0 elf
#monitor flash write_image erase ../main.hex 0 ihex
#monitor flash write_image erase ../main.bin 0 bin
#monitor flash write_image erase ../test_led.elf 0 elf
#load test_led.elf
load main.elf

#monitor sleep 200
#monitor reset
kill
quit
