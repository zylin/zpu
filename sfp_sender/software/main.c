/*
 * $Date$
 * $Author$
 * $Revision$
 */

//#include <stdio.h>

#include "peripherie.h"
#include <common.h>
#include <timer.h>             // sleep
#include <uart.h>
#include "schedule.h"          // scheduler_init, scheduler_task_*
#include "monitor.h"           // monitor_init, monitor_add_command, monitor_mainloop
#include "i2c.h"               // i2c_init, i2c_command, i2c_check_ack
#include "i2c_functions.h"     // i2c_check_function, i2c_read_eeprom_function
#include "monitor_functions.h" // x_function, wmem_function, clear_function


#define DEBUG_ON
#define SYSINFO_ON

#define TRIGGER_CHANNELS (10)           // number of channels
#define TRIGGER_ADDRESS  (0x80000800)   // address of first trigger generator
#define SFP_ADDRESS      (0x80000900)   // SFP controller


////////////////////////////////////////
// named IOs
// input
#define SWITCH0                           (1<<  0)
#define SWITCH1                           (1<<  1)
#define SWITCH2                           (1<<  2)
#define SWITCH3                           (1<<  3)
#define BUTTON0                           (1<<  4)
#define BUTTON1                           (1<<  5)
#define BUTTON2                           (1<<  6)
#define BUTTON3                           (1<<  7)
#define SIMULATION_ACTIVE                 (1<< 31)
// output
#define LED0                              (1<<  0)
#define LED1                              (1<<  1)
#define LED2                              (1<<  2)
#define LED3                              (1<<  3)

#define HEADER0                           (1<<  8)
#define HEADER1                           (1<<  9)
#define HEADER2                           (1<< 10)
#define HEADER3                           (1<< 11)
#define HEADER4                           (1<< 12)
#define HEADER5                           (1<< 13)
#define HEADER6                           (1<< 14)
#define HEADER7                           (1<< 15)


////////////////////////////////////////////////////////////
//  trigger definitions

typedef struct {
    volatile uint32_t status;        // 0x00 active, gated, cycles
    volatile uint32_t wait_pulses;   // 0x04
    volatile uint32_t on_pulses;     // 0x08
    volatile uint32_t off_pulses;    // 0x0C
} reg_t;

typedef union {
    uint32_t reserved[4];
    reg_t reg;
} u1_t;


u1_t *trigger_gen = (u1_t *) TRIGGER_ADDRESS; 

char channel_names[TRIGGER_CHANNELS][20] = {"channel 0", "channel 1", "channel 2", "channel 3"};


////////////////////////////////////////////////////////////
//  SFP controller definitions
typedef struct {
    volatile uint32_t status;        // 0x00 active, gated, cycles
} sfp_controller_t;

sfp_controller_t *sfp_controller = (sfp_controller_t *) SFP_ADDRESS;



////////////////////////////////////////////////////////////

uint32_t         simulation_active;
volatile uint8_t timer_tick;
uint8_t          end_simulation = FALSE;


////////////////////////////////////////
// prototypes

void running_light( uint32_t simulation_active);

uint32_t run_light_function( void);
uint32_t sfp_status_function( void);
uint32_t sfp_tx_test( void);


uint32_t set_function( void);
uint32_t set_name_function( void);
uint32_t get_function( void);
uint32_t getall_function( void);
uint32_t update_function( void);
void sim_config_function( void);
uint32_t demo_config_function( void);

uint32_t banner_help_function( void);


////////////////////////////////////////
// combined print functions


/*
    output function for UART and VGA
*/
char uart_vga_putchar( char c)
{
    uart_putchar( c);
    //vga_putchar( c);
}


char uart_lcd_vga_putchar( char c)
{
    uart_putchar( c);
    //vga_putchar( c);
    lcd_putc( c);
}


/*
    output function for DEBUG console and VGA
*/
char debug_vga_putchar( char c)
{
    debug_putchar( c);
    vga_putchar( c);
}



