OUTPUT_FORMAT("elf32-littlearm", "elf32-littlearm", "elf32-littlearm")
OUTPUT_ARCH(arm)

MEMORY
{
    flash (RX)  : ORIGIN = 0x00000000, LENGTH = 512k
    sram (W!RX) : ORIGIN = 0x04000000, LENGTH = 96k
}

SECTIONS
{  
    .fixed :
    {
        . = ALIGN(4);
        _sfixed = .;
        *(.text .text.*)        
        *(.rodata .rodata.*)        
        *(.gnu.linkonce.t.*)
        *(.glue_7)
        *(.glue_7t)
        *(.gcc_except_table)
        *(.gnu.linkonce.r.*)
    } >flash
 
/*    .ARM.extab   : { *(.ARM.extab*) } */

    . = ALIGN(4);
        
    __exidx_start = .;
    .ARM.exidx   : { 
        *(.ARM.exidx* .gnu.linkonce.armexidx.*) 
    } >flash
    __exidx_end = .;

    . = ALIGN(4);
        
    _efixed = .;
    PROVIDE(etext = .);        

    .relocate : AT (_efixed)
    {
        . = ALIGN(4);
        _srelocate = .;
        *(.data .data.*)
        *(.gnu.linkonce.d.*)
        . = ALIGN(4);
        _erelocate = .;
    } >sram

    .bss (NOLOAD) : {
        _szero = .;
        *(.bss .bss.*)
        *(.gnu.linkonce.b.*)
        *(COMMON)
		. = ALIGN(4);
        _ezero = .;
    } >sram
	. = ALIGN(4);
    
    end = .;
}
