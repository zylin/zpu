#include <peripherie.h>

apbuart_t         *uart0      = (apbuart_t *)  0x80000100;
gptimer_t         *timer0     = (gptimer_t *)  0x80000200;
irqmp_t           *irqmp0     = (irqmp_t *)    0x80000300;
apbvga_t          *vga0       = (apbvga_t *)   0x80000600;
grgpio_t          *gpio0      = (grgpio_t *)   0x80000800;
greth_t           *ether0     = (greth_t *)    0x80000c00;
volatile uint32_t *debug_con0 = (uint32_t *)   0x80000d00;
dcm_ctrl_t        *dcm_ctrl0  = (dcm_ctrl_t *) 0x80000e00;
ddrspa_t          *ddr0       = (ddrspa_t *)   0xfff00000;


char debug_putchar( char c)
{
    *debug_con0 = (uint32_t) c;
    return 0;
}

char (* putchar_fp) (char);// = debug_putchar;


