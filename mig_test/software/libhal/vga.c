//#include <stdio.h>

#include "peripherie.h"


////////////////////////////////////////
// common defines

#define bit_is_set(mem, bv)               (mem & bv)
#define bit_is_clear(mem, bv)             (!(mem & bv))
#define loop_until_bit_is_set(mem, bv)    do {} while( bit_is_clear(mem, bv))
#define loop_until_bit_is_clear(mem, bv)  do {} while( bit_is_set(mem, bv))




uint8_t vga_line;
uint8_t vga_column;

void vga_init( void)
{
    vga0->background_color = 0x00000000;
    vga0->foreground_color = 0x0000ff00;
    vga_line               = 0;
    vga_column             = 0;
}



void vga_clear( void)
{
    uint32_t count;
    uint32_t count_max = 37*80;

    for(count = 0; count< count_max; count++)
        vga0->data = count<<8;

    vga_line               = 0;
    vga_column             = 0;
}


void vga_putchar( char c)
{

    vga0->data = (( vga_line * 80 + vga_column)<<8) | c;
    if ( (c == '\n') || (vga_column == 79) ) // line feed (+ carrige return)
    {
        if (vga_line<36) 
            vga_line++;
        else
            vga_line = 0;

        vga_column = 0;
    }
    else if (c == '\f') // form feed
    {
        vga_clear();
    }
    else
    {
        vga_column++;
    }
        
}


