/*
 * $Date$
 * $Author$
 * $Revision$
 */

//#include <stdio.h>

#include "peripherie.h"
#include <common.h>             // fill
#include <timer.h>              // sleep
#include <uart.h>
#include "schedule.h"           // scheduler_init, scheduler_task_*
#include "monitor.h"            // monitor_init, monitor_add_command, monitor_mainloop
#include "monitor_functions.h"  // x_function, wmem_function, clear_function
#include "ad9854_functions.h"   // ad9854_init
#include "rena.h"               // rena_t, rena_channel_config, rena_controller_status, rena_status, rena_read_token
#include "fwf_roe_cmd.h"        // interface command definitions

//#define BOARD_SP605  TODO
#define BOARD_S3E
//#define DEBUG_ON
//#define SYSINFO_ON


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

uint32_t         simulation_active;
volatile uint8_t timer_tick;
uint8_t          end_simulation = FALSE;


////////////////////////////////////////
// prototypes

void running_light( uint32_t simulation_active);

uint32_t run_light_function( void);

uint32_t banner_help_function( void);

uint32_t version_function( void);
uint32_t rena_follow_mode_function( void);
uint32_t ddsinit_function( void);
uint32_t testgen_function( void);


////////////////////////////////////////
// combined print functions


/*****************************************************************************
* Function:     uart_lcd_vga_putchar 
* Description:  output function for UART, VGA and LCD/GLCD
* Parameters:   c           - character for output                         
* Returns:      
*****************************************************************************/
char uart_lcd_putchar( char c)
{
    uart_putchar( c);
    lcd_putc( c);
}


