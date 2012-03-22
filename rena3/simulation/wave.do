onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_tb/top_i0/simulation_break
add wave -noupdate /top_tb/top_i0/cpu_reset
add wave -noupdate /top_tb/top_i0/sysclk_p
add wave -noupdate /top_tb/top_i0/user_clock
add wave -noupdate /top_tb/top_i0/user_sma_clock_p
add wave -noupdate -group clocks /top_tb/top_i0/sys_clk
add wave -noupdate -group clocks /top_tb/top_i0/clk_100
add wave -noupdate -group clocks /top_tb/top_i0/clk_box
add wave -noupdate -group clocks /top_tb/top_i0/clk_vga
add wave -noupdate -group clocks /top_tb/top_i0/clk_gtx_125
add wave -noupdate -group clocks /top_tb/top_i0/reset
add wave -noupdate -group clocks /top_tb/top_i0/reset_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_clk0_m2c_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_clk0_m2c_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_clk1_m2c_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_clk1_m2c_p
add wave -noupdate -group FMC /top_tb/top_i0/iic_scl_main
add wave -noupdate -group FMC /top_tb/top_i0/iic_sda_main
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la00_cc_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la00_cc_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la01_cc_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la01_cc_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la02_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la02_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la03_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la03_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la04_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la04_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la05_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la05_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la06_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la06_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la07_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la07_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la08_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la08_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la09_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la09_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la10_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la10_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la11_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la11_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la12_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la12_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la13_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la13_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la14_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la14_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la15_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la15_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la16_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la16_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la17_cc_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la17_cc_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la18_cc_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la18_cc_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la19_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la19_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la20_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la20_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la21_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la21_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la22_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la22_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la23_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la23_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la24_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la24_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la25_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la25_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la26_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la26_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la27_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la27_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la28_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la28_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la29_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la29_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la30_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la30_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la31_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la31_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la32_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la32_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la33_n
add wave -noupdate -group FMC /top_tb/top_i0/fmc_la33_p
add wave -noupdate -group FMC /top_tb/top_i0/fmc_prsnt_m2c_l
add wave -noupdate -group FMC /top_tb/top_i0/fmc_pwr_good_flash_rst_b
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/TEST
add wave -noupdate -group RENA3 -format Analog-Step -height 50 -max 4.0 /top_tb/rena3_testboard_i0/rena3_model_i0/VU
add wave -noupdate -group RENA3 -format Analog-Step -height 50 -max 4.0 /top_tb/rena3_testboard_i0/rena3_model_i0/VV
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/DETECTOR_IN
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/AOUTP
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/AOUTN
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/OVERFLOW
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/CSHIFT
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/CIN
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/CS
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/TS_N
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/TS_P
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/TF_N
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/TF_P
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/FOUT
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/SOUT
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/TOUT
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/READ
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/TIN
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/SIN
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/FIN
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/SHRCLK
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/FHRCLK
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/ACQUIRE_P
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/ACQUIRE_N
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/CLS_P
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/CLS_N
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/CLF
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/TCLK
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/channel_configuration_array
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/channel_inp_array
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/channel_outp_array
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/slow_token_register
add wave -noupdate -group RENA3 /top_tb/rena3_testboard_i0/rena3_model_i0/fast_token_register
add wave -noupdate -divider GPIO
add wave -noupdate /top_tb/top_i0/gpio_button
add wave -noupdate /top_tb/top_i0/gpio_header_ls
add wave -noupdate /top_tb/top_i0/gpio_led
add wave -noupdate /top_tb/top_i0/gpio_switch
add wave -noupdate -divider {rena controller}
add wave -noupdate -expand /top_tb/top_i0/box_i0/rena3_0_in
add wave -noupdate -expand /top_tb/top_i0/box_i0/rena3_controller_i0/r.rena
add wave -noupdate -childformat {{/top_tb/top_i0/box_i0/rena3_controller_i0/r.acquire_time -radix unsigned} {/top_tb/top_i0/box_i0/rena3_controller_i0/r.channel_mask -radix hexadecimal}} -expand -subitemconfig {/top_tb/top_i0/box_i0/rena3_controller_i0/r.acquire_time {-height 15 -radix unsigned} /top_tb/top_i0/box_i0/rena3_controller_i0/r.channel_mask {-height 15 -radix hexadecimal} /top_tb/top_i0/box_i0/rena3_controller_i0/r.sample_mem {-height 15 -childformat {{/top_tb/top_i0/box_i0/rena3_controller_i0/r.sample_mem.address -radix unsigned} {/top_tb/top_i0/box_i0/rena3_controller_i0/r.sample_mem.data -radix decimal}}} /top_tb/top_i0/box_i0/rena3_controller_i0/r.sample_mem.address {-height 15 -radix unsigned} /top_tb/top_i0/box_i0/rena3_controller_i0/r.sample_mem.data {-height 15 -radix decimal}} /top_tb/top_i0/box_i0/rena3_controller_i0/r
add wave -noupdate -divider testgen
add wave -noupdate /top_tb/top_i0/box_i0/rena3_0_out.test
add wave -noupdate -divider {analog -> ADC}
add wave -noupdate /top_tb/rena3_testboard_i0/adc_model_i0/clk
add wave -noupdate /top_tb/rena3_testboard_i0/adc_model_i0/analog_p
add wave -noupdate /top_tb/rena3_testboard_i0/adc_model_i0/analog_n
add wave -noupdate -radix decimal /top_tb/rena3_testboard_i0/adc_model_i0/digital
add wave -noupdate /top_tb/rena3_testboard_i0/adc_model_i0/otr
add wave -noupdate -divider DDS
add wave -noupdate /top_tb/top_i0/box_i0/ad9854_out
add wave -noupdate /top_tb/top_i0/box_i0/ad9854_in
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {218469529 ps} 0} {{Cursor 2} {246655000 ps} 0}
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
WaveRestoreZoom {243195477 ps} {250905331 ps}
