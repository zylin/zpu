/*
 * $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/hardware/board_sp601/rtl/teilerregister.vhd $
 * $Date: 2010-10-29 15:57:42 +0200 (Fr, 29 Okt 2010) $
 * $Author: lange $
 * $Revision: 659 $
 */

#ifndef RENA_H
#define RENA_H

#include <types.h>


typedef struct {
    volatile uint32_t control_status;   // 0x00
    volatile uint32_t rena_status;      // 0x04
    volatile uint32_t config_low;       // 0x08
    volatile uint32_t config_high;      // 0x0C
    volatile uint32_t acquire_time;     // 0x10
} rena_t;


extern rena_t *rena; // 0x80000d00;

// low level functions
uint32_t rena_channel_config(uint8_t channel, uint8_t high_config, uint32_t low_config);


// monitor functions
uint32_t rena_controller_status( void);
uint32_t rena_status( void);
uint32_t rena_channel_config_function( void);

#endif // RENA_H
