//#include <stdio.h>

#include "peripherie.h"

////////////////////////////////////////
// common defines

#define bit_is_set(mem, bv)               (mem & bv)
#define bit_is_clear(mem, bv)             (!(mem & bv))
#define loop_until_bit_is_set(mem, bv)    do {} while( bit_is_clear(mem, bv))
#define loop_until_bit_is_clear(mem, bv)  do {} while( bit_is_set(mem, bv))



////////////////////////////////////////
// timer functions

void msleep(uint32_t msec)
{
    uint32_t tcr;

    timer0->e[0].reload = (F_CPU/TIMER_PRESCALER/1000)*msec;
    timer0->e[0].ctrl   = TIMER_ENABLE | TIMER_LOAD;

    do 
    {
        tcr = timer0->e[0].ctrl;
    } while ( (tcr & TIMER_ENABLE));
}

void nsleep(uint32_t nsec)
{
    uint32_t tcr;

    timer0->e[0].reload = (F_CPU/TIMER_PRESCALER/1000000)*nsec;
    timer0->e[0].ctrl   = TIMER_ENABLE | TIMER_LOAD;

    do 
    {
        tcr = timer0->e[0].ctrl;
    } while ( (tcr & TIMER_ENABLE));
}

void wait( uint32_t value)
{
    uint32_t i;

    for (i=0; i<value; i++) {}
}

void timer_init( void)
{
    timer0->scaler_reload = TIMER_PRESCALER-1; // set prescaler
}




////////////////////////////////////////
// uart functions


void uart_init( void)
{
    uart0->scaler = UART_SCALER;
    uart0->ctrl   = UART_CONTROL_TX_ENABLE | UART_CONTROL_RX_ENABLE;
}

char uart_getchar()
{
    loop_until_bit_is_set(uart0->status, UART_STATUS_DATA_READY);
    return uart0->data;
}

void uart_putchar_raw( char c)
{
    loop_until_bit_is_set( uart0->status, UART_STATUS_TX_FIFO_EMPTY);
    //loop_until_bit_is_set( uart0->status, UART_STATUS_TX_REG_EMPTY);
    uart0->data = c;
}

void uart_putchar( char c)
{
    if (c == '\n') 
        uart_putchar_raw( '\r');
    uart_putchar_raw( c);
}

void uart_putstr(const char *s)
{
    while (*s) 
    {
        uart_putchar( *s++);
    }
}
        



////////////////////////////////////////
// specific stuff

void running_light_init( void)
{
    // enable output drivers
    gpio0->iodir = 0x000000FF;
}


//
// generate a running light pattern
//
void running_light( void)
{
//  unsigned int pattern = 0x01800180;
	unsigned int pattern = 0x01003007;

            
    while (1)
    {
    
        gpio0->ioout = pattern;
        msleep( 125);
        pattern = (pattern << 1) | (pattern >> 31);
    }

}



//
//
//
void uart_test( void)
{

    timer0->e[1].reload = (F_CPU/TIMER_PRESCALER);
        
    while (1)
    {
        if bit_is_clear( timer0->e[1].ctrl, TIMER_ENABLE)
        {
            uart_putchar( 'a');
            timer0->e[1].ctrl   = TIMER_ENABLE | TIMER_LOAD;
        }
    }

}


//
// puts input switches doubled on leds
//
void gpio_test( void)
{
    uint32_t val;

    while (1)
    {
        val          = gpio0->iodata & 0x0F; // mask sw
        gpio0->ioout = (val << 4) | val;
    }
}


int main(void)
{

    timer_init();
    uart_init();

    uart_putstr("SoC, ZPU test program\n");
    uart_putstr("compiled: " __DATE__ "   " __TIME__ "\n");

    running_light_init();

    //uart_test();
    running_light();
    //gpio_test();

    //puts("end.");
    abort();
}
