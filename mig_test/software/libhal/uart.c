//#include <stdio.h>

#include "peripherie.h"

////////////////////////////////////////
// common defines

#define bit_is_set(mem, bv)               (mem & bv)
#define bit_is_clear(mem, bv)             (!(mem & bv))
#define loop_until_bit_is_set(mem, bv)    do {} while( bit_is_clear(mem, bv))
#define loop_until_bit_is_clear(mem, bv)  do {} while( bit_is_set(mem, bv))


////////////////////////////////////////
// uart functions


void uart_init( void)
{
    uart0->scaler = UART_SCALER;
    uart0->ctrl   = UART_CONTROL_TX_ENABLE | UART_CONTROL_RX_ENABLE;
}


unsigned int uart_check_receiver()
{
    return ( bit_is_set( uart0->status, UART_STATUS_DATA_READY) != 0);
}


char uart_getchar()
{
    loop_until_bit_is_set(uart0->status, UART_STATUS_DATA_READY);
    return uart0->data;
}


void uart_putchar_raw( char c)
{
    #if UART_FIFOSIZE==1 || !defined(UART_FIFOSIZE)
    loop_until_bit_is_set( uart0->status, UART_STATUS_TX_REG_EMPTY);
    #else
    loop_until_bit_is_clear( uart0->status, UART_STATUS_TX_FIFO_FULL);
    #endif
    uart0->data = c;
}


char uart_putchar( char c)
{
    if (c == '\n') 
        uart_putchar_raw( '\r');
    uart_putchar_raw( c);
    return 0;
}

