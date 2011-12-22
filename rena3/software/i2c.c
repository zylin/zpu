/*
 * $Date$
 * $Author$
 * $Revision$
 */

#include "i2c.h"


////////////////////////////////////////////////////////////
// i2c functions



void i2c_init( void)
{
    #ifdef BOARD_SP605 
    i2c_dvi->clock_prescaler = I2C_PRESCALER_400K;
    i2c_dvi->control         = I2C_CORE_ENABLE;
    #endif

    i2c_fmc->clock_prescaler = I2C_PRESCALER_400K;
    i2c_fmc->control         = I2C_CORE_ENABLE;
}

uint8_t i2c_command( i2cmst_t* i2c, uint8_t command, uint8_t data)
{
    i2c->data    = data;
    i2c->command = command;
    loop_until_bit_is_clear( i2c->command, I2C_TIP);
    
    return i2c->command; // read status register
}


uint8_t i2c_check_ack( i2cmst_t* i2c)
{
    return bit_is_clear( i2c->command, I2C_RX_ACK);
}


