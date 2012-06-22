
/*
 * $Date$
 * $Author$
 * $Revision$
 */

#include "rena.h"

//rena_t   *rena        = (rena_t *)  0x80000d00;
//uint32_t *token_table = (uint32_t*) 0x10000000;



/*
    print status of rena controller
*/
uint32_t rena_controller_status( void)
{
    putstr("UNKNOWN");
    putchar('\n');
    return( 0);
}


/*
    get rena trigger status
*/
uint32_t rena_status( void)
{
    putstr("fast trigger : 0"); 
    putstr("\nslow trigger : 0");
    putstr("\noverflow     : 0");
    putchar('\n');

    return( 0);
}


/*
    print content of trigger chains
*/
uint32_t rena_chains_function( void)
{
    putstr(  "fast trigger chain: 0x");  
    puthex( 4, 0); 
    puthex(32, 0);
    putstr("\nfast channel mask (and): 0x"); 
    puthex( 4, 0); 
    puthex(32, 0);
    putstr("\nfast force mask (or):    0x"); 
    puthex( 4, 0); 
    puthex(32, 0);
    putchar('\n');
    putstr("\nslow trigger chain: 0x"); 
    puthex( 4, 0); 
    puthex(32, 0);
    putstr("\nslow channel mask (and): 0x"); 
    puthex( 4, 0); 
    puthex(32, 0);
    putstr("\nslow force mask (or):    0x"); 
    puthex( 4, 0); 
    puthex(32, 0);
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

    token = 3;

    putstr("tokens: 3\n");

    for ( index = 0; index < token; index++)
    {
        putstr("8000\n");
    }

    return( token);
}

////////////////////////////////////////////////////////////
// monitor functions
uint32_t rena_channel_config_function( void)
{
    uint32_t low_config;

    low_config  = monitor_get_argument_hex(3);

    return( low_config);
}


/*
    start rena acquirement
*/
uint32_t rena_acquire_function( void)
{
    uint32_t time;

    time = monitor_get_argument_int(1);

    return( time);
}


/*
    stop rena
*/
uint32_t rena_stop_function( void)
{
}

/*
    power down all channels
*/

uint32_t rena_powerdown_config_function( void)
{
}


/*
    set one bit in the force mask
    set rena to follower mode
*/
uint32_t rena_follow_mode( uint8_t channel)
{
    uint32_t temp;

    temp = 0;
    if (channel < 32)
    {
        temp = (1 << channel);
    }
    
    return( temp);
}



/*
 * activate the test generator
 */
uint32_t rena_testgen( uint8_t polarity, uint16_t cycles)
{
    uint32_t test_generator;

    test_generator = (polarity << RENA_TEST_POL_PIN) | cycles;
    return( test_generator);
}
