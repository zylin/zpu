onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tdc_tb/simulation_run
add wave -noupdate -format Logic /tdc_tb/tb_clk
add wave -noupdate -divider ins
add wave -noupdate -format Logic /tdc_tb/pulse0
add wave -noupdate -divider chains
add wave -noupdate -format Literal -radix hexadecimal /tdc_tb/tdc_i0/channels_i(0)/channel_i/taps
add wave -noupdate -format Literal -radix hexadecimal /tdc_tb/tdc_i0/channels_i(0)/channel_i/tapsr1
add wave -noupdate -format Literal -radix hexadecimal /tdc_tb/tdc_i0/channels_i(0)/channel_i/tapsr2
add wave -noupdate -format Literal -radix hexadecimal /tdc_tb/tdc_i0/channels_i(0)/channel_i/thermometer_coder_i0/thermo_in
add wave -noupdate -format Literal -radix unsigned /tdc_tb/tdc_i0/channels_i(0)/channel_i/thermometer_coder_i0/code_out
add wave -noupdate -divider outs
add wave -noupdate -format Literal -radix unsigned -expand /tdc_tb/tdc_i0_results
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {45486 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 474
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {76140 ps}
