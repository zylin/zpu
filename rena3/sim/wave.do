onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /rena3_model_tb/simulation_run
add wave -noupdate -format Logic /rena3_model_tb/clock
add wave -noupdate -format Logic /rena3_model_tb/reset
add wave -noupdate -format Literal -expand /rena3_model_tb/r
add wave -noupdate -divider RENA3
add wave -noupdate -format Logic /rena3_model_tb/rena3_model_i0/cshift
add wave -noupdate -format Logic /rena3_model_tb/rena3_model_i0/cin
add wave -noupdate -format Logic /rena3_model_tb/rena3_model_i0/cs
add wave -noupdate -format Literal /rena3_model_tb/rena3_model_i0/channel_configuration/channel_configuration
add wave -noupdate -format Literal -expand /rena3_model_tb/rena3_model_i0/channel_configuration_array
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2237667 ps} 0}
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
WaveRestoreZoom {0 ps} {5754 ns}
