/******************** (C) COPYRIGHT 2007 PROPOX ********************************
* File Name          : lcd_lib_91x.h
* Author             : PROPOX Team
* Date First Issued  : 09/24/2007 : Version 1.0
* Description        : This file provides all the 2x16 LCD functions.
********************************************************************************
* History:
********************************************************************************
* THE PRESENT SOFTWARE WHICH IS FOR GUIDANCE ONLY AIMS AT PROVIDING CUSTOMERS
* WITH CODING INFORMATION REGARDING THEIR PRODUCTS IN ORDER FOR THEM TO SAVE TIME.
* AS A RESULT, PROPOX SHALL NOT BE HELD LIABLE FOR ANY DIRECT, INDIRECT OR
* CONSEQUENTIAL DAMAGES WITH RESPECT TO ANY CLAIMS ARISING FROM THE
* CONTENT OF SUCH SOFTWARE AND/OR THE USE MADE BY CUSTOMERS OF THE CODING
* INFORMATION CONTAINED HEREIN IN CONNECTION WITH THEIR PRODUCTS.
*******************************************************************************/

/* Define to prevent recursive inclusion ------------------------------------ */
#ifndef _lcd_lib_91x_H
#define _lcd_lib_91x_H

/* Includes ------------------------------------------------------------------*/
#include "91x_lib.h"
#include "91x_gpio.h"

/* Private Definision */
#define D7_set GPIO_WriteBit(GPIO8, GPIO_Pin_3, Bit_SET)
#define D6_set GPIO_WriteBit(GPIO8, GPIO_Pin_2, Bit_SET)
#define D5_set GPIO_WriteBit(GPIO8, GPIO_Pin_1, Bit_SET)
#define D4_set GPIO_WriteBit(GPIO8, GPIO_Pin_0, Bit_SET)

#define D7_reset GPIO_WriteBit(GPIO8, GPIO_Pin_3, Bit_RESET)
#define D6_reset GPIO_WriteBit(GPIO8, GPIO_Pin_2, Bit_RESET)
#define D5_reset GPIO_WriteBit(GPIO8, GPIO_Pin_1, Bit_RESET)
#define D4_reset GPIO_WriteBit(GPIO8, GPIO_Pin_0, Bit_RESET)

#define RS_set GPIO_WriteBit(GPIO8, GPIO_Pin_4, Bit_SET)
#define E_set  GPIO_WriteBit(GPIO8, GPIO_Pin_5, Bit_SET)

#define RS_reset GPIO_WriteBit(GPIO8, GPIO_Pin_4, Bit_RESET)
#define E_reset  GPIO_WriteBit(GPIO8, GPIO_Pin_5, Bit_RESET)

void delay(int time);
void LCDinit(void);
void LCDsendChar(u8 ch);
void LCDsendCommand(u8 cmd);
void LCDclr(void);
void LCDhome(void);
void LCDstring(u8* data, u8 nBytes);
void LCDGotoXY(u8 row, u8 column);
void LCDshiftLeft(u8 right);
void LCDshiftRight(u8 left);
void LCDcursorOn(void);
void LCDcursorOnBlink(void);
void LCDcursorOFF(void);
void LCDblank(void);
void LCDvisible(void);
void LCDcursorLeft(u8 left);
void LCDcursorRight(u8 right);

#endif /* _lcd_lib_91x_H */


/******************* (C) COPYRIGHT 2007 PROPOX *****END OF FILE****/
