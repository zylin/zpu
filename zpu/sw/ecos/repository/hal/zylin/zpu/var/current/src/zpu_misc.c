/*==========================================================================
//
//      zpu_misc.c
//
//      HAL misc board support code for Zylin ZPU
//
//==========================================================================
//####ECOSGPLCOPYRIGHTBEGIN####
// -------------------------------------------
// This file is part of eCos, the Embedded Configurable Operating System.
// Copyright (C) 1998, 1999, 2000, 2001, 2002 Red Hat, Inc.
// Copyright (C) 2003 Nick Garnett <nickg@calivar.com>
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
// Author(s):    gthomas
// Contributors: gthomas, jskov, nickg, tkoeller
// Date:         2001-07-12
// Purpose:      HAL board support
// Description:  Implementations of HAL board interfaces
//
//####DESCRIPTIONEND####
//
//========================================================================*/

#include <pkgconf/hal.h>

#include <cyg/infra/cyg_type.h>         // base types
#include <cyg/infra/cyg_trac.h>         // tracing macros
#include <cyg/infra/cyg_ass.h>          // assertion macros

#include <cyg/hal/hal_io.h>             // IO macros
#include <cyg/hal/hal_arch.h>           // Register state info
#include <cyg/hal/hal_diag.h>
#ifdef CYGDBG_HAL_DEBUG_GDB_BREAK_SUPPORT
#include <cyg/hal/drv_api.h>            // HAL ISR support
#endif
#include <cyg/hal/hal_intr.h>           // necessary?

#include <cyg/hal/hal_cache.h>
#include <cyg/hal/hal_if.h>             // calling interface
#include <cyg/hal/hal_misc.h>           // helper functions
#include <cyg/hal/var_io.h>             // platform registers





// -------------------------------------------------------------------------
// Clock support

static cyg_uint32 _period;


void hal_clock_initialize(cyg_uint32 period)
{
	_period=period;
	*TIMER_PERIOD=period;
	*TIMER_INTERRUPT=0x2; // reset counter
}

void hal_clock_reset(cyg_uint32 vector, cyg_uint32 period)
{
	/* the next interrupt will happen without further action */
}


long long  _readCycles();

void hal_clock_read(cyg_uint32 *pvalue)
{
	*pvalue=_period-1-*TIMER_COUNTER;
}

// -------------------------------------------------------------------------
//
void hal_delay_us(cyg_int32 usecs)
{
	long long until=_readCycles();
	until+=((long long)usecs*(long long)(CYGNUM_HAL_ZYLIN_ZPU_CLOCK_SPEED))/(long long)1000000;
	
	/* waiting for the moment to pass.... */		
	for (;;)
	{
		if (_readCycles()>until)
		{
			break;
		}
	}
}

// -------------------------------------------------------------------------
// Hardware init

void hal_hardware_init(void)
{
	int i;
	for (i=0; i<CYGNUM_HAL_ISR_COUNT; i++)
	{
		hal_interrupt_handlers[i]=(CYG_ADDRESS)hal_default_isr;
	}
}

// -------------------------------------------------------------------------
// This routine is called to respond to a hardware interrupt (IRQ).  It
// should interrogate the hardware and return the IRQ vector number.

int hal_IRQ_handler(void)
{
	// for now we only have this type of interrupt
	if ((*TIMER_INTERRUPT&0x1)!=0)
	{
		return CYGNUM_HAL_INTERRUPT_TIMER;
	} else if ((*UART_INTERRUPT&0x1)!=0)
	{
		return CYGNUM_HAL_INTERRUPT_UART;
	}
#ifdef CYGPKG_IO_ETH_DRIVERS
	else if (ethermac_interrupt())
	{
		return CYGNUM_HAL_INTERRUPT_ETHERMAC;
	} 
#endif
	else
	{
		return CYGNUM_HAL_INTERRUPT_NONE;
	}
}

// -------------------------------------------------------------------------
// Interrupt control
//

void hal_interrupt_mask(int vector)
{
    CYG_ASSERT(vector <= CYGNUM_HAL_ISR_MAX &&
               vector >= CYGNUM_HAL_ISR_MIN , "Invalid vector");

	if (vector==CYGNUM_HAL_INTERRUPT_TIMER)
	{
		*TIMER_ENABLE=0;
	} else if (vector==CYGNUM_HAL_INTERRUPT_UART)
	{
		*UART_ENABLE=0;
	} 
#ifdef CYGPKG_IO_ETH_DRIVERS
	else if (vector==CYGNUM_HAL_INTERRUPT_ETHERMAC)
	{
		ethermac_enable(0);
	}
#endif
}

void hal_interrupt_unmask(int vector)
{
    CYG_ASSERT(vector <= CYGNUM_HAL_ISR_MAX &&
               vector >= CYGNUM_HAL_ISR_MIN , "Invalid vector");
	if (vector==CYGNUM_HAL_INTERRUPT_TIMER)
	{
		*TIMER_ENABLE=1;
	} else if (vector==CYGNUM_HAL_INTERRUPT_UART)
	{
		*UART_ENABLE=1;
	} 
#ifdef CYGPKG_IO_ETH_DRIVERS
	else if (vector==CYGNUM_HAL_INTERRUPT_ETHERMAC)
	{
		ethermac_enable(1);
	}
#endif
	
}

void hal_interrupt_acknowledge(int vector)
{
	if (vector==CYGNUM_HAL_INTERRUPT_TIMER)
	{
		*TIMER_INTERRUPT=0x1;
	} else if (vector==CYGNUM_HAL_INTERRUPT_UART)
	{
		*UART_INTERRUPT=0x1;
	} 
#ifdef CYGPKG_IO_ETH_DRIVERS
	else if (vector==CYGNUM_HAL_INTERRUPT_ETHERMAC)
	{
		ethermac_ack();
	}
#endif	
	
}

void hal_interrupt_configure(int vector, int level, int up)
{
    CYG_ASSERT(vector <= CYGNUM_HAL_ISR_MAX &&
               vector >= CYGNUM_HAL_ISR_MIN , "Invalid vector");
}

void hal_interrupt_set_level(int vector, int level)
{
    CYG_ASSERT(vector <= CYGNUM_HAL_ISR_MAX &&
               vector >= CYGNUM_HAL_ISR_MIN , "Invalid vector");
    CYG_ASSERT(level >= 0 && level <= 7, "Invalid level");

}

void hal_show_IRQ(int vector, int data, int handler)
{
}


/* Use the watchdog to generate a reset */
void hal_zpu_reset_cpu(void)
{
}

/* nothing to do by default */
cyg_uint32
hal_default_isr(cyg_uint32 vector, CYG_ADDRWORD data)
{
	return 0;
}

//--------------------------------------------------------------------------
// EOF zpu_misc.c
