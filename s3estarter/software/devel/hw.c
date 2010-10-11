#include "peripherie.h"

apbuart_t  *uart0     = (apbuart_t *)  0x80000100;
gptimer_t  *timer0    = (gptimer_t *)  0x80000200;
apbvga_t   *vga0      = (apbvga_t *)   0x80000600;
grgpio_t   *gpio0     = (grgpio_t *)   0x80000800;
greth_t    *ether0    = (greth_t *)    0x80000c00;
dcm_ctrl_t *dcm_ctrl0 = (dcm_ctrl_t *) 0x80000e00;
ddrspa_t   *ddr0      = (ddrspa_t *)   0xfff00000;

