/*
 * $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/hardware/board_sp601/rtl/teilerregister.vhd $
 * $Date: 2010-10-29 15:57:42 +0200 (Fr, 29 Okt 2010) $
 * $Author: lange $
 * $Revision: 659 $
 */

#ifndef RENA_H
#define RENA_H

#include <types.h>

#define RENA_FM     (1 <<  0)
#define RENA_ENS    (1 <<  1)
#define RENA_ENF    (1 <<  2)
#define RENA_POLPOS (1 << 11) 

typedef struct {
    volatile uint32_t control_status;        // 0x00
    volatile uint32_t rena_status;           // 0x04
    volatile uint32_t config_low;            // 0x08
    volatile uint32_t config_high;           // 0x0C
    volatile uint32_t acquire_time;          // 0x10
    volatile uint32_t channel_and_mask_low;  // 0x14
    volatile uint32_t channel_and_mask_high; // 0x18
    volatile uint32_t token_count;           // 0x1c
//  volatile uint32_t channel_or_mask_low;   // 0x1c
//  volatile uint32_t channel_or_mask_high;  // 0x20
} rena_t;


extern rena_t *rena; // 0x80000d00;

// low level functions
uint32_t rena_channel_config(uint8_t channel, uint8_t high_config, uint32_t low_config);


// monitor functions
uint32_t rena_controller_status( void);
uint32_t rena_status( void);
uint32_t rena_channel_config_function( void);
uint32_t rena_read_token( void);

#endif // RENA_H
