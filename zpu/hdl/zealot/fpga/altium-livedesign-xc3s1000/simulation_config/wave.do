onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_tb/tb_reset_n
add wave -noupdate /top_tb/tb_clk
add wave -noupdate -divider <NULL>
add wave -noupdate /top_tb/tb_rs232_rx
add wave -noupdate /top_tb/tb_rs232_tx
add wave -noupdate /top_tb/tb_rs232_rts
add wave -noupdate /top_tb/tb_rs232_cts
add wave -noupdate -divider Buttons
add wave -noupdate /top_tb/tb_button_n
add wave -noupdate -divider LEDs
add wave -noupdate /top_tb/tb_led
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 2
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
WaveRestoreZoom {1294218073 ps} {1421130628 ps}
