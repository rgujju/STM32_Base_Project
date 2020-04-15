/* Highest address of the user mode stack */
_estack = 0x20030000;    /* end of RAM */

/* Set minimum size for stack and dynamic memory. */
/* (The linker will generate an error if there is
 *  less than this much RAM leftover.) 
 *  For the current application, Default amount is enough
 *  but as the complexity grow, you will have to
 *  increase this */

_Min_Heap_Size = 0x4B0;      /* required amount of heap  */
_Min_Stack_Size = 0x400;    /* required amount of stack */

/* Specify the memory areas */
MEMORY
{
    RAM (xrw)      : ORIGIN = 0x20000000, LENGTH = 192K
    CCMRAM (rw)      : ORIGIN = 0x10000000, LENGTH = 64K
    FLASH (rx)      : ORIGIN = 0x8000000, LENGTH = 2048K
}


INCLUDE ../layout_base.ld
