OUTPUT_FORMAT("elf32-zpu", "elf32-zpu", "elf32-zpu")
OUTPUT_ARCH(zpu)
SEARCH_DIR(.);

ENTRY(_start)

MEMORY 
{
    ahbrom (rx)   : ORIGIN = 0x00000000, LENGTH = 8K
    ahbram (rwx)  : ORIGIN = 0x00100000, LENGTH = 4K
}

/* for sbrk.c:37 */
/*_stack = ORIGIN(ahbram)+LENGTH(ahbram); */
_stack = 0x00101000;

SECTIONS
{
    .text           :
    {
      *(.fixed_vectors)
      *(.text .text.*)
      *(.rodata .rodata.*)
    } > ahbrom 


    .data           :
    AT ( ADDR(.text) + SIZEOF(.text) )
    {
      *(.data .data.* )
    } >ahbram
    
    .bss            :
    {
     *(.bss .bss.*)
     . = ALIGN(4);
    } >ahbram
    . = ALIGN(4);
    _bss_end = . ;
    _end     = . ; /* for sbrk.c:33 */
    
}
    

