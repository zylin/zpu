onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_tb/simulation_run
add wave -noupdate /top_tb/tb_reset_n
add wave -noupdate /top_tb/tb_clk
add wave -noupdate -divider SPI
add wave -noupdate /top_tb/tb_ssio_do
add wave -noupdate /top_tb/tb_ssio_clk
add wave -noupdate /top_tb/tb_ssio_lo
add wave -noupdate /top_tb/tb_ssio_di
add wave -noupdate /top_tb/tb_ssio_li
add wave -noupdate -divider <NULL>
add wave -noupdate -expand /top_tb/tb_button_n
add wave -noupdate /top_tb/tb_dip_switch_n
add wave -noupdate -expand /top_tb/tb_led_n
add wave -noupdate -divider <NULL>
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {333000000000 ps} 0} {{Cursor 2} {365440964649 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 111
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
WaveRestoreZoom {486107784431 ps} {664831188687 ps}
