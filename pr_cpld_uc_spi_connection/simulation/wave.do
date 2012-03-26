onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /sr_tb/sdi
add wave -noupdate /sr_tb/clk
add wave -noupdate /sr_tb/latch_or_shift
add wave -noupdate /sr_tb/port_in
add wave -noupdate /sr_tb/sdo
add wave -noupdate /sr_tb/port_out
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
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {530250 ps}
