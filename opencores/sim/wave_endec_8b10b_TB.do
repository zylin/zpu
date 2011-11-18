onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /endec_8b10b_tb/TRESET
add wave -noupdate /endec_8b10b_tb/TBYTECLK
add wave -noupdate -radix unsigned /endec_8b10b_tb/tchar
add wave -noupdate -radix unsigned /endec_8b10b_tb/kcounter
add wave -noupdate -radix unsigned /endec_8b10b_tb/dcounter
add wave -noupdate -radix unsigned /endec_8b10b_tb/tcharout
add wave -noupdate -radix unsigned /endec_8b10b_tb/tlcharout
add wave -noupdate -divider dec
add wave -noupdate -radix unsigned /endec_8b10b_tb/tdec
add wave -noupdate /endec_8b10b_tb/tdeck
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2253311 ps} 0}
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
WaveRestoreZoom {0 ps} {4200 ns}
