### STM32 Base/Template Project {#mainpage}

|    Type    |   Tool used |
| ---------- | ----------- |
| Build framework | cmake |
| Toolchain | arm-none-eabi-gcc |
| RTOS | FreeRTOS |
| HAL  | STM32 CubeMX |
| Test framework | Unity |
| Mocking framework | FFF |
| Code coverage | lcov |
| GDB utilities | GDB dashboard |
| GDB server | openocd |
| Documentation | doxygen |

### Installation
#### Method 1
- Clone complete repo including submodules  
  `git clone --recurse-submodules --depth 1 --single-branch https://github.com/rgujju/STM32_Base_Project <your_project_name>`  
  But the problem with this is the CMSIS and FreeRTOS repos (submodules) are huge due to history and takes time to download.

#### Method 2
- Clone this repo only and change paths of CMSIS and FreeRTOS in the **CmakeLists.txt** to the ones you already have.
  `git clone --depth 1 --single-branch https://github.com/rgujju/STM32_Base_Project <your_project_name>`

### Usage
- **components** folder includes external libraries like RTOS, HAL, CMSIS, unity, and FFF mostly as git submodules.
- **modules** folder contains sources for individual parts which can be unit tested.
- **test** folder contains the tests for the modules.
- Debug build is the default build if ``CMAKE_BUILD_TYPE`` is not specified during cross-compiling  
- ARM Semihosting is turned on by default. To turn off use ``-DSEMIHOSTING=0``. ``SEMIHOSTING`` is also a macro which is set if ARM semihosting is enabled.  
- Most of the values like HSE, linker script, RTOS path, HAL path, CMSIS path, etc can be set in the configurable section of CMakeLists.txt in project root.  
- To add new modules, copy **modules/simple_module** to **modules/<your_module_name>** and rename simple_module with ``<your_module_name>`` in the CMakeLists.txt file, 
  and add ``add_subdirectory(<your_module_name>)`` to the **modules/CMakeLists.txt**.
  Finally add ``<your_module_name>`` to the *MODULES_USED* variable in **CMakeLists.txt** in the project root. 
- For adding test for the modules, create **test/test_<your_module_name>.c** and add two lines as follows in **test/CMakeLists.txt**  

   ```
   list(APPEND tests_names "test_<your_module_name>")
   list(APPEND tests_flags " ")
   ```
- For ``make flash`` to work openocd should be running.

#### Build Tests for host
``mkdir -p build/test``  
Generate Makefile  
``cmake ../.. -DTARGET_GROUP=test``  
Build the tests  
``make``  
To run the tests  
``ctest --verbose``  
or to test and generate coverage report all together.  
``make coverage``  
The coverage report will be in **build/test/coverage/index.html**  

#### Build Release for cross-compiling
``mkdir -p build/release``  
Generate Makefile  
``cmake ../.. -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=../../cross.cmake -DTARGET_GROUP=production``  
Generate elf  
``make <your_project_name>.elf``  
Load the board with elf  
``make flash``  

Note: To make FreeRTOS link with ``-flto`` option during Release build ``-Wl,--undefined=vTaskSwitchContext`` is passed to the linker.  

#### Build Debug (default) for cross-compiling
``mkdir -p build/debug``  
Generate Makefile  
``cmake ../.. -DCMAKE_BUILD_TYPE=Debug -DCMAKE_TOOLCHAIN_FILE=../../cross.cmake -DTARGET_GROUP=production``  
Generate elf  
``make <your_project_name>.elf``  
Start GDB and load the board with elf with GDB dashboard output to eg: /dev/pts/12  
``make flash GDB_TTY=/dev/pts/12``  
Note: ``flash`` target is not present when ``-DTARGET_GROUP=test`` is provided.  
Currently using terminator to split the terminal to two and output the GDB dashboard to the terminal on the right  

#### Generate documentation
In the above created folders **(build/release, build/debug)**, use command  
`make docs`  
Documentation files will be generated in html and latex format. For example if command is used in **build/release** dir then
documentation will be generated in **build/release/html/index.html**  
Note: ``docs`` target is not present when ``-DTARGET_GROUP=test`` is provided.  

### Porting
- This project uses the STM32F429 mcu but should be portable to any mcu.
- Replace **components/STM32F4xx_HAL_Driver** and **include/stm32f4xx_hal_conf.h** with the HAL of your mcu.
- Replace **include/STM32F4xx** with the vendor files for your mcu. These files are basically the system, startup and header files of your mcu.
- The above 2 folders are provided by the vendor. In case of STM32, it is possible to use STM32CubeMX to generate them.
- Change *MCU Setup*, *HAL Setup*, and optionally *RTOS Setup* and *CMSIS Setup* in the **CMakeLists.txt** file.
