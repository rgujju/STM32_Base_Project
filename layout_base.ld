/*
LICENSE

The MIT License (MIT)

Copyright (c) 2020 Rohit Gujarathi https://github.com/rgujju

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

/* Explicitly mention label for the program's entry point */
ENTRY(Reset_Handler)

SECTIONS
{
    /* The vector table goes at the start of flash. */
    .isr_vector :
    {
        . = ALIGN(4); /* The code memory ie FLASH of ARM Cortex-M micros need to be word aligned */
                      /* The word size is 32 bits or 4 bytes for the one i am using */
        KEEP (*(.isr_vector)) /* Use KEEP command to avoid removal of code if using link time garbage collection */
        . = ALIGN(4);
    } >FLASH

    /* The 'text' section contains the main program code. */
    .text :
    {
        . = ALIGN(4);
        *(.text*)
        *(.glue_7)         /* glue arm to thumb code */
        *(.glue_7t)        /* glue thumb to arm code */
        *(.eh_frame)

        KEEP (*(.init))
        KEEP (*(.fini))

        . = ALIGN(4);
        _etext = .;        /* define a global symbols at end of code */
    } >FLASH
    
    /* The 'rodata' section contains read-only data,
     * constants, strings, information that won't change. 
     * variables defined with const keyword in C */
    .rodata :
    {
        . = ALIGN(4);
        *(.rodata*)
        . = ALIGN(4);

    } >FLASH
    
    .ARM.extab   : { *(.ARM.extab* .gnu.linkonce.armextab.*) } >FLASH
    .ARM : {
        __exidx_start = .;
        *(.ARM.exidx*)
        __exidx_end = .;
    } >FLASH

    .preinit_array     :
    {
        PROVIDE_HIDDEN (__preinit_array_start = .);
        KEEP (*(.preinit_array*))
        PROVIDE_HIDDEN (__preinit_array_end = .);
    } >FLASH
    
    .init_array :
    {
        PROVIDE_HIDDEN (__init_array_start = .);
        KEEP (*(SORT(.init_array.*)))
        KEEP (*(.init_array*))
        PROVIDE_HIDDEN (__init_array_end = .);
    } >FLASH
    
    .fini_array :
    {
        PROVIDE_HIDDEN (__fini_array_start = .);
        KEEP (*(SORT(.fini_array.*)))
        KEEP (*(.fini_array*))
        PROVIDE_HIDDEN (__fini_array_end = .);
    } >FLASH
  
    /* PLT section contains code for accessing the dynamically linked functions
     * ie funtions from shared libraries in a postion independent manner */
    .plt :
    {
        . = ALIGN(4);
        *(.plt)
        . = ALIGN(4);
    } >FLASH
    
    /* The 'data' section is space set aside in RAM for
     * things like non-zero global and static variables, which can change. */
   
    .data :
    {
        /* We cannot declare _sidata here, because it will be assigned the 
         * start of RAM (0x20000000), instead of end of FLASH */
        . = ALIGN(4);
        /* Mark start/end locations for the 'data' section. */
        _sdata = .;
        *(.data*)
        . = ALIGN(4);
    } >RAM AT> FLASH /* Mentioning RAM here, specifies the VMA ie virtual memory address ie address during execution */
    /* The AT defines the load address of the .data section. This is where the section will be loaded */

    /* _sidata will be the location .data section will be stored
     * in the flash, and _sdata will be the location of .data section 
     * in the RAM. We use these two addresses to copy data from _sidata
     * to _sdata*/
    _sidata = LOADADDR(.data);

    /* CCM-RAM section */
    /* This is a special type of fast access memory */
    .ccmram :
    {
        . = ALIGN(4);
        _sccmram = .;       /* create a global symbol at ccmram start */
        *(.ccmram)
        *(.ccmram*)
        
        . = ALIGN(4);
        _eccmram = .;       /* create a global symbol at ccmram end */
    } >CCMRAM AT> FLASH

    /* The global offset table is the table for indirectly accessing the global variables
     * The table contains addresses of the global variables. The text section contains 
     * a address of the GOT base and a offset in it to access the appropriate variables.
     * This is done to access the variables in a postion independent manner. */
    .got :
    {
        . = ALIGN(4);
        _sgot = .;
        *(.got)
    } >RAM AT> FLASH
    
    /* got.plt section contains entries which is used with the PLT to access the functions 
     * in a position independent manner. */
    .got.plt :
    {
        . = ALIGN(4);
        *(.got.plt)
        _edata = .;
    } >RAM AT> FLASH
    
    /* The 'bss' section is similar to the 'data' section,
    *  but its space is initialized to all 0s at the
    *  start of the program. */
    .bss :
    {
        . = ALIGN(4);
        /* Also mark the start/end of the BSS section. */
        _sbss = .;
        __bss_start__ = _sbss;
        *(.bss*)
        /* A special notation is needed for common symbols, 
         * because in many object file formats common symbols 
         * do not have a particular input section. The linker 
         * treats common symbols as though they are in an 
         * input section named ‘COMMON’.*/ 
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;
        __bss_end__ = _ebss;

    } >RAM
    
    /* Space set aside for the application's heap/stack. */
    /* User_heap_stack section, used to check that there is enough RAM left */
    ._user_heap_stack :
    {
        . = ALIGN(8);
        PROVIDE ( end = . );
        PROVIDE ( _end = . );
        . = . + _Min_Heap_Size;
        . = . + _Min_Stack_Size;
        . = ALIGN(8);
    } >RAM
    
    /* Remove information from the standard libraries */
    /DISCARD/ :
    {
        libc.a ( * )
        libm.a ( * )
        libgcc.a ( * )
    }

    .ARM.attributes 0 : { *(.ARM.attributes) }
}


