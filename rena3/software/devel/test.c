#include <stdio.h>

int main(void)
{
	volatile int a;

	int *ptr = (int *) 0x8001234;

	puts("read from adress 0x1234");
	a = *ptr;

	puts("end.");
	abort();
}
