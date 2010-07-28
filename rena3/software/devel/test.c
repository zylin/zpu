#include <stdio.h>

int main(void)
{
	volatile int a = 10;
	volatile int b;

	volatile int *ptra = (int *) 0x80000800;
	volatile int *ptrb = (int *) 0x80000804;

	//puts("read from adress 0x1234");
    *ptra = 10;    // write
    *ptrb = 16;    // write
    *ptra = 16;    // write
	b     = *ptrb; // read

	//puts("end.");
	abort();
}
