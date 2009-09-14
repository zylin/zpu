/*
	FreeRTOS.org V5.3.0 - Copyright (C) 2003-2009 Richard Barry.

	This file is part of the FreeRTOS.org distribution.

	FreeRTOS.org is free software; you can redistribute it and/or modify it
	under the terms of the GNU General Public License (version 2) as published
	by the Free Software Foundation and modified by the FreeRTOS exception.
	**NOTE** The exception to the GPL is included to allow you to distribute a
	combined work that includes FreeRTOS.org without being obliged to provide
	the source code for any proprietary components.  Alternative commercial
	license and support terms are also available upon request.  See the 
	licensing section of http://www.FreeRTOS.org for full details.

	FreeRTOS.org is distributed in the hope that it will be useful,	but WITHOUT
	ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
	FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
	more details.

	You should have received a copy of the GNU General Public License along
	with FreeRTOS.org; if not, write to the Free Software Foundation, Inc., 59
	Temple Place, Suite 330, Boston, MA  02111-1307  USA.


	***************************************************************************
	*                                                                         *
	* Get the FreeRTOS eBook!  See http://www.FreeRTOS.org/Documentation      *
	*                                                                         *
	* This is a concise, step by step, 'hands on' guide that describes both   *
	* general multitasking concepts and FreeRTOS specifics. It presents and   *
	* explains numerous examples that are written using the FreeRTOS API.     *
	* Full source code for all the examples is provided in an accompanying    *
	* .zip file.                                                              *
	*                                                                         *
	***************************************************************************

	1 tab == 4 spaces!

	Please ensure to read the configuration and relevant port sections of the
	online documentation.

	http://www.FreeRTOS.org - Documentation, latest information, license and
	contact details.

	http://www.SafeRTOS.com - A version that is certified for use in safety
	critical systems.

	http://www.OpenRTOS.com - Commercial support, development, porting,
	licensing and training services.
*/

/*-----------------------------------------------------------
 * Implementation of functions defined in portable.h for the MicroBlaze port.
 *----------------------------------------------------------*/


/* Scheduler includes. */
#include "FreeRTOS.h"
#include "task.h"

/* Standard includes. */
#include <string.h>

/* hardware/software platform specific defines */
#define DISABLE_C_PROTOTYPES
#include <devices.h>

/* Tasks are started with interrupts enabled. */
#define portINITIAL_INTERRUPT_ENABLE	( ( portSTACK_TYPE ) INTERRUPT_GLOBAL_ENABLE )

/* Tasks are started with a critical section nesting of 0 - however prior
to the scheduler being commenced we don't want the critical nesting level
to reach zero, so it is initialised to a high value. */
#define portINITIAL_NESTING_VALUE	( 0xff )

/* The stack used by the ISR is filled with a known value to assist in
debugging. */
#define portISR_STACK_FILL_VALUE	0x55555555

/* Counts the nesting depth of calls to portENTER_CRITICAL().  Each task 
maintains it's own count, so this variable is saved as part of the task
context. */
volatile unsigned portBASE_TYPE uxCriticalNesting = portINITIAL_NESTING_VALUE;

/* To limit the amount of stack required by each task, this port uses a
separate stack for interrupts. */
unsigned portLONG *pulISRStack;

/*-----------------------------------------------------------*/

/*
 * Sets up the periodic ISR used for the RTOS tick.  This uses timer 0, but
 * could have alternatively used the watchdog timer or timer 1.
 */
static void prvSetupTimerInterrupt( void );
/*-----------------------------------------------------------*/

/* 
 * Initialise the stack of a task to look exactly as if a call to 
 * portSAVE_CONTEXT had been made.
 * 
 * See the header file portable.h.
 */
portSTACK_TYPE *pxPortInitialiseStack( portSTACK_TYPE *pxTopOfStack, pdTASK_CODE pxCode, void *pvParameters )
{
	/* Function call parameters. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) pvParameters;

	/* Place initial PC (task entry point) */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) pxCode;	/* PC */

	/* Place initial value for INTERRUPT global ENABLE */
	pxTopOfStack--;
	*pxTopOfStack = portINITIAL_INTERRUPT_ENABLE;	/* interrupt state (global enable) */
	
	/* Stack an initial value for the critical section nesting.  This
	is initialised to zero as tasks are started with interrupts enabled. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x00;

	/* Place an initial value for all temporary registers mapped to mem[0..16] by gcc */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x11111111;	/* mem[0] */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x22222222;	/* mem[4] */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x33333333;	/* mem[8] */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x44444444;	/* mem[12] */

	/* Return a pointer to the top of the stack we have generated so this can
	be stored in the task control block for the task. */
	return pxTopOfStack;
}
/*-----------------------------------------------------------*/

