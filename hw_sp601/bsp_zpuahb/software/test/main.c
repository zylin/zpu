//#include <stdio.h>

#include <peripherie.h>
#include <common.h>
#include <timer.h>         // sleep
#include <uart.h>
#include <schedule.h>      // scheduler
#include <lcd-routines.h>

#define DEBUG_ON

// no LCD on SP601
//#define LCD_ENABLE

// no VGA on SP601
//#define VGA_ENABLE


////////////////////////////////////////
// common defines

#define bit_is_set(mem, bv)               (mem & bv)
#define bit_is_clear(mem, bv)             (!(mem & bv))
#define loop_until_bit_is_set(mem, bv)    do {} while( bit_is_clear(mem, bv))
#define loop_until_bit_is_clear(mem, bv)  do {} while( bit_is_set(mem, bv))


////////////////////////////////////////////////////////////
// named keys
#define BUTTON_WEST                       (1<<7)
#define BUTTON_EAST                       (1<<4)
#define BUTTON_SOUTH                      (1<<5)
#define BUTTON_NORTH                      (1<<6)  // is it right

#define WORD_MODE                         (0)
#define BIT_MODE                          (1)

uint32_t         simulation_active;
volatile uint8_t timer_tick;
uint8_t          end_simulation = FALSE;

volatile uint32_t running_direction;


////////////////////////////////////////////////////////////
// combined print functions


char combined_putchar( char c)
{
    uart_putchar( c);
    #ifdef VGA_ENABLE 
    vga_putchar( c);
    #endif
}


////////////////////////////////////////////////////////////
// zpu interrupt function
void _zpu_interrupt( void)
{
    // test for gpio_button interrupt
    //running_direction = !running_direction;
    //irqmp0->irq_clear = BUTTON_WEST; // clear interrupt

    uint32_t reg_val;

    // check for timer 0.0 interrupt
    reg_val = timer0->e[0].ctrl;
    if bit_is_set( reg_val, TIMER_INT_PENDING)
    {
        // clear interrupt pending bit
        clear_bit( reg_val, TIMER_INT_PENDING);
        timer0->e[0].ctrl = reg_val;

        timer_tick = TRUE;
    }
    return;
}


////////////////////////////////////////////////////////////
void running_light_init( void)
{
    // enable output drivers
    gpio0->iodir      |= 0x000000FF;
    running_direction  = 0;

    /*
    // enable interrupt on key west
    gpio0->irqpol      |= BUTTON_WEST; // 0=act_low, 1=act_high / 0=falling edge, 1=rising_edge
    gpio0->irqedge     |= BUTTON_WEST; // 0=level, 1=edge sensitive
    gpio0->irqmask     |= BUTTON_WEST; // set this after polarity and edge to avoid interrupt

    irqmp0->irq_mask   = BUTTON_WEST;  // enable global interrupts
    */
}


//
// function for scheduler
//
void end_simulation_task( void)
{
    end_simulation = TRUE;
}


