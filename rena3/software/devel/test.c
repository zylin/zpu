#include <stdio.h>

int main(void)
{
	int a;

	int *ptr = (int *) 0x1234;

	puts("read from adress 0x1234\n");
	a = *ptr;

	puts("end simulation.\n");
	abort();
}
