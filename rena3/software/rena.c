
/*
 * $Date$
 * $Author$
 * $Revision$
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
    rena->control_status = RENA_MODE_IDLE;

    // Attention: order is important
    rena->config_low  = low_config;
    // write to high config trigger the config process
    // combine trigger an high config bits
    rena->config_high = (channel << 3) | high_config;
    
    // wait until config is ready
    while (rena->control_status != RENA_MODE_IDLE) {};
}


/*
    print content of trigger chains
*/
uint32_t rena_chains_function( void)
{
    putstr(  "fast trigger chain: 0x");  
    puthex( 4, rena->fast_trigger_chain_high); 
    puthex(32, rena->fast_trigger_chain_low);
    putstr("\nslow trigger chain: 0x"); 
    puthex( 4, rena->slow_trigger_chain_high); 
    puthex(32, rena->slow_trigger_chain_low);
    putstr("\nchannel mask (and): 0x"); 
    puthex( 4, rena->channel_mask_high); 
    puthex(32, rena->channel_mask_low);
    putstr("\nforce mask (or):    0x"); 
    puthex( 4, rena->channel_force_mask_high); 
    puthex(32, rena->channel_force_mask_low);
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
    return( low_config);
}


/*
    start rena acquirement
*/
uint32_t rena_acquire_function( void)
{
    uint32_t time;

    time = monitor_get_argument_int(1);
    
    //while (rena->control_status != RENA_MODE_IDLE) {};
    
    rena->acquire_time = time;

    // activate acquire
    rena->control_status = RENA_MODE_ACQUIRE;

    return( time);
}


/*
    stop rena
*/
uint32_t rena_stop_function( void)
{
    rena->control_status = RENA_MODE_IDLE;
}


/*
    rena demo config
*/
#define DAC_SLOW (127)
#define DAC_FAST (127)
#define SEL      (15)
#define GAIN     (3)

uint32_t rena_demo_config_function( void)
{
    uint8_t index;
    uint8_t  config_high;
    uint32_t config_low;

    uint8_t channel;
    channel = monitor_get_argument_int(1);
    

    config_high = 
        0;

    config_low = 
        (GAIN     << RENA_GAIN) |
        RENA_RANGE_15fF         |
        (SEL      << RENA_SEL)  |
        RENA_SIEZA_1000         |
        (DAC_FAST << RENA_DF)   | 
        RENA_POLPOS             |
        (DAC_SLOW << RENA_DS)   | 
        //RENA_ENF                | 
        RENA_ENS;

    for( index = 0; index < 35; index++)
    {
        rena_channel_config( index, config_high, config_low);
    }

    rena_channel_config( channel, RENA_ECAL, config_low);
    return( 0);
}

/*
    power down all channels
*/

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
    set one bit in the force mask
    set rena to follower mode
*/
uint32_t rena_follow_mode( uint8_t channel)
{
    // decide which bit to set
    if (channel < 32)
    {
        rena->channel_force_mask_low  = (1 << channel);
        rena->channel_force_mask_high = 0;
    }
    else
    {
        rena->channel_force_mask_low  = 0;
        rena->channel_force_mask_high = (1 << (channel - 32));
    }
    
    rena->control_status = RENA_MODE_FOLLOW;

    return( rena->channel_force_mask_low);
}


/*
    set rena to follower mode
*/
uint32_t rena_set_ecal( uint8_t channel)
{
    uint8_t  config_high;
    uint32_t config_low;
    

    config_high = 
//      RENA_FB_TC              |
        RENA_ECAL;

    config_low = 
//      RENA_FETSEL_SIMPLE      |
//      (GAIN     << RENA_GAIN) |
//      (SEL      << RENA_SEL)  |
//      RENA_RANGE_60fF         |
//      RENA_SIEZA_1000         |
//      (DAC_FAST << RENA_DF)   | 
//      RENA_POLPOS             |
//      (DAC_SLOW << RENA_DS)   | 
//      RENA_ENF                | 
//      RENA_ENS                |
        RENA_FM;
    
    rena_channel_config( channel, config_high, config_low);
    return( config_low);
}


void rena_simulate_follower_mode( void)
{
    rena_channel_config( 0, 0x2, RENA_FM);
    
    rena->channel_force_mask_low  = 0x00000001;
    rena->channel_force_mask_high = 0x0;
    rena->control_status = RENA_MODE_FOLLOW;
    usleep( 50);
    testgen( 0);
    rena->control_status = RENA_MODE_IDLE;

}


/*
 * activate the test generator
 */
uint32_t rena_testgen( uint8_t polarity, uint16_t cycles)
{
    rena->test_generator = (polarity << RENA_TEST_POL_PIN) | cycles;
    return( rena->test_generator);
}
