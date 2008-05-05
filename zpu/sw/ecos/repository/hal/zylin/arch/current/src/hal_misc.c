/*==========================================================================
//
//      hal_misc.c
//
//      HAL miscellaneous functions
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
// Author(s):    nickg, gthomas
// Contributors: nickg, gthomas
// Date:         1999-02-20
// Purpose:      HAL miscellaneous functions
// Description:  This file contains miscellaneous functions provided by the
//               HAL.
//
//####DESCRIPTIONEND####
//
//=========================================================================*/

#include <pkgconf/hal.h>
#include <pkgconf/hal_zylin.h>
#ifdef CYGPKG_KERNEL
#include <pkgconf/kernel.h>
#endif
#ifdef CYGPKG_CYGMON
#include <pkgconf/cygmon.h>
#endif

#include <cyg/infra/cyg_type.h>
#include <cyg/infra/cyg_trac.h>         // tracing macros
#include <cyg/infra/cyg_ass.h>          // assertion macros

#include <cyg/hal/hal_arch.h>           // HAL header
#include <cyg/hal/hal_intr.h>           // HAL header

#include <cyg/hal/var_io.h>
#include <cyg/hal/hal_io.h>

externC void diag_printf(const char *fmt, ...);

/*------------------------------------------------------------------------*/
/* First level C exception handler.                                       */


/*------------------------------------------------------------------------*/
/* C++ support - run initial constructors                                 */

#ifdef CYGSEM_HAL_STOP_CONSTRUCTORS_ON_FLAG
cyg_bool cyg_hal_stop_constructors;
#endif

typedef void (*pfunc) (void);
extern pfunc __CTOR_LIST__[];
extern pfunc __CTOR_END__[];

void
cyg_hal_invoke_constructors (void)
{
#ifdef CYGSEM_HAL_STOP_CONSTRUCTORS_ON_FLAG
    static pfunc *p = &__CTOR_END__[-1];
    
    cyg_hal_stop_constructors = 0;
    for (; p >= __CTOR_LIST__; p--) {
        (*p) ();
        if (cyg_hal_stop_constructors) {
            p--;
            break;
        }
    }
#else
    pfunc *p;

    for (p = &__CTOR_END__[-1]; p >= __CTOR_LIST__; p--)
        (*p) ();
#endif
}


/*-------------------------------------------------------------------------*/
/* Misc functions                                                          */

int
hal_lsbindex(int mask)
{
    int i;
    for (i = 0;  i < 32;  i++) {
      if (mask & (1<<i)) return (i);
    }
    return (-1);
}

int
hal_msbindex(int mask)
{
    int i;
    for (i = 31;  i >= 0;  i--) {
      if (mask & (1<<i)) return (i);
    }
    return (-1);
}

/*------------------------------------------------------------------------*/
/* Architecture default ISR                                               */

externC cyg_uint32
hal_arch_default_isr(CYG_ADDRWORD vector, CYG_ADDRWORD data)
{
    CYG_TRACE1(true, "Interrupt: %d", vector);

    CYG_FAIL("Spurious Interrupt!!!");
    return 0;
}

extern volatile int *INTERRUPT_MASK;

cyg_uint32 zpu_disable_interrupts()
{
	/* NOTE! We disable interrupts before flipping the cached state */
	cyg_uint32 t=*INTERRUPT_MASK;
	*INTERRUPT_MASK=1;
	return t;
}

void zpu_enable_interrupts()
{
	*INTERRUPT_MASK=0;
}

void zpu_restore_interrupts(cyg_uint32 t)
{
	if (t==0)
		zpu_enable_interrupts();
	else
		zpu_disable_interrupts();
}

externC cyg_uint32 zpu_query_interrupts()
{
	return *INTERRUPT_MASK;
}

/*------------------------------------------------------------------------*/
// EOF hal_misc.c
