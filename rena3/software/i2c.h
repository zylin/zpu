/*
 * $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/software/test/i2c.h $
 * $Date: 2011-06-24 13:22:23 +0200 (Fr, 24. Jun 2011) $
 * $Author: lange $
 * $Revision: 1084 $
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
