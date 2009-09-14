/* Scheduler includes. */
#include "FreeRTOS.h"
#include "task.h"

#include "devices.h"

#define mainTINY_STACK	256
void vTest(void *pvParameters);
void vTest2(void *pvParameters);

/*-----------------------------------------------------------*/

/*
 * Create all the demo tasks - then start the scheduler.
 */
int main (void) 
{
	/* When re-starting a debug session (rather than cold booting) we want
	to ensure the installed interrupt handlers do not execute until after the
	scheduler has been started. */
	portDISABLE_INTERRUPTS();

	#if configUSE_PREEMPTION == 1
		xTaskCreate( vTest, "TST1", mainTINY_STACK, ( void * ) 10, tskIDLE_PRIORITY, NULL );
		xTaskCreate( vTest2, "TST2", mainTINY_STACK, ( void * ) 10, tskIDLE_PRIORITY, NULL );
	#endif

	/* Finally start the scheduler. */
	vTaskStartScheduler();

	/* Should not get here as the processor is now under control of the 
	scheduler! */

   	return 0;
}

void vTest(void *pvParameters)
{
const portTickType xDelay = 100 / portTICK_RATE_MS;
	unsigned bit = 16;
	unsigned dir = 0;   
	
	for(;;)
	{
		CLEAR_BIT(SP3SK_GPIO, bit);
		if(dir == 0) { if(++bit == 23) { dir=1; } }
		else { if(--bit == 16) { dir=0;} }
		SET_BIT(SP3SK_GPIO, bit);
		vTaskDelay( xDelay );
	}
}

void vTest2(void *pvParameters)
{
const portTickType xDelay = 250 / portTICK_RATE_MS;
	unsigned pos;
	char marcas[] = "|/-\\";
	
	for(;;)
	{
		uart1_printline("\r");
		uart1_printline("Running...");
		uart1_printchar(marcas[pos]);
		if(++pos == 4) pos = 0;
		vTaskDelay( xDelay );
	}
}
