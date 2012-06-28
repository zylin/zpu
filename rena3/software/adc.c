
/*
 * $Date$
 * $Author$
 * $Revision$
 */

#include "peripherie.h"
#include "adc.h"

uint32_t adc_read( void)
{
    uint32_t value;
    uint32_t data;

    set_bit( gpio0->ioout, CLK_ADC_PIN);
    data = gpio0->iodata;
    // extract overflow bit
    value = (data >> 16);// & 0x7FFF) | ((data & 0x8000) << 16);
    clear_bit( gpio0->ioout, CLK_ADC_PIN);
    return( value);
}
