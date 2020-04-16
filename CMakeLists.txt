cmake_minimum_required(VERSION 3.11.1)

if(NOT CMAKE_TOOLCHAIN_FILE)
    set(CMAKE_TOOLCHAIN_FILE ../cross.cmake)
    message(WARNING "[WARN] CMAKE_TOOLCHAIN_FILE not specified: Using ${CMAKE_TOOLCHAIN_FILE} by default")
endif()
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug CACHE STRING "Choose the type of build." FORCE)
    message(WARNING "[WARN] CMAKE_BUILD_TYPE not specified: Using ${CMAKE_BUILD_TYPE} by default")
endif()

set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

#################### CONFIGURABLE SECTION ###########################

#-------------------
# Project Setup
#-------------------
enable_language(C ASM)
project(main VERSION 1.0)

#-------------------
# MCU Setup
#-------------------
set(MCU STM32F429xx)
set(MCU_DIR include/STM32F4xx/)
set(MCU_SPEC  cortex-m4)
set(FLOAT_SPEC "-mfloat-abi=hard -mfpu=fpv4-sp-d16")

# Dont need to change this if MCU is defined correctly
# Below commands are for fetching the path to the system and startup files
# If execute_process is not able to locate the files properly
# then directly set the STARTUP_FILE and SYSTEM_FILE to the required files
execute_process(COMMAND
    bash "-c" "echo -n startup_${MCU}.s | awk '{print tolower($0)}'"
    OUTPUT_VARIABLE STARTUP_FILE_NAME
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )
set(STARTUP_FILE ${MCU_DIR}/Source/Templates/gcc/${STARTUP_FILE_NAME})
set(SYSTEM_FILE  ${MCU_DIR}/Source/Templates/system_stm32f4xx.c)

# Set the Highspeed external clock value (HSE) in MHz
set(HSE_VAL 8000000)

# Define the linker script location
set(LINKER_SCRIPT linker.ld)

#-------------------
# HAL Setup
#-------------------
# Select 1 if STM32 HAL library is to be used. This will add -DUSE_HAL_DRIVER=1 to the CFLAGS
# If enabled then set the correct path of the HAL Driver folder
#set(USE_HAL = 1
#ifeq (1,$(USE_HAL))
set(HAL_DIR components/STM32F4xx_HAL_Driver)
#endif

#-------------------
# RTOS Setup
#-------------------
# Path to FreeRTOS Kernel
set(RTOS_DIR components/FreeRTOS-Kernel)
# Modify this to the path where your micrcontroller specific port is
set(RTOS_DIR_MCU ${RTOS_DIR}/portable/GCC/ARM_CM4F) # For cortex-m4 microcontroller
set(RTOS_HEAP    ${RTOS_DIR}/portable/MemMang/heap_4.c) # Select which heap implementation to use

#-------------------
# CMSIS Setup
#-------------------
# Set the path to the CMSIS folder
set(CMSIS_DIR components/CMSIS/CMSIS)

#################### ADVANCED SECTION ###########################

#-------------------
# General Flags
#-------------------
set(OBJECT_GEN_FLAGS " \
-mcpu=${MCU_SPEC} \
-mthumb \
-fno-builtin \
-Wall \
-ffunction-sections -fdata-sections \
-fomit-frame-pointer \
-mthumb-interwork \
-mabi=aapcs \
${FLOAT_SPEC} \
")

#-------------------
# CFLAGS
#-------------------
set(CMAKE_C_FLAGS " \
${OBJECT_GEN_FLAGS} \
" CACHE INTERNAL "C Compiler options")

#-------------------
#ASMFLAGS
#-------------------
set(CMAKE_ASM_FLAGS " \
${OBJECT_GEN_FLAGS} \
-x assembler-with-cpp \
" CACHE INTERNAL "ASM Compiler options")

#-------------------
# LFLAGS
#-------------------
set(CMAKE_EXE_LINKER_FLAGS " \
${OBJECT_GEN_FLAGS} \
-T../${LINKER_SCRIPT} \
-Wl,-Map=${PROJECT_NAME}.map \
-Wl,--print-memory-usage \
-Wl,--gc-sections \
" CACHE INTERNAL "Linker options")

