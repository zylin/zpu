onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider testbench
add wave -noupdate -format Logic /top_tb/simulation_run
add wave -noupdate -format Logic /top_tb/tb_clk_50mhz
add wave -noupdate -format Logic /top_tb/tb_rot_center
add wave -noupdate -divider box
add wave -noupdate -format Logic /top_tb/top_i0/box_i0/reset
add wave -noupdate -format Logic /top_tb/top_i0/box_i0/clk
add wave -noupdate -format Logic /top_tb/top_i0/box_i0/break
add wave -noupdate -divider AHB
add wave -noupdate -format Literal -radix hexadecimal -expand /top_tb/top_i0/box_i0/ahbctrl_i0_msti
add wave -noupdate -format Literal -radix hexadecimal /top_tb/top_i0/box_i0/ahbmo
add wave -noupdate -divider gpio
add wave -noupdate -format Literal -radix hexadecimal /top_tb/top_i0/box_i0/gpioi
add wave -noupdate -format Literal -radix hexadecimal /top_tb/top_i0/box_i0/gpioo
add wave -noupdate -divider LEDs
add wave -noupdate -format Literal /top_tb/tb_led
add wave -noupdate -divider clocks
add wave -noupdate -format Logic /top_tb/top_i0/box_i0/clk
add wave -noupdate -format Logic /top_tb/top_i0/box_i0/clk_gen_i0_clk_dv
add wave -noupdate -format Logic /top_tb/top_i0/box_i0/clk_gen_i0_clk_fx
add wave -noupdate -format Logic /top_tb/top_i0/box_i0/clk_gen_i0_clk_ready
add wave -noupdate -format Logic /top_tb/top_i0/box_i0/clkddr
add wave -noupdate -format Logic /top_tb/top_i0/box_i0/reset
add wave -noupdate -format Literal /top_tb/top_i0/box_i0/reset_shiftreg
add wave -noupdate -divider {DDR dcm}
add wave -noupdate -format Logic /top_tb/top_i0/box_i0/ddrspa_i0/ddr_phy0/ddr_phy0/xc3se/ddr_phy0/nops/read_dll/clkin
add wave -noupdate -format Logic /top_tb/top_i0/box_i0/ddrspa_i0/ddr_phy0/ddr_phy0/xc3se/ddr_phy0/nops/read_dll/rst
add wave -noupdate -format Logic /top_tb/top_i0/box_i0/ddrspa_i0/ddr_phy0/ddr_phy0/xc3se/ddr_phy0/nops/read_dll/clk0
add wave -noupdate -format Logic /top_tb/top_i0/box_i0/ddrspa_i0/ddr_phy0/ddr_phy0/xc3se/ddr_phy0/nops/read_dll/clk2x
add wave -noupdate -format Logic /top_tb/top_i0/box_i0/ddrspa_i0/ddr_phy0/ddr_phy0/xc3se/ddr_phy0/nops/read_dll/clkfx
add wave -noupdate -format Logic /top_tb/top_i0/box_i0/ddrspa_i0/ddr_phy0/ddr_phy0/xc3se/ddr_phy0/nops/read_dll/clkdv
add wave -noupdate -divider {DDR Ram}
add wave -noupdate -format Literal /top_tb/top_i0/box_i0/ddr_clk
add wave -noupdate -format Literal /top_tb/top_i0/box_i0/ddr_clkb
add wave -noupdate -format Logic /top_tb/top_i0/box_i0/ddr_clk_fb
add wave -noupdate -format Logic /top_tb/top_i0/box_i0/ddr_clk_fb_out
add wave -noupdate -format Literal /top_tb/top_i0/box_i0/ddr_cke
add wave -noupdate -format Literal /top_tb/top_i0/box_i0/ddr_csb
add wave -noupdate -format Logic /top_tb/top_i0/box_i0/ddr_web
add wave -noupdate -format Logic /top_tb/top_i0/box_i0/ddr_rasb
add wave -noupdate -format Logic /top_tb/top_i0/box_i0/ddr_casb
add wave -noupdate -format Literal /top_tb/top_i0/box_i0/ddr_dm
add wave -noupdate -format Literal /top_tb/top_i0/box_i0/ddr_dqs
add wave -noupdate -format Literal -radix unsigned /top_tb/top_i0/box_i0/ddr_ad
add wave -noupdate -format Literal /top_tb/top_i0/box_i0/ddr_ba
add wave -noupdate -format Literal /top_tb/top_i0/box_i0/ddr_dq
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6441530000 ps} 0} {{Cursor 2} {5052166 ps} 0}
configure wave -namecolwidth 161
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
WaveRestoreZoom {439444 ps} {978593 ps}
