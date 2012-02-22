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
void uart_putchar( char c);

#endif // UART_H