#------------------
# Debug Flags
#------------------
set(CMAKE_C_FLAGS_DEBUG "-Og -g -gdwarf-3 -gstrict-dwarf" CACHE INTERNAL "C Compiler options for debug build type")
set(CMAKE_CXX_FLAGS_DEBUG "-Og -g -gdwarf-3 -gstrict-dwarf" CACHE INTERNAL "C++ Compiler options for debug build type")
set(CMAKE_ASM_FLAGS_DEBUG "-Og -g -gdwarf-3 -gstrict-dwarf" CACHE INTERNAL "ASM Compiler options for debug build type")
set(CMAKE_EXE_LINKER_FLAGS_DEBUG "" CACHE INTERNAL "Linker options for debug build type")

#------------------
# Release Flags
#-----------------
set(CMAKE_C_FLAGS_RELEASE "-Os -flto" CACHE INTERNAL "C Compiler options for release build type")
set(CMAKE_CXX_FLAGS_RELEASE "-Os -flto" CACHE INTERNAL "C++ Compiler options for release build type")
set(CMAKE_ASM_FLAGS_RELEASE "" CACHE INTERNAL "ASM Compiler options for release build type")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "-flto -Wl,--undefined=vTaskSwitchContext" CACHE INTERNAL "Linker options for release build type")

# Control ARM Semihosting support
if(NOT SEMIHOSTING)
    set(SEMIHOSTING 1)
    message(WARNING "[WARN] Semihosting support not specified: Enabling by default")
endif()

######################################################################
# @Target: ${PROJECT_NAME}.elf
# @Brief: Build the actual elf file of the project
######################################################################
message(STATUS "[INFO] Startup file used is ${STARTUP_FILE}")

#-------------------
# HAL library
#-------------------
file(GLOB HAL_SRC
    "${HAL_DIR}/Src/*.c"
    )
add_library(hal STATIC
    ${HAL_SRC}
    )
target_include_directories(hal
    PUBLIC
    ${HAL_DIR}/Inc
    ${MCU_DIR}/Include
    ${CMSIS_DIR}/Core/Include
    PRIVATE
    ${PROJECT_SOURCE_DIR}/include
    )
target_compile_definitions(hal
    PUBLIC
    ${MCU}
    HSE_VALUE=${HSE_VAL}
    )

#-------------------
# FreeRTOS library
#-------------------
file(GLOB RTOS_SRC
    "${RTOS_DIR}/*.c"
    "${RTOS_DIR_MCU}/*.c"
    )
add_library(rtos STATIC
    ${RTOS_SRC}
    ${RTOS_HEAP}
    )
target_include_directories(rtos
    PUBLIC
    ${RTOS_DIR}/include
    ${RTOS_DIR_MCU}
    PRIVATE
    ${PROJECT_SOURCE_DIR}/include
    )

#-------------------
# Main elf
#-------------------
set(SOURCES
    src/main.c
    ${STARTUP_FILE}
    ${SYSTEM_FILE}
    )
add_executable(${PROJECT_NAME}.elf
    ${SOURCES}
    )
target_include_directories(${PROJECT_NAME}.elf
    PUBLIC
    ${PROJECT_SOURCE_DIR}/include
    )
target_link_libraries(${PROJECT_NAME}.elf
    PUBLIC
    rtos
    hal
    )
target_compile_definitions(${PROJECT_NAME}.elf
    PUBLIC
    ${MCU}
    HSE_VALUE=${HSE_VAL}
    SEMIHOSTING=${SEMIHOSTING}
    )

if("${SEMIHOSTING}" STREQUAL "1")
    string(APPEND CMAKE_EXE_LINKER_FLAGS "--specs=rdimon.specs -lc -lrdimon")
else()
    string(APPEND CMAKE_EXE_LINKER_FLAGS "--specs=nosys.specs")
endif()

######################################################################
# @Target: flash
# @Brief: flash the release/debug elf using gdb
######################################################################
add_custom_target(flash DEPENDS ${PROJECT_NAME}.elf)
add_custom_command(TARGET flash
    #COMMAND bash "-c" "pgrep -x \"openocd\" || (echo \"Please start openocd\" && exit -1)"
    COMMAND echo "Starting GDB client"
    COMMAND ${CMAKE_C_GDB} ${PROJECT_NAME}.elf
    -ex "target extended :3333"
    -ex "load ${PROJECT_NAME}.elf"
    -ex "monitor arm semihosting enable"
    )

# Unset all cache
unset(SEMIHOSTING)
unset(CMAKE_TOOLCHAIN_FILE)
unset(CMAKE_BUILD_TYPE)

