//==========================================================================
//
//     
//
//      Ethernet device driver for Opencore's ethermac on Zylin Phi
//
//==========================================================================
//####ECOSGPLCOPYRIGHTBEGIN####
// -------------------------------------------
// This file is part of eCos, the Embedded Configurable Operating System.
// Copyright (C) 1998, 1999, 2000, 2001, 2002 Red Hat, Inc.
//
// eCos is free software; you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation; either version 2 or (at your option) any later version.
//
// eCos is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for more details.
//
// You should have received a copy of the GNU General Public License along
// with eCos; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
//
// As a special exception, if other files instantiate templates or use macros
// or inline functions from this file, or you compile this file and link it
// with other works to produce a work based on this file, this file does not
// by itself cause the resulting work to be covered by the GNU General Public
// License. However the source code for this file must still be made available
// in accordance with section (3) of the GNU General Public License.
//
// This exception does not invalidate any other reasons why a work based on
// this file might be covered by the GNU General Public License.
//
// Alternative licenses for eCos may be arranged by contacting Red Hat, Inc.
// at http://sources.redhat.com/ecos/ecos-license/
// -------------------------------------------
//####ECOSGPLCOPYRIGHTEND####
//####BSDCOPYRIGHTBEGIN####
//
// -------------------------------------------
//
// Portions of this software may have been derived from OpenBSD or other sources,
// and are covered by the appropriate copyright disclaimers included herein.
//
// -------------------------------------------
//
//####BSDCOPYRIGHTEND####
//==========================================================================
//#####DESCRIPTIONBEGIN####
//
// Author(s):      Gaisler Research, (Konrad Eisele<eiselekd@web.de>)
// Contributors: 
// Date:         2005-01-20
// Purpose:      
// Description:  hardware driver for Opencores ethernet
//              
//
//####DESCRIPTIONEND####
//
//==========================================================================

#include <pkgconf/system.h>
#ifdef CYGPKG_IO_ETH_DRIVERS
#include <pkgconf/io_eth_drivers.h>
#endif
#include <pkgconf/devs_eth_opencores_ethermac.h>


#include <cyg/infra/cyg_type.h>
#include <cyg/hal/hal_arch.h>
#include <cyg/hal/hal_intr.h>
#include <cyg/hal/hal_diag.h>
#include <cyg/hal/hal_cache.h>
#include <cyg/infra/cyg_ass.h>
#include <cyg/infra/diag.h>
#include <cyg/hal/drv_api.h>
#include <cyg/io/eth/netdev.h>
#include <cyg/io/eth/eth_drv.h>

#ifdef CYGPKG_NET
#include <pkgconf/net.h>
#include <cyg/kernel/kapi.h>
#include <net/if.h>  /* Needed for struct ifnet */
#endif

#include <cyg/hal/hal_arch.h>
#include <cyg/hal/hal_intr.h>
//#include <cyg/hal/hal_leon3.h>

externC void openeth_device_init(struct eth_drv_sc *sc, cyg_uint32 idx, cyg_uint32 base, cyg_uint32 irq);
 
bool openeth_phi_init(struct cyg_netdevtab_entry *ndp)
{
  struct eth_drv_sc *sc = (struct eth_drv_sc *)(ndp->device_instance);

#if !defined(CYGPKG_DEVS_ETH_OPENCORES_ETHERMAC_FLUSH)
#error "CYGPKG_DEVS_ETH_OPENCORES_ETHERMAC_FLUSH must be 1 for Zylin Phi"
#endif

#if 0  
  int  i,j;
  amba_ahb_device adev[CYGNUM_DEVS_ETH_OPENCORES_ETHERMAC_DEV_COUNT];
  j = amba_get_free_ahbslv_devices (VENDOR_GAISLER, GAISLER_ETHAHB, adev, CYGNUM_DEVS_ETH_OPENCORES_ETHERMAC_DEV_COUNT);
  for (i = 0;i < j;i++) {
    openeth_device_init(sc,i,adev[i].start[0],adev[i].irq);
  }
#endif
	openeth_device_init(sc, 0, 0x080C0000, CYGNUM_HAL_INTERRUPT_ETHERMAC);
	return 1;
}
