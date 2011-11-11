/*
 * $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/software/test/main.c $
 * $Date: 2011-09-06 15:48:10 +0200 (Di, 06. Sep 2011) $
 * $Author: lange $
 * $Revision: 1243 $
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


//#define BOARD_SP605  TODO
#define DEBUG_ON
#define SYSINFO_ON


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
//  rena3 definitions



////////////////////////////////////////////////////////////
//  DDS definitions



////////////////////////////////////////////////////////////

uint32_t         simulation_active;
volatile uint8_t timer_tick;
uint8_t          end_simulation = FALSE;


////////////////////////////////////////
// prototypes

void running_light( uint32_t simulation_active);

uint32_t run_light_function( void);

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
    #ifdef SYSINFO_ON
    monitor_add_command("sysinfo", "show system info <verbose>",            system_info_function);
    #endif
    #ifdef DEBUG_ON                                                              
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
        if bit_is_set( gpio0->iodata, BUTTON0)
        {
        }

    }
}


// helper functions ////////////////////////////////////////
////////////////////////////////////////////////////////////


// monitor functions ///////////////////////////////////////
////////////////////////////////////////////////////////////


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
// start running light
uint32_t run_light_function( void)
{
    running_light( simulation_active);
    return 0;
}



////////////////////////////////////////////////////////////

void banner( void)
{
    putstr("\n\n");
    putchar('\f');

    putstr("rena3 controller board");

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