/*****************************************************************************
* Function:     uart_monitor
* Description:  process serial commands
* Parameters:   
* Returns:      
*****************************************************************************/
void uart_monitor( void)
{
    uint8_t  c;
    uint8_t  key_time_out;
    uint32_t key_state;

    putchar( '\n');

    monitor_init();

    //monitor_add_command("reset",   "system reset",                          reset_function, -1);
    #ifdef SYSINFO_ON
    monitor_add_command("sysinfo", "show system info <verbose>",            system_info_function, -1);
    #endif
    
    monitor_add_command(FWF_ROE_CMD_VERSION,   "report version",                        version_function,               FWF_ROE_CMD_VERSION_Code);
    monitor_add_command(FWF_ROE_CMD_CONTROL,   "rena controller status",                rena_controller_status,         FWF_ROE_CMD_CONTROL_Code);
    monitor_add_command(FWF_ROE_CMD_STATUS,    "rena status",                           rena_status,                    FWF_ROE_CMD_STATUS_Code);
    monitor_add_command(FWF_ROE_CMD_CONFIG,    "<channel> <high> <low_config>",         rena_channel_config_function,   FWF_ROE_CMD_CONFIG_Code);
    monitor_add_command(FWF_ROE_CMD_POWER_OFF, "set RENA to power down mode",           rena_powerdown_config_function, FWF_ROE_CMD_POWER_OFF_Code);
    monitor_add_command(FWF_ROE_CMD_FOLLOW,    "<channel> set a rena to follower mode", rena_follow_mode_function,      FWF_ROE_CMD_FOLLOW_Code);
                                               
    monitor_add_command(FWF_ROE_CMD_ACQUIRE,   "<time> activate RENA",                  rena_acquire_function,          FWF_ROE_CMD_ACQUIRE_Code);
    monitor_add_command(FWF_ROE_CMD_STOP,      "set RENA controller to IDLE",           rena_stop_function,             FWF_ROE_CMD_STOP_Code);
    monitor_add_command(FWF_ROE_CMD_CHAINS,    "print trigger chains",                  rena_chains_function,           FWF_ROE_CMD_CHAINS_Code);
    monitor_add_command(FWF_ROE_CMD_TOKEN,     "print sampled RENA tokens",             rena_read_token,                FWF_ROE_CMD_TOKEN_Code);
                                               
                                               
    monitor_add_command(FWF_ROE_CMD_DDSINIT,   "initalize DDS chip <freq tuning word>", ddsinit_function,               FWF_ROE_CMD_DDSINIT_Code);
    monitor_add_command(FWF_ROE_CMD_TESTGEN,   "generate test impulse <length>",        testgen_function,               FWF_ROE_CMD_TESTGEN_Code);
                                               
    #ifdef DEBUG_ON                                                                
    monitor_add_command("run",                 "running light",                         run_light_function, -1);
                                               
    monitor_add_command("wmem",                "write word <addr> <length> <value(s)>", wmem_function, -1);
    monitor_add_command("x",                   "eXamine memory <addr> <length>",        x_function, -1);
    #endif                                     
    monitor_add_command(FWF_ROE_CMD_HELP,      "",                                      banner_help_function,           FWF_ROE_CMD_HELP_Code);

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


/*****************************************************************************
* Function:     running_light
* Description:  give a small running light on the LED output
* Parameters:   boolean     - simulation is active or not
* Returns:      
*****************************************************************************/
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
// functions for scheduler

/*****************************************************************************
* Function:     end_simulation_task
* Description:  set the end simulation flag
* Parameters:   
* Returns:      
*****************************************************************************/
void end_simulation_task( void)
{
    end_simulation = TRUE;
}


/*****************************************************************************
* Function:     run_light_function
* Description:  start the running light
* Parameters:   
* Returns:      0
*****************************************************************************/
uint32_t run_light_function( void)
{
    running_light( simulation_active);
    return 0;
}



/*****************************************************************************
* Function:     banner
* Description:  print system information for sim and on hardware
* Parameters:   
* Returns:      
*****************************************************************************/
void banner( void)
{
    putstr("\n\n");

    putstr("rena3 - read out electronic, SIMULATOR");

    char     *hw_revision  =    (char *)0x80000000;
    int32_t  *hw_frequency = (int32_t *)0x80000020;

    if (simulation_active) 
    {
        putstr(" (on sim)\n");
    }
    else
    {
        putchar('\n'); putstr( FWF_ROE_ZPU_SW_VERSION);
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


/*****************************************************************************
* Function:     banner_help_function
* Description:  print the banner and the system help
* Parameters:   
* Returns:      0
*****************************************************************************/
uint32_t banner_help_function( void)
{
    banner();
    help_function();

    return 0;
}

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
/*****************************************************************************
* Function:     _zpu_interrupt
* Description:  interrupt funktion, maintain the timer tick, set flags
* Parameters:   
* Returns:      
*****************************************************************************/
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

/*****************************************************************************
* Function:     version_function
* Description:  print out the interface version
* Parameters:   
* Returns:      0
*****************************************************************************/
uint32_t version_function( void)
{
    putstr( FWF_ROE_ZPU_SW_VERSION);
    putchar('\n');
    return 0;
}



/*****************************************************************************
* Function:     ddsinit_function
*
* Description:  init DDS with frequency tuning word
*               can be calculates as follow:
*               FTW = ( desired frequency * 2**48) / sysclk
*               sysclk should be 200 MHz
*               example: 10 MHz ddsinit CCCC CCCCCCCC
*
* Parameters:   (frequency tuning word high bits: 47..32)
*               (frequency tuning word low  bits: 31..0)
* Returns:      0
*****************************************************************************/
uint32_t ddsinit_function( void)
{
    uint32_t low;
    uint32_t high;
    uint64_t ftw;

    high = monitor_get_argument_hex(1);
    low  = monitor_get_argument_hex(2);

    return low;
}


/*****************************************************************************
* Function:     rena_follow_mode_function
* Description:  activate follower mode (for debugging)
* Parameters:   
* Returns:      
*****************************************************************************/
uint32_t rena_follow_mode_function( void)
{
    uint8_t channel;
    channel = monitor_get_argument_int(1);

    return( rena_follow_mode( channel));
}




/*****************************************************************************
* Function:     testgen_function
* Description:  program the test pulse generator (for debugging/calibrating)
* Parameters:   
* Returns:      
*****************************************************************************/
uint32_t testgen_function( void)
{
    uint16_t cycles;

    cycles = monitor_get_argument_int(1);
   
    return cycles;
}


/*****************************************************************************
* Function:     main
* Description:  initialisation and running the system
* Parameters:   
* Returns:      
*****************************************************************************/
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
    // enable timer interrupt, for scheduler
    set_bit( timer0->e[0].ctrl, TIMER_INT_ENABLE);

    if (!simulation_active) {
        
        #ifdef BOARD_SP605
        vga_init();
        chrontel_init(); // dvi
        #endif
        #ifdef BOARD_S3E
        lcd_init();
        lcd_string("RENA3 emulator");
        #endif
        putchar_fp = uart_putchar;
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

    // test of scheduler
    // scheduler_task_add( end_simulation_task, 3);
    // running_light( simulation_active);
    
    //////////////////////////////////////////////////////////// 
    // end simulation
    abort();
    
}
