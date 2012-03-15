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
add wave -noupdate -radix hexadecimal /top_tb/top_i0/box_i0/ahbctrl_i0/msti.hgrant
add wave -noupdate /top_tb/top_i0/box_i0/ahbmo(1)
add wave -noupdate -childformat {{/top_tb/top_i0/box_i0/ahbmo(0).haddr -radix hexadecimal} {/top_tb/top_i0/box_i0/ahbmo(0).hwdata -radix hexadecimal} {/top_tb/top_i0/box_i0/ahbmo(0).hirq -radix hexadecimal} {/top_tb/top_i0/box_i0/ahbmo(0).hconfig -radix hexadecimal}} -expand -subitemconfig {/top_tb/top_i0/box_i0/ahbmo(0).haddr {-radix hexadecimal} /top_tb/top_i0/box_i0/ahbmo(0).hwdata {-radix hexadecimal} /top_tb/top_i0/box_i0/ahbmo(0).hirq {-radix hexadecimal} /top_tb/top_i0/box_i0/ahbmo(0).hconfig {-radix hexadecimal}} /top_tb/top_i0/box_i0/ahbmo(0)
add wave -noupdate -expand -group ZPU /top_tb/top_i0/box_i0/zpu_ahb_i0/zpu_size_i1/zpu_i0/interrupt
add wave -noupdate -expand -group ZPU -radix hexadecimal -childformat {{/top_tb/top_i0/box_i0/zpu_ahb_i0/zpu_size_i1/zpu_i0/opcode(0) -radix hexadecimal} {/top_tb/top_i0/box_i0/zpu_ahb_i0/zpu_size_i1/zpu_i0/opcode(1) -radix hexadecimal} {/top_tb/top_i0/box_i0/zpu_ahb_i0/zpu_size_i1/zpu_i0/opcode(2) -radix hexadecimal} {/top_tb/top_i0/box_i0/zpu_ahb_i0/zpu_size_i1/zpu_i0/opcode(3) -radix hexadecimal}} -expand -subitemconfig {/top_tb/top_i0/box_i0/zpu_ahb_i0/zpu_size_i1/zpu_i0/opcode(0) {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/zpu_ahb_i0/zpu_size_i1/zpu_i0/opcode(1) {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/zpu_ahb_i0/zpu_size_i1/zpu_i0/opcode(2) {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/zpu_ahb_i0/zpu_size_i1/zpu_i0/opcode(3) {-height 15 -radix hexadecimal}} /top_tb/top_i0/box_i0/zpu_ahb_i0/zpu_size_i1/zpu_i0/opcode
add wave -noupdate -expand -group ZPU -format Analog-Step -height 74 -max 15999.999999999998 -radix hexadecimal /top_tb/top_i0/box_i0/zpu_ahb_i0/zpu_size_i1/zpu_i0/pc
add wave -noupdate -expand -group ZPU -format Analog-Step -height 74 -max 16385.0 -min 16356.0 -radix hexadecimal /top_tb/top_i0/box_i0/zpu_ahb_i0/zpu_size_i1/zpu_i0/sp
add wave -noupdate -expand -group ZPU -radix hexadecimal /top_tb/top_i0/box_i0/zpu_ahb_i0/zpu_size_i1/zpu_i0/stackA
add wave -noupdate -expand -group ZPU -radix hexadecimal /top_tb/top_i0/box_i0/zpu_ahb_i0/zpu_size_i1/zpu_i0/stackB
add wave -noupdate -expand -group ZPU /top_tb/top_i0/box_i0/zpu_ahb_i0/zpu_size_i1/zpu_i0/idim_flag
add wave -noupdate -expand -group ZPU /top_tb/top_i0/box_i0/zpu_ahb_i0/zpu_size_i1/zpu_i0/state
add wave -noupdate -expand -group ZPU /top_tb/top_i0/box_i0/zpu_ahb_i0/zpu_size_i1/zpu_i0/insn
add wave -noupdate -expand -group ZPU /top_tb/top_i0/box_i0/zpu_ahb_i0/zpu_size_i1/zpu_i0/in_mem_busy
add wave -noupdate -expand -group ZPU /top_tb/top_i0/box_i0/zpu_ahb_i0/clk_en
add wave -noupdate -expand -group ZPU /top_tb/top_i0/box_i0/zpu_ahb_i0/clk_en_to_zpu
add wave -noupdate -expand -group ZPU -radix hexadecimal /top_tb/top_i0/box_i0/zpu_ahb_i0/data_from_ahb
add wave -noupdate -expand -group ZPU -radix hexadecimal /top_tb/top_i0/box_i0/zpu_ahb_i0/data_to_ahb
add wave -noupdate -expand -group ZPU /top_tb/top_i0/box_i0/zpu_ahb_i0/mem_request
add wave -noupdate -expand -group ZPU -radix hexadecimal /top_tb/top_i0/box_i0/zpu_ahb_i0/mem_read
add wave -noupdate -expand -group ZPU -radix hexadecimal /top_tb/top_i0/box_i0/zpu_ahb_i0/mem_write
add wave -noupdate -expand -group ZPU /top_tb/top_i0/box_i0/zpu_ahb_i0/mem_ack
add wave -noupdate -expand -group ZPU -radix hexadecimal /top_tb/top_i0/box_i0/zpu_ahb_i0/out_mem_addr
add wave -noupdate -expand -group ZPU /top_tb/top_i0/box_i0/zpu_ahb_i0/out_mem_readEnable
add wave -noupdate -expand -group ZPU /top_tb/top_i0/box_i0/zpu_ahb_i0/out_mem_writeEnable
add wave -noupdate -expand -group ZPU /top_tb/top_i0/box_i0/zpu_ahb_i0/state
add wave -noupdate /top_tb/top_i0/box_i0/ahbso(5)
add wave -noupdate /top_tb/top_i0/box_i0/ahbso(3)
add wave -noupdate /top_tb/top_i0/box_i0/ahbso(1)
add wave -noupdate /top_tb/top_i0/box_i0/ahbso(0)
add wave -noupdate -divider GPIO
add wave -noupdate /top_tb/top_i0/gpio_button
add wave -noupdate /top_tb/top_i0/gpio_switch
add wave -noupdate /top_tb/top_i0/gpio_header_ls
add wave -noupdate /top_tb/top_i0/gpio_led
add wave -noupdate -expand -group PHY /top_tb/top_i0/phy_mdc
add wave -noupdate -expand -group PHY /top_tb/top_i0/phy_mdio
add wave -noupdate -expand -group PHY /top_tb/top_i0/phy_txclk
add wave -noupdate -expand -group PHY /top_tb/top_i0/phy_rxclk
add wave -noupdate -expand -group PHY /top_tb/top_i0/phy_int
add wave -noupdate -expand -group PHY /top_tb/top_i0/phy_reset_b
add wave -noupdate -expand -group PHY /top_tb/top_i0/phy_col
add wave -noupdate -expand -group PHY /top_tb/top_i0/phy_crs
add wave -noupdate -expand -group PHY /top_tb/top_i0/phy_rxctl_rxdv
add wave -noupdate -expand -group PHY /top_tb/top_i0/phy_rxd
add wave -noupdate -expand -group PHY /top_tb/top_i0/phy_rxer
add wave -noupdate -expand -group PHY /top_tb/top_i0/phy_txc_gtxclk
add wave -noupdate -expand -group PHY /top_tb/top_i0/phy_txctl_txen
add wave -noupdate -expand -group PHY /top_tb/top_i0/phy_txd
add wave -noupdate -expand -group PHY /top_tb/top_i0/phy_txer
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {257408000 ps} 0} {{Cursor 2} {254736000 ps} 0}
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
WaveRestoreZoom {254408318 ps} {258856676 ps}
