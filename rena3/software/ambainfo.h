/*
 * $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/software/test/ambainfo.h $
 * $Date: 2011-05-25 15:27:07 +0200 (Mi, 25 Mai 2011) $
 * $Author: lange $
 * $Revision: 1036 $
 */

#ifndef AMBAINFO_H
#define AMBAINFO_H

void print_vendor_device( uint8_t vendor, uint8_t device);
void apb_info( uint32_t* addr, uint8_t verbose);
void ahb_info( uint8_t verbose);

#endif // AMBAINFO_H
