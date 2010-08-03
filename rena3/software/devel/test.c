#include <stdio.h>

int main(void)
{
	unsigned int pattern = 0x01800180;
	volatile int *gpio = (unsigned int *) 0x80000804;

    while (1)
    {
        *gpio = pattern;
        pattern = (pattern << 1) | (pattern >> 31);
    }

    //puts("end.");
    abort();
}
