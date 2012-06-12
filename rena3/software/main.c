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
#include "fwf_roe_cmd.h"        // interface command definitions

//#define BOARD_SP605  TODO
//#define DEBUG_ON
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

uint32_t         simulation_active;
volatile uint8_t timer_tick;
uint8_t          end_simulation = FALSE;


////////////////////////////////////////
// prototypes

void running_light( uint32_t simulation_active);

uint32_t run_light_function( void);

uint32_t banner_help_function( void);

uint32_t version_function( void);
uint32_t rena_trouble( void);
uint32_t rena_trouble_acquire( void);
uint32_t rena_follow_mode_function( void);
uint32_t rena_set_ecal_function( void);
uint32_t ddsinit_function( void);
uint32_t testgen_function( void);


////////////////////////////////////////
// combined print functions


/*****************************************************************************
* Function:     uart_vga_putchar                                             
* Description:  output function for UART and VGA
* Parameters:   c           - character for output                         
* Returns:      
*****************************************************************************/
char uart_vga_putchar( char c)
{
    uart_putchar( c);
    //vga_putchar( c);
}


/*****************************************************************************
* Function:     uart_lcd_vga_putchar 
* Description:  output function for UART, VGA and LCD/GLCD
* Parameters:   c           - character for output                         
* Returns:      
*****************************************************************************/
char uart_lcd_vga_putchar( char c)
{
    uart_putchar( c);
    //vga_putchar( c);
    lcd_putc( c);
}


/*****************************************************************************
* Function:     debug_vga_putchar
* Description:  output function for DEBUG console and VGA
* Parameters:   c           - character for output                         
* Returns:      
*****************************************************************************/
char debug_vga_putchar( char c)
{
    debug_putchar( c);
    vga_putchar( c);
}


/*****************************************************************************
* Function:     button_pressed
* Description:  check if actually a button is pressed
* Parameters:   
* Returns:      boolean     - TRUE if one of the buttons is pressed
*****************************************************************************/
uint8_t button_pressed( void)
{
    if bit_is_set( gpio0->iodata, BUTTON0)
    {
        return TRUE;
    }
    if bit_is_set( gpio0->iodata, BUTTON1)
    {
        return TRUE;
    }
    if bit_is_set( gpio0->iodata, BUTTON2)
    {
        return TRUE;
    }
    if bit_is_set( gpio0->iodata, BUTTON3)
    {
        return TRUE;
    }
    return FALSE;
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

    monitor_add_command("reset",   "system reset",                          reset_function, -1);
    #ifdef SYSINFO_ON
    monitor_add_command("sysinfo", "show system info <verbose>",            system_info_function, -1);
    #endif
    
    monitor_add_command(FWF_ROE_CMD_VERSION,   "report version",                        version_function,               FWF_ROE_CMD_VERSION_Code);
    monitor_add_command(FWF_ROE_CMD_CONTROL,   "rena controller status",                rena_controller_status,         FWF_ROE_CMD_CONTROL_Code);
    monitor_add_command(FWF_ROE_CMD_STATUS,    "rena status",                           rena_status,                    FWF_ROE_CMD_STATUS_Code);
    monitor_add_command(FWF_ROE_CMD_CONFIG,    "<channel> <high> <low_config>",         rena_channel_config_function,   FWF_ROE_CMD_CONFIG_Code);
    monitor_add_command("demo",                "<channel> ECAL, demo config for RENA",  rena_demo_config_function,      -1);
    monitor_add_command(FWF_ROE_CMD_POWER_OFF, "set RENA to power down mode",           rena_powerdown_config_function, FWF_ROE_CMD_POWER_OFF_Code);
    monitor_add_command(FWF_ROE_CMD_FOLLOW,    "<channel> set a rena to follower mode", rena_follow_mode_function,      FWF_ROE_CMD_FOLLOW_Code);
    monitor_add_command("ecal",                "<channel> config to ECAL",              rena_set_ecal_function,         -1);
                                               
    monitor_add_command(FWF_ROE_CMD_ACQUIRE,   "<time> activate RENA",                  rena_acquire_function,          FWF_ROE_CMD_ACQUIRE_Code);
    monitor_add_command(FWF_ROE_CMD_STOP,      "set RENA controller to IDLE",           rena_stop_function,             FWF_ROE_CMD_STOP_Code);
    monitor_add_command(FWF_ROE_CMD_CHAINS,    "print trigger chains",                  rena_chains_function,           FWF_ROE_CMD_CHAINS_Code);
    monitor_add_command(FWF_ROE_CMD_TOKEN,     "print sampled RENA tokens",             rena_read_token,                FWF_ROE_CMD_TOKEN_Code);
                                               
    monitor_add_command("trouble",             "<cnt> <time> <ch> trouble follow mode", rena_trouble,                   -1);
    monitor_add_command("tracq",               "<count> <time> trouble acquire mode",   rena_trouble_acquire,           -1);
                                               
    monitor_add_command(FWF_ROE_CMD_DDSINIT,   "initalize DDS chip <freq tuning word>", ddsinit_function,               FWF_ROE_CMD_DDSINIT_Code);
    monitor_add_command("ddsinfo",             "read dds registers",                    ad9854_info,                    -1);
    monitor_add_command(FWF_ROE_CMD_TESTGEN,   "generate test impulse <length>",        testgen_function,               FWF_ROE_CMD_TESTGEN_Code);
    monitor_add_command("adc",                 "read adc value",                        adc_read,                       -1);
                                               
    #ifdef DEBUG_ON                                                                
    monitor_add_command("run",                 "running light",                         run_light_function);
    monitor_add_command("i2c",                 "check I2C address",                     i2c_check_function);
    monitor_add_command("eeprom",              "read EEPROM <bus> <i2c_addr> <length>", i2c_read_eeprom_function);
                                               
    monitor_add_command("mem",                 "alias for x",                           x_function);
    monitor_add_command("wmem",                "write word <addr> <length> <value(s)>", wmem_function);
    monitor_add_command("x",                   "eXamine memory <addr> <length>",        x_function);
    #endif                                     
    //monitor_add_command("clear",               "clear screen",   clear_function,       -1);
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

    putstr("rena3 - read out electronic");

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
* Description:  init DDS with frequency tuning word
* Parameters:   
* Returns:      0
*****************************************************************************/
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
    uint8_t  index;
    uint32_t loop;
    uint32_t value;
    
    uint8_t  config_high;
    uint32_t config_low;


    loop  = monitor_get_argument_int(1);
    value = monitor_get_argument_int(2);
    index = monitor_get_argument_int(3);
    
    rena_powerdown_config_function();
    
    // trouble shoot for follower mode
    while ((loop > 0) && (! button_pressed()))
    {

        config_high = 
//          RENA_FB_TC         | 
            RENA_ECAL;

        config_low  = 
            (3   << RENA_GAIN) |
            RENA_RSEL_VREFHI   |
            (7  << RENA_SEL)   |
            RENA_POLNEG        |
            (30 << RENA_DS)    | 
            RENA_FM;

        // configure channel (index)
        rena_channel_config( index, config_high, config_low);
        usleep( 100);

        // set follow mode on channel
        rena_follow_mode( index);
        usleep( 100);

        // generate testpulse
        rena_testgen( RENA_TEST_POL_NEG, value);
        usleep( 100);

        // switch off all channels
        rena_powerdown_config_function();
        msleep( 100);

        loop--;
    }
   
    return( config_low);
}

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////

