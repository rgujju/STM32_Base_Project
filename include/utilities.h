/**
 ******************************************************************************
 * @file    utilities.h
 * @brief   Contains helper code
 ******************************************************************************
 * @attention
 * 
 * LICENSE
 * 
 * The MIT License (MIT)
 * 
 * Copyright (c) 2020 Rohit Gujarathi
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
*/

#pragma once

#include <stdio.h>
#include <stdint.h>

#define DBUG_EN 1
#define INFO_EN 1
#define WARN_EN 1
#define ERRR_EN 1

#if SEMIHOSTING
extern void initialise_monitor_handles(void);
#define DBUG(fmt...) if(DBUG_EN){printf("[DBUG] " fmt); printf("\n");}
#define INFO(fmt...) if(INFO_EN){printf("[INFO] " fmt); printf("\n");}
#define WARN(fmt...) if(WARN_EN){printf("[WARN] " fmt); printf("\n");}
#define ERRR(fmt...) if(ERRR_EN){printf("[ERRR] " fmt); printf("\n");}

#define DBUG_CUST_S(fmt...) if(DBUG_EN){printf("[DBUG] " fmt);}
#define DBUG_CUST_C(fmt...) if(DBUG_EN){printf(fmt);}
#define DBUG_CUST_E(fmt...) if(DBUG_EN){printf(fmt "\n");}

#define INFO_CUST_S(fmt...) if(INFO_EN){printf("[INFO] " fmt);}
#define INFO_CUST_C(fmt...) if(INFO_EN){printf(fmt);}
#define INFO_CUST_E(fmt...) if(INFO_EN){printf(fmt "\n");}
#endif /* SEMIHOSTING */

#if !defined  (Error_Handler)
extern void Default_Handler(void);
#define Error_Handler    Default_Handler
#endif /* Error_Handler */

/**
 * @brief   Add two 8 bit integers
 *
 * @param a first uint8_t
 * @param b second uint8_t
 *
 * @retval  a+b
 */
uint8_t add(uint8_t a, uint8_t b);
