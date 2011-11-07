onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_tb/simulation_run
add wave -noupdate /top_tb/tb_cpu_reset
add wave -noupdate /top_tb/tb_sysclk_n
add wave -noupdate /top_tb/tb_sysclk_p
add wave -noupdate /top_tb/tb_user_clock
add wave -noupdate -divider <NULL>
add wave -noupdate /top_tb/tb_gpio_button
add wave -noupdate /top_tb/tb_gpio_header_ls
add wave -noupdate /top_tb/tb_gpio_led
add wave -noupdate /top_tb/tb_gpio_switch
add wave -noupdate -expand -group USB/RS232 /top_tb/tb_usb_1_cts
add wave -noupdate -expand -group USB/RS232 /top_tb/tb_usb_1_rts
add wave -noupdate -expand -group USB/RS232 /top_tb/tb_usb_1_rx
add wave -noupdate -expand -group USB/RS232 /top_tb/tb_usb_1_tx
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
add wave -noupdate -group {Flash memory} /top_tb/tb_flash_a
add wave -noupdate -group {Flash memory} /top_tb/tb_flash_d
add wave -noupdate -group {Flash memory} /top_tb/tb_fpga_d0_din_miso_miso1
add wave -noupdate -group {Flash memory} /top_tb/tb_fpga_d1_miso2
add wave -noupdate -group {Flash memory} /top_tb/tb_fpga_d2_miso3
add wave -noupdate -group {Flash memory} /top_tb/tb_flash_we_b
add wave -noupdate -group {Flash memory} /top_tb/tb_flash_oe_b
add wave -noupdate -group {Flash memory} /top_tb/tb_flash_ce_b
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_clk0_m2c_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_clk0_m2c_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_clk1_m2c_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_clk1_m2c_p
add wave -noupdate -group {FMC connector} /top_tb/tb_iic_scl_main
add wave -noupdate -group {FMC connector} /top_tb/tb_iic_sda_main
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la00_cc_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la00_cc_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la01_cc_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la01_cc_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la02_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la02_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la03_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la03_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la04_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la04_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la05_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la05_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la06_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la06_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la07_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la07_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la08_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la08_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la09_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la09_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la10_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la10_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la11_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la11_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la12_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la12_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la13_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la13_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la14_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la14_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la15_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la15_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la16_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la16_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la17_cc_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la17_cc_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la18_cc_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la18_cc_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la19_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la19_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la20_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la20_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la21_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la21_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la22_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la22_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la23_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la23_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la24_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la24_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la25_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la25_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la26_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la26_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la27_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la27_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la28_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la28_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la29_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la29_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la30_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la30_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la31_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la31_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la32_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la32_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la33_n
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_la33_p
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_prsnt_m2c_l
add wave -noupdate -group {FMC connector} /top_tb/tb_fmc_pwr_good_flash_rst_b
add wave -noupdate -group {special FPGA pins} /top_tb/tb_fpga_awake
add wave -noupdate -group {special FPGA pins} /top_tb/tb_fpga_cclk
add wave -noupdate -group {special FPGA pins} /top_tb/tb_fpga_cmp_clk
add wave -noupdate -group {special FPGA pins} /top_tb/tb_fpga_cmp_mosi
add wave -noupdate -group {special FPGA pins} /top_tb/tb_fpga_hswapen
add wave -noupdate -group {special FPGA pins} /top_tb/tb_fpga_init_b
add wave -noupdate -group {special FPGA pins} /top_tb/tb_fpga_m0_cmp_miso
add wave -noupdate -group {special FPGA pins} /top_tb/tb_fpga_m1
add wave -noupdate -group {special FPGA pins} /top_tb/tb_fpga_mosi_csi_b_miso0
add wave -noupdate -group {special FPGA pins} /top_tb/tb_fpga_onchip_term1
add wave -noupdate -group {special FPGA pins} /top_tb/tb_fpga_onchip_term2
add wave -noupdate -group {special FPGA pins} /top_tb/tb_fpga_vtemp
add wave -noupdate -group {special FPGA pins} /top_tb/tb_spi_cs_b
add wave -noupdate -group {Ethernet phy} /top_tb/tb_phy_col
add wave -noupdate -group {Ethernet phy} /top_tb/tb_phy_crs
add wave -noupdate -group {Ethernet phy} /top_tb/tb_phy_int
add wave -noupdate -group {Ethernet phy} /top_tb/tb_phy_mdc
add wave -noupdate -group {Ethernet phy} /top_tb/tb_phy_mdio
add wave -noupdate -group {Ethernet phy} /top_tb/tb_phy_reset
add wave -noupdate -group {Ethernet phy} /top_tb/tb_phy_rxclk
add wave -noupdate -group {Ethernet phy} /top_tb/tb_phy_rxctl_rxdv
add wave -noupdate -group {Ethernet phy} /top_tb/tb_phy_rxd
add wave -noupdate -group {Ethernet phy} /top_tb/tb_phy_rxer
add wave -noupdate -group {Ethernet phy} /top_tb/tb_phy_txclk
add wave -noupdate -group {Ethernet phy} /top_tb/tb_phy_txctl_txen
add wave -noupdate -group {Ethernet phy} /top_tb/tb_phy_txc_gtxclk
add wave -noupdate -group {Ethernet phy} /top_tb/tb_phy_txd
add wave -noupdate -group {Ethernet phy} /top_tb/tb_phy_txer
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1393701250 ps} 0} {{Cursor 2} {138750 ps} 0}
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
WaveRestoreZoom {0 ps} {327615 ps}
