cmake_minimum_required(VERSION 3.11.1)
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

# Control ARM Semihosting support
set(ENABLE_SEMIHOSTING 1)

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
# Set the path to required CMSIS folde
set(CMSIS_DIR components/CMSIS/CMSIS/)

#-------------------
# Toolchain Setup
#-------------------
# Uncomment below to set path to the CROSS_TOOLCHAIN
# Keep slash at the end
#set(TOOLCHAIN_BIN_DIR /usr/local/bin/)
set(CROSS_TOOLCHAIN arm-none-eabi-)
set(HOST_TOOLCHAIN )

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

######################################################################
# @Target: ${PROJECT_NAME}.elf
# @Brief: Build the actual elf file of the project
######################################################################
message("[INFO] Startup file used is ${STARTUP_FILE}")

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
    ENABLE_SEMIHOSTING=${ENABLE_SEMIHOSTING}
    )
set_target_properties(${PROJECT_NAME}.elf
    PROPERTIES TOOLCHAIN ${CROSS_TOOLCHAIN}
    )

if(${ENABLE_SEMIHOSTING} STREQUAL "1")
    target_link_options(${PROJECT_NAME}.elf
        PUBLIC
        --specs=rdimon.specs -lc -lrdimon
        )
else()
    target_link_options(${PROJECT_NAME}.elf
        PUBLIC
        -specs=nosys.specs
        )
endif()

######################################################################
# @Target: flash
# @Brief: flash the release/debug elf using gdb
######################################################################
add_custom_target(flash DEPENDS ${PROJECT_NAME}.elf)
add_custom_command(TARGET flash
    #COMMAND bash "-c" "pgrep -x \"openocd\" || (echo \"Please start openocd\" && exit -1)"
    COMMAND echo "Starting GDB client"
    COMMAND ${CMAKE_C_GDB} ${PROJECT_NAME}.elf -ex "target extended :3333" -ex "load ${PROJECT_NAME}.elf" -ex "monitor arm semihosting enable"
    )


#-----------------------------
# Compiler and generic options
#-----------------------------
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_CROSSCOMPILING 1)

set(CMAKE_C_COMPILER ${TOOLCHAIN_BIN_DIR}${CROSS_TOOLCHAIN}gcc${TOOLCHAIN_EXT} CACHE INTERNAL "C Compiler")
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_BIN_DIR}${CROSS_TOOLCHAIN}g++${TOOLCHAIN_EXT} CACHE INTERNAL "C++ Compiler")
set(CMAKE_ASM_COMPILER ${TOOLCHAIN_BIN_DIR}${CROSS_TOOLCHAIN}gcc${TOOLCHAIN_EXT} CACHE INTERNAL "ASM Compiler")
set(CMAKE_OBJCOPY ${TOOLCHAIN_BIN_DIR}${CROSS_TOOLCHAIN}objcopy CACHE INTERNAL "Objcopy tool")
set(CMAKE_SIZE_UTIL ${TOOLCHAIN_BIN_DIR}${CROSS_TOOLCHAIN}size CACHE INTERNAL "Size tool")
set(CMAKE_C_GDB ${TOOLCHAIN_BIN_DIR}${CROSS_TOOLCHAIN}gdb-py CACHE INTERNAL "Debugger")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)



