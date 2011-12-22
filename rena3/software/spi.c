/*
 * $Date$
 * $Author$
 * $Revision$
 */

#include "spi.h"

    
spi_t *spi0 = (spi_t *)0x80000b00;


/*
    initialize the SPI module

*/
void spi_init( void)
{
    // deactivate
    clear_bit( spi0->mode, 1 << SPI_MODE_EN);

    // activate core

    // CPOL  = 0
    // CPHA  = 0
    // DIV16 = 0
    // REV   = 0  (LSB first)
    // MS    = 1  Master
    // LEN   = 7  (= number of transmit bits -1)
    spi0->mode = SPI_DIV16 << SPI_MODE_DIV16 | 
                 1 << SPI_MODE_REV |
                 1 << SPI_MODE_MS | 
                 1 << SPI_MODE_EN | 
                 SPI_WORDLEN << SPI_MODE_LEN |
                 SPI_PRESCALER << SPI_MODE_PM |
                 SPI_FACT << SPI_MODE_FACT;
}



void spi_send( uint8_t value)
{

    // shift left to align
    // msb first
    spi0->transmit = value << 24;

}



/*
    transmit data fast without shift
*/
void spi_send_raw( uint32_t value)
{
    spi0->transmit = value;
}


uint32_t spi_receive( void)
{
    loop_until_bit_is_set( spi0->event, SPI_EVENT_NE);
    return (spi0->receive >> 16);
}

void spi_info( void)
{

    uint32_t value;

    value = spi0->capability;
    putstr("SPI capability: 0x"); puthex(32, value);
    putstr("\n  SSSZ   : "); putint( 0xff & (value >> SPI_CAPABILITY_SSSZ));
    putstr("\n  MAXWLEN: "); putint( 0x0f & (value >> SPI_CAPABILITY_MAXWLEN));
    putstr("\n  TWEN   : "); putbool( bit_is_set(value, SPI_CAPABILITY_TWEN));
    putstr("\n  AMODE  : "); putbool( bit_is_set(value, SPI_CAPABILITY_AMODE));
    putstr("\n  ASELA  : "); putbool( bit_is_set(value, SPI_CAPABILITY_ASLEA));
    putstr("\n  SSEN   : "); putbool( bit_is_set(value, SPI_CAPABILITY_SLAVE_SELECT_ENABLE));
    putstr("\n  FDEPTH : "); putint( 0xff & (value >> SPI_CAPABILITY_FIFODEPTH));
    putstr("\n  REV    : "); putint( 0xff & (value >> SPI_CAPABILITY_REVISION));
    putchar('\n');
}


