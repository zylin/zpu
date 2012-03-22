onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider input
add wave -noupdate /system_tb/system_i0/reset_n
add wave -noupdate /system_tb/system_i0/clk
add wave -noupdate /system_tb/system_i0/channel_active_in_n
add wave -noupdate /system_tb/system_i0/clear_mt_in_n
add wave -noupdate /system_tb/system_i0/clear_sps_in_n
add wave -noupdate /system_tb/system_i0/error_in_n
add wave -noupdate /system_tb/system_i0/test_mt_in_n
add wave -noupdate /system_tb/system_i0/test_sps_in_n
add wave -noupdate -divider system
add wave -noupdate /system_tb/system_i0/error_out_int
add wave -noupdate /system_tb/system_i0/channel_ok_out_int
add wave -noupdate -divider output
add wave -noupdate /system_tb/system_i0/channel_ok_out
add wave -noupdate /system_tb/system_i0/channel_ok_out
add wave -noupdate /system_tb/system_i0/error_out_n
add wave -noupdate /system_tb/system_i0/main_error_led_out_n
add wave -noupdate /system_tb/system_i0/main_ok_led_out_n
add wave -noupdate /system_tb/system_i0/main_ok_opto_out
add wave -noupdate /system_tb/system_i0/test_led1_n
add wave -noupdate /system_tb/system_i0/test_led2_n
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {42667 ps} 0}
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
WaveRestoreZoom {0 ps} {256 ns}
