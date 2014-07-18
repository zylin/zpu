onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_tb/simulation_run
add wave -noupdate /top_tb/tb_clk
add wave -noupdate /top_tb/tb_user_led_n
add wave -noupdate -expand -group {carrier board LEDs} /top_tb/tb_b2b_b3_l59_n
add wave -noupdate -expand -group {carrier board LEDs} /top_tb/tb_b2b_b3_l59_p
add wave -noupdate -expand -group {carrier board LEDs} /top_tb/tb_b2b_b3_l9_p
add wave -noupdate -expand -group {carrier board LEDs} /top_tb/tb_b2b_b3_l9_n
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {83164314 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1923
configure wave -griddelta 32
configure wave -timeline 1
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {901530 ns}
