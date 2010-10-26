//#include <stdio.h>

#include <peripherie.h>
#include <lcd-routines.h>

//#define LCD_ENABLE

////////////////////////////////////////
// common defines

#define bit_is_set(mem, bv)               (mem & bv)
#define bit_is_clear(mem, bv)             (!(mem & bv))
#define loop_until_bit_is_set(mem, bv)    do {} while( bit_is_clear(mem, bv))
#define loop_until_bit_is_clear(mem, bv)  do {} while( bit_is_set(mem, bv))

////////////////////////////////////////
// named keys
#define BUTTON_WEST                       (1<<7)
#define BUTTON_EAST                       (1<<4)
#define BUTTON_SOUTH                      (1<<5)
#define BUTTON_NORTH                      (1<<6)  // is it right

#define WORD_MODE                         (0)
#define BIT_MODE                          (1)

uint32_t simulation_active;




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
        if (temp<10) dataString [i+1] = temp + 0x30;
        else         dataString [i+1] = (temp - 10) + 0x41;

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
        if (temp<10) dataString [i+1] = temp + 0x30;
        else         dataString [i+1] = (temp - 10) + 0x41;

        data = data/16;
    }
    uart_putstr( dataString);
    vga_putstr( dataString);
}


void vga_putbin(unsigned char dataType, unsigned long data) 
{
    unsigned char count, i, temp;
    char dataString[] = "0b                                ";

    for(i=dataType; i>0; i--)
    {
        temp = data % 2;
        dataString [i+1] = temp + 0x30;
        data = data/2;
    }
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
        if (temp<10) dataString [i+1] = temp + 0x30;
        else         dataString [i+1] = (temp - 10) + 0x41;

        data = data/16;
    }
    vga_putstr( dataString);
}


