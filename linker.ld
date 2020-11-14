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


INCLUDE layout_base.ld
