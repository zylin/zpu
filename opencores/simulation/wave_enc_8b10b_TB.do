onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /enc_8b10b_tb/encoder/RESET
add wave -noupdate /enc_8b10b_tb/encoder/SBYTECLK
add wave -noupdate /enc_8b10b_tb/encoder/KI
add wave -noupdate /enc_8b10b_tb/encoder/AI
add wave -noupdate /enc_8b10b_tb/encoder/BI
add wave -noupdate /enc_8b10b_tb/encoder/CI
add wave -noupdate /enc_8b10b_tb/encoder/DI
add wave -noupdate /enc_8b10b_tb/encoder/EI
add wave -noupdate /enc_8b10b_tb/encoder/FI
add wave -noupdate /enc_8b10b_tb/encoder/GI
add wave -noupdate /enc_8b10b_tb/encoder/HI
add wave -noupdate /enc_8b10b_tb/encoder/JO
add wave -noupdate /enc_8b10b_tb/encoder/HO
add wave -noupdate /enc_8b10b_tb/encoder/GO
add wave -noupdate /enc_8b10b_tb/encoder/FO
add wave -noupdate /enc_8b10b_tb/encoder/IO
add wave -noupdate /enc_8b10b_tb/encoder/EO
add wave -noupdate /enc_8b10b_tb/encoder/DO
add wave -noupdate /enc_8b10b_tb/encoder/CO
add wave -noupdate /enc_8b10b_tb/encoder/BO
add wave -noupdate /enc_8b10b_tb/encoder/AO
add wave -noupdate -radix unsigned /enc_8b10b_tb/tchar
add wave -noupdate -radix unsigned /enc_8b10b_tb/tcharout
add wave -noupdate -radix unsigned /enc_8b10b_tb/tlcharout
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {660000 ps} 0}
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {4200 ns}
