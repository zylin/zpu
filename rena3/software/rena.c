
/*
 * $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/hardware/board_sp601/rtl/teilerregister.vhd $
 * $Date: 2010-10-29 15:57:42 +0200 (Fr, 29 Okt 2010) $
 * $Author: lange $
 * $Revision: 659 $
 */

#include "rena.h"

rena_t *rena = (rena_t *) 0x80000d00;

/*
    print status of rena controller
*/
uint32_t rena_status( void)
{
    uint32_t status;

    status = rena->status;

    switch( status & 0xff)
    {
        case 0x00: putstr("idle");      break;
        case 0x01: putstr("configure"); break;
        case 0x03: putstr("aquire");    break;
        case 0x04: putstr("readout");   break;
        default:   putstr("UNKNOWN");   break;
    }
    putchar('\n');

    return( 0);
}


/*
    get rena trigger status
*/
uint32_t rena_trigger( void)
{
    uint32_t status;

    status = (rena->status >> 30) & 0x03;

    putstr("\ntrigger");
    putstr("\nfast : "); putint( (status>1) & 0x01);
    putstr("\nslow : "); putint( (status>0) & 0x01);
    putchar('\n');

    return( status);
}


/*
    write configuration of one channel
*/
uint32_t rena_channel_config(uint8_t channel, uint8_t high_config, uint32_t low_config)
{
    // wait until rena is idle
    while (rena->status != 0) {};

    // Attention: order is important
    rena->config_low  = low_config;
    // write to high config trigger the config process
    // combine trigger an high config bits
    rena->config_high = (channel << 3) | high_config;
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
