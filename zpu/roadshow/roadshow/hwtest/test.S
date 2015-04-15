_loop:
	im 0x5a 		;  write Z to UART
	nop
	im 0x080a000c
	store
	; increaase counter
	im _test
	load
	im 1
	add
	im _test
	store
	
	
	im _loop
	poppc 			;  loop
	
	.align 4
_test: .long 1
