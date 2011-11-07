/*** Linker Script File     ***/
/*** Hitex/We/2006-04-24   ***/

/* Memory Definitions         */
/* for STR912-Eval            */



MEMORY
{
  IntCodeFlash (rx)  : ORIGIN = 0x00000000, LENGTH = 512k
  IntDataRAM (rw)    : ORIGIN = 0x04000000, LENGTH = 96k
  IntDataEth (!rx)   : ORIGIN = 0x07C00000, LENGTH = 0x42F        /* AHB nonbuffered Ethernet RAM */      
}

/* this address is used in startup for initilizing stack */
/* stack is at the end of data range                                      */
        
PROVIDE(_top_stack_ = 0x4018000 -4);

SECTIONS
{

  /* first section is .text which is used for code */
  .start : { *(.startup)} >IntCodeFlash = 0
  .text :
    {
        /* here is the path to change and Processor-specific ISR_XXX-file */
        ./startup912.o (.text)  /* Startup code */
        ./*(.text)           /* remaining code */
        *(.glue_7t) 
        *(.glue_7)
    } >IntCodeFlash =0

    __end_of_text__ = .;

    __exidx_start = .;
    .ARM.exidx   : { *(.ARM.exidx* .gnu.linkonce.armexidx.*) }
    __exidx_end = .;



  . = ALIGN(4);

  /* .rodata section which is used for read-only data (constants) */

  .rodata . :
  {
    *(.rodata)
  } >IntCodeFlash

  . = ALIGN(4);

  _etext = . ;
  PROVIDE (etext = .);

  /* .data section which is used for initialized data */

  .data : AT (_etext)
  {
    _data = . ;
    __data_beg_src__ = __end_of_text__;
    __data_start__ = . ;
    PROVIDE (__data_start__ = .) ;
    *(.data)
    SORT(CONSTRUCTORS)
        *(.ramfunc) 
  } >IntDataRAM
  . = ALIGN(4);

  _edata = . ;
   PROVIDE (edata = .);

  /* .bss section which is used for uninitialized data */

  .bss :
  {
    __bss_start = . ;
    __bss_start__ = . ;
    *(.bss)
    *(COMMON)
  } >IntDataRAM
  . = ALIGN(4);
  __bss_end__ = . ;
  __bss_end = . ;

  _end = .;
  PROVIDE (end = .);

.bss2 :
  {
    /* used for uninitialized data */

    __bss2_start = . ;
    __bss2_start__ = . ;
    *(COMMON)
    . = ALIGN(4);
    __bss2_end__ = . ;

  } >IntDataRAM

  /* Stabs debugging sections.  */
  .stab          0 : { *(.stab) }
  .stabstr       0 : { *(.stabstr) }
  .stab.excl     0 : { *(.stab.excl) }
  .stab.exclstr  0 : { *(.stab.exclstr) }
  .stab.index    0 : { *(.stab.index) }
  .stab.indexstr 0 : { *(.stab.indexstr) }
  .comment       0 : { *(.comment) }
  /* DWARF debug sections.
     Symbols in the DWARF debugging sections are relative to the beginning
     of the section so we begin them at 0.  */
  /* DWARF 1 */
  .debug          0 : { *(.debug) }
  .line           0 : { *(.line) }
  /* GNU DWARF 1 extensions */
  .debug_srcinfo  0 : { *(.debug_srcinfo) }
  .debug_sfnames  0 : { *(.debug_sfnames) }
  /* DWARF 1.1 and DWARF 2 */
  .debug_aranges  0 : { *(.debug_aranges) }
  .debug_pubnames 0 : { *(.debug_pubnames) }
  /* DWARF 2 */
  .debug_info     0 : { *(.debug_info .gnu.linkonce.wi.*) }
  .debug_abbrev   0 : { *(.debug_abbrev) }
  .debug_line     0 : { *(.debug_line) }
  .debug_frame    0 : { *(.debug_frame) }
  .debug_str      0 : { *(.debug_str) }
  .debug_loc      0 : { *(.debug_loc) }
  .debug_macinfo  0 : { *(.debug_macinfo) }
  /* SGI/MIPS DWARF 2 extensions */
  .debug_weaknames 0 : { *(.debug_weaknames) }
  .debug_funcnames 0 : { *(.debug_funcnames) }
  .debug_typenames 0 : { *(.debug_typenames) }
  .debug_varnames  0 : { *(.debug_varnames) }
}


