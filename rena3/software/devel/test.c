#include <stdio.h>

int main(void)
{
	volatile int a = 10;
	volatile int b;

	int *ptra = (int *) 0x80000800;
	int *ptrb = (int *) 0x80000804;

	//puts("read from adress 0x1234");
    *ptra = a;
	b = *ptrb;

	//puts("end.");
	abort();
}
