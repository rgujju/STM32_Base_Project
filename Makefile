
#################### CONFIGURABLE SECTION ###########################
# Target can be anything you want. It will create an elf and bin file
# with this name
TARGET = main

# The following three item are the most important to change
# Change this based on chip architecture
MCU = STM32F429xx
MCU_DIR = ./include/STM32F4xx/
MCU_SPEC  = cortex-m4
FLOAT_SPEC = -mfloat-abi=hard -mfpu=fpv4-sp-d16

# Define the linker script location
LD_SCRIPT = linker.ld

# set the path to FreeRTOS package
RTOS_DIR  ?= ./components/FreeRTOS-Kernel
# Modify this to the path where your micrcontroller specific port is
RTOS_DIR_MCU  ?= $(RTOS_DIR)/portable/GCC/ARM_CM4F

# Dont need to change this if MCU is defined correctly
# It will add for eg: startup_stm2f429xx.s file to the $(ASM_SOURCES)
STARTUP_FILE = $(MCU_DIR)/Source/Templates/gcc/startup_$(shell echo "$(MCU)" | awk '{print tolower($$0)}').s

# Select 1 if STM32 HAL library is to be used. This will add -DUSE_HAL_DRIVER=1 to the CFLAGS
# If enabled then set the correct path of the HAL Driver folder
USE_HAL = 1
ifeq (1,$(USE_HAL))
	HAL_SRC = ./components/STM32F4xx_HAL_Driver/Src
	HAL_INC = ./components/STM32F4xx_HAL_Driver/Inc
endif
# Add assembler and C files to this
AS_SRC_DIR    = src
C_SRC_DIR     = src $(MCU_DIR)/Source/Templates $(HAL_SRC)
INCLUDE_DIR   = include $(RTOS_DIR)/include $(RTOS_DIR_MCU) $(CMSIS_DIR)/Core/Include $(MCU_DIR)/Include $(HAL_INC)
LIBS_SRC_DIR  = 
# Dynamic lib sources
DLIB_SRC_DIR  = 

# Toolchain definitions (ARM bare metal defaults)
# Set the TOOLCHAIN_PATH variable to the path where it is installed
# If it is accessible globally. ie it is in your system path ($PATH)
# then leave it blank. A slash at the end of the path is required
# eg: TOOLCHAIN_PATH = /usr/local/bin/
TOOLCHAIN_PATH = 
TOOLCHAIN = $(TOOLCHAIN_PATH)arm-none-eabi-
CC 	= $(TOOLCHAIN)gcc
AS 	= $(TOOLCHAIN)as
LD 	= $(TOOLCHAIN)gcc
OC 	= $(TOOLCHAIN)objcopy
OD 	= $(TOOLCHAIN)objdump
OS 	= $(TOOLCHAIN)size
GDB = $(TOOLCHAIN)gdb

# System utilities
# Remove file and folders
RM 		= rm -rf
# Remove file
MKDIR 	= mkdir -p
######################################################################
.DELETE_ON_ERROR:

######################################################################
# Various sources files and objects
######################################################################
CMSIS_DIR = ./components/CMSIS/CMSIS/
TARGET_DIR = target
BUILD_DIR  = build

