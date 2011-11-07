/******************** (C) COPYRIGHT 2006 STMicroelectronics ********************
* File Name          : main.c
* Author             : MCD Application Team
* Date First Issued  : 05/18/2006 : Version 1.0
* Description        : Main program body
********************************************************************************
* History:
* 05/24/2006 : Version 1.1
* 05/18/2006 : Version 1.0
********************************************************************************
* THE PRESENT SOFTWARE WHICH IS FOR GUIDANCE ONLY AIMS AT PROVIDING CUSTOMERS
* WITH CODING INFORMATION REGARDING THEIR PRODUCTS IN ORDER FOR THEM TO SAVE TIME.
* AS A RESULT, STMICROELECTRONICS SHALL NOT BE HELD LIABLE FOR ANY DIRECT,
* INDIRECT OR CONSEQUENTIAL DAMAGES WITH RESPECT TO ANY CLAIMS ARISING FROM THE
* CONTENT OF SUCH SOFTWARE AND/OR THE USE MADE BY CUSTOMERS OF THE CODING
* INFORMATION CONTAINED HEREIN IN CONNECTION WITH THEIR PRODUCTS.
*******************************************************************************/

/* Includes ------------------------------------------------------------------*/
#include "91x_lib.h"

/* Private typedef -----------------------------------------------------------*/
/* Private define ------------------------------------------------------------*/
/* Private macro -------------------------------------------------------------*/
/* Private variables ---------------------------------------------------------*/
  GPIO_InitTypeDef GPIO_InitStructure;

/* Private function prototypes -----------------------------------------------*/
  void SCU_Configuration(void);
  static void Delay(u32 nCount);

/* Private functions ---------------------------------------------------------*/
/*******************************************************************************
* Function Name  : main
* Description    : Main program
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
int main()
{
  /* Configure the system clocks */
  SCU_Configuration();

/* GPIO Configuration --------------------------------------------------------*/
  GPIO_DeInit(GPIO8);
  GPIO_InitStructure.GPIO_Direction = GPIO_PinOutput;
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_0 | GPIO_Pin_2 | GPIO_Pin_4 | GPIO_Pin_6;
  GPIO_InitStructure.GPIO_Type = GPIO_Type_PushPull ;
  GPIO_Init (GPIO8, &GPIO_InitStructure);

  while(1)
  {
    /* Turn OFF leds connected to P9.0, P9.1, P9.2 and P9.3 pins */
    GPIO_WriteBit(GPIO8, GPIO_Pin_0, Bit_SET);
    Delay(0x7FFFF);
    GPIO_WriteBit(GPIO8, GPIO_Pin_2, Bit_SET);
    Delay(0x7FFFF);
    GPIO_WriteBit(GPIO8, GPIO_Pin_4, Bit_SET);
    Delay(0x7FFFF);
    GPIO_WriteBit(GPIO8, GPIO_Pin_6, Bit_SET);
    Delay(0x7FFFF);
    /* Turn ON leds connected to P9.0, P9.1, P9.2 and P9.3 pins */
    GPIO_WriteBit(GPIO8, GPIO_Pin_0, Bit_RESET);
    Delay(0x7FFFF);
    GPIO_WriteBit(GPIO8, GPIO_Pin_2, Bit_RESET);
    Delay(0x7FFFF);
    GPIO_WriteBit(GPIO8, GPIO_Pin_4, Bit_RESET);
    Delay(0x7FFFF);
    GPIO_WriteBit(GPIO8, GPIO_Pin_6, Bit_RESET);
    Delay(0x7FFFF);
  }
}

/*******************************************************************************
* Function Name  : SCU_Configuration
* Description    : Configures the system clocks.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void SCU_Configuration(void)
{
  /* Enable the __GPIO9 */
  SCU_APBPeriphClockConfig(__GPIO8 ,ENABLE);
}

/*******************************************************************************
* Function Name  : Delay
* Description    : Inserts a delay time.
* Input          : nCount: specifies the delay time length.
* Output         : None
* Return         : None
*******************************************************************************/
static void Delay(u32 nCount)
{
  u32 j = 0;

  for(j = nCount; j != 0; j--);
}
/******************* (C) COPYRIGHT 2006 STMicroelectronics *****END OF FILE****/

