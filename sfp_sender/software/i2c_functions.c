/*
 * $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/software/test/i2c_functions.c $
 * $Date: 2011-08-29 16:53:19 +0200 (Mo, 29. Aug 2011) $
 * $Author: lange $
 * $Revision: 1228 $
 */

#include <types.h>
#include <peripherie.h>

/*
    probe all I2C addresses and check for ACK
*/
uint32_t i2c_check_function( void) 
{
    uint8_t  addr;
    uint16_t count;

    count = 0;

    #ifdef BOARD_SP605 
    putstr("i2c DVI\n");
    for (addr = 0; addr < 128; addr++) {
        if bit_is_clear( i2c_command(i2c_dvi, (I2C_START) | (I2C_WRITE) | (I2C_STOP), addr << 1), I2C_RX_ACK) {
            putstr("address: 0x"); puthex( 8, addr); putstr("   -->   ACK\n");
            count++;
        }
        //putchar('\n');
    }
    #endif

    putstr("i2c FMC\n");
    for (addr = 0; addr < 128; addr++) {
        if bit_is_clear( i2c_command(i2c_fmc, (I2C_START) | (I2C_WRITE) | (I2C_STOP), addr << 1), I2C_RX_ACK) {
            putstr("address: 0x"); puthex( 8, addr); putstr("   -->   ACK\n");
            count++;
        }
    }

    return count;
}

/*
 * read one byte from EEPROM memory location
 */
uint8_t i2c_eeprom_read_byte( i2cmst_t* i2c, uint8_t i2c_addr, uint16_t mem_addr)
{
    // we use random read, slow but universal
    // address + read
    i2c_command( i2c, (I2C_START) | (I2C_WRITE), (i2c_addr << 1));
    i2c_command( i2c, (I2C_WRITE), mem_addr >> 8);
    i2c_command( i2c, (I2C_WRITE), mem_addr & 0x00ff);
    i2c_command( i2c, (I2C_START) | (I2C_WRITE), (i2c_addr << 1) + 1); // read
    if bit_is_clear( i2c_command( i2c, (I2C_READ)  | (I2C_STOP),  0), I2C_RX_ACK) 
        return i2c->data;
}


/*
 * print complete eeprom content to screen
 */
void i2c_read_eeprom( i2cmst_t* i2c, uint8_t i2c_addr, uint16_t length) 
{
    uint16_t  reg;
    uint8_t   data;
    uint8_t   buf[8];

    putstr("read data ("); putint(length); putstr(" bytes) from I2C-address 0x");
    puthex( 8, i2c_addr); putstr("\n\n");
    
    // read length bytes out of device
    for (reg = 0; reg < length; reg++) {

        data = i2c_eeprom_read_byte( i2c, i2c_addr, reg);
//  
//      // address + read
//      i2c_command( i2c, (I2C_START) | (I2C_WRITE), (i2c_addr << 1) + 1);

//      if bit_is_clear( i2c_command( i2c, (I2C_READ)  | (I2C_STOP),  0), I2C_RX_ACK) 
//      {
//          data = i2c->data;
            putstr("0x"); puthex( 8, data); putstr(" ");
            if ((data > 127) || (data < 32)) {
                buf[ reg % 8] = 32;
            } else {
                buf[ reg % 8] = data;
            }
//      }
        if  (reg % 8 == 7) {
            putstr( buf);
            putchar('\n');
        }
    }
    
    // dummy read at end
    i2c->command = (I2C_READ) | (I2C_STOP);
    loop_until_bit_is_clear( i2c->command, I2C_TIP);
}


/*
    read the EEPROM from the connected display
    and dump it content
*/
uint32_t i2c_read_eeprom_function( void)
{
    uint8_t   i2c_bus;
    uint8_t   i2c_address;
    uint16_t  length;
    i2cmst_t* i2c;

    i2c_bus     = monitor_get_argument_int(1);
    i2c_address = monitor_get_argument_hex(2);
    length      = monitor_get_argument_int(3);

    #ifdef BOARD_SP605 
    // select I2C bus 0 = fmc/main, 1 = dvi
    i2c = (i2c_bus == 0) ? (i2c_fmc) : (i2c_dvi);
    #else
    i2c = i2c_fmc;
    #endif
    // set default length
    if (length == 0)
        length = 128;
    i2c_read_eeprom( i2c, i2c_address, length);
    return length;
}

