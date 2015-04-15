onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_tb/tb_rot_center
add wave -noupdate /top_tb/tb_clk_50mhz
add wave -noupdate /top_tb/tb_rs232_dce_rxd
add wave -noupdate /top_tb/tb_rs232_dce_txd
add wave -noupdate -divider Buttons
add wave -noupdate /top_tb/tb_btn_east
add wave -noupdate /top_tb/tb_btn_north
add wave -noupdate /top_tb/tb_btn_south
add wave -noupdate /top_tb/tb_btn_west
add wave -noupdate -divider LEDs
add wave -noupdate /top_tb/top_i0/led
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {56714893 ps} 0}
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
WaveRestoreZoom {0 ps} {151772250 ps}
