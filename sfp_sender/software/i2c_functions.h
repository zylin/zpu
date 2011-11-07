/*
 * $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/software/test/i2c_functions.h $
 * $Date: 2011-08-25 13:50:17 +0200 (Do, 25. Aug 2011) $
 * $Author: lange $
 * $Revision: 1211 $
 */

#ifndef I2C_FUNCTIONS_H
#define I2C_FUNCTIONS_H


////////////////////////////////////////
// I2C addresses
#define I2C_ADDR_DISPLAY                (0x50)
#define I2C_ADDR_PCF8574                (0x20)


extern uint8_t pcf8574_state;


uint32_t i2c_check_function( void);
uint8_t  i2c_eeprom_read_byte( i2cmst_t* i2c, uint8_t i2c_addr, uint16_t mem_addr);
void     i2c_read_eeprom( i2cmst_t* i2c, uint8_t i2c_addr, uint16_t length);
uint32_t i2c_read_eeprom_function( void);

#endif // I2C_FUNCTIONS_H

