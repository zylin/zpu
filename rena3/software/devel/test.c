//#include <stdio.h>

#include "peripherie.h"

////////////////////////////////////////
// common defines

#define bit_is_set(mem, bv)               (mem & bv)
#define bit_is_clear(mem, bv)             (!(mem & bv))
#define loop_until_bit_is_set(mem, bv)    do {} while( bit_is_clear(mem, bv))
#define loop_until_bit_is_clear(mem, bv)  do {} while( bit_is_set(mem, bv))

uint32_t simulation_active;


////////////////////////////////////////
// timer functions

void msleep(uint32_t msec)
{
    uint32_t tcr;

    // 1 msec    = 6250
    // 167 msec  = 2**20 (20 bit counter) 391 slices
    // 2684 msec = 2**24 (24 bit counter) 450 slices
    //           = 2**32 (32 bit counter) 572 slices
    timer0->e[0].reload = (F_CPU/TIMER_PRESCALER/1000)*msec;
    timer0->e[0].ctrl   = TIMER_ENABLE | TIMER_LOAD;

    do 
    {
        tcr = timer0->e[0].ctrl;
    } while ( (tcr & TIMER_ENABLE));
}

void sleep(uint32_t sec)
{
    uint32_t timer;

    for (timer=0; timer<sec; timer++)
    {
        msleep( 166);
        msleep( 166);
        msleep( 166);
        msleep( 166);
        msleep( 166);
        msleep( 166);
    }
}

void nsleep(uint32_t nsec)
{
    uint32_t tcr;

    // 1 nsec = 6
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
        uart_putchar( *s++);
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



uint8_t vga_line;
uint8_t vga_column;

void vga_init( void)
{
    vga0->background_color = 0x00000000;
    vga0->foreground_color = 0x00ffffff;
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
    if ( (c == '\n') || (vga_column == 79) )
    {
        if (vga_line<36) 
            vga_line++;
        else
            vga_line = 0;

        vga_column = 0;
    }
    else
    {
        vga_column++;
    }
        
}

void vga_putstr(char *s)
{
    while (*s)
        vga_putchar( *s++);
}


void putstr(char *s)
{
    uart_putstr( s);
    vga_putstr( s);
}

void puthex(unsigned char dataType, unsigned long data) 
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
    vga_putstr( dataString);
}


void vga_puthex(unsigned char dataType, unsigned long data) 
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
    vga_putstr( dataString);
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
    // data memory segment from 0xa000000 to 0xa0000FFF

    greth_tx_descriptor_t *descr        = (greth_tx_descriptor_t *) (0xa0000000);
    mac_header_t          *mac_header   = (mac_header_t *)          (0xa0000100);
    
    uint32_t i;

    // setup the data
    //   fill buffer (ethernet address, type field, etc.)
    for (i=0; i<data_length; i++)
        mac_header->ip_header.udp_header.data[i] = data_length - i;

    // setup ethernet packet
    mac_header->dest_mac[0]            = 0x00; // ipconfig -all
    mac_header->dest_mac[1]            = 0x1b;
    mac_header->dest_mac[2]            = 0x21;
    mac_header->dest_mac[3]            = 0x68;
    mac_header->dest_mac[4]            = 0x4b;
    mac_header->dest_mac[5]            = 0x0a;
    mac_header->source_mac[0]          = 0xde;
    mac_header->source_mac[1]          = 0xad;
    mac_header->source_mac[2]          = 0xbe;
    mac_header->source_mac[3]          = 0xef;
    mac_header->source_mac[4]          = 0x00;
    mac_header->source_mac[5]          = 0x20;
    mac_header->ethertype              = ETHERTYPE_IPv4;//data_length;

    mac_header->ip_header.version         = (4<<4) | 5 ; //version + (5*32 bit length)
    mac_header->ip_header.tos             = 0;
    mac_header->ip_header.length          = data_length + 29;
    mac_header->ip_header.identification  = 0;
    mac_header->ip_header.fragment_offset = FLAG_DF | 0;
    mac_header->ip_header.ttl             = 255;
    mac_header->ip_header.protocol_id     = PROTOCOL_UDP;
    mac_header->ip_header.checksum        = 0x678d;
    mac_header->ip_header.source_ip       = (10<<24)+(0<<16)+(0<<8)+(2<<0);
    mac_header->ip_header.dest_ip         = (10<<24)+(0<<16)+(0<<8)+(1<<0);

    mac_header->ip_header.udp_header.source_port = 5050;
    mac_header->ip_header.udp_header.dest_port   = 5050;
    mac_header->ip_header.udp_header.length      = data_length + 8;
    mac_header->ip_header.udp_header.checksum    = 0x9fe3;
    
    
    // setup the descriptor
    //   set buffer address on descriptor
    descr->address = (uint32_t) mac_header; 
    //   enable descriptor
    descr->control = ETHER_DESCRIPTOR_ENABLE | ETHER_DESCRIPTOR_WRAP | data_length + 42;

    // give descriptor to core
    ether0->tx_pointer = (uint32_t) descr;

    // set tx enable bit
    ether0->control = ETHER_CONTROL_TX_ENABLE | ETHER_CONTROL_FULL_DUPLEX;

    // wait for end of transmission
    loop_until_bit_is_clear( descr->control, ETHER_DESCRIPTOR_ENABLE);
    
    putstr("\ngreth->control :"); puthex( 32, ether0->control);
    putstr("\ngreth->status  :"); puthex( 32, ether0->status);
    putstr("\ndescr->control :"); puthex( 32, descr->control);

    // ether_test_read_mdio();
    // check for errors in descriptor
    //ETHER_DESCRIPTOR_UNDERRUN_ERR
    //ETHER_DESCRIPTOR_ATTEMEPT_LIMIT_ERR

    // check transmission status
    // 3 bits (TE, TI, TA)
}



