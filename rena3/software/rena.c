
/*
 * $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/hardware/board_sp601/rtl/teilerregister.vhd $
 * $Date: 2010-10-29 15:57:42 +0200 (Fr, 29 Okt 2010) $
 * $Author: lange $
 * $Revision: 659 $
 */

#include "rena.h"

rena_t   *rena        = (rena_t *)  0x80000d00;
uint32_t *token_table = (uint32_t*) 0x10000000;



/*
    print status of rena controller
*/
uint32_t rena_controller_status( void)
{
    uint32_t status;

    status = rena->control_status;

    switch( status & 0xff)
    {
        case 0x00: putstr("idle");      break;
        case 0x01: putstr("configure"); break;
        case 0x03: putstr("detect");    break;
        case 0x04: putstr("aquire");    break;
        case 0x05: putstr("analyze");   break;
        case 0x06: putstr("desire");    break;
        case 0x07: putstr("readout");   break;
        case 0x08: putstr("readlag");   break;
        case 0x09: putstr("follow");    break;
        default:   putstr("UNKNOWN");   break;
    }
    putchar('\n');

    return( 0);
}


/*
    get rena trigger status
*/
uint32_t rena_status( void)
{
    uint32_t status;

    status = rena->rena_status;

    putstr("fast trigger : ");   putint(( status >> 2) & 0x01);
    putstr("\nslow trigger : "); putint(( status >> 1) & 0x01);
    putstr("\noverflow     : "); putint(( status >> 0) & 0x01);
    putchar('\n');

    return( status);
}


/*
    write configuration of one channel
*/
uint32_t rena_channel_config(uint8_t channel, uint8_t high_config, uint32_t low_config)
{

    // Attention: order is important
    rena->config_low  = low_config;
    // write to high config trigger the config process
    // combine trigger an high config bits
    rena->config_high = (channel << 3) | high_config;
    
    // wait until config is ready
    while (rena->control_status != 0) {};
}


/*
    print content of trigger chains
*/
uint32_t rena_chains_function( void)
{
    putstr("fast trigger chain: 0x");  
    puthex(32, rena->fast_trigger_chain_high); 
    puthex(32, rena->fast_trigger_chain_low);
    putstr("\nslow trigger chain: 0x"); 
    puthex(32, rena->slow_trigger_chain_high); 
    puthex(32, rena->slow_trigger_chain_low);
    putchar('\n');
    return (0);
}


/*
    read (and print) tokens
*/
uint32_t rena_read_token( void)
{
    uint8_t token;
    uint8_t index;

    token = rena->token_count;

    putstr("tokens: ");
    putint( token);
    putchar('\n');

    for ( index = 0; index < token - 1; index++)
    {
        putint( token_table[ index]);
        putchar('\n');
    }

    return( token);
}

////////////////////////////////////////////////////////////
// monitor functions
uint32_t rena_channel_config_function( void)
{
    uint8_t  channel;
    uint8_t  high_config;
    uint32_t low_config;

    channel     = monitor_get_argument_int(1);
    high_config = monitor_get_argument_hex(2);
    low_config  = monitor_get_argument_hex(3);

    rena_channel_config( channel, high_config, low_config);
}


/*
    start rena acquirement
*/
uint32_t rena_acquire_function( void)
{
    uint32_t time;

    time = monitor_get_argument_int(1);
    
    while (rena->control_status != 0) {};
    
    rena->acquire_time = time;

    // activate acquire
    rena->control_status = 2;

    return( time);
}


/*
    stop rena
*/
uint32_t rena_stop_function( void)
{
    rena->control_status = 0;
}


/*
    rena demo config
*/
#define DAC_SLOW (0)
#define DAC_FAST (0)
#define SEL      (10)
#define GAIN     (3)

uint32_t rena_demo_config_function( void)
{
    uint8_t index;
    uint8_t  config_high;
    uint32_t config_low;

    config_high = 
        RENA_ECAL;

    config_low = 
        RENA_FETSEL_SIMPLE      |
        (GAIN     << RENA_GAIN) |
        RENA_PZSEL_EN           |
        (SEL      << RENA_SEL)  |
        RENA_SIEZA_1000         |
        (DAC_FAST << RENA_DF)   | 
        RENA_POLPOS             |
        (DAC_SLOW << RENA_DS)   | 
        RENA_ENF                | 
        RENA_ENS;

    for( index = 0; index < 35; index++)
    {
        rena_channel_config( index, config_high, config_low);
    }
    return( 0);
}



uint32_t rena_powerdown_config_function( void)
{
    uint8_t index;
    uint8_t  config_high;
    uint32_t config_low;

    config_high = 
        RENA_FPDWN;

    config_low = 
        RENA_PDWN;

    for( index = 0; index < 35; index++)
    {
        rena_channel_config( index, config_high, config_low);
    }
    return( 0);
}


/*
    set rena channel 0 to follower mode
*/
uint32_t rena_follow_mode_function( void)
{
    uint8_t  config_high;
    uint32_t config_low;

    uint8_t channel;
    channel = monitor_get_argument_int(1);
    

    config_high = 
        RENA_ECAL;

    config_low = 
        RENA_FETSEL_SIMPLE      |
        (GAIN     << RENA_GAIN) |
        (SEL      << RENA_SEL)  |
        RENA_SIEZA_1000         |
        (DAC_FAST << RENA_DF)   | 
        RENA_POLPOS             |
        (DAC_SLOW << RENA_DS)   | 
        RENA_ENF                | 
        RENA_ENS                |
        RENA_FM;
        
    rena_channel_config( channel, config_high, config_low);
    rena->control_status = 9;

    return( 0);
}