/*
 * $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/hw_sp605/bsp_zpuahb/software/include/vga.h $
 * $Date$
 * $Author$
 * $Revision$
 */


#include "peripherie.h"


extern uint8_t vga_line;
extern uint8_t vga_column;

void vga_init( void);
void vga_clear( void);
void vga_putchar( char c);

