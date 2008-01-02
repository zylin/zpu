/*

zpu-elf-gcc -abel `pwd`/hello.c -o hello.elf -Wl,--relax -Wl,--gc-sections  -g
zpu-elf-objdump --disassemble-all >hello.dis hello.elf
zpu-elf-objcopy -O binary hello.elf hello.bin
 
 * */
#include <stdio.h>

int j;
int k;

int main(int argc, char **argv)
{
	int i;
  for (i=0; i< 10; i++)
    {
      puts("Hello world 1\n");
      puts("Hello world 2\n");
    j=-4;
    if ((j>>1)!=-2)
    {
    	abort();
    }
    
    k=10;
    if (k*j!=-40)
    {
    	abort();
    }
    
    j=10;
    k=10000000;
    if (k*j!=100000000)
    {
    	abort();
    }
    
    j=0x80000000;
    k=0xffffffff;
    if (j>k)
    {
    	abort();
    }
    }
    if (i!=10)
    {
    	abort();
    }
    
}