//
//  process serial commands
//
void uart_monitor( void)
{
    uint8_t  c;
    uint8_t  key_time_out;
    uint32_t key_state;

    putchar( '\n');

    monitor_init();

    monitor_add_command("reset",   "system reset",                          reset_function);
    monitor_add_command("set",     "set <channel> <wait> <on> <off> <count> <gate>", set_function);
    monitor_add_command("ch",      "alias for set"                                 , set_function);
    monitor_add_command("name",    "name <channel> <channel_name>",                  set_name_function);
    monitor_add_command("get",     "get <channel>",                                  get_function);
    monitor_add_command("status",  "get all channel settings",                       getall_function);
    monitor_add_command("update",  "update signals on all channels",                 update_function);
    monitor_add_command("demo",    "set demonstration configuration",                demo_config_function);
    #ifdef SYSINFO_ON
    monitor_add_command("sysinfo", "show system info <verbose>",            system_info_function);
    #endif
    #ifdef DEBUG_ON                                                              
    monitor_add_command("sfp",     "read/set sfp status <on/off>",          sfp_status_function);
    monitor_add_command("test",    "SFP TX test",                           sfp_tx_test);
    monitor_add_command("run",     "running light",                         run_light_function);
    monitor_add_command("i2c",     "check I2C address",                     i2c_check_function);
    monitor_add_command("eeprom",  "read EEPROM <bus> <i2c_addr> <length>", i2c_read_eeprom_function);
    monitor_add_command("mem",     "alias for x",                           x_function);
    monitor_add_command("wmem",    "write word <addr> <length> <value(s)>", wmem_function);
    monitor_add_command("x",       "eXamine memory <addr> <length>",        x_function);
    #endif                         
    monitor_add_command("clear",   "clear screen",   clear_function);
    monitor_add_command("help",    "",               banner_help_function);

    // initial help
    help_function();

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
        if ( uart_check_receiver() ) 
        {
            monitor_input( uart_getchar() );
        }

        // process commands
        monitor_mainloop();

        // process buttons

        // update for trigger channels
        if bit_is_set( gpio0->iodata, BUTTON0)
        {
            update_function();
        }

        
        // activate SFP sender
        if bit_is_set( gpio0->iodata, BUTTON1)
        {
            set_bit( sfp_controller->status,   (1<<8));
        }

        // activate transmission
        if bit_is_set( gpio0->iodata, BUTTON2)
        {
            set_bit( sfp_controller->status,   (1<<16));
            loop_until_bit_is_clear( sfp_controller->status, (1<<16));
        }

        // deactivate SFP sender
        if bit_is_set( gpio0->iodata, BUTTON3)
        {
            clear_bit( sfp_controller->status, (1<<8));
        }

    }
}


// helper functions ////////////////////////////////////////
////////////////////////////////////////////////////////////

void print_setting(uint8_t channel)
{
    uint8_t i;

    putint( channel); putstr(": ");
    putstr( channel_names[channel]); fill(strlen( channel_names[channel]), 16);
    putstr("  wait: ");  fill( putint( trigger_gen[channel].reg.wait_pulses),  8);
    putstr("  on: ");    fill( putint( trigger_gen[channel].reg.on_pulses),    8);
    putstr("  off: ");   fill( putint( trigger_gen[channel].reg.off_pulses),   8);
    putstr("  count: "); fill( putint( (trigger_gen[channel].reg.status) && 0x3fffffff), 6);
    if bit_is_set( trigger_gen[channel].reg.status, (1<<30))
    {
        putstr("  gated ");
    }
    else
    {
        putstr("  direct");
    }
    putstr("  status: "); 
    switch( trigger_gen[channel].reg.status)
    {
        case 0: putstr("idle");   break;
        case 1: putstr("active"); break;
    }
    putchar('\n');
}


// monitor functions ///////////////////////////////////////
////////////////////////////////////////////////////////////

uint32_t set_function( void)
{
    uint8_t  ch;
    uint32_t wait_pulses;
    uint32_t on_pulses;
    uint32_t off_pulses;
    uint32_t count_pulses;
    uint8_t  gate;

    ch           = monitor_get_argument_int(1);
    wait_pulses  = monitor_get_argument_int(2);
    on_pulses    = monitor_get_argument_int(3);
    off_pulses   = monitor_get_argument_int(4);
    count_pulses = monitor_get_argument_int(5);
    gate         = monitor_get_argument_int(6);
    
    if (ch < TRIGGER_CHANNELS)
    {
        trigger_gen[ch].reg.wait_pulses  = wait_pulses;
        trigger_gen[ch].reg.on_pulses    = on_pulses;
        trigger_gen[ch].reg.off_pulses   = off_pulses;
        trigger_gen[ch].reg.status       = (gate << 30) || count_pulses;
        print_setting( ch);
    }
    else
    {
        putstr("Error: invalid channel number ("); putint( ch); putstr(")\n");
    }
    return ch;
}


uint32_t set_name_function( void)
{
    uint8_t  ch;
    ch                 = monitor_get_argument_int(1);
    strcpy( channel_names[ ch], monitor_get_argument_string(2));
    return ch;
}


uint32_t get_function( void)
{
    uint8_t ch;

    ch = monitor_get_argument_int(1);
    if (ch < TRIGGER_CHANNELS)
    {
        print_setting( ch);
    }
    else
    {
        putstr("Error: wrong channel number ("); putint( ch); putstr(")\n");
    }
    return ch;
}


