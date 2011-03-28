onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/tb_clk
add wave -noupdate /testbench/tb_pulse_13
add wave -noupdate /testbench/singlepulser_i0_pulse_out
add wave -noupdate -divider singlepulser
add wave -noupdate /testbench/singlepulser_i0/pulse_reg
add wave -noupdate -radix unsigned /testbench/singlepulser_i0/singlepulser
add wave -noupdate /testbench/singlepulser_i0/pulse_out_int
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {113 ns} 0} {{Cursor 2} {1236 ns} 0}
configure wave -namecolwidth 171
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
WaveRestoreZoom {1198 ns} {1246 ns}
