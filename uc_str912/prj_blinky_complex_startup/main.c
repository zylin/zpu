/********************************************************************
 * Project:    STR9-comStick GNU (UART on Interrupt)
 * File:       main.c
 *
 * System:     ARM9TDMI 32 Bit (STR912FW44X)
 * Compiler:   GCC 4.0.3
 *
 * Date:       2006-12-20
 * Author:     Applications@Hitex.de
 *
 * Rights:     Hitex Development Tools GmbH
 *             Greschbachstr. 12
 *             D-76229 Karlsruhe
 ********************************************************************
 * Description:
 *
 * This file is part of the GNU Example chain for STR9-comStick
 * The code is bassed on usage of the STmicro library functions
 * This is a small implementation of UART1 feature with command interface
 * The application runs in ARM mode with high optimization level.
 *
 ********************************************************************
 * History:
 *
 *    Revision 1.0    2006/12/20      Gn
 *    Initial revision
 ********************************************************************
 * This is a preliminary version.
 *
 * WARRANTY:  HITEX warrants that the media on which the SOFTWARE is
 * furnished is free from defects in materials and workmanship under
 * normal use and service for a period of ninety (90) days. HITEX entire
 * liability and your exclusive remedy shall be the replacement of the
 * SOFTWARE if the media is defective. This Warranty is void if failure
 * of the media resulted from unauthorized modification, accident, abuse,
 * or misapplication.
 *
 * DISCLAIMER:  OTHER THAN THE ABOVE WARRANTY, THE SOFTWARE IS FURNISHED
 * "AS IS" WITHOUT WARRANTY OF ANY KIND. HITEX DISCLAIMS ALL OTHER WARRANTIES,
 * EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 *
 * NEITHER HITEX NOR ITS AFFILIATES SHALL BE LIABLE FOR ANY DAMAGES ARISING
 * OUT OF THE USE OF OR INABILITY TO USE THE SOFTWARE, INCLUDING DAMAGES FOR
 * LOSS OF PROFITS, BUSINESS INTERRUPTION, OR ANY SPECIAL, INCIDENTAL, INDIRECT
 * OR CONSEQUENTIAL DAMAGES EVEN IF HITEX HAS BEEN ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGES.
 ********************************************************************/

#include "defines.h"

#define global extern   /* to declare external variables and functions      */
#include "91x_lib.h"

#include "main.h"

extern void          _enableInterrupts(void);


   GPIO_InitTypeDef  GPIO_InitStructure;


/* Private function prototypes -----------------------------------------------*/
   void SCU_Configuration(void);
   void GPIO_Configuration(void);
   void VIC_Configuration(void);
   static void Delay(u32 nCount);

int main (void)
{

   /* Configure the system clocks */
   SCU_Configuration();
   /* Configure the GPIOs */
   GPIO_Configuration();
   /* VIC setup */
   VIC_Configuration();


   /* endless loop */
   while (1)
   {
      /* Turn ON leds connected to P8.0 pins */
      GPIO_WriteBit(GPIO8, GPIO_Pin_0, Bit_SET);
      GPIO_WriteBit(GPIO8, GPIO_Pin_1, Bit_SET);
      GPIO_WriteBit(GPIO8, GPIO_Pin_2, Bit_SET);
      GPIO_WriteBit(GPIO8, GPIO_Pin_3, Bit_SET);

      /* Insert delay */
      Delay(0x1FFFFF);

      /* Turn OFF leds connected to 88.0 pins */
      GPIO_WriteBit(GPIO8, GPIO_Pin_0, Bit_RESET);
      GPIO_WriteBit(GPIO8, GPIO_Pin_1, Bit_RESET);
      GPIO_WriteBit(GPIO8, GPIO_Pin_2, Bit_RESET);
      GPIO_WriteBit(GPIO8, GPIO_Pin_3, Bit_RESET);

      /* Insert delay */
      Delay(0x1FFFFF);
   }
}

void SCU_Configuration(void)
{

// FMI_BankRemapConfig(4, 2, 0x00000000, 0x80000); /* Set Flash banks size & address */
   FMI_Config(FMI_READ_WAIT_STATE_2, FMI_WRITE_WAIT_STATE_0, FMI_PWD_ENABLE,\
               FMI_LVD_ENABLE, FMI_FREQ_HIGH); /* FMI Waite States */

   SCU_MCLKSourceConfig(SCU_MCLK_OSC);

   SCU_PLLFactorsConfig(192,25,2);            /* PLL = 96 MHz */
   SCU_PLLCmd(ENABLE);                        /* PLL Enabled  */

   SCU_RCLKDivisorConfig(SCU_RCLK_Div1);    /* RCLK @96Mhz */
   SCU_HCLKDivisorConfig(SCU_HCLK_Div1);    /* AHB  @96Mhz */
   SCU_FMICLKDivisorConfig(SCU_FMICLK_Div1);/* FMI  @96Mhz */
   SCU_PCLKDivisorConfig(SCU_PCLK_Div2);    /* APB  @48Mhz */
   SCU_MCLKSourceConfig(SCU_MCLK_PLL);      /* MCLK @96Mhz */

   /* Set the PCLK Clock to MCLK/2 */
   SCU_PCLKDivisorConfig(SCU_PCLK_Div2);

   /* Enable VIC clock */
   SCU_APBPeriphClockConfig(__VIC, ENABLE);
   SCU_APBPeriphReset(__VIC, DISABLE);

   /* Enable the GPIO8 Clock */
   SCU_APBPeriphClockConfig(__GPIO8, ENABLE);
 
   /* Enable the clock for the GPIO3 */
   SCU_APBPeriphClockConfig(__GPIO3, ENABLE);

}

/* GPIO Configuration --------------------------------------------------------*/
void GPIO_Configuration(void)
{
   GPIO_DeInit(GPIO8);
   GPIO_DeInit(GPIO3);                         /* GPIO3 Deinitialization */
   /* LED */
   GPIO_InitStructure.GPIO_Direction = GPIO_PinOutput;
   GPIO_InitStructure.GPIO_Pin       = GPIO_Pin_All;
   GPIO_InitStructure.GPIO_Type      = GPIO_Type_PushPull ;
   GPIO_Init (GPIO8, &GPIO_InitStructure);
   /* button */
   GPIO_InitStructure.GPIO_Direction = GPIO_PinInput;
   GPIO_InitStructure.GPIO_Pin       = GPIO_Pin_0;
   GPIO_InitStructure.GPIO_Type      = GPIO_Type_PushPull ;
   GPIO_Init (GPIO3, &GPIO_InitStructure);

}

void VIC_Configuration(void)
{
   /* reset to default state */
   VIC_DeInit();
}

/*******************************************************************************
* Function Name  : Delay
* Description    : Inserts a delay time.
* Input          : nCount: specifies the delay time length.
*******************************************************************************/
static void Delay(u32 nCount)
{
   u32 j = 0;

   for(j = nCount; j > 0; j--)
      asm("nop");   
}
/************************************** EOF *********************************/

