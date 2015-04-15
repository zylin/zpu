#include <syscall.h>
#include <stdio.h>
#include <errno.h>
#include <sys/stat.h>

extern int _hardware;
/* _cpu_config==0 => Abel
 * _cpu_config==1 => Zeta
 * _cpu_config==2 => Phi
 */
extern int _cpu_config;
static volatile int *UART;
static volatile int *TIMER;
volatile int *MHZ;



/*
 * Wait indefinitely for input byte
 */


int __attribute__ ((weak)) inbyte()  
{
	int val;
	for (;;)
	{
		val=UART[1];
		if ((val&0x100)!=0)
		{
			return val&0xff;
		}
	}
}



/* 
 * Output one character to the serial port 
 * 
 * 
 */
void __attribute__ ((weak)) outbyte(int c)  
{
	/* Wait for space in FIFO */
	while ((UART[0]&0x100)==0);
	UART[0]=c;
}

static const int mhz=64;

void __attribute__ ((weak)) _initIO(void)  
{
	if (_hardware)
	{
		if (_cpu_config==2)
		{
			/* Phi board addresses */
			UART=(volatile int *)0x080a000c;
			TIMER=(volatile int *)0x080a0014; 
			MHZ=(volatile int *)&mhz; 
		} else 
		{
			/* Abel board */
			UART=(volatile int *)0xc000;
			TIMER=(volatile int *)0x9000;
			MHZ=(volatile int *)0x8800;
		}
	} else
	{
		UART=(volatile int *)0x80000024;
		TIMER=(volatile int *)0x80000100;
		MHZ=(volatile int *)0x80000200;
	}
}



long long __attribute__ ((weak)) _readCycles()  
{
	long long clock;
	unsigned int i;
	
	TIMER[0]=0x2; /* sample timer */
	clock=0;
	for (i=0; i<2; i++)
	{
		clock|=((long long )(TIMER[i]))<<(i*32);
	}
	return clock;
}
