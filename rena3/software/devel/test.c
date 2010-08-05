//#include <stdio.h>
//#include <stdlib.h> // itoa

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
    #if UART_FIFOSIZE==1 || !defined(UART_FIFOSIZE)
    loop_until_bit_is_set( uart0->status, UART_STATUS_TX_REG_EMPTY);
    #else
    loop_until_bit_is_clear( uart0->status, UART_STATUS_TX_FIFO_FULL);
    #endif
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

// http://www.mikrocontroller.net/articles/FAQ#itoa.28.29
void itoa( int z, char* Buffer )
{
  int i = 0;
  int j;
  char tmp;
  unsigned u;    // In u bearbeiten wir den Absolutbetrag von z.
  
    // ist die Zahl negativ?
    // gleich mal ein - hinterlassen und die Zahl positiv machen
    if( z < 0 ) {
      Buffer[0] = '-';
      Buffer++;
      // -INT_MIN ist idR. größer als INT_MAX und nicht mehr 
      // als int darstellbar! Man muss daher bei der Bildung 
      // des Absolutbetrages aufpassen.
      u = ( (unsigned)-(z+1) ) + 1; 
    }
    else { 
      u = (unsigned)z;
    }
    // die einzelnen Stellen der Zahl berechnen
    do {
      Buffer[i++] = '0' + u % 10;
      u /= 10;
    } while( u > 0 );
 
    // den String in sich spiegeln
    for( j = 0; j < i / 2; ++j ) {
      tmp = Buffer[j];
      Buffer[j] = Buffer[i-j-1];
      Buffer[i-j-1] = tmp;
    }
    Buffer[i] = '\0';
}




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
//  set leds on number or resend incomming character
//
void uart_test( void)
{

    char val;

    // default value
    gpio0->ioout = 0x55;

    while (1)
    {
        val = uart_getchar();
        switch (val)
        {
            case '0':  gpio0->ioout = 0x00; break;
            case '1':  gpio0->ioout = 0x01; break;
            case '2':  gpio0->ioout = 0x03; break;
            case '3':  gpio0->ioout = 0x07; break;
            case '4':  gpio0->ioout = 0x0f; break;
            case '5':  gpio0->ioout = 0x1f; break;
            case '6':  gpio0->ioout = 0x3f; break;
            case '7':  gpio0->ioout = 0x7f; break;
            case '8':  gpio0->ioout = 0xff; break;
            case '\r': break;
            case '\n': break;
            default:
                uart_putchar( '+');
                uart_putchar( val);
                uart_putchar( '-');
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

//
// puts ethernet registers
//
void ether_test( void)
{
    char str[20];
    
    //sprintf( str, "%d", 15); // compiled library too big for ram

    uart_putstr( "\ngreth registers:");
    uart_putstr( "\ncontrol:      "); itoa( ether0->control,      str); uart_putstr( str);
    uart_putstr( "\nstatus:       "); itoa( ether0->status ,      str); uart_putstr( str);
    uart_putstr( "\nmac_msb:      "); itoa( ether0->mac_msb,      str); uart_putstr( str);
    uart_putstr( "\nmac_lsb:      "); itoa( ether0->mac_lsb,      str); uart_putstr( str);
    uart_putstr( "\nmdio_control: "); itoa( ether0->mdio_control, str); uart_putstr( str);
    uart_putstr( "\ntx_pointer:   "); itoa( ether0->tx_pointer,   str); uart_putstr( str);
    uart_putstr( "\nrx_pointer:   "); itoa( ether0->rx_pointer,   str); uart_putstr( str);
    uart_putstr( "\nedcl_ip:      "); itoa( ether0->edcl_ip,      str); uart_putstr( str);
    uart_putstr( "\nhash_msb:     "); itoa( ether0->hash_msb,     str); uart_putstr( str);
    uart_putstr( "\nhash_lsb:     "); itoa( ether0->hash_lsb,     str); uart_putstr( str);
    uart_putchar('\n');

}


int main(void)
{

    uint32_t simulation_active = bit_is_set(gpio0->iodata, (1<<31));


    timer_init();
    uart_init();

    uart_putstr("\n\n");
    uart_putstr("SoC, ZPU test program ");
    (simulation_active) ? uart_putstr("(on simulator)\n") : uart_putstr("(on hardware)\n");
    uart_putstr("compiled: " __DATE__ "   " __TIME__ "\n");


    ether_test();

    uart_test();
    
    running_light_init();
    running_light();
    
    //gpio_test();

    //puts("end.");
    abort();
}
