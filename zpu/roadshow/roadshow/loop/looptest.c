/* This is a peek & poke example for an FPGA. 

   It should loop at a frequency of ~50 instructions. If
   the ZPU(small) is running at 25MHz, then this would yield
   a peek & poke every 8ms or so.

  zpu-elf-gcc -O3 -zeta looptest.c -o looptest.elf -Wl,--relax -Wl,--gc-sections */


/*
0000051c <main>:
 51c:   ff              im -1
 51d:   3d              pushspadd
 51e:   0d              popsp
 51f:   80              im 0
 520:   52              storesp 8

00000521 <.L2>:
 521:   81              im 1
 522:   12              addsp 8
 523:   82              im 2
 524:   80              im 0
 525:   80              im 0
 526:   08              load
 527:   71              loadsp 4
 528:   82              im 2
 529:   80              im 0
 52a:   90              im 16
 52b:   0c              store
 52c:   81              im 1
 52d:   12              addsp 8
 52e:   82              im 2
 52f:   80              im 0
 530:   80              im 0
 531:   08              load
 532:   71              loadsp 4
 533:   82              im 2
 534:   80              im 0
 535:   90              im 16
 536:   0c              store
 537:   52              storesp 8
 538:   52              storesp 8
 539:   52              storesp 8
 53a:   52              storesp 8
 53b:   e5              im -27
 53c:   39              poppcrel
*/
#define FPGA_ADDR                       0x8000

typedef  volatile unsigned int* pAddr;
#define FPGA_READ         *(pAddr) (FPGA_ADDR)

#define FPGA_WRITE         *(pAddr) (FPGA_ADDR + 16)


int main(int argc, char **argv)
{
int i;
int j = 0;

    while (1)

    {
    j++;
    i =  FPGA_READ;
    FPGA_WRITE = j;
    }
} 
