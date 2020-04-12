#include <stdlib.h>
#include <stdio.h>
#include <setjmp.h>
#include <stddef.h>

#define CMOCKA_ENABLED

#define exit(status) while(1)

#define abort() while(1)

#define getenv(env) NULL

//#define fputs(str, stream) INFO(str)

#define fflush(stream)

#define fopen(stream, mode) NULL

#define fclose(stream)

//#define fprintf(stream, format, ...) INFO(format, ##__VA_ARGS__)

//#define printf(format, ...) INFO(format, ##__VA_ARGS__)

