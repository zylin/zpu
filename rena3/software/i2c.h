/*
 * $Date$
 * $Author$
 * $Revision$
 */

#ifndef I2C_H
#define I2C_H

#include "peripherie.h"
#include <types.h>


////////////////////////////////////////////////////////////
// i2c functions

void     i2c_init( void);
uint8_t  i2c_command( i2cmst_t* i2c, uint8_t command, uint8_t data);
uint8_t  i2c_check_ack( i2cmst_t* i2c);

#endif // I2C_H
