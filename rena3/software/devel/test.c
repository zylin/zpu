#include <stdio.h>

int main(void)
{
	volatile int a;

	int *ptr = (int *) 0x80000800;

	//puts("read from adress 0x1234");
	a = *ptr;

	//puts("end.");
	abort();
}
