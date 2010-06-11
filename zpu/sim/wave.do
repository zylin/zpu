onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic -radix hexadecimal /fpga_top/zpu/clk
add wave -noupdate -format Logic -radix hexadecimal /fpga_top/zpu/areset
add wave -noupdate -format Logic -radix hexadecimal /fpga_top/zpu/enable
add wave -noupdate -format Logic -radix hexadecimal /fpga_top/zpu/in_mem_busy
add wave -noupdate -format Literal -radix hexadecimal /fpga_top/zpu/mem_read
add wave -noupdate -format Literal -radix hexadecimal /fpga_top/zpu/mem_write
add wave -noupdate -format Literal -radix hexadecimal /fpga_top/zpu/out_mem_addr
add wave -noupdate -format Logic -radix hexadecimal /fpga_top/zpu/out_mem_writeenable
add wave -noupdate -format Logic -radix hexadecimal /fpga_top/zpu/out_mem_readenable
add wave -noupdate -format Literal -radix hexadecimal /fpga_top/zpu/mem_writemask
add wave -noupdate -format Logic -radix hexadecimal /fpga_top/zpu/interrupt
add wave -noupdate -format Logic -radix hexadecimal /fpga_top/zpu/break
add wave -noupdate -format Logic -radix hexadecimal /fpga_top/zpu/readio
add wave -noupdate -format Logic -radix hexadecimal /fpga_top/zpu/memawriteenable
add wave -noupdate -format Literal -radix hexadecimal /fpga_top/zpu/memaaddr
add wave -noupdate -format Literal -radix hexadecimal /fpga_top/zpu/memawrite
add wave -noupdate -format Literal -radix hexadecimal /fpga_top/zpu/memaread
add wave -noupdate -format Logic -radix hexadecimal /fpga_top/zpu/membwriteenable
add wave -noupdate -format Literal -radix hexadecimal /fpga_top/zpu/membaddr
add wave -noupdate -format Literal -radix hexadecimal /fpga_top/zpu/membwrite
add wave -noupdate -format Literal -radix hexadecimal /fpga_top/zpu/membread
add wave -noupdate -format Literal -radix hexadecimal /fpga_top/zpu/pc
add wave -noupdate -format Literal -radix hexadecimal /fpga_top/zpu/sp
add wave -noupdate -format Logic -radix hexadecimal /fpga_top/zpu/idim_flag
add wave -noupdate -format Logic -radix hexadecimal /fpga_top/zpu/busy
add wave -noupdate -format Logic -radix hexadecimal /fpga_top/zpu/begin_inst
add wave -noupdate -format Literal -radix hexadecimal /fpga_top/zpu/trace_opcode
add wave -noupdate -format Literal -radix hexadecimal /fpga_top/zpu/trace_pc
add wave -noupdate -format Literal -radix hexadecimal /fpga_top/zpu/trace_sp
add wave -noupdate -format Literal -radix hexadecimal /fpga_top/zpu/trace_topofstack
add wave -noupdate -format Literal -radix hexadecimal /fpga_top/zpu/trace_topofstackb
add wave -noupdate -format Literal -radix hexadecimal /fpga_top/zpu/sampledopcode
add wave -noupdate -format Literal -radix hexadecimal /fpga_top/zpu/opcode
add wave -noupdate -format Literal -radix hexadecimal /fpga_top/zpu/decodedopcode
add wave -noupdate -format Literal -radix hexadecimal /fpga_top/zpu/sampleddecodedopcode
add wave -noupdate -format Literal -radix hexadecimal /fpga_top/zpu/state
add wave -noupdate -format Literal -radix hexadecimal /fpga_top/zpu/memaaddr_stdlogic
add wave -noupdate -format Literal -radix hexadecimal /fpga_top/zpu/memawrite_stdlogic
add wave -noupdate -format Literal -radix hexadecimal /fpga_top/zpu/memaread_stdlogic
add wave -noupdate -format Literal -radix hexadecimal /fpga_top/zpu/membaddr_stdlogic
add wave -noupdate -format Literal -radix hexadecimal /fpga_top/zpu/membwrite_stdlogic
add wave -noupdate -format Literal -radix hexadecimal /fpga_top/zpu/membread_stdlogic
add wave -noupdate -format Literal -radix hexadecimal /fpga_top/zpu/topcode_sel
add wave -noupdate -format Logic -radix hexadecimal /fpga_top/zpu/ininterrupt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {894201 ps} 0}
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ps} {939750 ps}
