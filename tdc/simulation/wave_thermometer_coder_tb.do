onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /thermometer_coder_tb/thermometer_coder_i0/thermo_in
add wave -noupdate -format Literal -radix unsigned /thermometer_coder_tb/thermometer_coder_i0/code_out
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {6720 ps}
