#ifndef CYGONCE_HAL_ARCH_H
#define CYGONCE_HAL_ARCH_H

//==========================================================================
//
//      hal_arch.h
//
//      Architecture specific abstractions
//
//==========================================================================
//####ECOSGPLCOPYRIGHTBEGIN####
// -------------------------------------------
// This file is part of eCos, the Embedded Configurable Operating System.
// Copyright (C) 1998, 1999, 2000, 2001, 2002, 2003 Red Hat, Inc.
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
// Purpose:      Define architecture abstractions
// Usage:        #include <cyg/hal/hal_arch.h>

//              
//####DESCRIPTIONEND####
//
//==========================================================================

#include <pkgconf/hal.h>         // To decide on stack usage
#include <cyg/infra/cyg_type.h>
#include <cyg/hal/plf_io.h>
#ifdef CYGBLD_HAL_ZYLIN_PLF_ARCH_H
#include <cyg/hal/plf_arch.h>
#endif

#ifdef CYGBLD_HAL_ZYLIN_VAR_ARCH_H
#include <cyg/hal/var_arch.h>
#endif


// It seems that r0-r3,r12 are considered scratch by function calls

typedef struct 
{
    cyg_uint32 reg[8];
    cyg_uint32  interrupt;
    cyg_uint32  pc;	// must be last...
} HAL_SavedRegisters;

//-------------------------------------------------------------------------
// Exception handling function.
// This function is defined by the kernel according to this prototype. It is
// invoked from the HAL to deal with any CPU exceptions that the HAL does
// not want to deal with itself. It usually invokes the kernel's exception
// delivery mechanism.

externC void cyg_hal_deliver_exception( CYG_WORD code, CYG_ADDRWORD data );

//-------------------------------------------------------------------------
// Bit manipulation macros

externC int hal_lsbindex(int);
externC int hal_msbindex(int);

#define HAL_LSBIT_INDEX(index, mask) index = hal_lsbindex(mask)
#define HAL_MSBIT_INDEX(index, mask) index = hal_msbindex(mask)

//-------------------------------------------------------------------------
// Context Initialization
// Initialize the context of a thread.
// Arguments:
// _sparg_ name of variable containing current sp, will be changed to new sp
// _thread_ thread object address, passed as argument to entry point
// _entry_ entry point address.
// _id_ bit pattern used in initializing registers, for debugging.

#define HAL_THREAD_INIT_CONTEXT( _sparg_, _thread_, _entry_, _id_ ) \
    CYG_MACRO_START                                                         \
    cyg_uint32 *_sp_=(cyg_uint32 *)(((CYG_WORD)_sparg_) &~3); 				\
    *--_sp_=(CYG_ADDRWORD)_thread_;											\
    *--_sp_=(CYG_ADDRWORD)0xffffffff; /* dummy return address */				\
    *--_sp_=(cyg_uint32)(_entry_);     /* PC = [initial] entry point */ \
    *--_sp_= 0; /* interrupt mask */  \
    *--_sp_= (_id_)|7;      \
    *--_sp_= (_id_)|6;      \
    *--_sp_= (_id_)|5;      \
    *--_sp_= (_id_)|4;      \
    *--_sp_= (_id_)|3;      \
    *--_sp_= (_id_)|2;      \
    *--_sp_= (_id_)|1;      \
    *--_sp_=(_id_)|0;      \
    _sparg_ = (CYG_ADDRWORD)_sp_;                                          \
    CYG_MACRO_END

//--------------------------------------------------------------------------
// Context switch macros.
// The arguments are pointers to locations where the stack pointer
// of the current thread is to be stored, and from where the sp of the
// next thread is to be fetched.

externC void hal_thread_switch_context( CYG_ADDRESS to, CYG_ADDRESS from );
externC void hal_thread_load_context( CYG_ADDRESS to )
    __attribute__ ((noreturn));

#define HAL_THREAD_SWITCH_CONTEXT(_fspptr_,_tspptr_)                    \
        hal_thread_switch_context((CYG_ADDRESS)_tspptr_,                \
                                  (CYG_ADDRESS)_fspptr_);

#define HAL_THREAD_LOAD_CONTEXT(_tspptr_)                               \
        hal_thread_load_context( (CYG_ADDRESS)_tspptr_ );

//--------------------------------------------------------------------------
// Execution reorder barrier.
// When optimizing the compiler can reorder code. In multithreaded systems
// where the order of actions is vital, this can sometimes cause problems.
// This macro may be inserted into places where reordering should not happen.

#define HAL_REORDER_BARRIER() asm volatile ( "" : : : "memory" )

