/* =========================================================================== *
 * Copyright (c) 2014, Infineon Technologies AG                                *
 * All rights reserved.                                                        *
 *                                                                             *
 * Redistribution and use in source and binary forms, with or without          *
 * modification, are permitted provided that the following conditions are met: *
 * Redistributions of source code must retain the above copyright notice, this *
 * list of conditions and the following disclaimer. Redistributions in binary  *
 * form must reproduce the above copyright notice, this list of conditions and *
 * the following disclaimer in the documentation and/or other materials        *
 * provided with the distribution. Neither the name of the copyright holders   *
 * nor the names of its contributors may be used to endorse or promote         *
 * products derived from this software without specific prior written          *
 * permission.                                                                 *
 *                                                                                                                                                                                                                                                                                                                   *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" *
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,       *
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR      *
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR           *
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,       *
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,         *
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; *
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,    *
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR     *
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF      *
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                                  *
 * To improve the quality of the software, users are encouraged to share       *
 * modifications, enhancements or bug fixes with                               *
 * Infineon Technologies AG (dave@infineon.com).                               *
 *                                                                             *
 * ========================================================================== */

/**
 * @file
 * @date 09 Dec, 2014
 * @version 1.0.2
 *
 * @brief CCU8 demo example
 *
 * Synchronous start of CC8 slices using SCU and CCU8 drivers.
 * In this example, a CCU8 Slice is operated in a Single-shot Timer mode.
 * The start of the timer is triggered by an external event mapped to EVENT-1 of the slice.
 * The external event is generated by the SCU.
 * The timer generates 2 interrupts, one each for Compare match and Period match. The
 * interrupt counters for the respective interrupts are incremented in the ISRs.
 *
 * History <br>
 *
 * Version 1.0.0 Initial <br>
 * Version 1.0.1 1. Updated the code to support CCU8 LLD version 0.1.2. <br>
 *               2. Calls to XMC_SCU_RESET_DeassertPeripheralReset(), XMC_SCU_CLOCK_EnablePeripheralClock
 *                  are removed as XMC_CCU8_Init is calling these functions.
 *               3. Call to XMC_SCU_CLOCK_Init() is removed as clock is initialized by startup code.
 * Version 1.0.2 1. Updated the code to support CCU8 LLD version 0.2.1. <br>
 *
 */

/*********************************************************************************************************************
 * HEADER FILES
 ********************************************************************************************************************/
#include <xmc_ccu8.h>
#include <xmc_scu.h>

/*********************************************************************************************************************
 * MACROS
 ********************************************************************************************************************/
#define SLICE_PTR         CCU80_CC81
#define MODULE_PTR        CCU80
#define MODULE_NUMBER     (0U)
#define SLICE_NUMBER      (1U)
#define CAPCOM_MASK       (0x100U) /**< Only CCU80 */

/*********************************************************************************************************************
 * GLOBAL DATA
 ********************************************************************************************************************/


XMC_CCU8_SLICE_COMPARE_CONFIG_t g_timer_object =
{
  .timer_mode          = XMC_CCU8_SLICE_TIMER_COUNT_MODE_EA,
  .monoshot            = true,
  .shadow_xfer_clear   = false,
  .dither_timer_period = false,
  .dither_duty_cycle   = false,
  .prescaler_mode      = XMC_CCU8_SLICE_PRESCALER_MODE_NORMAL,
  .mcm_ch1_enable      = false,
  .mcm_ch2_enable      = false,
  .slice_status        = XMC_CCU8_SLICE_STATUS_CHANNEL_1,
  .passive_level_out0  = XMC_CCU8_SLICE_OUTPUT_PASSIVE_LEVEL_LOW,
  .passive_level_out1  = XMC_CCU8_SLICE_OUTPUT_PASSIVE_LEVEL_LOW,
  .passive_level_out2  = XMC_CCU8_SLICE_OUTPUT_PASSIVE_LEVEL_LOW,
  .passive_level_out3  = XMC_CCU8_SLICE_OUTPUT_PASSIVE_LEVEL_LOW,
  .asymmetric_pwm      = false,
  .invert_out0         = false,
  .invert_out1         = false,
  .invert_out2         = false,
  .invert_out3         = false,
  .prescaler_initval   = 0U,
  .float_limit         = 0U,
  .dither_limit        = 0U,
  .timer_concatenation = false
};

/* CCU Slice Capture Initialization Data */
XMC_CCU8_SLICE_CAPTURE_CONFIG_t g_capture_object =
{
  .fifo_enable 		     = false,
  .timer_clear_mode    = XMC_CCU8_SLICE_TIMER_CLEAR_MODE_NEVER,
  .same_event          = false,
  .ignore_full_flag    = false,
  .prescaler_mode	     = XMC_CCU8_SLICE_PRESCALER_MODE_NORMAL,
  .prescaler_initval   = 0U,
  .float_limit		     = 0U,
  .timer_concatenation = false
};