uint32_t rena_trouble_acquire( void)
{
    uint8_t  index;
    uint32_t  loop;
    uint32_t value;
    uint32_t config;
    
    uint8_t  config_high;
    uint32_t config_low;
   
    loop  = monitor_get_argument_int(1);
    value = monitor_get_argument_int(2);
   
   // trouble shoot on acquire mode
    uint8_t dac_value;

    dac_value = 0;
    index     = 0;
    rena_powerdown_config_function();

    while ((loop > 0) && (! button_pressed()))
    {

        config_high = 
            RENA_ECAL;

        config_low  = 
            (3        << RENA_GAIN) |
            RENA_RSEL_VREFHI        |
            (5        << RENA_SEL)  |
            (dac_value << RENA_DF)  | 
            RENA_POLNEG             |
            (dac_value << RENA_DS)  | 
//          RENA_ENF                |
            RENA_ENS;
        rena_channel_config( index, config_high, config_low);
    
        rena_testgen( RENA_TEST_POL_NEG, value);

        rena->acquire_time   = 0;
        rena->control_status = RENA_MODE_ACQUIRE;
        
        msleep( 20);

        rena_powerdown_config_function();
//      puthex( 8,  config_high); putchar(' ');
//      puthex( 32, config_low);  putchar(' ');
        putint( dac_value);       putchar(' ');
//      putint( index);           putchar('\n');
        dac_value = (dac_value < 255) ? dac_value + 1 : 0;
//      index     = (index     < 35 ) ? index     + 1 : 0;

        rena_controller_status();
        rena_status();

        loop--;
    }

    return( config_low);
}


////////////////////////////////////////////////////////////
uint32_t rena_follow_mode_function( void)
{
    uint8_t channel;
    channel = monitor_get_argument_int(1);

    return( rena_follow_mode( channel));
}


////////////////////////////////////////////////////////////
uint32_t rena_set_ecal_function( void)
{

    uint8_t channel;
    channel = monitor_get_argument_int(1);

    return( rena_set_ecal( channel));
}

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////


uint32_t testgen_function( void)
{
    uint16_t cycles;

    cycles = monitor_get_argument_int(1);
   
    rena_testgen( RENA_TEST_POL_NEG, cycles);
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
    
    // set all rena registers to (zero/ power off)    
    rena_powerdown_config_function();
    // init rena testgen polarity
    rena_testgen( RENA_TEST_POL_NEG, 0);


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
    rena_set_ecal( 34);
    rena_follow_mode( 34);
    
    // generate some test pulse
    usleep( 5);
    rena_testgen( RENA_TEST_POL_NEG, 10);
    usleep( 5);
    rena_testgen( RENA_TEST_POL_POS, 10);
    usleep( 5);
*/
    
    uint8_t  config_high;
    uint32_t config_low;

        config_high = 
            RENA_ECAL;

        config_low  = 
            (1        << RENA_GAIN) |
//          RENA_RSEL_VREFHI        |
            (6        << RENA_SEL)  |
            RENA_POLPOS             |
            (30 << RENA_DS)  | 
            RENA_ENS                |
            RENA_FM;
        rena_channel_config( 35, config_high, config_low);
    
        rena_testgen( RENA_TEST_POL_NEG, 100);
        rena->acquire_time   = 0;
        rena->control_status = RENA_MODE_ACQUIRE;
        
        usleep( 2);

    

    // test of scheduler
//  scheduler_task_add( end_simulation_task, 3);
//  running_light( simulation_active);
    
    //////////////////////////////////////////////////////////// 
    // end simulation
    abort();
    
}
