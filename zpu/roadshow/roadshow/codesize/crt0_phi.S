/* Startup code for ZPU
   Copyright (C) 2005 Free Software Foundation, Inc.

This file is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2, or (at your option) any
later version.

In addition to the permissions in the GNU General Public License, the
Free Software Foundation gives you unlimited permission to link the
compiled version of this file with other programs, and to distribute
those programs without any restriction coming from the use of this
file.  (The General Public License restrictions do apply in other
respects; for example, they cover modification of the file, and
distribution when not linked into another program.)

This file is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; see the file COPYING.  If not, write to
the Free Software Foundation, 59 Temple Place - Suite 330,
Boston, MA 02111-1307, USA.  */
	.file	"crt0.S"
	
	
	
	
;	.section ".fixed_vectors","ax"
; KLUDGE!!! we remove the executable bit to avoid relaxation 
	.section ".fixed_vectors","a" 

; DANGER!!!! 
; we need to align these code sections to 32 bytes, which
; means we must not use any assembler instructions that are relaxed
; at linker time
; DANGER!!!! 

	.macro fixedim value
			im \value
	.endm

	.macro  jsr address
	
			im 0		; save R0
			load
			im 4		; save R1
			load
			im 8		; save R2
			load
	
			fixedim \address
			call
			
			im 8
			store		; restore R2
			im 4
			store		; restore R1
			im 0
			store		; restore R0
	.endm


	.macro  jmp address
			fixedim \address
			poppc
	.endm
		

	.macro fast_neg
	not
	im 1
	add
	.endm
	
	.macro cimpl funcname
	; save R0
	im 0
	load
	
	; save R1
	im 4
	load
	
	; save R2
	im 8
	load
	
	loadsp 20
	loadsp 20
	
	fixedim \funcname
	call

	; destroy arguments on stack
	storesp 0
	storesp 0	
	 
	im 0
	load
	
	; poke the result into the right slot
	storesp 24

	; restore R2
	im 8
	store
	
	; restore R1
	im 4
	store
	
	; restore r0
	im 0
	store
	
	
	storesp 4
	poppc
	.endm

	.macro mult1bit
	; create mask of lowest bit in A
	loadsp 8 ; A
	im 1
	and
	im -1
	add
	not
	loadsp 8 ; B
	and 
	add ; accumulate in C
	
	; shift B left 1 bit
	loadsp 4 ; B
	addsp 0
	storesp 8 ; B
	
	; shift A right 1 bit
	loadsp 8 ; A
	flip
	addsp 0
	flip
	storesp 12 ; A
	.endm



/* vectors */
        .balign 32,0
# offset 0x0000 0000
		.globl _start
_start:
		; intSp must be 0 when we jump to _premain
		
		im ZPU_ID
		loadsp 0
		im _cpu_config
		store
		config
		jmp _premain



/* instruction emulation code */

	.data

	
	.globl _hardware
_hardware:
	.long 0
	.globl _cpu_config
_cpu_config:
	.long 0

