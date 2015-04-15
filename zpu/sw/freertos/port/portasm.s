	.extern pxCurrentTCB
	.extern vTaskISRHandler
	.extern vTaskSwitchContext
	.extern uxCriticalNesting
	.extern pulISRStack

	.global __FreeRTOS_interrupt_handler
	.global VPortYieldASM
	.global vStartFirstTask

/* interrupt controller port */
	.equ INTERRUPT_ENABLE,0x8020

.macro portSAVE_CONTEXT
	/* PC is at the top of stack */
	
	/* store interrupt global enable bit */
	im INTERRUPT_ENABLE
	load
	im 1
	and
	
	/* Store nesting critical level */
	im uxCriticalNesting
	load
	
	/* Store temporary registers */
	im 0
	load			/* store mem[0] */
	im 4
	load			/* store mem[4] */
	im 8
	load			/* store mem[8] */
	im 12
	load			/* store mem[12] */
	
	/* Store top of stack at pxCurrentTCB */
	pushsp
	im pxCurrentTCB
	load
	store
.endm

.macro portRESTORE_CONTEXT
	im pxCurrentTCB		/* Load the top of stack value from the TCB. */
	load
	load
	popsp
	
	/* Restore the temporary registers. */
	im 12
	store				/* restore mem[12] */
	im 8
	store				/* restore mem[8] */
	im 4
	store				/* restore mem[4] */
	im 0
	store				/* restore mem[0] */

	/* Load the critical nesting value. */
	im uxCriticalNesting
	store

	/* Set interrupt global enable status */
	im INTERRUPT_ENABLE
	load
	im ~1
	and
	or
	im INTERRUPT_ENABLE
	store

	/* restore PC and enable interrupts at ZPU level */
	.byte 0x03			/* popint */
.endm

.macro portRESTORE_CONTEXT_NOINTERRUPT
	im pxCurrentTCB		/* Load the top of stack value from the TCB. */
	load
	load
	popsp
	
	/* Restore the temporary registers. */
	im 12
	store				/* restore mem[12] */
	im 8
	store				/* restore mem[8] */
	im 4
	store				/* restore mem[4] */
	im 0
	store				/* restore mem[0] */

	/* Load the critical nesting value. */
	im uxCriticalNesting
	store

	/* Set interrupt global enable status */
	im INTERRUPT_ENABLE
	load
	im ~1
	and
	or
	im INTERRUPT_ENABLE
	store

	/* restore PC */
	poppc
.endm

	.text
	.align  2

__FreeRTOS_interrupt_handler:
	portSAVE_CONTEXT

	/* Now switch to use the ISR stack. */
	im pulISRStack
	load
	popsp

	/* Call function */
	im vTaskISRHandler
	call

	portRESTORE_CONTEXT

VPortYieldASM:
	portSAVE_CONTEXT

	/* Now switch to use the ISR stack. */
	im pulISRStack
	load
	popsp

	/* Call function to switch context */
	im vTaskSwitchContext
	call

	portRESTORE_CONTEXT_NOINTERRUPT

vStartFirstTask:
	portRESTORE_CONTEXT_NOINTERRUPT