uint32_t getall_function( void)
{
    uint8_t ch;

    for (ch=0; ch<TRIGGER_CHANNELS; ch++)
        print_setting( ch);

    return ch;
}


uint32_t update_function( void)
{
    uint8_t ch;

    // update all signals
    set_bit(   gpio0->ioout, (1<<31));
    clear_bit( gpio0->ioout, (1<<31));

    return 0;
}


void sim_config_function( void)
{
    // test cases:
    // 1. test if channel is not active without write to status register
    // 2. test for continous wave 1 on 1 off (till stop)
    // 3. test for continous wave 2 on 2 off (till stop)
    // 4. test asymmetrical waves
    // 5. test for single pulse
    // 6. test for direct mode
    // 7. test for count
    // 8. test for wait

    // check if channel is not active (no write on status register)
    trigger_gen[0].reg.wait_pulses  =  2;
    trigger_gen[0].reg.on_pulses    =  0;
    trigger_gen[0].reg.off_pulses   =  0;
    trigger_gen[0].reg.status       =  (0 << 30) || 4;
    
    // 0 wait
    // check if on/off is one clock
    trigger_gen[7].reg.wait_pulses  =  0;
    trigger_gen[7].reg.on_pulses    =  1;
    trigger_gen[7].reg.off_pulses   =  1;
    trigger_gen[7].reg.status       =  (0 << 30) || 0;

    // 1 wait
    trigger_gen[8].reg.wait_pulses  =  1;
    trigger_gen[8].reg.on_pulses    =  2;
    trigger_gen[8].reg.off_pulses   =  2;
    trigger_gen[8].reg.status       =  (0 << 30) || 0;

    // 2 wait
    trigger_gen[9].reg.wait_pulses  =  2;
    trigger_gen[9].reg.on_pulses    =  2;
    trigger_gen[9].reg.off_pulses   =  2;
    trigger_gen[9].reg.status       =  (0 << 30) || 3;
}


uint32_t demo_config_function( void)
{
    // config for demo
    trigger_gen[0].reg.wait_pulses  =  50 + 20;
    trigger_gen[0].reg.on_pulses    =  20;
    trigger_gen[0].reg.off_pulses   =  1;
    trigger_gen[0].reg.status       =  (0 << 30) || 1;
    
    trigger_gen[1].reg.wait_pulses  =  50 + 2;
    trigger_gen[1].reg.on_pulses    =  2;
    trigger_gen[1].reg.off_pulses   =  1;
    trigger_gen[1].reg.status       =  (0 << 30) || 0;

    trigger_gen[2].reg.wait_pulses  =  50 + 0;
    trigger_gen[2].reg.on_pulses    =  1;
    trigger_gen[2].reg.off_pulses   =  1;
    trigger_gen[2].reg.status       =  (0 << 30) || 0;

    trigger_gen[3].reg.wait_pulses  =  50 + 0;
    trigger_gen[3].reg.on_pulses    =  1;
    trigger_gen[3].reg.off_pulses   =  1;
    trigger_gen[3].reg.status       =  (0 << 30) || 1;
    
    // 0 wait
    // check if on/off is one clock
    trigger_gen[4].reg.wait_pulses  =  50 + 0;
    trigger_gen[4].reg.on_pulses    =  1;
    trigger_gen[4].reg.off_pulses   =  1;
    trigger_gen[4].reg.status       =  (0 << 30) || 0;

    // 1 wait
    trigger_gen[5].reg.wait_pulses  =  50 + 1;
    trigger_gen[5].reg.on_pulses    =  2;
    trigger_gen[5].reg.off_pulses   =  2;
    trigger_gen[5].reg.status       =  (0 << 30) || 0;

    trigger_gen[6].reg.wait_pulses  =  50 + 2;
    trigger_gen[6].reg.on_pulses    =  2;
    trigger_gen[6].reg.off_pulses   =  2;
    trigger_gen[6].reg.status       =  (0 << 30) || 3;
    
    trigger_gen[7].reg.wait_pulses  =  0;
    trigger_gen[7].reg.on_pulses    =  1;
    trigger_gen[7].reg.off_pulses   =  1;
    trigger_gen[7].reg.status       =  (0 << 30) || 1;
    
    trigger_gen[8].reg.wait_pulses  =  45;
    trigger_gen[8].reg.on_pulses    =  1;
    trigger_gen[8].reg.off_pulses   =  1;
    trigger_gen[8].reg.status       =  (0 << 30) || 1;

    trigger_gen[9].reg.wait_pulses  =  50;
    trigger_gen[9].reg.on_pulses    =  1;
    trigger_gen[9].reg.off_pulses   =  1;
    trigger_gen[9].reg.status       =  (0 << 30) || 1;

    return 0;
}


