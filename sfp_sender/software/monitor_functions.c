/*
 * $Date$
 * $Author$
 * $Revision$
 */

#include <types.h>
#include "monitor.h"
#include "ambainfo.h"          // apb_info, ahb_info
#include "peripherie.h"


volatile uint8_t running_direction = 0;


/*
    exit the monitor program
*/
uint32_t quit_function( void)
{
    monitor_run = FALSE;
    return 0;
}


/*
    do a memory dump
    arguments:
        start address
        length
*/
uint32_t x_function( void)
{
    uint32_t  addr;
    uint32_t  count;
    uint32_t  index;
    uint32_t* ptr;

    addr  = monitor_get_argument_hex(1);
    count = monitor_get_argument_hex(2);

    // set minimum count, if count is not set
    if (count == 0) count = 16;
    
    // we can only read at 32 bit aligned addresses
    ptr = (uint32_t*)(addr & 0xfffffffc);

    if (count != 1)
    {
        for (index = 0; index < count; index++)
        {
            if ( (index % 4) == 0) 
            {
                putstr("\n0x"); puthex(32, (uint32_t)ptr); putstr(" : ");
            }
            putstr("0x"); puthex( 32, *ptr); putchar(' ');
            *ptr++;
        }
    }
    else
    // fast version without address
    {
        putstr("0x"); puthex( 32, *ptr);
    }
    putchar( '\n');
    return 0;
}


/*
    write specific value on memory
    arguments:
        address
        count
        value(0) .. value(n)
*/
uint32_t wmem_function( void)
{
    uint32_t  addr;
    uint8_t   count;
    uint8_t   index;
    uint32_t  value;
    uint32_t* ptr;
    
    addr  = monitor_get_argument_hex(1);
    count = monitor_get_argument_int(2);

    ptr  = (uint32_t*)addr; // automatic word aligned

    index = 3;
    while (count > 0)
    {
        value = monitor_get_argument_hex(index);
        index++;
        count--;
        *ptr = value;
        ptr++;
    }
    return count;
}


/*
    clear screen
*/
uint32_t clear_function( void) 
{
    putchar('\f');
    return 0;
}


////////////////////////////////////////////////////////////
// reset function
uint32_t reset_function( void)
{
    *reset_reg = 0x87654321;
    return 1;
}


////////////////////////////////////////////////////////////
// system info
uint32_t system_info_function( void)
{
    uint8_t   verbose;

    verbose = monitor_get_argument_int(1); 
    ahb_info( verbose);
    return 0;
}


