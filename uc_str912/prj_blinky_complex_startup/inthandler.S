# Hitex/We/26.04.2006
# primary interrupt service

# Standard definitions of Mode bits and Interrupt (I & F) flags in PSRs

    .equ    Mode_USR,   0x10
    .equ    Mode_FIQ,   0x11
    .equ    Mode_IRQ,   0x12
    .equ    Mode_SVC,   0x13
    .equ    Mode_ABT,   0x17
    .equ    Mode_UND,   0x1B
    .equ    Mode_SYS,   0x1F

    .equ    I_BIT, 0x80        /* when I bit is set, IRQ is disabled */
    .equ    F_BIT, 0x40        /* when F bit is set, FIQ is disabled */

       .text
# generate arm instructions (.code32)
   .arm
   .extern     UART1_isr
   .global     UART1_IRQHandler /*_uart1_srv*/
   .global     _disableInterrupts
   .global     _enableInterrupts


# enable FIQ interrupts

   .func    _enableInterrupts
_enableInterrupts:
      stmfd   sp!,  {r1}
      mrs         r1, CPSR
      bic         r1, r1, #I_BIT
      bic         r1, r1, #F_BIT
      msr         CPSR_c, r1
      ldmfd       sp!, {r1}
      mov         pc, r14
      .size   __enableInterrupts, . - __enableInterrupts
      .endfunc


#disable FIQ interrupts

       .func   _disableInterrupts
_disableInterrupts:
      stmfd    sp!, {r1}
      mrs      r1, CPSR
      orr      r1, r1, #0x40
      msr      CPSR_c, r1
      ldmfd    sp!, {r1}
      mov      pc, r14
      .size    __disableInterrupts, . - __disableInterrupts
      .endfunc


###################################################
#
# primary interrupt services
#
###################################################
.macro SvCon
# Adjust and save LR_irq in IRQ stack
      sub         r14, r14, #4
      stmfd       sp!, {r14}

# Save SPSR and r0 in IRQ stack
      mrs         r14, SPSR
      stmfd       sp!, {r0, r1, r14}

# Save used registers and LR in User Stack
      stmfd       sp!, { r1-r3, r12, r14}
.endm
.macro RsCon
# Restore used registers and LR from User Stack
      ldmia       sp!, { r1-r3, r12, r14}

# Restore SPSR_irq and r0 from IRQ stack
      ldmia       sp!, {r0, r1, r14}
      msr         SPSR_cxsf, r14
# Restore adjusted  LR_irq from IRQ stack directly in the PC
      ldmia       sp!, {pc}^
.endm

#inthandler entries
      .func   UART1_IRQHandler /*_uart1_srv*/
UART1_IRQHandler: /*_uart1_srv:*/
      SvCon
#  enter ISR
      bl UART1_isr        /* branch to isr */
#  back from ISR
      RsCon
      .size   __uart1_srv, . - __uart1_srv
      .endfunc

.end