void running_light_init( void)
{
    // enable output drivers
    gpio0->iodir |= 0x000000FF;
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
    
        gpio0->ioout = 0x000000ff & pattern;
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
    uint32_t              data_length   = 64;
    
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

// fill the memory with data (data = address)
void memory_test_init( uint32_t start, uint32_t length)
{
    uint32_t *memory = (uint32_t *) start;//(0x90000000);
    uint32_t *memptr;
    uint32_t i;
  
    #ifdef LCD_ENABLE
    lcd_clear(); lcd_string("memory test init");
    #endif

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
    uint32_t i;
    uint32_t data;
    uint8_t  error;
   

    // read and compare
    error = 0;
    for ( i=0; i<length; i++)
    {
        data = *memory;
        if (memory != data) error++;
        memory++;
    }
    return( error);
}

int memory_test_dot( int mode)
// mode 0  --> print wordwise
// mode 1  --> print bitwise
{
    uint32_t i;
    uint32_t s;
    uint32_t *mem;
    uint32_t data;
    uint32_t chunks = 0x0001;
    char     str[20];
    uint32_t count_bad;
    uint8_t  error;

    vga_init();
    // print status line
    itoa( dcm_ctrl0->psvalue, str); vga_putstr("phase shift  -  value: "); vga_putstr( str); vga_putstr("  status: ");  vga_puthex( 8, dcm_ctrl0->psstatus); vga_putstr("     ");
    
    count_bad = 0;
    s         = 0x90000000;


    if (mode == WORD_MODE)
    {

        for (i=0; i<2048; i++)
        {
            if ((i%64) == 0)
            {
                vga_putstr("\n"); vga_puthex( 32, s); vga_putstr(" ");
            }
            error = memory_test_complete( s, chunks);
            vga_putchar( '0' + error);
            count_bad += error;
            s += sizeof(data) * chunks;
        }
    }
    else
    {
        mem = s;
        for (i=0; i<32; i++)
        {
            vga_putstr("\n"); vga_puthex( 32, mem); vga_putchar(' ');
            data = *mem;
            vga_putbin( 32, data); vga_putchar(' ');
            if (mem == data) vga_putstr("ok  ");
            else             vga_putstr("FAIL");
            mem++;
        }
    }

    return( count_bad);
}



uint16_t memory_test_fast( void)
{
    uint32_t i;
    uint32_t s;
    uint32_t *mem;
    uint32_t data;
    uint32_t chunks = 0x0001;
    char     str[20];
    uint32_t count_bad;
    uint8_t  error;

    
    count_bad = 0;
    s         = 0x90000000;


    for (i=0; i<2048; i++)
    {
        error = memory_test_complete( s, chunks);
        count_bad += error;
        s += sizeof(data) * chunks;
    }

    return( count_bad);
}


void memory_info( void)
{
    uint32_t value;
    uint8_t  mobile;
    char str[10];

    putstr("DDR memory info");


    value = ddr0->sdram_control;

    putstr("\n\nauto t_RERESH :");  itoa( value & 0x7fff, str); putstr( str);
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

    putstr("\n\nDDR frequency :");  itoa( value & 0x0fff, str); putstr( str);
    putstr("\nDDR data width:");  itoa( 1<<(3+(value >> 12 & 0x07)), str); putstr( str);
    mobile = value >> 15 & 0x01;
    putstr("\nmobile support:");  puthex(  8, mobile);

    if (mobile) {
    
        value = ddr0->sdram_power_saving;

        putstr("\n\nself refresh  :");  
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
      
     
        value = ddr0->phy_config_0;
        putstr("\n\nphy config 0  :");  puthex(32 , value);

        value = ddr0->phy_config_1;
        putstr("\n\nphy config 1  :");  puthex(32 , value);
    }
        
    value = ddr0->status_read;
    putstr("\n\nstatus read   :");  puthex(32 , value);

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

    uint32_t get_max_range( uint32_t sdram_config)
    {
        uint32_t frequency;
        uint32_t factor;
        uint32_t value;

        frequency = sdram_config & 0x00000fff;                 // mask bits
        factor    = (frequency < 60) ? 10 : 15;            // select factor
        value     = factor * ((1000/frequency) - 3);       // p. 127, ug331.pdf
        return( value);
    }

    uint16_t       range_max = get_max_range( ddr0->sdram_config);
    uint16_t       i;
    uint16_t       min_error;
    int32_t        min_error_pos;
    int8_t         first_changed;
    int32_t        low_value;
    int32_t        high_value;
    int32_t        end_value;
    char           str[20];
    int8_t         low_found;
    int8_t         high_found;

    putstr("\n\nDCM phase shift testing");
    
    i = memory_test_dot( WORD_MODE);
    putstr("\ninitial: "); itoa( dcm_ctrl0->psvalue, str); putstr( str); putstr(" "); puthex( 32, i);

    #ifdef LCD_ENABLE
    lcd_clear(); lcd_string("go down");
    #endif
    //while (dcm_ctrl0->psstatus != 3)
    while (dcm_ctrl0->psvalue >= -range_max)
    {
        dcm_ctrl0->psdec = 0; while (dcm_ctrl0->psstatus == 0); 
    }

    // set one up
    dcm_ctrl0->psinc = 0;  while (dcm_ctrl0->psstatus == 0); 
    dcm_ctrl0->psstatus = 0;
    
    #ifdef LCD_ENABLE
    lcd_clear(); lcd_string("scan range");
    lcd_setcursor( 0, 2); itoa( dcm_ctrl0->psvalue, str); lcd_string( str); lcd_data( ' ');
    #endif
    i             = 0xffff;
    min_error     = memory_test_dot( WORD_MODE);
    min_error_pos = dcm_ctrl0->psvalue;

    low_found     = FALSE; low_value  = -555;
    high_found    = FALSE; high_value =  555;
    first_changed = FALSE;

    while ( dcm_ctrl0->psvalue <= range_max) 
    {
        dcm_ctrl0->psinc = 0;  while (dcm_ctrl0->psstatus == 0); 

        i = memory_test_dot( WORD_MODE);
        vga_putstr("\n");

        // min error detection
        if (i < min_error)
        {
            min_error     = i;
            min_error_pos = dcm_ctrl0->psvalue;
            first_changed = TRUE;
        }
        // low value
        if ( (i == 0) && (!low_found) )
        {
            low_found = TRUE;
            low_value = dcm_ctrl0->psvalue;
        }
        if ( (i == 0) && low_found )
        {
            high_found = TRUE;
            high_value = dcm_ctrl0->psvalue;
        }
        // uart + lcd debug
        putstr("\n");        
        lcd_setcursor( 0, 2); 
        itoa( dcm_ctrl0->psvalue, str); 
        #ifdef LCD_ENABLE
        lcd_string( str); lcd_data( ' ');
        #endif
        uart_putstr( str); uart_putstr("\t");
        itoa( i, str); putstr( str); 
        vga_putstr("    ");
    }

    #ifdef LCD_ENABLE
    lcd_clear(); lcd_string("go to eye");
    #endif
    if ((low_found) && (high_found))
    {
        end_value = high_value - ((high_value - low_value) / 2);
    }
    else
    {
        if (first_changed)
        {
            end_value = min_error_pos;
        }
        else
        {
            end_value = 0;
        }
    }

    // end_value means now the left shift
    end_value = dcm_ctrl0->psvalue - end_value;

    while (end_value > 0)
    {
        end_value--;
        dcm_ctrl0->psdec = 0;  while (dcm_ctrl0->psstatus == 0); 
    }
    
    vga_clear();
    putstr("\n");if (low_found)  putstr("low found");  else putstr("low NOT found");
    putstr("\n");if (high_found) putstr("high found"); else putstr("high NOT found");
    putstr("\nlow:         "); itoa( low_value, str);                putstr( str);
    putstr("\nhigh:        "); itoa( high_value, str);               putstr( str);
    putstr("\n");
    putstr("\ndiff:        "); itoa(  high_value-low_value, str);    putstr( str);
    putstr("\ndiff/2:      "); itoa( (high_value-low_value)/2, str); putstr( str);
    putstr("\n");
    putstr("\nmin_err:     "); itoa( min_error, str);                putstr( str);
    putstr("\nmin_err_pos: "); itoa( min_error_pos, str);            putstr( str);
    putstr("\n");if (first_changed) putstr("go min_error"); else putstr("go zero");
    putstr("\n");
    putstr("\nfinal:       "); itoa( dcm_ctrl0->psvalue, str);           putstr( str);
    #ifdef LCD_ENABLE
    lcd_clear(); lcd_string("dcm_test_ps done");
    #endif
}

/*
 * this code try to find the data valid window from ddr sdram
 *
 * problem: not bubble proof
 *
 */
uint8_t ddr_scan_fast( void)
{

    // max range fpr dcm phase shift depends
    // on used frequency (only on spartan 3a)
    uint32_t get_max_range( uint32_t sdram_config)
    {
        uint32_t frequency;
        uint32_t factor;
        uint32_t value;

        frequency = sdram_config & 0x00000fff;                 // mask bits
        factor    = (frequency < 60) ? 10 : 15;            // select factor
        value     = factor * ((1000/frequency) - 3);       // p. 127, ug331.pdf
        return( value);
    }

    uint16_t       range_max = get_max_range( ddr0->sdram_config);
    int32_t        low_value;
    int32_t        high_value;
    int32_t        end_value;
    int32_t        shift_value;
    char           str[20];
    int8_t         low_found;
    int8_t         high_found;
    int8_t         data_valid;
    uint16_t       errors;

    data_valid = FALSE;
    low_found  = FALSE; low_value  = -15;
    high_found = FALSE; high_value =  15;

    while (dcm_ctrl0->psvalue >= -range_max)
    {
        dcm_ctrl0->psdec = 0; while (dcm_ctrl0->psstatus == 0); 
    }

    while ( ((!low_found) || (!high_found)) && ( dcm_ctrl0->psvalue <= range_max))
    {
        errors = memory_test_fast();

        if ( (!low_found) && (errors == 0))
        {
            low_found = TRUE;
            low_value = dcm_ctrl0->psvalue;
        }
        if ( (low_found) && (errors != 0))
        {
            high_found = TRUE;
            high_value = dcm_ctrl0->psvalue;
        }
        dcm_ctrl0->psinc = 0;  while (dcm_ctrl0->psstatus == 0); 
    }

    // make decision
    if (low_found && high_found && ((high_value-low_value) > 30) )
    {
        end_value  = high_value - ((high_value - low_value) / 2);
        data_valid = TRUE;
    }
    else
    {
        end_value = 40; // fits in most cases
    }

    // end_value means now the left shift
    shift_value = dcm_ctrl0->psvalue - end_value;

    while (shift_value > 0)
    {
        shift_value--;
        dcm_ctrl0->psdec = 0;  while (dcm_ctrl0->psstatus == 0); 
    }
    
    vga_clear();
    putstr("\n");if (data_valid) putstr("data valid"); else putstr("data NOT valid");
    putstr("\n");if (low_found)  putstr("low  found"); else putstr("low  NOT found");
    putstr("\n");if (high_found) putstr("high found"); else putstr("high NOT found");
    putstr("\nlow:         "); itoa( low_value, str);                putstr( str);
    putstr("\nhigh:        "); itoa( high_value, str);               putstr( str);
    putstr("\n");
    putstr("\ndiff:        "); itoa(  high_value-low_value, str);    putstr( str);
    putstr("\ndiff/2:      "); itoa( (high_value-low_value)/2, str); putstr( str);
    putstr("\n");
    putstr("\nfinal:       "); itoa( dcm_ctrl0->psvalue, str);       putstr( str);

    return( data_valid);
}

void ddr_init( void)
{
    ddr0->sdram_control = 
          (1<<31)    // refresh enable
        | (0<<30)    // t_RP  = 2 clocks (40 ns) (2+x)
        | (5<<27)    // t_RFC = 8 clocks (80 ns) (3+x)
        | (0<<26)    // t_RCD = 2 clocks (30 ns) (2+x)
        | (2<<23)    // 32 MB RAM
        | (1<<21)    // col size = 1024
        | (1<<17)    // PLL reset
        | (1<<16)    // initalize
        | (1<<15)    // clock enable
        | 780;       // t_REFRESH
    loop_until_bit_is_clear( ddr0->sdram_control, 16);
}
    

int main(void)
{
    char str[20];
    int  test_mode;

    test_mode = WORD_MODE;

    // check if on simulator or on hardware
    simulation_active = bit_is_set(gpio0->iodata, (1<<31));

    timer_init();
    uart_init();
        

    /*
    if (simulation_active) {
        
        // 32 writes
        memory_test_init( 0x90000000, 8);
        
        // 32 reads
        uint8_t i;
        uint32_t data;
        uint32_t *memptr = 0x90000000;

        data = 0;
        for ( i=0; i<8; i++)
        {
            data += *memptr;
            memptr++;
        }
        puthex(32, data); putc('\n');
        abort();
    }
    */


    //lcd_init();
    vga_init();
    ddr_init();
    //running_light_init();
    //ether_init();

    putstr("test.c ");
    (simulation_active) ? putstr("(on simulator)\n") : putstr("(on hardware)\n");
    putstr("compiled: " __DATE__ "  " __TIME__ "\n");
    
    // fill the memory once (safe time)
    memory_test_init( 0x90000000, 0x0010000);

    #ifdef LCD_ENABLE
    lcd_string("init done.");
    #endif
    
    putstr("\n\n");
    //vga_clear();


    memory_info();
    sleep( 5);
    ddr_scan_fast();//dcm_test_ps();
    sleep( 5);
    
    vga_clear();
    #ifdef LCD_ENABLE
    lcd_clear(); lcd_string("enter main loop");
    #endif
    while (1)
    {
        memory_test_dot( test_mode);
        //sleep( 1);
        if bit_is_set( gpio0->iodata, BUTTON_WEST)   
        {
            #ifdef LCD_ENABLE
            lcd_clear(); lcd_string("ps step down");
            #endif
            dcm_ctrl0->psdec = 0;
        }

        if bit_is_set( gpio0->iodata, BUTTON_EAST)
        {
            #ifdef LCD_ENABLE
            lcd_clear(); lcd_string("ps step up");
            #endif
            dcm_ctrl0->psinc = 0;
        }

        if bit_is_set( gpio0->iodata, BUTTON_SOUTH)  
        {
            ddr_init();
            ddr_scan_fast();
            sleep( 5);
            memory_test_init( 0x90000000, 0x0010000); // btn south -> inc ps
        }

        if bit_is_set( gpio0->iodata, BUTTON_NORTH)  
        {
            #ifdef LCD_ENABLE
            lcd_clear(); lcd_string("switch test mode");
            #endif
            vga_clear();
            test_mode = !(test_mode);
        }

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
