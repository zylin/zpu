onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_tb/top_i0/box_i0/clk
add wave -noupdate /top_tb/top_i0/box_i0/ahbctrl_i0/msto(0).hbusreq
add wave -noupdate /top_tb/top_i0/box_i0/ahbctrl_i0/msto(1).hbusreq
add wave -noupdate -divider ahbctrl
add wave -noupdate -expand /top_tb/top_i0/box_i0/ahbctrl_i0/msti.hgrant
add wave -noupdate /top_tb/top_i0/box_i0/ahbctrl_i0/msti.hready
add wave -noupdate -divider gpio
add wave -noupdate -expand /top_tb/top_i0/gpio_led
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {64180831 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {1840927 ps}
