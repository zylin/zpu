onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /test_pulse_gen_tb/testbench_trigger
add wave -noupdate -format Analog-Step -height 74 -max 0.69999999999999996 /test_pulse_gen_tb/test_pulse_gen_i0_pulse
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
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
WaveRestoreZoom {0 ps} {3675 us}