////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////


void running_light( uint32_t simulation_active)
{
	unsigned int pattern = 0x80300700;
    uint32_t count = 3;

            
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
            //msleep( 12);
        }
    }

}



////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// functions for scheduler

void end_simulation_task( void)
{
    end_simulation = TRUE;
}

////////////////////////////////////////////////////////////
// SFP functions
uint32_t sfp_status_function( void)
{
    uint8_t tx;
    uint32_t value;
    
    tx = monitor_get_argument_int(1);

    if (tx == 1)
    {
        set_bit( sfp_controller->status, (1<<8));
    }
    else
    {
        clear_bit( sfp_controller->status, (1<<8));
    }

    value = sfp_controller->status;
    putstr("SFP status: ");

    putstr("\n  TX ");
    if bit_is_set( value, 1<<0)
    {
        putstr("fault");
    }
    else
    {
        putstr("normal");
    }

    putstr("\n  module ");
    if bit_is_set( value, 1<<1)
    {
        putstr("not ");
    }
    putstr("present");

    putstr("\n  ");
    if bit_is_set( value, 1<<2)
    {
        putstr("loss of receiver Signal");
    }
    else
    {
        putstr("normal operation");
    }

    putstr("\n  SFP tx ");
    if bit_is_set( value, 1<<8)
    {
        putstr("enabled");
    }
    else
    {
        putstr("disabled");
    }

    putstr("\n  bandwith ");
    if bit_is_set( value, 1<<9)
    {
        putstr("full");
    }
    else
    {
        putstr("reduced");
    }
    putchar('\n');

    return value;
}


////////////////////////////////////////////////////////////
// start running light
uint32_t run_light_function( void)
{
    running_light( simulation_active);
    return 0;
}


////////////////////////////////////////////////////////////
uint32_t sfp_tx_test( void)
{
    putstr("\nSFT TX test");
    // activate SFP sender
    set_bit( sfp_controller->status,   (1<<8));
    // activate transmission
    set_bit( sfp_controller->status,   (1<<16));
    loop_until_bit_is_clear( sfp_controller->status, (1<<16));
    // deactivate SFP sender
    clear_bit( sfp_controller->status, (1<<8));
    putstr("\ndone.\n");
    return 0;
}


////////////////////////////////////////////////////////////

void banner( void)
{
    putstr("\n\n");
    putchar('\f');

    putstr("SFP sender");

    char *hw_revision = (char *)0x80000000;

    if (simulation_active) 
    {
        putstr(" (on sim)\n");
    }
    else
    {
        putstr("\nHW synthesized: "); putstr( hw_revision);
        putstr("\nSW compiled   : " __DATE__ "  " __TIME__ );
        putstr("\nsystem clock  : "); putint( F_CPU/1000000);  putstr(" MHz\n");
        #ifdef DEBUG_ON
        putstr("DEBUG MODE");
        putstr(" ON\n");
        #endif
    }
}


uint32_t banner_help_function( void)
{
    banner();
    help_function();

    return 0;
}

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
void _zpu_interrupt( void)
{
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
////////////////////////////////////////////////////////////

int main(void)
{
    uint32_t port_value;
    uint16_t i;


    // check if on simulator or on hardware
    simulation_active = bit_is_set(gpio0->iodata, (1<<31));

    //////////////////////////////////////////////////////////// 
    // init stuff
    timer_init();
    uart_init();
    scheduler_init();
    i2c_init();
    // enable timer interrupt, for scheduler
    set_bit( timer0->e[0].ctrl, TIMER_INT_ENABLE);


    if (!simulation_active) {

        #ifdef BOARD_SP605
        vga_init();
        chrontel_init(); // dvi
        #endif
        // uart_vga_putchar use VGA and UART for output
        putchar_fp = uart_vga_putchar;
    }
    else
    {
        // debug_putchar is for simulator
        putchar_fp = debug_putchar;
    }

    //////////////////////////////////////////////////////////// 
    // banner
    banner();

    //////////////////////////////////////////////////////////// 
    // decide which main function to use
    
    if (!simulation_active) 
    {
        putchar_fp = uart_putchar;
        uart_monitor();
    }
   
    sfp_tx_test();

    // test central trigger generator
    //demo_config_function();
    //update_function();

    // test of scheduler
    scheduler_task_add( end_simulation_task, 1);
    running_light( simulation_active);
    
    //////////////////////////////////////////////////////////// 
    // end simulation
    abort();
    
}
