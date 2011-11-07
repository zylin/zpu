target remote localhost:3333
monitor reset
monitor sleep 500
monitor poll
monitor soft_reset_halt
monitor flash protect 0 0 10 off
monitor flash probe 0
monitor flash info 0
monitor reset run
monitor sleep 500
