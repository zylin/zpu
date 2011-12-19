
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
    // wait until rena is idle
    while (rena->control_status != 0) {};

    // Attention: order is important
    rena->config_low  = low_config;
    // write to high config trigger the config process
    // combine trigger an high config bits
    rena->config_high = (channel << 3) | high_config;
}

/*
    read (and print) tokens
*/
uint32_t rena_read_token( void)
{
    uint8_t token;
    uint8_t index;

    token = rena->token_count;

    putstr("tokens:");
    putint( token);
    putchar('\n');

    for ( index = 0; index++; index < token - 1)
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