/* Interrupt counters */
volatile uint32_t g_num_period_interrupts;
volatile uint32_t g_num_compare_interrupts;
volatile bool period_match;

/*********************************************************************************************************************
  * MAIN APPLICATION
********************************************************************************************************************/

/* Interrupt handlers */
void CCU80_0_IRQHandler(void)
{
  g_num_period_interrupts++;
  XMC_CCU8_SLICE_ClearEvent(SLICE_PTR, XMC_CCU8_SLICE_IRQ_ID_PERIOD_MATCH);
  period_match = true;
}

void CCU80_1_IRQHandler(void)
{
  g_num_compare_interrupts++;
  XMC_SCU_SetCcuTriggerLow(CAPCOM_MASK);
  XMC_CCU8_SLICE_ClearEvent(SLICE_PTR, XMC_CCU8_SLICE_IRQ_ID_COMPARE_MATCH_UP_CH_1);
}


int main(void)
{
  /* Local variable which holds configuration of Event-1 */
  XMC_CCU8_SLICE_EVENT_CONFIG_t config;

  config.duration = XMC_CCU8_SLICE_EVENT_FILTER_5_CYCLES;
  config.edge     = XMC_CCU8_SLICE_EVENT_EDGE_SENSITIVITY_RISING_EDGE;
  config.level    = XMC_CCU8_SLICE_EVENT_LEVEL_SENSITIVITY_ACTIVE_HIGH; /* Not needed */
  config.mapped_input = XMC_CCU8_SLICE_INPUT_H;

  /* Ensure fCCU reaches CCU42 */
  XMC_CCU8_SetModuleClock(MODULE_PTR, XMC_CCU8_CLOCK_SCU);

  XMC_CCU8_Init(MODULE_PTR, XMC_CCU8_SLICE_MCMS_ACTION_TRANSFER_PR_CR);

  /* Get the slice out of idle mode */
  XMC_CCU8_EnableClock(MODULE_PTR, SLICE_NUMBER);

  /* Start the prescaler and restore clocks to slices */
  XMC_CCU8_StartPrescaler(MODULE_PTR);

  /* Initialize the Slice */
  XMC_CCU8_SLICE_CompareInit(SLICE_PTR, &g_timer_object);

  /* Enable compare match and period match events */
  XMC_CCU8_SLICE_EnableEvent(SLICE_PTR, XMC_CCU8_SLICE_IRQ_ID_PERIOD_MATCH);
  XMC_CCU8_SLICE_EnableEvent(SLICE_PTR, XMC_CCU8_SLICE_IRQ_ID_COMPARE_MATCH_UP_CH_1);

  /* Connect period match event to SR0 */
  XMC_CCU8_SLICE_SetInterruptNode(SLICE_PTR, XMC_CCU8_SLICE_IRQ_ID_PERIOD_MATCH, XMC_CCU8_SLICE_SR_ID_0);

  /* Connect compare match event to SR1 */
  XMC_CCU8_SLICE_SetInterruptNode(SLICE_PTR, XMC_CCU8_SLICE_IRQ_ID_COMPARE_MATCH_UP_CH_1, XMC_CCU8_SLICE_SR_ID_1);


  /* Configure NVIC */

  /* Set priority */
  NVIC_SetPriority(CCU80_0_IRQn, 10U);
  NVIC_SetPriority(CCU80_1_IRQn, 10U);

  /* Enable IRQ */
  NVIC_EnableIRQ(CCU80_0_IRQn);
  NVIC_EnableIRQ(CCU80_1_IRQn);

  /* Program a very large value into PR and CR */
  XMC_CCU8_SLICE_SetTimerPeriodMatch(SLICE_PTR, 65500U);
  XMC_CCU8_SLICE_SetTimerCompareMatch(SLICE_PTR, XMC_CCU8_SLICE_COMPARE_CHANNEL_1, 32000U);


  /* Enable shadow transfer */
  XMC_CCU8_EnableShadowTransfer(MODULE_PTR, XMC_CCU8_SHADOW_TRANSFER_SLICE_1);

  /* Configure Event-1 and map it to Input-I */
  XMC_CCU8_SLICE_ConfigureEvent(SLICE_PTR, XMC_CCU8_SLICE_EVENT_1, &config);

  /* Map Event-1 to Start function */
  XMC_CCU8_SLICE_StartConfig(SLICE_PTR, XMC_CCU8_SLICE_EVENT_1, XMC_CCU8_SLICE_START_MODE_TIMER_START_CLEAR);

  /* Generate an external start trigger */
  XMC_SCU_SetCcuTriggerHigh(CAPCOM_MASK);

  period_match = false;

  while(1U)
  {
    while(false == period_match);

    period_match = false;

    /* Generate an external start trigger */
    XMC_SCU_SetCcuTriggerHigh(CAPCOM_MASK);
  }

}
