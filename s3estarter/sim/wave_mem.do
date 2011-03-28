onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider testbench
add wave -noupdate /top_tb/simulation_run
add wave -noupdate /top_tb/tb_clk_50mhz
add wave -noupdate /top_tb/tb_rot_center
add wave -noupdate -divider box
add wave -noupdate /top_tb/top_i0/box_i0/reset
add wave -noupdate /top_tb/top_i0/box_i0/clk
add wave -noupdate /top_tb/top_i0/box_i0/break
add wave -noupdate -divider ZPU
add wave -noupdate -radix hexadecimal /top_tb/top_i0/box_i0/zpu_ahb_i0/zpu_i0/clk
add wave -noupdate -radix hexadecimal /top_tb/top_i0/box_i0/zpu_ahb_i0/zpu_i0/in_mem_busy
add wave -noupdate -radix hexadecimal /top_tb/top_i0/box_i0/zpu_ahb_i0/zpu_i0/out_mem_addr
add wave -noupdate -radix hexadecimal /top_tb/top_i0/box_i0/zpu_ahb_i0/zpu_i0/out_mem_readenable
add wave -noupdate -radix hexadecimal /top_tb/top_i0/box_i0/zpu_ahb_i0/zpu_i0/mem_read
add wave -noupdate -radix hexadecimal /top_tb/top_i0/box_i0/zpu_ahb_i0/zpu_i0/out_mem_writeenable
add wave -noupdate -radix hexadecimal /top_tb/top_i0/box_i0/zpu_ahb_i0/zpu_i0/mem_write
add wave -noupdate -radix hexadecimal /top_tb/top_i0/box_i0/zpu_ahb_i0/zpu_i0/interrupt
add wave -noupdate -color {Lime Green} -format Analog-Step -height 74 -max 4094.0 -min 3700.0 -radix hexadecimal /top_tb/top_i0/box_i0/zpu_ahb_i0/zpu_i0/sp
add wave -noupdate -color {Violet Red} -format Analog-Step -height 74 -max 6585.0000000000009 -radix hexadecimal /top_tb/top_i0/box_i0/zpu_ahb_i0/zpu_i0/pc
add wave -noupdate -divider wrapper
add wave -noupdate /top_tb/top_i0/box_i0/zpu_ahb_i0/state
add wave -noupdate /top_tb/top_i0/box_i0/zpu_ahb_i0/busy_to_zpu
add wave -noupdate /top_tb/top_i0/box_i0/zpu_ahb_i0/clk_en
add wave -noupdate -divider {new RAM}
add wave -noupdate -radix hexadecimal /top_tb/top_i0/box_i0/dualport_ram_ahb_wrapper_i0/ahbsi
add wave -noupdate -radix hexadecimal /top_tb/top_i0/box_i0/dualport_ram_ahb_wrapper_i0/ahbso
add wave -noupdate -radix hexadecimal /top_tb/top_i0/box_i0/dualport_ram_ahb_wrapper_i0/r
add wave -noupdate -radix hexadecimal /top_tb/top_i0/box_i0/dualport_ram_ahb_wrapper_i0/s
add wave -noupdate -radix hexadecimal /top_tb/top_i0/box_i0/dualport_ram_ahb_wrapper_i0/we
add wave -noupdate -radix hexadecimal -subitemconfig {/top_tb/top_i0/box_i0/dualport_ram_ahb_wrapper_i0/addr(13) {-radix hexadecimal} /top_tb/top_i0/box_i0/dualport_ram_ahb_wrapper_i0/addr(12) {-radix hexadecimal} /top_tb/top_i0/box_i0/dualport_ram_ahb_wrapper_i0/addr(11) {-radix hexadecimal} /top_tb/top_i0/box_i0/dualport_ram_ahb_wrapper_i0/addr(10) {-radix hexadecimal} /top_tb/top_i0/box_i0/dualport_ram_ahb_wrapper_i0/addr(9) {-radix hexadecimal} /top_tb/top_i0/box_i0/dualport_ram_ahb_wrapper_i0/addr(8) {-radix hexadecimal} /top_tb/top_i0/box_i0/dualport_ram_ahb_wrapper_i0/addr(7) {-radix hexadecimal} /top_tb/top_i0/box_i0/dualport_ram_ahb_wrapper_i0/addr(6) {-radix hexadecimal} /top_tb/top_i0/box_i0/dualport_ram_ahb_wrapper_i0/addr(5) {-radix hexadecimal} /top_tb/top_i0/box_i0/dualport_ram_ahb_wrapper_i0/addr(4) {-radix hexadecimal} /top_tb/top_i0/box_i0/dualport_ram_ahb_wrapper_i0/addr(3) {-radix hexadecimal} /top_tb/top_i0/box_i0/dualport_ram_ahb_wrapper_i0/addr(2) {-radix hexadecimal}} /top_tb/top_i0/box_i0/dualport_ram_ahb_wrapper_i0/addr
add wave -noupdate -divider mem
add wave -noupdate -radix hexadecimal /top_tb/top_i0/box_i0/dualport_ram_ahb_wrapper_i0/dualport_ram_i0/memawriteenable
add wave -noupdate -radix hexadecimal /top_tb/top_i0/box_i0/dualport_ram_ahb_wrapper_i0/dualport_ram_i0/memaaddr
add wave -noupdate -radix hexadecimal /top_tb/top_i0/box_i0/dualport_ram_ahb_wrapper_i0/dualport_ram_i0/memawrite
add wave -noupdate -radix hexadecimal /top_tb/top_i0/box_i0/dualport_ram_ahb_wrapper_i0/dualport_ram_i0/memaread
add wave -noupdate -divider AHB
add wave -noupdate -radix hexadecimal -subitemconfig {/top_tb/top_i0/box_i0/ahbctrl_i0_msti.hgrant {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbctrl_i0_msti.hready {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbctrl_i0_msti.hresp {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbctrl_i0_msti.hrdata {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbctrl_i0_msti.hcache {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbctrl_i0_msti.hirq {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbctrl_i0_msti.testen {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbctrl_i0_msti.testrst {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbctrl_i0_msti.scanen {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbctrl_i0_msti.testoen {-height 15 -radix hexadecimal}} /top_tb/top_i0/box_i0/ahbctrl_i0_msti
add wave -noupdate -radix hexadecimal -subitemconfig {/top_tb/top_i0/box_i0/ahbmo(3) {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbmo(2) {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbmo(1) {-height 15 -radix hexadecimal -expand} /top_tb/top_i0/box_i0/ahbmo(1).hbusreq {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbmo(1).hlock {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbmo(1).htrans {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbmo(1).haddr {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbmo(1).hwrite {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbmo(1).hsize {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbmo(1).hburst {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbmo(1).hprot {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbmo(1).hwdata {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbmo(1).hirq {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbmo(1).hconfig {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbmo(1).hindex {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbmo(0) {-height 15 -radix hexadecimal -expand} /top_tb/top_i0/box_i0/ahbmo(0).hbusreq {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbmo(0).hlock {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbmo(0).htrans {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbmo(0).haddr {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbmo(0).hwrite {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbmo(0).hsize {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbmo(0).hburst {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbmo(0).hprot {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbmo(0).hwdata {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbmo(0).hirq {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbmo(0).hconfig {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/ahbmo(0).hindex {-height 15 -radix hexadecimal}} /top_tb/top_i0/box_i0/ahbmo
add wave -noupdate -divider gpio
add wave -noupdate -radix hexadecimal -expand -subitemconfig {/top_tb/top_i0/box_i0/gpioi.din {-radix hexadecimal} /top_tb/top_i0/box_i0/gpioi.sig_in {-radix hexadecimal} /top_tb/top_i0/box_i0/gpioi.sig_en {-radix hexadecimal}} /top_tb/top_i0/box_i0/gpioi
add wave -noupdate -divider LEDs
add wave -noupdate -radix hexadecimal /top_tb/tb_led
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {17379510000 ps} 0} {{Cursor 2} {1074266 ps} 0}
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {188080 ps}
