onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Inputs
add wave -noupdate /channel_tb/tb_channel_active_in
add wave -noupdate /channel_tb/tb_error_in_n
add wave -noupdate /channel_tb/tb_test_in_n
add wave -noupdate /channel_tb/tb_test_sps_in
add wave -noupdate /channel_tb/tb_clear
add wave -noupdate /channel_tb/tb_clear_sps
add wave -noupdate -divider Output
add wave -noupdate /channel_tb/tb_error_out
add wave -noupdate /channel_tb/tb_channel_ok_out
add wave -noupdate -divider channel
add wave -noupdate /channel_tb/channel_i0/channel_active
add wave -noupdate /channel_tb/channel_i0/channel_error
add wave -noupdate /channel_tb/channel_i0/channel_ok
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {44333 ps} 0}
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
WaveRestoreZoom {0 ps} {512 ns}
