
#pragma once

#include <stdio.h>

#define DBUG_EN 1
#define INFO_EN 1
#define WARN_EN 1
#define ERRR_EN 1

#if ENABLE_SEMIHOSTING
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
#endif /* ENABLE_SEMIHOSTING */

#if !defined  (Error_Handler)
extern void Default_Handler(void);
#define Error_Handler    Default_Handler
#endif /* Error_Handler */

uint8_t add(uint8_t a, uint8_t b);
