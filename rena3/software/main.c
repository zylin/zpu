/*
 * $Date$
 * $Author$
 * $Revision$
 */

//#include <stdio.h>

#include "peripherie.h"
#include <common.h>
#include <timer.h>              // sleep
#include <uart.h>
#include "schedule.h"           // scheduler_init, scheduler_task_*
#include "monitor.h"            // monitor_init, monitor_add_command, monitor_mainloop
#include "i2c.h"                // i2c_init, i2c_command, i2c_check_ack
#include "i2c_functions.h"      // i2c_check_function, i2c_read_eeprom_function
#include "monitor_functions.h"  // x_function, wmem_function, clear_function
#include "ad9854_functions.h"   // ad9854_init
#include "adc.h"                // adc_read
#include "rena.h"               // rena_t, rena_channel_config

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

#define TESTGEN_PIN                       (1<< 31)

////////////////////////////////////////////////////////////
//  rena3 definitions



////////////////////////////////////////////////////////////

uint32_t         simulation_active;
volatile uint8_t timer_tick;
uint8_t          end_simulation = FALSE;


////////////////////////////////////////
// prototypes

void running_light( uint32_t simulation_active);

uint32_t run_light_function( void);

uint32_t banner_help_function( void);

uint32_t rena_trouble( void);
uint32_t ddsinit_function( void);
uint32_t testgen( uint32_t time);
uint32_t testgen_function( void);


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
    
    monitor_add_command("control", "rena controller status",                rena_controller_status);
    monitor_add_command("status",  "rena status",                           rena_status);
    
    monitor_add_command("config",  "<channel> <high> <low_config>",         rena_channel_config_function);
    monitor_add_command("demo",    "do complete demo config for RENA",      rena_demo_config_function);
    monitor_add_command("poff",    "set RENA to power down mode",           rena_powerdown_config_function);
    monitor_add_command("follow",  "set rena channel 0 to follower mode",   rena_follow_mode_function);

    monitor_add_command("acquire", "<time> activate RENA",                  rena_acquire_function);
    monitor_add_command("stop",    "set RENA controller to IDLE",           rena_stop_function);
    monitor_add_command("chains",  "print trigger chains",                  rena_chains_function);
    monitor_add_command("token",   "print sampled RENA tokens",             rena_read_token);
    
    monitor_add_command("trouble", "troublesearch RENA",                    rena_trouble);

    monitor_add_command("ddsinit", "initalize DDS chip <freq tuning word>", ddsinit_function);
    monitor_add_command("ddsinfo", "read dds registers",                    ad9854_info);

    #ifdef DEBUG_ON                                                              
    monitor_add_command("run",     "running light",                         run_light_function);
    monitor_add_command("i2c",     "check I2C address",                     i2c_check_function);
    monitor_add_command("eeprom",  "read EEPROM <bus> <i2c_addr> <length>", i2c_read_eeprom_function);

    monitor_add_command("adc",     "read adc value",                        adc_read);
    monitor_add_command("testgen", "generate test impulse",                 testgen_function);
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
            run_light_function();
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

uint32_t ddsinit_function( void)
{
    uint32_t low;
    uint32_t high;
    uint64_t ftw;

    high = monitor_get_argument_hex(1);
    low  = monitor_get_argument_hex(2);

    if ((high != 0) || (low != 0))
    {
        ftw = ((uint64_t)high << 32) | low;
    }
    else
    {
        ftw = FTW;
    }

    ad9854_init( ftw);
}

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////

uint32_t rena_trouble( void)
{
    uint8_t  config_high;
    uint32_t config_low;
    uint8_t  index;

    uint32_t time;

    time = monitor_get_argument_int(1);
   
    index = 0;

    config_high = 2; // = RENA_ECAL;
  
    config_low = 
//      RENA_FETSEL_SIMPLE      |
//      (GAIN     << RENA_GAIN) |
//      (SEL      << RENA_SEL)  |
//      RENA_SIEZA_1000         |
//      (DAC_FAST << RENA_DF)   | 
//      RENA_POLPOS             |
//      (DAC_SLOW << RENA_DS)   | 
//      RENA_ENF                | 
//      RENA_ENS                |
        RENA_FM;
  
    while (1)
    {
//      for (index = 0; index < 35; index++)
        {
            rena_channel_config( index, config_high, config_low);
            rena->control_status = 9;
            testgen( time);
        }
    }

    return( 0);
}
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////

uint32_t testgen( uint32_t time)
{
    set_bit( gpio0->ioout, TESTGEN_PIN);
    usleep( time);
    clear_bit( gpio0->ioout, TESTGEN_PIN);
}


uint32_t testgen_function( void)
{
    uint32_t time;

    time = monitor_get_argument_int(1);
   
    testgen( time);
}

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////

int main(void)
{
    uint32_t port_value;
    uint16_t i;


    // check if on simulator or on hardware
    simulation_active = bit_is_set( gpio0->iodata, (1<<31));

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

    // code which executes in simulation is started here:
/*    
    // configure rena
//  rena_channel_config(0, 0x2, RENA_ENF | RENA_ENS);
    rena_channel_config(1, RENA_ECAL, RENA_ENS);

    while (rena->control_status != 0) {};

    // set additional acquire time (1000 ns)
    rena->acquire_time = 100;

    // activate acquire
    rena->control_status = 2;

    // generate some test pulse
    usleep( 50);
    testgen( 0);

    // wait till idle
    while (rena->control_status != 0) {};
    
    putstr("tokens: ");
    putint( rena->token_count);
    putchar('\n');
*/
  
    rena_channel_config( 0, 2, 1);
    rena->control_status = 9;
    testgen( 0);
    rena->control_status = 0;

    // test of scheduler
//  scheduler_task_add( end_simulation_task, 3);
//  running_light( simulation_active);
    
    //////////////////////////////////////////////////////////// 
    // end simulation
    abort();
    
}
