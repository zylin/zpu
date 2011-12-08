
/*
 * $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/hardware/board_sp601/rtl/teilerregister.vhd $
 * $Date: 2010-10-29 15:57:42 +0200 (Fr, 29 Okt 2010) $
 * $Author: lange $
 * $Revision: 659 $
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
