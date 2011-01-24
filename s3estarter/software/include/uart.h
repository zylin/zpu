#ifndef UART_H
#define UART_H


////////////////////////////////////////
// uart functions

void uart_init( void);
unsigned int uart_check_receiver();
char uart_getchar();
void uart_putchar_raw( char c);
void uart_putchar( char c);

#endif // UART_H
