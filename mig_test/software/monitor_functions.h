/*
 * $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/hw_sp605/bsp_zpuahb/software/monitor_functions.h $
 * $Date$
 * $Author$
 * $Revision$
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
