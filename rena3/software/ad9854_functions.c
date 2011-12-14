/*
 * $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/hardware/board_sp601/rtl/teilerregister.vhd $
 * $Date: 2010-10-29 15:57:42 +0200 (Fr, 29 Okt 2010) $
 * $Author: lange $
 * $Revision: 659 $
 */

#include "peripherie.h"
#include "spi.h"
#include "ad9854_functions.h"

// number of bytes to transfer per register
const uint8_t transfer_length[12] = { 2, 2, 6, 6, 6, 4, 3, 4, 2, 2, 1, 2};


/*
    do initialisation of the AD9854 chip
    its connected in serial mode with unidirectional data lines

    parameter: frequency tuning word
*/
uint32_t ad9854_init( uint64_t ftw)
{
    uint8_t buffer[6];

    uint32_t config_value =  
        (AD9854_COMP_PDOWN  << 28) |
        (AD9854_QDAC_PDOWN  << 26) |
        (AD9854_DAC_PDOWN   << 25) |
        (AD9854_DIG_PDOWN   << 24) |
        (AD9854_PLL_200MHZ  << 22) |
        (AD9854_PLL_BYPASS  << 21) |
        (AD9854_SRC_QDAC    << 12) |
        (AD9854_REF_MUL     << 16) |
        (AD9854_MODE        <<  9) | 
        (AD9854_IO_CLK_OUT  <<  8) | 
        (AD9854_BYPASS_SINC <<  6) |
        (AD9854_OSK_ENABLE  <<  5) |
        (AD9854_OSK_INT     <<  4) |
        (AD9854_LSB_FIRST   <<  1) | 
        (AD9854_SDO_ACTIVE  <<  0);

    // spi config (max. 10 MHz SPI clk)
    spi_init();

    // master reset
    set_bit( gpio0->ioout, AD9854_MASTER_RES_PIN);
    // hold high for at least 10 system clk cycles
    clear_bit( gpio0->ioout, AD9854_MASTER_RES_PIN);
    
    
    // io reset
    set_bit(   gpio0->ioout, AD9854_IO_RESET_PIN);
    clear_bit( gpio0->ioout, AD9854_IO_RESET_PIN);


    // activate sdio 
    // write control register
    
    buffer[0] = (uint8_t) (config_value >> 24);
    buffer[1] = (uint8_t) (config_value >> 16);
    buffer[2] = (uint8_t) (config_value >>  8);
    buffer[3] = (uint8_t) (config_value >>  0);
    ad9854_reg_write( AD9854_CONTROL_REG, buffer);


    // io ud clk
//    set_bit(   gpio0->ioout, AD9854_IO_UD_CLK_PIN);
//    clear_bit( gpio0->ioout, AD9854_IO_UD_CLK_PIN);

    // set to single tone mode

    // avalible function in single tone mode:
    // phase adjust 1
    // shaped keying
    // phase offset or modulation
    // inverse sinc filter
    // frequency tuning word 1

    // set frequency
    buffer[0] = (uint8_t) (ftw >> 40);
    buffer[1] = (uint8_t) (ftw >> 32);
    buffer[2] = (uint8_t) (ftw >> 24);
    buffer[3] = (uint8_t) (ftw >> 16);
    buffer[4] = (uint8_t) (ftw >>  8);
    buffer[5] = (uint8_t) (ftw >>  0);
    ad9854_reg_write( AD9854_FREQUENCY_1_REG, buffer);

    // set I mul
    uint16_t mul = 2700; // 12 bit --> 0..4096
   
    buffer[0] = (uint8_t) (mul >> 8);
    buffer[1] = (uint8_t) (mul >> 0);
    ad9854_reg_write( AD9854_I_MULTIPLIER_REG, buffer);

    // set q mul
    buffer[0] = (uint8_t) (mul >> 8);
    buffer[1] = (uint8_t) (mul >> 0);
    ad9854_reg_write( AD9854_Q_MULTIPLIER_REG, buffer);

    // io ud clk
    set_bit(   gpio0->ioout, AD9854_IO_UD_CLK_PIN);
    clear_bit( gpio0->ioout, AD9854_IO_UD_CLK_PIN);
    
    return 0;
}


/*
    read value via SPI from AD9854 register

    args:
    reg    : register number to read
    buffer : destination
*/
uint8_t ad9854_reg_read( uint8_t reg, uint8_t *buffer)
{
    uint8_t index;

    // wait for space in fifo
    loop_until_bit_is_set( spi0->event, SPI_EVENT_NF);

    // send read register command
    spi_send( AD9854_READ | reg);

    // send zeros to generate enough clock impulses for reading
    for (index = 0; index < transfer_length[ reg]; index++)
    {
        spi_send( 0x00);
    }

    // ignore first value (= command)
    spi_receive();
    
    for (index = 0; index < transfer_length[ reg]; index++)
    {
        buffer[ index] = spi_receive();
    }

    return( transfer_length[ reg]);
}


/*
    write value via SPI to AD9854 register

    args:
    reg    : register number to write
    buffer : source data
*/
uint8_t ad9854_reg_write( uint8_t reg, uint8_t *buffer)
{
    uint8_t index;

    // wait for space in fifo
    loop_until_bit_is_set( spi0->event, SPI_EVENT_NF);

    // send write register command
    spi_send( (AD9854_WRITE | reg));

    // send data
    for (index = 0; index < transfer_length[ reg]; index++)
    {
        spi_send( buffer[ index]);
    }

    // do dummy reads to empty the fifo
    spi_receive();
    
    for (index = 0; index < transfer_length[ reg]; index++)
    {
        spi_receive();
    }

    return( transfer_length[ reg]);
}


/*
    print hex value from one register
*/
void print_reg_value( uint8_t reg)
{
    uint8_t buffer[6];
    uint8_t index;
    uint8_t length;

    length = ad9854_reg_read( reg, buffer);
    putstr( "0x");
    for (index = 0; index < length; index++)
    {
        puthex(8, buffer[ index] );
    }
    putchar('\n');
}


/*
    print some DDS register on screen
*/
uint32_t ad9854_info( void)
{
    
    // io reset
    set_bit(   gpio0->ioout, AD9854_IO_RESET_PIN);
    clear_bit( gpio0->ioout, AD9854_IO_RESET_PIN);

    // spi config (max. 10 MHz)
    spi_init();
   
    putstr("control    : "); print_reg_value( AD9854_CONTROL_REG);
    putstr("frequency  : "); print_reg_value( AD9854_FREQUENCY_1_REG);
    putstr("update clk : "); print_reg_value( AD9854_UPDATE_CLOCK_REG);
    putstr("ramp rate  : "); print_reg_value( AD9854_RAMP_RATE_REG);
    putstr("I mult reg : "); print_reg_value( AD9854_I_MULTIPLIER_REG);
    putstr("Q mult reg : "); print_reg_value( AD9854_Q_MULTIPLIER_REG);

    return (0);
}

