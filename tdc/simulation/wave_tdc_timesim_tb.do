onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tdc_tb/simulation_run
add wave -noupdate -format Logic /tdc_tb/tb_clk
add wave -noupdate -divider ins
add wave -noupdate -format Logic /tdc_tb/pulse0
add wave -noupdate -format Logic /tdc_tb/pulse1
add wave -noupdate -divider chains
add wave -noupdate -format Logic /tdc_tb/tdc_timesim_i0/channels_0_ibuf/o
add wave -noupdate -format Logic /tdc_tb/tdc_timesim_i0/channels_i_0_channel_i_n73_xused/o
add wave -noupdate -format Logic /tdc_tb/tdc_timesim_i0/channels_i_0_channel_i_mshreg_tapsr2_2_srl16e/d
add wave -noupdate -divider outs
add wave -noupdate -format Literal -radix unsigned -expand /tdc_tb/tdc_i0_results
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {13926 ps} 0}
configure wave -namecolwidth 287
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {189081 ps}
