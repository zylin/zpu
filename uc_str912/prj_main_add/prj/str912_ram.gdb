target remote localhost:3333
monitor reset
monitor sleep 500
monitor poll
monitor soft_reset_halt
monitor arm7_9 sw_bkpts enable

# Set SRAM size to 96 KB
monitor mww 0x5C002034 0x0197
monitor mdw 0x5C002034

# needed for gdb 6.8 and higher
set mem inaccessible-by-default off

load
break main
continue





