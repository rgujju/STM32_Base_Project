/**
 ******************************************************************************
 * @file    main.c
 * @brief   Example main file
 *          contains the main code for blinking an LED
 @verbatim
  ==============================================================================
                       ##### Title of the project  #####
  ==============================================================================

 @endverbatim
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

#include "utilities.h"
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"

#include "stm32f4xx_hal.h"

#include "simple_module.h"

void SystemClock_Config(void);

static GPIO_InitTypeDef  GPIO_InitStruct;

/** @brief   LED pin */
#define LED1_PIN GPIO_PIN_13
/** @brief   LED port */
#define LED1_PORT GPIOG

/**
* @brief    Task for blinking an LED every second
* 
* @param    pvParameters void pointer to task parameters
* 
* @retval   void
*/
void LedBlinky_Task(void *pvParameters) {
    while (1) {
        HAL_GPIO_TogglePin(LED1_PORT, LED1_PIN);
        vTaskDelay(1000/portTICK_PERIOD_MS);
    }
}

int main ( void ) {
#if SEMIHOSTING
    initialise_monitor_handles();
    setbuf(stdout, NULL);
    //~ setvbuf(stdout, NULL, _IONBF, 0);
    INFO("Main program start");
#endif
    HAL_Init();
    SystemClock_Config();
    __HAL_RCC_GPIOG_CLK_ENABLE();
    GPIO_InitStruct.Pin   = LED1_PIN;
    GPIO_InitStruct.Mode  = GPIO_MODE_OUTPUT_PP;
    GPIO_InitStruct.Pull  = GPIO_PULLUP;
    GPIO_InitStruct.Speed = GPIO_SPEED_HIGH;
    HAL_GPIO_Init(LED1_PORT, &GPIO_InitStruct);
    // calling something from the modules
    SomethingSimple(2, 7);
    xTaskCreate( LedBlinky_Task,						/* The function that implements the task. */
                 "LedBlinky", 							/* The text name assigned to the task - for debug only as it is not used by the kernel. */
                 configMINIMAL_STACK_SIZE, 				/* The size of the stack to allocate to the task. */
                 NULL, 									/* The parameter passed to the task - just to check the functionality. */
                 3, 										/* The priority assigned to the task. */
                 NULL );									/* The task handle is not required, so NULL is passed. */
    vTaskStartScheduler();
    while (1) {
    }
    return 0;
}

/**
* @brief    Setup the system clock
* 
* @note     This function is taken from STM32CubeMX
* 
* @retval   void
*/
void SystemClock_Config(void) {
    RCC_OscInitTypeDef RCC_OscInitStruct = {0};
    RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};
    /** Configure the main internal regulator output voltage
    */
    __HAL_RCC_PWR_CLK_ENABLE();
    __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE3);
    /** Initializes the CPU, AHB and APB busses clocks
    */
    RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
    RCC_OscInitStruct.HSEState = RCC_HSE_ON;
    RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
    RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
    RCC_OscInitStruct.PLL.PLLM = 8;
    RCC_OscInitStruct.PLL.PLLN = 128;
    RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV2;
    RCC_OscInitStruct.PLL.PLLQ = 4;
    if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK) {
        Error_Handler();
    }
    /** Initializes the CPU, AHB and APB busses clocks
    */
    RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                                  |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
    RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
    RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV4;
    RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
    RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;
    if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_0) != HAL_OK) {
        Error_Handler();
    }
}