RTOS_SRC      = $(patsubst %.c, %.o, $(wildcard $(RTOS_DIR)/*.c))
RTOS_MCU_SRC  = $(patsubst %.c, %.o, $(wildcard $(RTOS_DIR_MCU)/*.c))
OBJS         += $(RTOS_SRC) $(RTOS_MCU_SRC)

C_SRC    += $(foreach DIR, $(basename $(C_SRC_DIR)), $(wildcard $(DIR)/*.c))
OBJS     += $(patsubst %.c, %.o, $(C_SRC))
AS_SRC_S  = $(foreach DIR, $(basename $(AS_SRC_DIR)), $(wildcard $(DIR)/*.S))
OBJS     += $(patsubst %.S, %.o, $(AS_SRC_S))
AS_SRC_s  = $(foreach DIR, $(basename $(AS_SRC_DIR)), $(wildcard $(DIR)/*.s))
OBJS     += $(patsubst %.s, %.o, $(AS_SRC_s))
LIB_SRC   = $(wildcard $(LIBS_SRC_DIR)/*.c)
OBJS     += $(patsubst %.c, %.o, $(LIB_SRC))

C_SOURCES = $(C_SRC) $(LIB_SRC)
ASM_SOURCES = $(STARTUP_FILE) $(AS_SRC_S) $(AS_SRC_s)

OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))
# list of ASM program objects
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SOURCES:.s=.o)))
vpath %.s $(sort $(dir $(ASM_SOURCES)))

######################################################################
# Assembly directives.
######################################################################
ASFLAGS += -O0
ASFLAGS += -mcpu=$(MCU_SPEC)
ASFLAGS += -mthumb
ASFLAGS += -mthumb-interwork
ASFLAGS += -Wall
# (Set error messages to appear on a single line.)
ASFLAGS += -fmessage-length=0
ASFLAGS += $(FLOAT_SPEC)

######################################################################
# C compilation directives
######################################################################
CFLAGS += -mcpu=$(MCU_SPEC)
CFLAGS += -mthumb
CFLAGS += -mthumb-interwork
CFLAGS += -D$(MCU)
CFLAGS += -Wall
CFLAGS += -std=c99
CFLAGS += -g3
CFLAGS += $(FLOAT_SPEC)
# (Set error messages to appear on a single line.)
CFLAGS += -fmessage-length=0
# Create separate sections for function and data
# so it can be garbage collected by linker
CFLAGS += -ffunction-sections
CFLAGS += -fdata-sections
# Generate dependency information
CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"

# Add the include folders
CFLAGS += $(foreach x, $(basename $(INCLUDE_DIR)), -I $(x))

ifeq (1,$(USE_HAL))
	CFLAGS += -DUSE_HAL_DRIVER=1
endif

######################################################################
# Linker directives
######################################################################
LSCRIPT = ./$(LD_SCRIPT)

LFLAGS += $(CFLAGS)
#~ LFLAGS += -nostdlib
LFLAGS += -T$(LSCRIPT)
LFLAGS += -Wl,-Map=$(BUILD_DIR)/$(TARGET_DIR)/$(TARGET).map
LFLAGS += -Wl,--print-memory-usage
LFLAGS += -Wl,--gc-sections

# Dynamic lib Compilation flags
DLIB_CFLAGS += -mcpu=$(MCU_SPEC)
DLIB_CFLAGS += -mthumb
DLIB_CFLAGS += -Wall
DLIB_CFLAGS += -g3
DLIB_CFLAGS += -fmessage-length=0

# Dynamic lib linker flags
DLIB_LFLAGS += $(DLIB_SRC:%.c=-l%)

# List of dynamic libs
DLIBS       += $(DLIB_SRC:%.c=lib%.so)

# The following two lines are to remove the existing so and o files
DLIBS_SO  += $(DLIB_SRC:.c=.so)
DLIBS_O   += $(DLIB_SRC:.c=.o)

######################################################################
# File targets
######################################################################

# The PHONY keyword is required so that makefile does not
# consider the rule 'all' as a file
.PHONY: all
all: debug

# There should be a tab here on the line with $(CC), 4 spaces does not work
$(BUILD_DIR)/%.o: %.S Makefile | $(BUILD_DIR) 
	@ echo "[AS] $@"
	@ $(CC) -x assembler-with-cpp $(ASFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.s Makefile | $(BUILD_DIR) 
	@ echo "[AS] $@"
	@ $(CC) -x assembler-with-cpp $(ASFLAGS) -c $< -o $@

# If -c is used then it will create a reloc file ie normal object file
$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR) 
	@ echo "[CC] $@"
	@ $(CC) $(CFLAGS) $(INCLUDE) -c $< -o $@

# and not a dynamic object. For dynamic object -shared is required.
$(BUILD_DIR)/%.so: %.c Makefile | $(BUILD_DIR) 
	@ echo "[CC] $@"
	@ $(CC) -shared $(DLIB_CFLAGS) $< -o lib$@

$(BUILD_DIR)/$(TARGET_DIR)/$(TARGET).diss: $(BUILD_DIR)/$(TARGET_DIR)/$(TARGET).elf | $(BUILD_DIR)
	@ echo "[OD] $@"
	@ $(OD) -Dz --source $^ > $@

$(BUILD_DIR)/$(TARGET_DIR)/$(TARGET).elf: $(OBJECTS) | $(BUILD_DIR)
	@ echo "[LD] $@"
	@ $(LD) $^ $(LFLAGS) -o $@

$(BUILD_DIR)/$(TARGET_DIR)/$(TARGET).bin: $(BUILD_DIR)/$(TARGET_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET_DIR)/$(TARGET).diss | $(BUILD_DIR)
	@ echo "[OC] $@"
	@ $(OC) -S -O binary $< $@
	@ echo "[OS] $@"
	@ $(OS) $<

$(BUILD_DIR):
	@ $(MKDIR) $@/$(TARGET_DIR)

######################################################################
# @Target release
# @Brief Build executable with optimizations
######################################################################
.PHONY: release
release:DEBUG = 0
release: $(BUILD_DIR)/$(TARGET_DIR)/$(TARGET).bin
	@ echo "Built Release build"

######################################################################
# @Target debug
# @Brief Build executable with debug flags
######################################################################
.PHONY: debug
debug:DEBUG = 1
debug: $(BUILD_DIR)/$(TARGET_DIR)/$(TARGET).bin
	@ echo "Built Debug build"

######################################################################
# @Target clean
# @Brief Remove the target output files.
######################################################################
.PHONY: clean
clean:
	$(RM) $(BUILD_DIR)

######################################################################
# @Target flash
# @Brief Start GDB, connect to server and load the elf
######################################################################
.PHONY: flash
flash:
	@pgrep -x "openocd" || (echo "Please start openocd"; exit -1)
	@echo "Starting GDB client"
	$(GDB) -ex "target extended :3333" -ex "load $(BUILD_DIR)/$(TARGET_DIR)/$(TARGET).elf" -ex "monitor arm semihosting enable" $(BUILD_DIR)/$(TARGET_DIR)/$(TARGET).elf

######################################################################
# @Target Dependencies
# @Brief 
######################################################################
-include $(wildcard $(BUILD_DIR)/*.d)
