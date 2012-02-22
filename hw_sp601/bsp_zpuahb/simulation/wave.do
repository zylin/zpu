onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_tb/simulation_run
add wave -noupdate /top_tb/tb_sysclk_p
add wave -noupdate /top_tb/tb_user_clock
add wave -noupdate /top_tb/tb_user_sma_clock_p
add wave -noupdate /top_tb/tb_cpu_reset
add wave -noupdate -divider box
add wave -noupdate /top_tb/top_i0/box_i0/clk
add wave -noupdate /top_tb/top_i0/box_i0/box_reset
add wave -noupdate -divider GPIO
add wave -noupdate /top_tb/top_i0/gpio_button
add wave -noupdate /top_tb/top_i0/gpio_switch
add wave -noupdate /top_tb/top_i0/gpio_header_ls
add wave -noupdate -expand /top_tb/top_i0/gpio_led
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {145754237 ps} 0}
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
WaveRestoreZoom {0 ps} {735 us}