void memory_test( void)
{
    uint32_t *memoryw = (uint32_t *) (0x90000000);
    uint32_t *memoryr = (uint32_t *) (0x92000000);
    uint32_t *memptr;         //      0x_1000000
    uint32_t i;
    uint32_t read;
    uint32_t length = 32;
   

    memptr = memoryw;

    putstr("write address: ");   puthex( 32, (uint32_t) memptr);
    putstr("  length: ");        puthex( 32, length);
    putstr("\n\n");

    for ( i=0; i<length; i++)
    {
        *memptr = i;
        memptr++;
    }

    memptr = memoryr;
    for ( i=0; i<length; i++)
        {
            read = *memptr;
            if (!simulation_active)
            {
                putstr("read  address: ");        puthex( 32, (uint32_t) memptr);
                putstr("  expect: ");             puthex( 32, i);
                putstr("  got: ");                puthex( 32, read);
                (i == read) ? putstr(" ok") :  putstr(" error");
                putstr("\n");
            } else
            {
                putstr("  got: ");                  puthex( 32, read);
                putstr("\n");
            }

        memptr++;
        }
}

void memory_test_init( uint32_t start, uint32_t length)
{
    uint32_t *memory = (uint32_t *) start;//(0x90000000);
    uint32_t *memptr;
    uint32_t i;
   

    memptr = memory;

    // write
    for ( i=0; i<length; i++)
    {
        *memptr = (uint32_t) memptr;
        memptr++;
    }

}
int memory_test_complete( uint32_t start, uint32_t length)
{
    uint32_t *memory = (uint32_t *) start;//(0x90000000);
    uint32_t *memptr;
    uint32_t i;
    uint32_t read;
   

    // read/ compare
    memptr = memory;
    for ( i=0; i<length; i++)
    {
        read = *memptr;
        if (memptr != read) return( FALSE);
        memptr++;
    }
    return( TRUE);
}

int memory_test_dot( void)
{
    uint32_t i;
    uint32_t s;
    uint32_t chunks = 0x0002;
    char str[20];
    int count_bad;

    vga_init();
    itoa( dcm_ctrl0->dec, str); vga_putstr("phase shift : "); vga_putstr( str); vga_putstr("     ");
    
    s         = 0x90000000;
    count_bad = 0;

    for (i=0; i<2048; i++)
    {
        if ((i%64) == 0)
        {
            vga_putstr("\n"); vga_puthex( 32, s); vga_putstr(" ");
        }
        if ( memory_test_complete( s, chunks) )
            vga_putstr(".");
        else
        {
            vga_putstr("!");
            count_bad++;
        }
        s += chunks;
    }

    return( count_bad);
}