portBASE_TYPE xPortStartScheduler( void )
{
extern void ( __FreeRTOS_interrupt_handler )( void );
extern void ( vStartFirstTask )( void );

	/* Setup the FreeRTOS interrupt handler */
	*(volatile unsigned *) INTERRUPT_VECTOR = (unsigned) __FreeRTOS_interrupt_handler;

	/* Setup the hardware to generate the tick.  Interrupts are disabled when
	this function is called. */
	prvSetupTimerInterrupt();

	/* Allocate the stack to be used by the interrupt handler. */
	pulISRStack = ( unsigned portLONG * ) pvPortMalloc( configMINIMAL_STACK_SIZE * sizeof( portSTACK_TYPE ) );

	/* Restore the context of the first task that is going to run. */
	if( pulISRStack != NULL )
	{
		/* Fill the ISR stack with a known value to facilitate debugging. */
		memset( pulISRStack, portISR_STACK_FILL_VALUE, configMINIMAL_STACK_SIZE * sizeof( portSTACK_TYPE ) );
		pulISRStack += ( configMINIMAL_STACK_SIZE - 1 );

		/* Kick off the first task. */
		vStartFirstTask();
	}

	/* Should not get here as the tasks are now running! */
	return pdFALSE;
}
/*-----------------------------------------------------------*/

void vPortEndScheduler( void )
{
	/* Not implemented. */
}
/*-----------------------------------------------------------*/

/*
 * Manual context switch called by portYIELD or taskYIELD.  
 */
void vPortYield( void )
{
extern void VPortYieldASM( void );

	/* Perform the context switch in a critical section to assure it is
	not interrupted by the tick ISR.  It is not a problem to do this as
	each task maintains it's own interrupt status. */
	portENTER_CRITICAL();
		/* Jump directly to the yield function to ensure there is no
		compiler generated prologue code. */
		asm volatile (	"im VPortYieldASM		\n\t" \
						"call					\n\t" );
	portEXIT_CRITICAL();
}
/*-----------------------------------------------------------*/

/*
 * Hardware initialisation to generate the RTOS tick.   
 */
static void prvSetupTimerInterrupt( void )
{
const unsigned portLONG ulCounterValue = configCPU_CLOCK_HZ / configTICK_RATE_HZ;

	/* Initialize and start timer1 counter */
	*(volatile unsigned *) TIMER1_PORT = ulCounterValue;
	*(volatile unsigned *) TIMERS_CONTROL = TIMER1_ENABLE;
	
	/* Enable timer1 interrupt while maintaining other bit states
	   but disable global enable */
	*(volatile unsigned *) INTERRUPT_ENABLE &= ~INTERRUPT_GLOBAL_ENABLE;
	*(volatile unsigned *) INTERRUPT_ENABLE |= INTERRUPT_TIMER1;
}
/*-----------------------------------------------------------*/

/*
 * The interrupt handler placed in the interrupt vector when the scheduler is
 * started.  The task context has already been saved when this is called.
 * This handler determines the interrupt source and calls the relevant 
 * peripheral handler.
 */
void vTaskISRHandler( void )
{
void vTickISR(void);

	unsigned int_status = *(volatile unsigned *) INTERRUPT_STATUS;
	if(int_status & INTERRUPT_TIMER1)	vTickISR();
}
/*-----------------------------------------------------------*/

/* 
 * Handler for the timer interrupt.
 */
void vTickISR( void )
{
	/* Increment the RTOS tick - this might cause a task to unblock. */
	vTaskIncrementTick();

	/* Clear the timer interrupt */
	/* ... in this platform, timer interrupt is cleared automatically */

	/* If we are using the preemptive scheduler then we also need to determine
	if this tick should cause a context switch. */
	#if configUSE_PREEMPTION == 1
		vTaskSwitchContext();
	#endif
}
/*-----------------------------------------------------------*/

void zpu_disable_interrupts(void)
{	
	*(volatile unsigned *) INTERRUPT_ENABLE &= ~INTERRUPT_GLOBAL_ENABLE;
}

void zpu_enable_interrupts(void)
{
	*(volatile unsigned *) INTERRUPT_ENABLE |= INTERRUPT_GLOBAL_ENABLE;
}

/*-----------------------------------------------------------*/

void zpu_enter_critical(void)
{
	portDISABLE_INTERRUPTS();
	uxCriticalNesting++;
}
									
void zpu_exit_critical(void)
{	
	if( --uxCriticalNesting == 0 )
	{
  	  portENABLE_INTERRUPTS();
  	}
}
