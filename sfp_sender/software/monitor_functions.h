/*
 * $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/software/test/monitor_functions.h $
 * $Date: 2011-08-25 13:50:17 +0200 (Do, 25. Aug 2011) $
 * $Author: lange $
 * $Revision: 1211 $
 */

#ifndef MONITOR_FUNCTIONS_H
#define MONITOR_FUNCTIONS_H

extern volatile uint8_t running_direction;


uint32_t quit_function( void);
uint32_t x_function( void);
uint32_t wmem_function( void);
uint32_t clear_function( void);

uint32_t reset_function( void);

uint32_t system_info_function( void);

#endif // MONITOR_FUNCTIONS_H