//
// generate a running light pattern
//
void running_light( uint32_t simulation_active)
{
	unsigned int pattern = 0x80300700;
    uint32_t count = 31;

            
    while (1)
    {
    
        gpio0->ioout = 0x000000ff & pattern;
        if (running_direction)
        {
            pattern = (pattern << 1) | (pattern >> 31);
        }
        else
        {
            pattern = (pattern << 31) | (pattern >> 1);
        }


        if (simulation_active)
        {
            // do only limited runs
            //if (count == 0) break;
            //count--;
            
            // limit runs by timer tick
            if (timer_tick) 
            {
                timer_tick = FALSE;
                scheduler_task_check();
                
                if (end_simulation) break;
            }
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



#define MAX_COMMANDS       (16)
#define MAX_COMMAND_LENGTH (10)
#define MAX_HELP_LENGTH    (32)
#define BUFFER_LENGTH      (32)
#define CR                 '\r'
#define LF                 '\n'
#define BS                 '\b'
#define DEL                (0x7f)


typedef void (*command_ptr_t) (void);

static char          command_list[MAX_COMMANDS][MAX_COMMAND_LENGTH];
static char          help_list   [MAX_COMMANDS][MAX_HELP_LENGTH];
static command_ptr_t command_ptr_list[MAX_COMMANDS];

uint8_t       buffer[BUFFER_LENGTH];
uint8_t       command_number;
uint8_t       buffer_position;
command_ptr_t exec_function;



void monitor_init( void)
{
    buffer_position = 0;
    command_number  = 0;
    exec_function   = 0;
}


void monitor_add_command(char* new_command, char* new_help, command_ptr_t new_command_ptr) {
    strcpy( command_list[ command_number], new_command);
    strcpy( help_list[    command_number], new_help);
    command_ptr_list[ command_number] = new_command_ptr;
    command_number++;
}

void monitor_prompt( void) { 
    putstr("> ");
}


void process_buffer( void) {
    uint8_t command_index;
    uint8_t i;

    i = 0;

    while ( !((buffer[i] == ' ') || (buffer[i] == 0)) ) i++;
    
    if (!i) {
        monitor_prompt();
        return;
    }

    for ( command_index = 0; command_index < command_number; command_index++) {
        if ( !strncmp( command_list[ command_index], buffer, i) ) {
            exec_function = command_ptr_list[ command_index];
            return;
        }
    }
    putstr("command not found.\n");
    monitor_prompt();
}

uint8_t monitor_run;

void monitor_mainloop( void) 
{
  
    if (exec_function) {
        exec_function();
        exec_function = 0;
        monitor_prompt();
    }
}


void monitor_input(uint8_t c) {
    
    // carrige return
    if (c == CR) {
        putchar( LF);
        buffer[ buffer_position++] = 0;
        process_buffer();
        buffer_position = 0;

    // backspace or delete
    } else if ( (c == BS) || (c == DEL)) {
        if (buffer_position > 0) {
            putchar( BS);
            putchar( ' ');
            putchar( BS);
            buffer_position--;
        }
    } else {
        // add to buffer
        if ((c >= 0x20) && (buffer_position < (BUFFER_LENGTH-1))) {
            putchar( c);
            buffer[ buffer_position++] = c;
        }
    }
}

char* monitor_get_argument_string(uint8_t num)
{
    uint8_t index;
    uint8_t arg;

    // example line:
    // "   command   arg1   arg2 arg3 "

    index = 0;

    // search for first char (non space)
    while (( buffer[ index] != 0) && (buffer[ index] == ' ')) index++;

    for ( arg = 0; arg < num; arg++)
    {
        // next space 
        while (( buffer[ index] != 0) && (buffer[ index] != ' ')) index++;
        // next non space
        while (( buffer[ index] != 0) && (buffer[ index] == ' ')) index++;
    }
    return &buffer[ index];
}

int monitor_get_argument_int(uint8_t num)
{
    char *endptr;
    return strtol( monitor_get_argument_string(num), &endptr, 10);
}

uint32_t monitor_get_argument_hex(uint8_t num)
{
    char *endptr;
    return strtoul( monitor_get_argument_string(num), &endptr, 16);
}


void wmem_function( void);
void x_function( void);
void clear_function( void);
void led_function( void);
void quit_function( void);
void help_function( void);

void ether_test_read_mdio( void);
void ether_test_tx_packet( void);
void ether_test( void);
void ether_init( void);


//
//  react on serial commands
//
void uart_monitor( void)
{
    uint8_t c;

    //putstr("debug monitor\n");
    putchar( '\n');

    monitor_init();

    monitor_add_command("mem",     "like x",               x_function);
    monitor_add_command("wmem",    "write word",           wmem_function);
    monitor_add_command("x",       "eXamine memory",       x_function);
    monitor_add_command("clear",   "clear screen",         clear_function);
    monitor_add_command("led",     "start LED test",       led_function);
    monitor_add_command("mdio",    "read MDIO registers",  ether_test_read_mdio);
    monitor_add_command("tx",      "transmit test packet", ether_test_tx_packet);
    monitor_add_command("ethinfo", "greth info",           ether_test);
    monitor_add_command("ethinit", "reinit ethernet",      ether_init);
    monitor_add_command("quit",    "", quit_function);
    monitor_add_command("help",    "", help_function);

    monitor_prompt();

    monitor_run = TRUE;

    while( monitor_run)
    {
        // process scheduler
        if (timer_tick)
        {
            timer_tick = FALSE;
            scheduler_task_check();
        }

        // process uart
        if ( uart_check_receiver() ) {
            monitor_input( uart_getchar() );
        }

        // process commands
        monitor_mainloop();
    }
}


void quit_function( void)
{
    monitor_run = FALSE;
}


void help_function( void)
{
    uint8_t command_index;
    uint8_t i;

    putchar( LF);
    putstr("supported commands:\n\n");
    for ( command_index = 0; command_index < command_number; command_index++) {
        putstr( command_list[ command_index]); 
        if (strlen( help_list[ command_index]) > 0 )
        {
            for (i = strlen( command_list[ command_index]); i < MAX_COMMAND_LENGTH; i++) putchar(' ');
            putstr( " - ");
            putstr( help_list[ command_index]); 
        }
        putchar('\n');
    }
    putchar( LF);
}


void x_function( void)
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

    for (index = 0; index < count; index++)
    {
        if ( (index % 4) == 0) 
        {
            putstr("\n0x"); puthex(32, (uint32_t)ptr); putstr(" : ");
        }
        putstr("0x"); puthex( 32, *ptr); putchar(' ');
        *ptr++;
    }
    putchar( '\n');
}

void wmem_function( void)
{
    uint32_t  addr;
    uint32_t  value;
    uint32_t* ptr;
    
    addr  = monitor_get_argument_hex(1);
    value = monitor_get_argument_hex(2);

    ptr  = (uint32_t*)addr; // automatic word aligned
    *ptr = value;
}

void clear_function( void) {
    putchar('\f');
}


void led_function( void) {
    running_light( TRUE);
}


void flickr( void) {
    
    uint32_t count;
    count = 0;
    
    gpio0->iodir      |= 0x000000FF;
    
    while (1)
    {
        gpio0->ioout = count;
        count++;
    }
    
}

/*    
    const uint8_t line_max = 32;

    uint8_t index;
    char line[line_max];
    char c;


    while (1)
    {
        index = 0;
        while ((c = uart_getchar()) != '\n' && index < line_max)
        {
            line[index] = c;
            index++;
        }
        line[index] = 0;

*/


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

void ether_mdio_write( uint16_t phy_addr, uint16_t reg_addr, uint16_t data)
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
    uint16_t value;
    
    ether0->status  = 0xffffffff; // 0xffffffff is necessary to reset status
    ether0->mac_msb = 0x00000a00;
    ether0->mac_lsb = 0x2a0bfefb;
    ether0->control = ETHER_CONTROL_RESET;
    loop_until_bit_is_clear( ether0->control, ETHER_CONTROL_RESET);


    /* code for Digilent S3500E
    #define PHY_ADDRESS     0x1F
    ether_mdio_write( PHY_ADDRESS,  0, 0x2180);    // autoneg off, speed 100, full duplex, col test
    ether_mdio_write( PHY_ADDRESS,  0, (1 << 15));   // software reset
    loop_until_bit_is_clear( ether_mdio_read( PHY_ADDRESS, 0), (1 << 15));
    */

    /*
     * code for Marvel 88E111 on SP601 (and SP605?)
     */

    #define PHY_ADDRESS         7
    
    #define PHY_CONTROL         0
    #define PHY_RESTART_AUTONEG 9
    #define PHY_RESET           15

    #define GBIT_CONTROL        9
    #define GBIT_FULL_ADVERTISE 9
    #define GBIT_HALF_ADVERTISE 8
    
    // wait until phy is ready
    loop_until_bit_is_clear( ether_mdio_read( PHY_ADDRESS, PHY_CONTROL), (1 << PHY_RESET));

    // don't advertise 1000MBit modes
    // (usefull for 100MBit cores)
    value = ether_mdio_read( PHY_ADDRESS, GBIT_CONTROL);
    clear_bit( value, (1 << GBIT_HALF_ADVERTISE));
    clear_bit( value, (1 << GBIT_FULL_ADVERTISE));
    ether_mdio_write( PHY_ADDRESS, GBIT_CONTROL, value);
  
    // redo autonegotaion
    value = ether_mdio_read( PHY_ADDRESS, PHY_CONTROL);
    set_bit( value, (1 << PHY_RESTART_AUTONEG));
    ether_mdio_write( PHY_ADDRESS, PHY_CONTROL, value);
}
  

void ether_test( void)
{
    char str[20];
    uint32_t         simulation_active;
    simulation_active = bit_is_set(gpio0->iodata, (1<<31));
    
    if (simulation_active)
    {
        // reset status (for simulation)
        ether0->status     = 0xffffffff;
        ether0->mac_msb    = 0xffff001b;
        ether0->mac_lsb    = 0x21684b0a;
        ether0->tx_pointer = 0x00001234;
        ether0->rx_pointer = 0x00004321;
    }

    putstr( "\ngreth registers:");
    putstr( "\ncontrol:      0x"); puthex( 32, ether0->control);
    putstr( "\nstatus:       0x"); puthex( 32, ether0->status);
    putstr( "\nmac_msb:      0x"); puthex( 32, ether0->mac_msb);
    putstr( "\nmac_lsb:      0x"); puthex( 32, ether0->mac_lsb);
    putstr( "\nmdio_control: 0x"); puthex( 32, ether0->mdio_control);
    putstr( "\ntx_pointer:   0x"); puthex( 32, ether0->tx_pointer);
    putstr( "\nrx_pointer:   0x"); puthex( 32, ether0->rx_pointer);
    putstr( "\nedcl_ip:      0x"); puthex( 32, ether0->edcl_ip);
    putstr( "\nhash_msb:     0x"); puthex( 32, ether0->hash_msb);
    putstr( "\nhash_lsb:     0x"); puthex( 32, ether0->hash_lsb);
    putchar('\n');

} 


void ether_test_read_mdio( void)
{
    char str[20];
    uint32_t mdio_phy;  // 0..31
        
    void read_registers(uint32_t mdio_phy)
    {
        uint32_t mdio_reg;  // 0..31
        uint16_t mdio_data; // 16 bit

        putstr("\n mdio phy: 0x"); puthex( 8, mdio_phy);

        for (mdio_reg=0; mdio_reg<32; mdio_reg++)
        {
            // skip some registers
            if (mdio_reg == 11) mdio_reg=15;
            //if (mdio_reg == 19) mdio_reg=20;
            //if (mdio_reg == 24) mdio_reg=27;
            putstr("\n  reg: "); itoa( mdio_reg, str); putstr( str);
            putstr("-> 0x");       puthex( 16, ether_mdio_read( mdio_phy, mdio_reg));
        }
    }

    /*
    // multiple
    putstr("\nmdio phy registers");
    for ( mdio_phy=0; mdio_phy<32; mdio_phy++)
    {
        read_registers( mdio_phy);
    }
    */

    // single
    read_registers( 7);

    putchar('\n');
}





void ether_test_tx_packet( void)
{
    // data memory segment from 0xa000000 to 0xa0000FFF

    greth_tx_descriptor_t *descr        = (greth_tx_descriptor_t *) (0xa0000000);
    mac_header_t          *mac_header   = (mac_header_t *)          (0xa0000100);
    uint32_t              data_length   = 1464; // udp payload
    
    uint32_t i;
  
    // setup the data
    //   fill buffer (ethernet address, type field, etc.)
//  for (i=0; i<data_length; i++)
//      mac_header->ip_header.udp_header.data[i] = data_length - i;

    // setup ethernet packet
    mac_header->dest_mac[0]            = 0x00; // ipconfig -all
    mac_header->dest_mac[1]            = 0x1b;
    mac_header->dest_mac[2]            = 0x21;
    mac_header->dest_mac[3]            = 0x67;
    mac_header->dest_mac[4]            = 0xb8;
    mac_header->dest_mac[5]            = 0xb8;
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
    mac_header->ip_header.checksum        = 0x61b9;
    mac_header->ip_header.source_ip       = (10<<24)+(0<<16)+(0<<8)+(20<<0);
    mac_header->ip_header.dest_ip         = (10<<24)+(0<<16)+(0<<8)+(75<<0);

    mac_header->ip_header.udp_header.source_port = 5050;
    mac_header->ip_header.udp_header.dest_port   = 5050;
    mac_header->ip_header.udp_header.length      = data_length + 8;
    mac_header->ip_header.udp_header.checksum    = 0xb89b;
    
    
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
     
    // check transmission status
    // 3 bits (TE, TI, TA)
    
    // check for errors in descriptor
    //ETHER_DESCRIPTOR_UNDERRUN_ERR
    //ETHER_DESCRIPTOR_ATTEMEPT_LIMIT_ERR

    putstr("greth->control: 0x"); puthex( 32, ether0->control); putchar('\n');
    putstr("greth->status : 0x"); puthex( 32, ether0->status);  putchar('\n');
    putstr("descr->control: 0x"); puthex( 32, descr->control);  putchar('\n');

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

    putstr("write address: 0x");   puthex( 32, (uint32_t) memptr);
    putstr("  length: 0x");        puthex( 32, length);
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
                putstr("read  address: 0x");        puthex( 32, (uint32_t) memptr);
                putstr("  expect: 0x");             puthex( 32, i);
                putstr("  got: 0x");                puthex( 32, read);
                (i == read) ? putstr(" ok") :  putstr(" error");
                putstr("\n");
            } else
            {
                putstr("  got: 0x");                  puthex( 32, read);
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
        if ((uint32_t)memory != data) error++;
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

    #ifdef VGA_ENABLE
    vga_init();
    #endif
    
    count_bad = 0;
    s         = 0x90000000;


    if (mode == WORD_MODE)
    {

        for (i=0; i<2048; i++)
        {
            if ((i%64) == 0)
            {
                #ifdef VGA_ENABLE
                vga_putstr("\n0x"); vga_puthex( 32, s); vga_putstr(" ");
                #endif
            }
            error = memory_test_complete( s, chunks);
            #ifdef VGA_ENABLE
            vga_putchar( '0' + error);
            #endif
            count_bad += error;
            s += sizeof(data) * chunks;
        }
    }
    else
    {
        mem = (uint32_t*) s;
        for (i=0; i<32; i++)
        {
            #ifdef VGA_ENABLE
            vga_putstr("\n0x"); vga_puthex( 32, mem); vga_putchar(' ');
            #endif
            data = *mem;
            #ifdef VGA_ENABLE
            vga_putbin( 32, data); vga_putchar(' ');
            if ((uint32_t)mem == data) vga_putstr("ok  ");
            else                       vga_putstr("FAIL");
            #endif
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

    i         = 0;
    while ( (i<2048) && (count_bad==0) )
    {
        error = memory_test_complete( s, chunks);
        count_bad += error;
        s += sizeof(data) * chunks;
        i++;
    }

    return( count_bad);
}

//
// return: size of memory in 1k blocks
// 
uint32_t memory_detect_ramsize( uint32_t start)
{
    uint32_t *memory = (uint32_t *) start;
    uint32_t size;
    uint32_t blocksize = 1024/sizeof(*memory); 


    // fill with known values, beginning from top
    for (memory = (uint32_t*)(start + 0x0F000000); (uint32_t)memory >= start; memory -= blocksize)
    {
        *memory = (uint32_t)memory;
    }

    size = 0;
    // check for know values, beginning from bottom
    for (memory = (uint32_t*)start; (uint32_t)memory <= start + 0x0F000000; memory += blocksize)
    {
        if (*memory == (uint32_t)memory)
            size++;
    }
    
    return( size);
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
        putstr("address: 0x");   puthex( 32, (uint32_t) memptr);
        putstr(" data: 0x");     puthex( 32,           *memptr);
        putstr("\n");
    }
}


////////////////////////////////////////////////////////////

void banner( void)
{
    putstr("\n\ntest.c");

    char     *hw_revision  =    (char *)0x80000000;
    char     *svn_revision =    (char *)0x80000020;
    int32_t  *hw_frequency = (int32_t *)0x80000040;

    if (simulation_active) 
    {
        putstr(" (on sim)\n");
    }
    else
    {
        putstr("\nSVN revision  : "); putstr( svn_revision);
        putstr("\nHW synthesized: "); putstr( hw_revision);
        putstr("\nHW frequency  : "); putint( *hw_frequency/1000000);   putstr(" MHz");
        putstr("\nSW compiled   : " __DATE__ "  " __TIME__ );
        putstr("\nSW frequency  : "); putint( F_CPU/1000000);           putstr(" MHz");
        putchar('\n');
        #ifdef DEBUG_ON
        putstr("DEBUG MODE");
        putstr(" ON\n");
        #endif
    }
}


int main(void)
{
    char str[20];
    int  test_mode;

    test_mode = WORD_MODE;

    // check if on simulator or on hardware
    simulation_active = bit_is_set(gpio0->iodata, (1<<31));

    // flickr(); // just a test for simulation

    //////////////////////////////////////////////////////////// 
    // init stuff

    timer_init();
    uart_init();
    scheduler_init();
    //i2c_init();       TODO
    ether_init();

    // enable timer interrupt, for scheduler
    set_bit( timer0->e[0].ctrl, TIMER_INT_ENABLE);

    running_light_init();

    if (!simulation_active) 
    {
        putchar_fp = combined_putchar;
        #ifdef LCD_ENABLE
        lcd_init();
        #endif
        #ifdef VGA_ENABLE
        vga_init();
        #endif
    }
    else
    {
        // set to our output function
        putchar_fp = debug_putchar;
    }

    //////////////////////////////////////////////////////////// 
    // banner
    banner();
    #ifdef LCD_ENABLE
    lcd_string("init done.");
    #endif
    
    
    //////////////////////////////////////////////////////////// 
    // decide which main function to use
    
    if (!simulation_active) 
    {
        // active uart test
        //uart_test();

        uart_monitor();
    }
    

    /*
    // fill the memory once (safe time)
    memory_test_init( 0x90000000, 0x0010000);
    
    putstr("\n\nmemory size   :");  
    putint( memory_detect_ramsize( 0x90000000) );
    putstr(" blocks");
    sleep( 5);
    */

    /*
     putchar('\f');
    #ifdef LCD_ENABLE
    lcd_clear(); lcd_string("enter main loop");
    #endif
    while (1)
    {
        memory_test_dot( test_mode);
        //sleep( 1);
        if bit_is_set( gpio0->iodata, BUTTON_WEST)   
        {
        }

        if bit_is_set( gpio0->iodata, BUTTON_EAST)
        {
        }

        if bit_is_set( gpio0->iodata, BUTTON_SOUTH)  
        {
            memory_test_init( 0x90000000, 0x0010000);
            
            putstr("\n\nmemory size   :");  
            putint( memory_detect_ramsize( 0x90000000) );
            putstr(" blocks");
    
            sleep( 5);
        }

        if bit_is_set( gpio0->iodata, BUTTON_NORTH)  
        {
            #ifdef LCD_ENABLE
            lcd_clear(); lcd_string("switch test mode");
            #endif
             putchar('\f');
            test_mode = !(test_mode);
        }

    }
    */

    //ether_test();

    // simulate tx package
    uint8_t i;
//  for ( i=0; i<3; i++)
        ether_test_tx_packet();
    
    /*
    // simulate MDIO
    ether_test_read_mdio();
    */
    
    /*
     *  test of scheduler with running light
     */
    scheduler_task_add( end_simulation_task, 2);
    running_light( simulation_active);
    
    /*
     *  simple gpio_test
     */
    //gpio_test();

    abort();
    
}
