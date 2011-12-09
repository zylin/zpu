/*
 * $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/hardware/board_sp601/rtl/teilerregister.vhd $
 * $Date: 2010-10-29 15:57:42 +0200 (Fr, 29 Okt 2010) $
 * $Author: lange $
 * $Revision: 659 $
 */

#ifndef AD9854_FUNCTIONS_H
#define AD9854_FUNCTIONS_H

#include <types.h>
#include "spi.h"

#define AD9854_MASTER_RES_PIN  (1<<15)
#define AD9854_IO_RESET_PIN    (1<<14)
#define AD9854_IO_UD_CLK_PIN   (1<<13)

uint32_t ad9854_init( void);
uint32_t ad9854_info( void);
uint8_t  ad9854_reg_write( uint8_t reg, uint8_t *buffer);
uint8_t  ad9854_reg_read( uint8_t reg, uint8_t *buffer);

#define AD9854_READ                 (0x80)
#define AD9854_WRITE                (0x00)

#define AD9854_PHASE_1_REG          (0x0)
#define AD9854_PHASE_2_REG          (0x1)
#define AD9854_FREQUENCY_1_REG      (0x2)
#define AD9854_FREQUENCY_2_REG      (0x3)
#define AD9854_DELTA_FREQUENCY_REG  (0x4)
#define AD9854_UPDATE_CLOCK_REG     (0x5)
#define AD9854_RAMP_RATE_REG        (0x6)
#define AD9854_CONTROL_REG          (0x7)
#define AD9854_I_MULTIPLIER_REG     (0x8)
#define AD9854_Q_MULTIPLIER_REG     (0x9)
#define AD9854_SHAPE_RAMP_REG       (0xA)
#define AD9854_Q_DAC_REG            (0xB)


#define MODE_SINGLE_TONE    (0x0)
#define MODE_FSK            (0x1)
#define MODE_RAMPED_FSK     (0x2)
#define MODE_CHIRP          (0x3)
#define MODE_BPSK           (0x4)


#define AD9854_COMP_PDOWN  (1)
#define AD9854_QDAC_PDOWN  (0)
#define AD9854_DAC_PDOWN   (0)
#define AD9854_DIG_PDOWN   (0)
#define AD9854_PLL_200MHZ  (0)
#define AD9854_PLL_BYPASS  (0)
#define AD9854_REF_MUL     (5)
#define AD9854_SRC_QDAC    (0)
#define AD9854_MODE        (MODE_SINGLE_TONE)
#define AD9854_IO_CLK_OUT  (0)
#define AD9854_BYPASS_SINC (0)
#define AD9854_OSK_ENABLE  (1)
#define AD9854_OSK_INT     (0)
#define AD9854_LSB_FIRST   (0)
#define AD9854_SDO_ACTIVE  (1)

#if AD9854_PLL_BYPASS == 0
#define AD9854_CLOCK  (AD9854_REF_MUL * 10000000ULL)
#else
#define AD9854_CLOCK  (10000000ULL)
#endif

#define OUTPUT_FREQUENCY    (5000000ULL)

// generate WRONG result:
//#define FTW                 (uint64_t)((OUTPUT_FREQUENCY * 281474976710656ULL) / AD9854_CLOCK)
// acceptable result:
#define FTW                 (uint64_t)(OUTPUT_FREQUENCY * (281474976710656ULL / AD9854_CLOCK))

#endif // AD9854_FUNCTIONS_H
