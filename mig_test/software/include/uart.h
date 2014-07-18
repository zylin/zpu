/*
 * $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/hw_sp605/bsp_zpuahb/software/include/uart.h $
 * $Date$
 * $Author$
 * $Revision$
 */


#ifndef UART_H
#define UART_H


////////////////////////////////////////
// uart functions

#define UART_HW_HANDSHAKE_ON    (uart0-> ctrl |= UART_CONTROL_FLOW_CONTROL)
#define UART_HW_HANDSHAKE_OFF   (uart0-> ctrl &= ~UART_CONTROL_FLOW_CONTROL)

void uart_init( void);
unsigned int uart_check_receiver();
char uart_getchar();
void uart_putchar_raw( char c);
char uart_putchar( char c);

#endif // UART_H
