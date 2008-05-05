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
#include <string.h>
#include <cyg/hal/hal_arch.h>           // Register state info

extern char __bss_start[];
extern char __bss_end[];

externC void cyg_hal_invoke_constructors (void);
externC void cyg_start (void);
externC void hal_hardware_init (void);
externC void _initIO();

void _premain(void)
{
    // clear BSS
	memset(__bss_start, 0, __bss_end-__bss_start);
	
	_initIO();

	hal_hardware_init();	
	
    cyg_hal_invoke_constructors();

	cyg_start();
	
	__asm("breakpoint"); // stop debugger/sim here for now
//	for (;;); // hang forever
}

CYG_ADDRWORD hal_vsr_table[CYGNUM_HAL_VSR_COUNT];
CYG_ADDRWORD hal_interrupt_handlers[CYGNUM_HAL_ISR_COUNT];
CYG_ADDRWORD hal_interrupt_data[CYGNUM_HAL_ISR_COUNT];
CYG_ADDRWORD hal_interrupt_objects[CYGNUM_HAL_ISR_COUNT];

externC cyg_ucount32 cyg_scheduler_sched_lock;
externC cyg_uint32 hal_IRQ_handler();

externC void interrupt_end(
    cyg_uint32          isr_ret,
    CYG_ADDRWORD       intr,
    HAL_SavedRegisters  *ctx
    );


#ifndef CYGIMP_HAL_COMMON_INTERRUPTS_USE_INTERRUPT_STACK


void _zpu_interrupt(void)
{
	cyg_uint32 source;
#ifdef CYGFUN_HAL_COMMON_KERNEL_SUPPORT                 
	cyg_scheduler_sched_lock++;
#endif
	/* we don't support reentrant interrupts, so we disable interrupts here. */
	cyg_uint32 t;
	HAL_DISABLE_INTERRUPTS(t);

	source=hal_IRQ_handler();
 	if (source!=CYGNUM_HAL_INTERRUPT_NONE)
 	{

 		cyg_uint32 result;

 		result=((cyg_uint32 (*)(cyg_uint32, CYG_ADDRWORD))hal_interrupt_handlers[source])(source, hal_interrupt_data[source]);
 	 	/* restore interrupts again. */
 		HAL_ENABLE_INTERRUPTS();
 		/* Interrupts must be enabled here as the scheduler is invoked here. */
 		interrupt_end(result, hal_interrupt_objects[source], NULL);
 	} else
 	{
 	 	/* restore interrupts again. */
 		HAL_ENABLE_INTERRUPTS();
 	}
}
#else
/* low-level interrupt handling routine */
cyg_uint32 _zpu_interrupt_stack(cyg_uint32 source)
{
#ifdef CYGFUN_HAL_COMMON_KERNEL_SUPPORT                 
	cyg_scheduler_sched_lock++;
#endif
	/* we don't support reentrant interrupts, so we disable interrupts here. */
	cyg_uint32 t;
	HAL_DISABLE_INTERRUPTS(t);
	
	cyg_uint32 result=0;
 	if (source!=CYGNUM_HAL_INTERRUPT_NONE)
 	{
 		cyg_uint32 result;
 		result=((cyg_uint32 (*)(cyg_uint32, CYG_ADDRWORD))hal_interrupt_handlers[source])(source, hal_interrupt_data[source]);
 	}
 	return result;
}
void _zpu_interrupt_thread(cyg_uint32 source, cyg_uint32 result)
{
 	if (source!=CYGNUM_HAL_INTERRUPT_NONE)
 	{
 		/* Interrupts must be enabled here as the scheduler is invoked here. */
 		interrupt_end(result, hal_interrupt_objects[source], NULL);
 	}
}
#endif
