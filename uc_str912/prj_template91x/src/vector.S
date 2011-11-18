/***********************************************************************************
*	Copyright 2005 Anglia Design
*	This demo code and associated components are provided as is and has no warranty,
*	implied or otherwise.  You are free to use/modify any of the provided
*	code at your own risk in your applications with the expressed limitation
*	of liability (see below)
* 
*	LIMITATION OF LIABILITY:   ANGLIA OR ANGLIA DESIGNS SHALL NOT BE LIABLE FOR ANY
*	LOSS OF PROFITS, LOSS OF USE, LOSS OF DATA, INTERRUPTION OF BUSINESS, NOR FOR
*	INDIRECT, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES OF ANY KIND WHETHER UNDER
*	THIS AGREEMENT OR OTHERWISE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
*
*	Author			: Spencer Oliver
*	Web     		: www.anglia-designs.com
*
***********************************************************************************/

	.equ	VectorAddress,		0xFFFFF030	/* VIC Vector address register address. */
	.equ	VectorAddressDaisy,	0xFC000030	/* Daisy VIC Vector address register */

	.equ    Mode_USR,       0x10
	.equ    Mode_FIQ,       0x11
	.equ    Mode_IRQ,       0x12
	.equ    Mode_SVC,       0x13
	.equ    Mode_ABT,       0x17
	.equ    Mode_UND,       0x1B
	.equ    Mode_SYS,       0x1F			/* available on ARM Arch 4 and later */

	.equ    I_Bit,          0x80			/* when I bit is set, IRQ is disabled */
	.equ    F_Bit,          0x40			/* when F bit is set, FIQ is disabled */

	.text
	.arm
	.section .vectors, "ax"

	.global	Reset_Vec

/* Note: LDR PC instructions are used here, though branch (B) instructions */
/* could also be used, unless the ROM is at an address >32MB. */

/*******************************************************************************
                        Exception vectors
*******************************************************************************/

Reset_Vec:	LDR     pc, Reset_Addr		/* Reset Handler */
Undef_Vec:	LDR     pc, Undefined_Addr
SWI_Vec:	LDR     pc, SWI_Addr
PAbt_Vec:	LDR     pc, Prefetch_Addr
DAbt_Vec:	LDR     pc, Abort_Addr
			NOP							/* Reserved vector */
IRQ_Vec:	LDR     pc, IRQ_Addr
FIQ_Vec:	LDR     pc, FIQ_Addr

/*******************************************************************************
               Exception handlers address table
*******************************************************************************/

Reset_Addr:		.word	_start
Undefined_Addr:	.word	UndefinedHandler
SWI_Addr:		.word	SWIHandler
Prefetch_Addr:	.word	PrefetchHandler
Abort_Addr:		.word	AbortHandler
				.word	0				/* reserved */
IRQ_Addr:		.word	IRQHandler
FIQ_Addr:		.word	FIQHandler

/*******************************************************************************
                         Exception Handlers
*******************************************************************************/

/*******************************************************************************
* Macro Name     : SaveContext
* Description    : This macro used to save the context before entering
                   an exception handler.
* Input          : The range of registers to store.
* Output         : none
*******************************************************************************/

.macro	SaveContext reg1 reg2
		STMFD	sp!,{\reg1-\reg2,lr}	/* Save The workspace plus the current return */
										/* address lr_ mode into the stack */
		MRS		r1, spsr				/* Save the spsr_mode into r1 */
		STMFD	sp!, {r1}				/* Save spsr */
.endm

/*******************************************************************************
* Macro Name     : RestoreContext
* Description    : This macro used to restore the context to return from
                   an exception handler and continue the program execution.
* Input          : The range of registers to restore.
* Output         : none
*******************************************************************************/

.macro	RestoreContext reg1 reg2
		LDMFD	sp!, {r1}				/* Restore the saved spsr_mode into r1 */
		MSR		spsr_cxsf, r1			/* Restore spsr_mode */
		LDMFD	sp!, {\reg1-\reg2,pc}^	/* Return to the instruction following */
										/* the exception interrupt */
.endm

/*******************************************************************************
* Function Name  : IRQHandler
* Description    : This function called when IRQ exception is entered.
* Input          : none
* Output         : none
*******************************************************************************/

IRQHandler:
		SUB    lr, lr, #4				/* Update the link register */
		SaveContext r0, r12				/* Save the workspace plus the current */
										/* return address lr_irq and spsr_irq */
		LDR    r0, =VectorAddress
		LDR    r0, [r0]					/* Read the routine address */
		LDR    r1, =VectorAddressDaisy
		LDR    r1, [r1]
		/* Padding between the acknowledge and re-enable of interrupts */
		/* For more details, please refer to the following URL */
		/* http://www.arm.com/support/faqip/3682.html */
		NOP
		NOP
		MSR		cpsr_c, #Mode_SYS		/* Switch to SYS mode and enable IRQ */
		STMFD	sp!, {lr}				/* Save the link register. */
		LDR		lr, =ReturnAddress		/* Read the return address. */
		MOV		pc, r0					/* Branch to the IRQ handler. */
ReturnAddress:
		LDMFD	sp!, {lr}						/* Restore the link register. */
		MSR		cpsr_c, #Mode_IRQ|I_Bit|F_Bit	/* Switch to IRQ mode and disable IRQ */
		LDR		r0, =VectorAddress				/* Write to the VectorAddress to clear the */
		STR		r0, [r0]				/* respective interrupt in the internal interrupt */
		LDR		r1, =VectorAddressDaisy	/* Write to the VectorAddressDaisy to clear the */
		STR		r1, [r1]				/* respective interrupt in the internal interrupt */
		RestoreContext r0, r12			/* Restore the context and return to the program execution. */

/*******************************************************************************
* Function Name  : SWIHandler
* Description    : This function called when SWI instruction executed.
* Input          : none
* Output         : none
*******************************************************************************/

SWIHandler:
		SaveContext r0, r12			/* r0 holds swi number */
		MOV 	r1, sp				/* load regs */
		BL		SWI_Handler
		RestoreContext r0, r12

/*******************************************************************************
* Function Name  : UndefinedHandler
* Description    : This function called when undefined instruction
                   exception is entered.
* Input          : none
* Output         : none
*******************************************************************************/

UndefinedHandler:
		SaveContext r0, r12
		BL		Undefined_Handler
		RestoreContext r0, r12

/*******************************************************************************
* Function Name  : PrefetchAbortHandler
* Description    : This function called when Prefetch Abort
                   exception is entered.
* Input          : none
* Output         : none
*******************************************************************************/

PrefetchHandler:
		SUB		lr, lr, #4			/* Update the link register. */
		SaveContext r0, r12
		BL		Prefetch_Handler
		RestoreContext r0, r12

/*******************************************************************************
* Function Name  : DataAbortHandler
* Description    : This function is called when Data Abort
                   exception is entered.
* Input          : none
* Output         : none
*******************************************************************************/

AbortHandler:
		SUB		lr, lr, #8			/* Update the link register. */
		SaveContext r0, r12
		BL		Abort_Handler
		RestoreContext r0, r12

/*******************************************************************************
* Function Name  : FIQHandler
* Description    : This function is called when FIQ
                   exception is entered.
* Input          : none
* Output         : none
*******************************************************************************/

FIQHandler:
		SUB		lr, lr, #4			/* Update the link register. */
		SaveContext r0, r7
		BL		FIQ_Handler
		RestoreContext r0, r7

	.end
