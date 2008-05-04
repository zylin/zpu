/*
 * Shows usage of interrupts. Goes along with zpu_core_small_wip.vhd.
 */
#include <stdio.h>


int counter;

/* Example of single, fixed interval non-maskable, nested interrupt. The interrupt signal is
 * held high for enough cycles to guarantee that it will be noticed, i.e. longer than
 * any io access + 4 cycles roughly.
 */
void  _zpu_interrupt(void)
{
	/* interrupts are enabled so we need to finish up quickly,
	 * lest we will get infinite recursion!*/
	counter++;
}

int main(int argc, char **argv)
{
	int t;
	t=counter;
	for (;;)
	{
		if (t==counter)
		{
			puts("No interrupt\n");
		} else
		{
			puts("Got interrupt\n");
		}
	}
    
}
