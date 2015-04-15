// #===========================================================================
// #
// #    context.S
// #
// #    ZYLIN context switch code
// #
// #===========================================================================
//####ECOSGPLCOPYRIGHTBEGIN####
// -------------------------------------------
// This file is part of eCos, the Embedded Configurable Operating System.
// Copyright (C) 1998, 1999, 2000, 2001, 2002 Red Hat, Inc.
//
// eCos is free software; you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation; either version 2 or (at your option) any later version.
//
// eCos is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for more details.
//
// You should have received a copy of the GNU General Public License along
// with eCos; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
//
// As a special exception, if other files instantiate templates or use macros
// or inline functions from this file, or you compile this file and link it
// with other works to produce a work based on this file, this file does not
// by itself cause the resulting work to be covered by the GNU General Public
// License. However the source code for this file must still be made available
// in accordance with section (3) of the GNU General Public License.
//
// This exception does not invalidate any other reasons why a work based on
// this file might be covered by the GNU General Public License.
//
// Alternative licenses for eCos may be arranged by contacting Red Hat, Inc.
// at http://sources.redhat.com/ecos/ecos-license/
// -------------------------------------------
//####ECOSGPLCOPYRIGHTEND####
// #===========================================================================
// ######DESCRIPTIONBEGIN####
// #
// # Author(s):    nickg, gthomas
// # Contributors: nickg, gthomas
// # Date:         1998-09-15
// # Purpose:      ZYLIN context switch code
// # Description:  This file contains implementations of the thread context 
// #               switch routines. It also contains the longjmp() and setjmp()
// #               routines.
// #
// #####DESCRIPTIONEND####
// #
// #===========================================================================

#include <pkgconf/hal.h>
#ifdef CYGPKG_KERNEL  // no CDL yet
#include <pkgconf/kernel.h>
#else
# undef CYGFUN_HAL_COMMON_KERNEL_SUPPORT
# undef CYGIMP_HAL_COMMON_INTERRUPTS_USE_INTERRUPT_STACK
#endif




#include "zylin.inc"

        .text


;; By using a macro, we get multiple breakpoint sites
	.macro LOAD_STATE 
	popsp	
	; stack pointer now points to beginning of HAL_SavedRegisters
	; we now pop the state of the CPU

	; this will restore r0-r3
	im 0
	store		
	im 4	
	store		
	im 8
	store		
	im 12
	store		
	im 16
	store		
	im 20
	store		
	im 24
	store		
	im 28
	store		
	
	;; restore interrupts 
	im INTERRUPT_MASK
	load
	store


	.endm


// ----------------------------------------------------------------------------
//  hal_thread_switch_context
//  Switch thread contexts

	    
	.globl hal_thread_switch_context
hal_thread_switch_context:

	;; save interrupt state
	im INTERRUPT_MASK
	load
	load

	; store current state on stack
	im 28
	load
	im 24
	load
	im 20
	load
	im 16
	load
	im 12
	load
	im 8 
	load
	im 4
	load
	im 0
	load
	

	;; store pointer to SP in "from" pointer
	pushsp
	pushsp
	im 8+8*4+4+4
	add
	load
	store		

	;; put pointer to '*to' on stack
	pushsp
	im 4+8*4+4
	add
	load
	load

	LOAD_STATE

	poppc			; voila! jump to saved pc
	
	
		
        
// ----------------------------------------------------------------------------
//  hal_thread_load_context
//  Load thread context

	.globl hal_thread_load_context
hal_thread_load_context:
	pushsp
	im 4
	add
	load
	load			; pointer to HAL_SavedRegisters on stack

load_state_internal:	
	LOAD_STATE
	
	poppc			; voila! jump to saved pc

// ----------------------------------------------------------------------------
//  HAL longjmp, setjmp implementations

	.globl hal_setjmp
hal_setjmp:	
	.byte 0

        
	.globl hal_longjmp
 hal_longjmp:	
	.byte 0

// ----------------------------------------------------------------------------
//  end of context.S

#ifdef CYGIMP_HAL_COMMON_INTERRUPTS_USE_INTERRUPT_STACK

	; push 1 onto stack if we're already switched, 0 otherwise
	.macro  check_thread_stack
	pushsp						; 0xda68
	im __interrupt_stack		; 0x241a
	lessthan					; => 1
	im __interrupt_stack_base
	pushsp 
	lessthan
	or
	
	.endm

	; push 1 onto stack if we're already switched, 0 otherwise
	.macro  switch_stack
	pushsp
	im __interrupt_stack-4
	store	; saved stack pointer on interrupt stack.
	
	im __interrupt_stack-4
	popsp
	; we're now on the interrupt stack 
	
	.endm
	
	.macro  switch_stack_back
	; return to thread stack
	popsp
	.endm

_zpu_invoke_zpu_interrupt_stack:
	im hal_IRQ_handler
	call
	im 0
	load ; return value - source
	
	im _zpu_interrupt_stack
	call
	im 0 
	load ; return value - result
	
	; we've got source and ISR result args on the stack
	im _zpu_interrupt_thread
	call
	storesp 0 ; destroy args 
	storesp 0

	poppc


// switch to interrupt stack, invoke interrupt handler, switch back to original stack, enable interrupts
	.globl _zpu_interrupt
_zpu_interrupt:
	; disable interrupts, we don't nest	
	im 1
	nop
	im INTERRUPT_MASK
	load
	store	

	; if we're interrupting the DSRs then
	; we're already on the interrupt stack
	check_thread_stack
	
	impcrel _already_switched
	eqbranch
	
_zpu_interrupt_switch_stack:
	switch_stack	
	
	im _zpu_invoke_zpu_interrupt_stack
	call
	
	switch_stack_back
	
	im .already_switched2
	poppc
	
_already_switched:
	im _zpu_invoke_zpu_interrupt_stack
	call
	
.already_switched2:
	; turn on interrupts and run on thread stack.	
	im 0
	nop
	im INTERRUPT_MASK
	load
	store	; unmask interrupts

	; we're now running on thread stack
	
	im _zpu_interrupt_thread
	call
	
	poppc

	.globl hal_interrupt_stack_call_pending_DSRs
hal_interrupt_stack_call_pending_DSRs:
	; the scheduler is not running, so only interrupts
	; could have switched stacks at this point and
	; since we're running, interrupts are not
	switch_stack	
	
	im cyg_interrupt_call_pending_DSRs
	call
	
	switch_stack_back

	; back on thread stack
	poppc



	
// Runtime stack used during all interrupt processing
#ifndef CYGNUM_HAL_COMMON_INTERRUPTS_STACK_SIZE
#define CYGNUM_HAL_COMMON_INTERRUPTS_STACK_SIZE 4096
#endif
		.bss
        .balign 4,0
        .global cyg_interrupt_stack_base
cyg_interrupt_stack_base:
__interrupt_stack_base:
        .rept CYGNUM_HAL_COMMON_INTERRUPTS_STACK_SIZE
        .byte 0
        .endr
        .balign 4,0
        .global cyg_interrupt_stack
cyg_interrupt_stack:
__interrupt_stack:
#endif


