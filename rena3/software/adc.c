
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

    set_bit( gpio0->ioout, CLK_ADC_PIN);
    value = (gpio0->iodata >> 16) & 0x7FFF;
    clear_bit( gpio0->ioout, CLK_ADC_PIN);
    return( value);
}