//--------------------------------------------------------------------------
// Breakpoint support
// HAL_BREAKPOINT() is a code sequence that will cause a breakpoint to happen
// if executed.
// HAL_BREAKINST is the value of the breakpoint instruction and 
// HAL_BREAKINST_SIZE is its size in bytes.

#define _stringify1(__arg) #__arg
#define _stringify(__arg) _stringify1(__arg)

#define HAL_BREAKINST_ZYLIN          0
#define HAL_BREAKINST_ZYLIN_SIZE     1


#define HAL_BREAKPOINT(_label_)                   \
asm volatile (" .globl  " #_label_ ";"            \
              #_label_":"                         \
              " .byte " _stringify(HAL_BREAKINST_ZYLIN) \
    );

//#define HAL_BREAKINST           {0xFE, 0xDE, 0xFF, 0xE7}
#define HAL_BREAKINST            HAL_BREAKINST_ZYLIN
#define HAL_BREAKINST_SIZE       HAL_BREAKINST_ZYLIN_SIZE
#define HAL_BREAKINST_TYPE       cyg_uint8

extern cyg_uint32 __zylin_breakinst;
#define HAL_BREAKINST_ADDR(x) (void*)&__zylin_breakinst)


// Translate a stack pointer as saved by the thread context macros above into
// a pointer to a HAL_SavedRegisters structure.
#define HAL_THREAD_GET_SAVED_REGISTERS( _sp_, _regs_ )  \
        (_regs_) = (HAL_SavedRegisters *)(_sp_)



//--------------------------------------------------------------------------
// HAL setjmp

#define CYGARC_JMP_BUF_SIZE 16  // Actually 11, but some room left over

typedef cyg_uint32 hal_jmp_buf[CYGARC_JMP_BUF_SIZE];

externC int hal_setjmp(hal_jmp_buf env);
externC void hal_longjmp(hal_jmp_buf env, int val);


//--------------------------------------------------------------------------
// Idle thread code.
// This macro is called in the idle thread loop, and gives the HAL the
// chance to insert code. Typical idle thread behaviour might be to halt the
// processor. Here we only supply a default fallback if the variant/platform
// doesn't define anything.

#ifndef HAL_IDLE_THREAD_ACTION
#define HAL_IDLE_THREAD_ACTION(_count_) CYG_EMPTY_STATEMENT
#endif

//---------------------------------------------------------------------------

// Minimal and sensible stack sizes: the intention is that applications
// will use these to provide a stack size in the first instance prior to
// proper analysis.  Idle thread stack should be this big.

//    THESE ARE NOT INTENDED TO BE MICROMETRICALLY ACCURATE FIGURES.
//           THEY ARE HOWEVER ENOUGH TO START PROGRAMMING.
// YOU MUST MAKE YOUR STACKS LARGER IF YOU HAVE LARGE "AUTO" VARIABLES!

// This is not a config option because it should not be adjusted except
// under "enough rope" sort of disclaimers.

// A minimal, optimized stack frame, rounded up - no autos
#define CYGNUM_HAL_STACK_FRAME_SIZE (4 * 80)

// Stack needed for a context switch: this is implicit in the estimate for
// interrupts so not explicitly used below:
#define CYGNUM_HAL_STACK_CONTEXT_SIZE (4 * 80)

// Interrupt + call to ISR, interrupt_end() and the DSR
#define CYGNUM_HAL_STACK_INTERRUPT_SIZE \
    ((4 * 80) + 2 * CYGNUM_HAL_STACK_FRAME_SIZE)

// Space for the maximum number of nested interrupts, plus room to call functions
#define CYGNUM_HAL_MAX_INTERRUPT_NESTING 16

#if 0
#define CYGNUM_HAL_STACK_SIZE_MINIMUM 
        (CYGNUM_HAL_MAX_INTERRUPT_NESTING * CYGNUM_HAL_STACK_INTERRUPT_SIZE + \
         2 * CYGNUM_HAL_STACK_FRAME_SIZE)

#define CYGNUM_HAL_STACK_SIZE_TYPICAL \
        (CYGNUM_HAL_STACK_SIZE_MINIMUM + \
         16 * CYGNUM_HAL_STACK_FRAME_SIZE)
#else
#define CYGNUM_HAL_STACK_SIZE_MINIMUM 16384 // KLUDGE!!! until interrupt stacks can be added

#define CYGNUM_HAL_STACK_SIZE_TYPICAL 32768 // KLUDGE!!! until interrupt stacks can be added

#endif

//--------------------------------------------------------------------------
// Macros for switching context between two eCos instances (jump from
// code in ROM to code in RAM or vice versa).
#define CYGARC_HAL_SAVE_GP()
#define CYGARC_HAL_RESTORE_GP()

#endif // CYGONCE_HAL_ARCH_H
// End of hal_arch.h
