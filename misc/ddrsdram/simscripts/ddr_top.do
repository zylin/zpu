vlib work
vcom -93 -explicit ../src/ddr_pkg.vhd
vcom -93 -explicit ../src/ddr_top.vhd
vsim -t 1ps ddr_top
view wave
view signals
radix hex
# Add wave signals

add wave -divider "System"
add wave sim:/ddr_top/areset
add wave sim:/ddr_top/cpu_clk
add wave sim:/ddr_top/cpu_clk_2x
add wave sim:/ddr_top/cpu_clk_4x
add wave sim:/ddr_top/ddr_in_clk
add wave sim:/ddr_top/ddr_in_clk_2x

add wave -divider "Ctrl interface"
add wave sim:/ddr_top/cpu_clk
add wave sim:/ddr_top/ddr_data_read
add wave sim:/ddr_top/ddr_data_write
add wave sim:/ddr_top/ddr_req
add wave sim:/ddr_top/ddr_rd_wr_n
add wave sim:/ddr_top/ddr_req_len
add wave sim:/ddr_top/ddr_read_en
add wave sim:/ddr_top/ddr_write_en
add wave sim:/ddr_top/ddr_command
add wave sim:/ddr_top/ddr_command_we

add wave -divider "DDR interface"
add wave sim:/ddr_top/sdr_clk_p
add wave sim:/ddr_top/sdr_clk_n_p
add wave sim:/ddr_top/cke_q_p
add wave sim:/ddr_top/cs_qn_p
add wave sim:/ddr_top/ras_qn_p
add wave sim:/ddr_top/cas_qn_p
add wave sim:/ddr_top/we_qn_p
add wave sim:/ddr_top/dm_q_p
add wave sim:/ddr_top/dqs_q_p
add wave sim:/ddr_top/ba_q_p
add wave sim:/ddr_top/sdr_a_p
add wave sim:/ddr_top/sdr_d_p

add wave -divider "Internal signals"
add wave sim:/ddr_top/clk2_phase
add wave sim:/ddr_top/clk4_phase
add wave sim:/ddr_top/ddr_state
add wave sim:/ddr_top/sdr_oe_n
add wave sim:/ddr_top/sdr_smp
add wave sim:/ddr_top/sdr_d


# Add input signals
force -freeze sim:/ddr_top/cpu_clk_4x 1 0, 0 {1.875 ns} -r 3.75 ns
run 100 ps
force -freeze sim:/ddr_top/cpu_clk_2x 1 0, 0 {3.75 ns} -r 7.5 ns
run 100 ps
force -freeze sim:/ddr_top/cpu_clk 1 0, 0 {7.5 ns} -r 15 ns
force -freeze sim:/ddr_top/ddr_in_clk 1 2ns, 0 {5.75 ns} -r 7.5 ns
force -freeze sim:/ddr_top/ddr_in_clk_2x 0 0.125ns, 1 {2 ns} -r 3.75 ns

force -freeze sim:/ddr_top/areset 1 0
force -freeze sim:/ddr_top/ddr_command 0000 0
force -freeze sim:/ddr_top/ddr_command_we 0 0
force -freeze sim:/ddr_top/ddr_data_write 1234abcd 0
force -freeze sim:/ddr_top/ddr_req 0 0
force -freeze sim:/ddr_top/ddr_req_adr 000000 0
force -freeze sim:/ddr_top/ddr_rd_wr_n 0 0
force -freeze sim:/ddr_top/ddr_req_len 0 0

# Start simulation
run 45 ns
force -freeze sim:/ddr_top/areset 0 0
run 92 ns
# DDR Command
force -freeze sim:/ddr_top/ddr_command 000A 0
force -freeze sim:/ddr_top/ddr_command_we 1 0
run 15 ns
force -freeze sim:/ddr_top/ddr_command 0000 0
force -freeze sim:/ddr_top/ddr_command_we 0 0
run 90 ns
# DDR Read
force -freeze sim:/ddr_top/ddr_req 1 0
force -freeze sim:/ddr_top/ddr_req_adr 00ABCD 0
force -freeze sim:/ddr_top/ddr_rd_wr_n 1 0
force -freeze sim:/ddr_top/ddr_req_len 0 0
run 15 ns
force -freeze sim:/ddr_top/ddr_req 0 0
force -freeze sim:/ddr_top/ddr_req_adr 000000 0
force -freeze sim:/ddr_top/ddr_rd_wr_n 0 0
force -freeze sim:/ddr_top/ddr_req_len 0 0
run 150 ns
# DDR Write
force -freeze sim:/ddr_top/ddr_req 1 0
force -freeze sim:/ddr_top/ddr_req_adr 00ABCD 0
force -freeze sim:/ddr_top/ddr_rd_wr_n 0 0
force -freeze sim:/ddr_top/ddr_req_len 0 0
run 15 ns
force -freeze sim:/ddr_top/ddr_req 0 0
force -freeze sim:/ddr_top/ddr_req_adr 000000 0
force -freeze sim:/ddr_top/ddr_rd_wr_n 0 0
force -freeze sim:/ddr_top/ddr_req_len 0 0
run 180 ns