void memory_info( void)
{
    uint32_t value;
    char str[20];

    putstr("DDR memory info");


    value = ddr0->sdram_control;

    putstr("\nauto t_RERESH :");  itoa( value & 0x7fff, str); putstr( str);
    putstr("\nclock enable  :");  puthex(  8, value >> 15 & 0x01);
    putstr("\ninitalize     :");  puthex(  8, value >> 16 & 0x01);
    putstr("\ncolumn size   :");  
        switch (value >> 21 & 0x03)
        {
            case 0: putstr(" 512"); break;
            case 1: putstr("1024"); break;
            case 2: putstr("2048"); break;
            case 3: putstr("4069"); break;
        }

    putstr("\nbanksize      :");  itoa( 1<<(3+(value >> 23 & 0x07)), str); putstr( str);putstr("Mbyte");
    
    // requirement for 100 MHz
    // trcd  0 (+1) -> t_rcd = 20 ns
    // trfc  4 (+3) -> t_rfc = 70 ns 
    // trp   0 (+2) -> t_rp  = 20 ns 
    // trp+trfc+4   -> t_rc  = 80 ns
    //                 t_ras = 50 ns
    
    putstr("\nt_RCD         :");  itoa( 1 + (value >> 26 & 0x01), str); putstr( str);
    putstr("\nt_RFC         :");  itoa( 3 + (value >> 27 & 0x07), str); putstr( str);
    putstr("\nt_RP          :");  itoa( 2 + (value >> 30 & 0x01), str); putstr( str);
    putstr("\nrefresh en.   :");  puthex(  8, value >> 31 & 0x01);

    
    value = ddr0->sdram_config;

    putstr("\nDDR frequency :");  itoa( value & 0x0fff, str); putstr( str);
    putstr("\nDDR data width:");  itoa( 1<<(3+(value >> 12 & 0x07)), str); putstr( str);
    putstr("\nmobile support:");  puthex(  8, value >> 15 & 0x01);

    
    value = ddr0->sdram_power_saving;

    putstr("\nself refresh  :");  
        switch (value & 0x07)
        {
            case 0: putstr("1/1"); break;
            case 1: putstr("1/2"); break;
            case 2: putstr("1/4"); break;
            case 5: putstr("1/8"); break;
            case 6: putstr("1/8"); break;
            default: putstr("unknown");
        } putstr(" array");
    putstr("\ntemp-comp refr:");  
        switch (value >> 3 & 0x03)
        {
            case 0: putstr("70"); break;
            case 1: putstr("45"); break;
            case 2: putstr("15"); break;
            case 3: putstr("85"); break;
        } putstr("°C");
    putstr("\ndrive strength:");  
        switch (value >> 5 & 0x07)
        {
            case 0: putstr("full"); break;
            case 1: putstr("half"); break;
            case 2: putstr("1/4"); break;
            case 3: putstr("3/4"); break;
        }
    putstr("\npower saving  :");  
        switch (value >> 16 & 0x07)
        {
            case 0: putstr("none"); break;
            case 1: putstr("power down"); break;
            case 2: putstr("self refresh"); break;
            case 4: putstr("clock stop"); break;
            case 5: putstr("deep power down"); break;
            default: putstr("unknown");
        }
    putstr("\nt_XP          :");  itoa( 2 + (value >> 19 & 0x01), str); putstr( str);
    putstr("\nt_XSR         :");  itoa( (value >> 20 & 0x0f), str); putstr( str);
    putstr("\nt_CKE         :");  itoa( 1 + (value >> 24 & 0x01), str); putstr( str);
    putstr("\nCAS latency   :");  itoa( 2 + (value >> 30 & 0x01), str); putstr( str);
    putstr("\nmobile enabled:");  puthex(  8, value >> 31 & 0x01);
   
 
    value = ddr0->status_read;

    putstr("\nstatus read   :");  puthex(32 , value);
}



