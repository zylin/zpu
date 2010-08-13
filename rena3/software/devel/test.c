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
        
// http://asalt-vehicle.googlecode.com/svn› trunk› src› uart.c
void uart_hex(unsigned char dataType, unsigned long data) 
{
    unsigned char count, i, temp;
    char dataString[] = "0x        ";

    if (dataType == 8) count = 2;
    if (dataType == 16) count = 4;
    if (dataType == 32) count = 8;

    for(i=count; i>0; i--)
    {
        temp = data % 16;
        if((temp>=0) && (temp<10)) dataString [i+1] = temp + 0x30;
        else dataString [i+1] = (temp - 10) + 0x41;

        data = data/16;
    }

    uart_putstr( dataString);
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
void running_light( uint32_t simulation_active)
{
//  unsigned int pattern = 0x01800180;
	unsigned int pattern = 0x80300700;
    uint32_t count = 32;

            
    while (1)
    {
    
        gpio0->ioout = pattern;
        pattern = (pattern << 1) | (pattern >> 31);

        if (simulation_active)
        {
            // do only limited runs
            if (count == 0) break;
            count--;
        } 
        else
        {
            msleep( 125);
        }
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

void ether_mdio_write( uint16_t data, uint16_t phy_addr, uint16_t reg_addr)
{
    loop_until_bit_is_clear( ether0->mdio_control, ETHER_MDIO_BUSY);
    ether0->mdio_control = (data << 16) | (phy_addr << 11) | (reg_addr << 6) | ETHER_MDIO_WR;
}

uint16_t ether_mdio_read( uint16_t phy_addr, uint16_t reg_addr)
{
    loop_until_bit_is_clear( ether0->mdio_control, ETHER_MDIO_BUSY);
    ether0->mdio_control = (phy_addr << 11) | (reg_addr << 6) | ETHER_MDIO_RD;
    loop_until_bit_is_clear( ether0->mdio_control, ETHER_MDIO_BUSY);
    return (ether0->mdio_control >> 16);
}
void ether_init( void)
{
    
    ether0->status  = 0xffffffff; // init for simulation
    ether0->mac_msb = 0xffff0a00;
    ether0->mac_lsb = 0x2a0bfefb;
    ether0->control = ETHER_CONTROL_RESET;
    loop_until_bit_is_clear( ether0->control, ETHER_CONTROL_RESET);
    ether_mdio_write( 0x1f, 0x00, 0x8000); // software reset
    ether_mdio_write( 0x1f, 0x00, 0x2180); // autoneg off, speed 100, full duplex, col test
}

void ether_test( void)
{
    char str[20];
    
    //sprintf( str, "%d", 15); // compiled library too big for ram

    // reset status (for simulation)
    ether0->status     = 0xffffffff;
    ether0->mac_msb    = 0xffff001b;
    ether0->mac_lsb    = 0x21684b0a;
    ether0->tx_pointer = 0x00001234;
    ether0->rx_pointer = 0x00004321;

    uart_putstr( "\ngreth registers:");
//  uart_putstr( "\ncontrol:      "); itoa( ether0->control,      str); uart_hex(8, str);
    uart_putstr( "\ncontrol:      "); uart_hex( 32, ether0->control);
    uart_putstr( "\nstatus:       "); uart_hex( 32, ether0->status);
    uart_putstr( "\nmac_msb:      "); uart_hex( 32, ether0->mac_msb);
    uart_putstr( "\nmac_lsb:      "); uart_hex( 32, ether0->mac_lsb);
    uart_putstr( "\nmdio_control: "); uart_hex( 32, ether0->mdio_control);
    uart_putstr( "\ntx_pointer:   "); uart_hex( 32, ether0->tx_pointer);
    uart_putstr( "\nrx_pointer:   "); uart_hex( 32, ether0->rx_pointer);
    uart_putstr( "\nedcl_ip:      "); uart_hex( 32, ether0->edcl_ip);
    uart_putstr( "\nhash_msb:     "); uart_hex( 32, ether0->hash_msb);
    uart_putstr( "\nhash_lsb:     "); uart_hex( 32, ether0->hash_lsb);
    uart_putchar('\n');

}

void ether_test_read_mdio( void)
{
    char str[20];
    uint32_t mdio_phy;  // 0..31
    uint32_t mdio_reg;  // 0..31
    uint16_t mdio_data; // 16 bit

    uart_putstr("\nmdio phy registers");
    for (mdio_phy=31; mdio_phy<32; mdio_phy++)
    {
        uart_putstr("\n mdio phy: "); uart_hex( 8, mdio_phy);

        for (mdio_reg=0; mdio_reg<32; mdio_reg++)
        {
            if (mdio_reg==7)  mdio_reg=16;
            if (mdio_reg==19) mdio_reg=20;
            if (mdio_reg==24) mdio_reg=27;
            uart_putstr("\n  reg: "); itoa( mdio_reg, str); uart_putstr( str);
            uart_putstr("-> ");       uart_hex( 16, ether_mdio_read( mdio_phy, mdio_reg));
//          uart_putstr("-> ");       uart_hex( 32, ether0->mdio_control);
        }
    }
    uart_putchar('\n');
}


void ether_test_tx_packet( void)
{
    // data from 0x2000000 to 0x20000FFF
    uint32_t length = 64; // minimum size is 46 (w/o vlan tag) or 42 (with vlan tag)
    
    typedef struct
    {
        volatile uint32_t array[length];
    } data_t;


    greth_tx_descriptor_t *descr       = (greth_tx_descriptor_t *) 0xa0000000;
    data_t                *data_buffer = (data_t *)                0xa0000100;

    
    uint32_t i;

    gpio0->ioout = 0x01;
    // setup the data
    //   fill buffer (ethernet address, type field, etc.)
    for (i=0; i<length; i++)
        data_buffer->array[i] = 100 - i;

    gpio0->ioout = 0x03;

    // setup the descriptor
    //   set buffer address on descriptor
    descr->address = (uint32_t) data_buffer; 
    //   enable descriptor
    descr->control = ETHER_DESCRIPTOR_ENABLE | ETHER_DESCRIPTOR_WRAP | length;

    // give descriptor to core
    ether0->tx_pointer = (uint32_t) descr;

    // set tx enable bit
    ether0->control = ETHER_CONTROL_TX_ENABLE | ETHER_CONTROL_FULL_DUPLEX;

    //gpio0->ioout = 0x07;
    //gpio0->ioout = (descr->control >> 11);

    // wait for end of transmission
    //loop_until_bit_is_clear( descr->control, ETHER_DESCRIPTOR_ENABLE);
    
    wait( 15000); 
    uart_putstr("\ngreth->control :"); uart_hex( 32, ether0->control);
    uart_putstr("\ngreth->status  :"); uart_hex( 32, ether0->status);
    uart_putstr("\ndescr->control :"); uart_hex( 32, descr->control);

    ether_test_read_mdio();
    // check for errors in descriptor
    //ETHER_DESCRIPTOR_UNDERRUN_ERR
    //ETHER_DESCRIPTOR_ATTEMEPT_LIMIT_ERR

    // check transmission status
    // 3 bits (TE, TI, TA)
}



int main(void)
{

    uint32_t simulation_active = bit_is_set(gpio0->iodata, (1<<31));


    timer_init();
    uart_init();
    running_light_init();
    ether_init();

    uart_putstr("\n\n");
    uart_putstr("test.c ");
    (simulation_active) ? uart_putstr("(on simulator)\n") : uart_putstr("(on hardware)\n");
    uart_putstr("compiled: " __DATE__ "  " __TIME__ "\n");


    //ether_test();
    ether_test_tx_packet();
    //ether_test_read_mdio();

    //uart_test();
    
    running_light( simulation_active);
    
    //gpio_test();

    //puts("end.");
    abort();
}
