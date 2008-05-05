//==========================================================================
//
//      
//
//      Opencores ethermac I/O definitions.
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
//==========================================================================
//#####DESCRIPTIONBEGIN####
//
// Author(s):      Gaisler Research, (Konrad Eisele<eiselekd@web.de>)
// Contributors:   
// Date:           2000-11-22
//####DESCRIPTIONEND####
//==========================================================================

#include <pkgconf/system.h>
#include <cyg/hal/hal_intr.h>          

#define CYGPKG_DEVS_ETH_OPENCORES_ETHERMAC_ETH0_ESA CYGPKG_DEVS_ETH_ZPU_OPENCORES_PHI_ETH0_ESA
#define CYGPKG_DEVS_ETH_OPENCORES_ETHERMAC_INITFN openeth_phi_init

#ifdef CYGPKG_DEVS_ETH_ZPU_OPENCORES_PHI_ETH0

//structs and tables for eth0
static oeth_info openeth_priv;
ETH_DRV_SC(oeth_sc,
           &openeth_priv,          // Driver specific data
		   CYGPKG_DEVS_ETH_ZPU_OPENCORES_PHI_ETH0_NAME, // Name for device
           openeth_start,
           openeth_stop,
           openeth_ioctl,
           openeth_can_send,
           openeth_send,
           openeth_recv,
           openeth_deliver,
           openeth_poll,
           openeth_int_vector
);

NETDEVTAB_ENTRY(oeth_netdev, 
                "openeth_" CYGPKG_DEVS_ETH_ZPU_OPENCORES_PHI_ETH0_NAME,
                openeth_init,
                &oeth_sc);
#endif

#if CYGNUM_DEVS_ETH_OPENCORES_ETHERMAC_DEV_COUNT > 1
#error Only 1 ethermac at a time supported yet (eth0) 
#endif

oeth_info *openeth_priv_array[CYGNUM_DEVS_ETH_OPENCORES_ETHERMAC_DEV_COUNT] = {
#ifdef CYGPKG_DEVS_ETH_ZPU_OPENCORES_PHI_ETH0
          &openeth_priv
#endif          
};

       
//EOF devs_eth_zpu_opencorec_phi.inl