void mem_dump( void)
{
    uint32_t *memptr;
    uint32_t i;

//  for ( i=0x80000e00; i<=0x80000e04; i+=0x00000004) // dcm control
//  for ( i=0xfff00000; i<=0xfff00018; i+=0x00000004) // ddr control
    for ( i=0x90000000; i<=0x90000080; i+=0x00000004) // ddr content
    {
        memptr = (uint32_t *) i;
        putstr("address: ");   puthex( 32, (uint32_t) memptr);
        putstr(" data: ");     puthex( 32,           *memptr);
        putstr("\n");
    }
}

void dcm_test_ps( void)
{

    const uint32_t pattern   = 0x55aaff55;
    const uint16_t range     = 255;
    const uint16_t sleeptime = 1;
    uint16_t       i;
    uint16_t       min_error;
    int32_t        min_error_pos;
    int32_t        low_value;
    int32_t        high_value;
    char           str[20];

    putstr("\n\nDCM phase shift testing");
    
    putstr("\ninitial: "); itoa( dcm_ctrl0->dec, str); putstr( str); putstr(" "); puthex( 32, memory_test_dot() );

    // go down
    while (dcm_ctrl0->dec > -range)
    {
        dcm_ctrl0->dec = 0;
        msleep( sleeptime);
    }

    // search low value
    i             = 0xffff;
    min_error     = 0xffff;
    min_error_pos = -range;
    while (( i != 0) && (dcm_ctrl0->dec < range))
    {
        dcm_ctrl0->inc = 0;
        i = memory_test_dot();
        if (i < min_error)
        {
            min_error = i;
            min_error_pos = dcm_ctrl0->dec;
        }
        putstr("\n"); itoa( i, str); putstr( str); 
    }
    low_value = dcm_ctrl0->dec;

    // search high value
    i = 0;
    while ((i == 0) && (dcm_ctrl0->dec < range))
    {
        dcm_ctrl0->inc = 0;
        i = memory_test_dot();
        if (i < min_error)
        {
            min_error = i;
            min_error_pos = dcm_ctrl0->dec;
        }
        putstr("\n"); itoa( i, str); putstr( str);
    }
    high_value = dcm_ctrl0->dec;
    // go to eye
    //for (i=0; i<( ( high_value-low_value) / 2); i++)
    for (i=0; i<( ( high_value-min_error_pos) ); i++)
    {
        dcm_ctrl0->dec = 0;
        msleep( sleeptime);
        //loop_until_bit_is_set( dcm_ctrl0->ready, (1<<0) );
    }

    putstr("\nlow:         "); itoa( low_value, str);                putstr( str);
    putstr("\nhigh:        "); itoa( high_value, str);               putstr( str);
    putstr("\ndiff:        "); itoa(  high_value-low_value, str);    putstr( str);
    putstr("\ndiff/2:      "); itoa( (high_value-low_value)/2, str); putstr( str);
    putstr("\nmin_err:     "); itoa( min_error, str);                putstr( str);
    putstr("\nmin_err_pos: "); itoa( min_error_pos, str);            putstr( str);
    putstr("\nfinal:       "); itoa( dcm_ctrl0->dec, str);           putstr( str);
}


int main(void)
{
    char str[20];

    // check if on simulator or on hardware
    simulation_active = bit_is_set(gpio0->iodata, (1<<31));

    memory_test_init( 0x90000000, 0x0010000);

    timer_init();
    vga_init();
    uart_init();
    running_light_init();
    ether_init();
    
    putstr("\n\n");
    vga_clear();

    putstr("test.c ");
    (simulation_active) ? putstr("(on simulator)\n") : putstr("(on hardware)\n");
    putstr("compiled: " __DATE__ "  " __TIME__ "\n");

    //memory_info();
    //sleep( 5);

    dcm_test_ps();
    sleep( 10);
    
    //vga_clear();
    //mem_dump();
    //sleep( 10);

    vga_clear();
    while (1)
    {
        memory_test_dot();
        //sleep( 1);
        if bit_is_set( gpio0->iodata, (1<<7))   dcm_ctrl0->dec = 0; // btn west -> dec ps
        if bit_is_set( gpio0->iodata, (1<<4))   dcm_ctrl0->inc = 0; // btn east -> inc ps

    }

    //ether_test();
    //ether_test_tx_packet();
    //ether_test_read_mdio();

    //uart_test();
    
    running_light( simulation_active);
    
    //gpio_test();

    //puts("end.");
    abort();
}
