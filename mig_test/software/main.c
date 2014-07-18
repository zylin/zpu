/*
 * $Date$
 * $Author$
 * $Revision$
 */

//#include <stdio.h>

#define BOARD_GIGABEE

#include "../include/peripherie.h"
#include <common.h>
#include <timer.h>             // sleep
#include <uart.h>
#include "schedule.h"          // scheduler_init, scheduler_task_*
#include "monitor.h"           // monitor_init, monitor_add_command, monitor_mainloop
#include "monitor_functions.h" // x_function, wmem_function, clear_function, quit_function


////////////////////////////////////////
// named IOs
// input
#define MAC_DATA                          (1<<  4)
#define SIMULATION_ACTIVE                 (1<< 31)
// output
#define LED0                              (1<<  0)
#define LED1                              (1<<  1)
#define LED2                              (1<<  2)
#define LED3                              (1<<  3)
#define LED_USER                          (1<<  5)







////////////////////////////////////////////////////////////

uint32_t         simulation_active;
volatile uint8_t timer_tick;
uint8_t          end_simulation = FALSE;


////////////////////////////////////////
// prototypes

void running_light( uint32_t simulation_active);

uint32_t run_light_function( void);




////////////////////////////////////////
// combined print functions

/*
char uart_lcd_putchar( char c, FILE *stream)
{
    uart_putchar( c, stream);
    lcd_putc( c, stream);
}
*/




// helper functions ////////////////////////////////////////
////////////////////////////////////////////////////////////

// monitor functions ///////////////////////////////////////
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////

void running_light( uint32_t simulation_active)
{
	unsigned int pattern = 0x80300700;
            
    while (1)
    {
    
        gpio0->ioout = 0x0000000f & pattern;
        pattern = (pattern << 1) | (pattern >> 31);


        if ( simulation_active)
        {
            // do only limited runs
            if ( timer_tick) 
            {
                timer_tick = FALSE;
                scheduler_task_check();
                
                if ( end_simulation) break;
            }
        } 
        else
        {
            msleep( 125);
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



//
//  process serial commands
//
void uart_monitor( void)
{
    uint8_t  c;
    uint8_t  key_time_out = 250;
    uint32_t key_state;

    putchar( '\n');

    monitor_init();


//  monitor_add_command("reset",   "system reset",                          reset_function);
    monitor_add_command("sysinfo", "show system info <verbose>",            system_info_function);

    monitor_add_command("run",     "running light",                         run_light_function);

    monitor_add_command("wmem",    "write word <addr> <length> <value(s)>", wmem_function);
    monitor_add_command("x",       "eXamine memory <addr> <length>",        x_function);
    monitor_add_command("task",    "print tasklist",                        scheduler_tasklist);
                   
    monitor_add_command("help",    "",               help_function);


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
    }
}



////////////////////////////////////////////////////////////

void banner( void)
{
    putstr("\n\n");
    putstr("BSP Trenz Gigabee");

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
    }
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
    
    // check if on simulator or on hardware
    simulation_active = bit_is_set( gpio0->iodata, (1<<31));

    //////////////////////////////////////////////////////////// 
    // init stuff
    timer_init();
    uart_init();
    scheduler_init();
    
        
    // enable timer interrupt, for scheduler
    set_bit( timer0->e[0].ctrl, TIMER_INT_ENABLE);    


    if (!simulation_active) 
    {
        stdout = uart_putchar;
    }
    else
    {
        // debug_putchar is for simulator
        stdout = debug_putchar;
    }

    //////////////////////////////////////////////////////////// 
    banner();

    //////////////////////////////////////////////////////////// 
    // decide which main function to use
    
    if ( !simulation_active) 
    {
		uart_monitor();
    }
   
    // test of scheduler
    scheduler_task_add( end_simulation_task, 1);
    running_light( simulation_active);
    
    //////////////////////////////////////////////////////////// 
    // end simulation
    abort();
    
}
