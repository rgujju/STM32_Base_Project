### STM32_Base_Project

|    Type    |   Tool used |
| ---------- | ----------- |
| Build framework | cmake |
| Toolchain | arm-none-eabi-gcc |
| RTOS | FreeRTOS |
| HAL  | STM32 CubeMX |
| Test framework | Unity |
| Mocking framework | FFF |
| GDB utilities | GDB dashboard |

### Usage
- Debug build is the default build if ``CMAKE_BUILD_TYPE`` is not specified during cross-compiling  
- ARM Semihosting is turned on by default. To turn off use ``-DSEMIHOSTING=0``. ``SEMIHOSTING`` is also a macro which is set if ARM semihosting is enabled.  
- Most of the values like HSE, linker script, RTOS path, HAL path, CMSIS path, etc can be set in the configurable section of CMakeLists.txt in project root.  
- For testing add two lines as follows in **test/CMakeLists.txt**  

   ```
   list(APPEND tests_names "test_<module_name>")
   list(APPEND tests_flags " ")
   ```

#### Build Tests for host
``mkdir -p build/test``  
``cmake ../.. -DTARGET_GROUP=test``  
To run the tests  
``ctest --verbose``  

#### Build Release for cross-compiling
``mkdir -p build/release``  
Generate Makefile  
``cmake ../.. -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=../../cross.cmake -DTARGET_GROUP=production``  
Generate elf  
``make``  
Load the board with elf  
``make flash``  

Note: To make FreeRTOS link with ``-flto`` option during Release build ``-Wl,--undefined=vTaskSwitchContext`` is passed to the linker.  

#### Build Debug (default) for cross-compiling
``mkdir -p build/debug``  
Generate Makefile  
``cmake ../.. -DCMAKE_BUILD_TYPE=Debug -DCMAKE_TOOLCHAIN_FILE=../../cross.cmake -DTARGET_GROUP=production``  
Generate elf  
``make``  
Start GDB and load the board with elf with GDB dashboard output to eg: /dev/pts/12  
``make flash GDB_TTY=/dev/pts/12``  

Currently using terminator to split the terminal to two and output the GDB dashboard to the terminal on the right  

