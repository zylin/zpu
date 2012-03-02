onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_tb/simulation_run
add wave -noupdate -divider <NULL>
add wave -noupdate /top_tb/tb_cpu_reset
add wave -noupdate /top_tb/tb_sysclk_p
add wave -noupdate /top_tb/central_trigger_testboard_i0/clk_fast_p
add wave -noupdate /top_tb/central_trigger_testboard_i0/clk_slow_p
add wave -noupdate /top_tb/top_i0/fmc_clk0_m2c_p
add wave -noupdate /top_tb/top_i0/clk_in_260
add wave -noupdate /top_tb/top_i0/clk_in_13
add wave -noupdate /top_tb/top_i0/user_sma_clock_p
add wave -noupdate /top_tb/top_i0/user_sma_clock_n
add wave -noupdate -group DDR2 /top_tb/tb_ddr2_a
add wave -noupdate -group DDR2 /top_tb/tb_ddr2_ba
add wave -noupdate -group DDR2 /top_tb/tb_ddr2_cas_b
add wave -noupdate -group DDR2 /top_tb/tb_ddr2_ras_b
add wave -noupdate -group DDR2 /top_tb/tb_ddr2_we_b
add wave -noupdate -group DDR2 /top_tb/tb_ddr2_cke
add wave -noupdate -group DDR2 /top_tb/tb_ddr2_clk_n
add wave -noupdate -group DDR2 /top_tb/tb_ddr2_clk_p
add wave -noupdate -group DDR2 /top_tb/tb_ddr2_dq
add wave -noupdate -group DDR2 /top_tb/tb_ddr2_ldm
add wave -noupdate -group DDR2 /top_tb/tb_ddr2_udm
add wave -noupdate -group DDR2 /top_tb/tb_ddr2_ldqs_n
add wave -noupdate -group DDR2 /top_tb/tb_ddr2_ldqs_p
add wave -noupdate -group DDR2 /top_tb/tb_ddr2_udqs_n
add wave -noupdate -group DDR2 /top_tb/tb_ddr2_udqs_p
add wave -noupdate -group DDR2 /top_tb/tb_ddr2_odt
add wave -noupdate /top_tb/tb_gpio_button
add wave -noupdate /top_tb/tb_gpio_header_ls
add wave -noupdate /top_tb/tb_gpio_led
add wave -noupdate /top_tb/tb_gpio_switch
add wave -noupdate -group PHY /top_tb/tb_phy_col
add wave -noupdate -group PHY /top_tb/tb_phy_crs
add wave -noupdate -group PHY /top_tb/tb_phy_int
add wave -noupdate -group PHY /top_tb/tb_phy_mdc
add wave -noupdate -group PHY /top_tb/tb_phy_mdio
add wave -noupdate -group PHY /top_tb/tb_phy_reset_b
add wave -noupdate -group PHY /top_tb/tb_phy_rxclk
add wave -noupdate -group PHY /top_tb/tb_phy_rxctl_rxdv
add wave -noupdate -group PHY /top_tb/tb_phy_rxd
add wave -noupdate -group PHY /top_tb/tb_phy_rxer
add wave -noupdate -group PHY /top_tb/tb_phy_txclk
add wave -noupdate -group PHY /top_tb/tb_phy_txctl_txen
add wave -noupdate -group PHY /top_tb/tb_phy_txc_gtxclk
add wave -noupdate -group PHY /top_tb/tb_phy_txd
add wave -noupdate -group PHY /top_tb/tb_phy_txer
add wave -noupdate -group {USB serial} /top_tb/tb_usb_1_cts
add wave -noupdate -group {USB serial} /top_tb/tb_usb_1_rts
add wave -noupdate -group {USB serial} /top_tb/tb_usb_1_rx
add wave -noupdate -group {USB serial} /top_tb/tb_usb_1_tx
add wave -noupdate -divider Channels
add wave -noupdate /top_tb/top_i0/box_i0_trigger_signals
add wave -noupdate /top_tb/top_i0/box_i0/channel_update
add wave -noupdate -divider SFP
add wave -noupdate /top_tb/top_i0/box_i0/sfp_status
add wave -noupdate -expand /top_tb/top_i0/box_i0/sfp_control
add wave -noupdate /top_tb/top_i0/box_i0/sfp_rx
add wave -noupdate /top_tb/top_i0/box_i0/sfp_tx
add wave -noupdate /top_tb/top_i0/box_i0/sfp_controller_apb_i0/r
add wave -noupdate /top_tb/top_i0/box_i0/sfp_controller_apb_i0/source
add wave -noupdate /top_tb/top_i0/box_i0/sfp_controller_apb_i0/rx_buffer
add wave -noupdate /top_tb/top_i0/box_i0/sfp_controller_apb_i0/tx_buffer
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {23177 ps} 0} {{Cursor 2} {6769136 ps} 0}
configure wave -namecolwidth 239
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
WaveRestoreZoom {0 ps} {112512 ps}
