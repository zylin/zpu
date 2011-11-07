/******************** (C) COPYRIGHT 2007 PROPOX ********************************
* File Name          : lcd_lib_91x.c
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

/* Includes ------------------------------------------------------------------*/
#include "91x_lib.h"
#include "91x_gpio.h"
#include "91x_map.h"
#include "91x_scu.h"
#include "lcd_lib_91x.h"


/*******************************************************************************
* Function Name  : delay
* Description    : Delay (opoznienie)
*                  
* Input          : time - number of cycles
* Output         : None
* Return         : None
*******************************************************************************/
void delay(int time)
{
  while(time--) 
	asm volatile ("nop");
}

/*******************************************************************************
* Function Name  : LCDinit
* Description    : Inicialize LCD (Inicjalizacja LCD)
*                  (4 bit data, 2 lines, characters 5x7, blinking cursor on)
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void LCDinit(void)
{
  GPIO_Write(GPIO8, 0x00);
  delay(375000); //15ms
  //--------- Write 0x03 ----------- 
  D7_reset;
  D6_reset;
  D5_set;
  D4_set;
  E_set;
  delay(25000); //1ms
  E_reset;
  delay(125000); //5ms
  //--------- Write 0x03 -----------
  D7_reset;
  D6_reset;
  D5_set;
  D4_set;
  E_set;
  delay(25000); //1ms
  E_reset;
  delay(25000); //1ms
  //--------- Write 0x03 -----------
  D7_reset;
  D6_reset;
  D5_set;
  D4_set;
  E_set;
  delay(25000); //1ms
  E_reset;
  delay(25000); //1ms
  //--------- Enable Four Bit Mode ----------
  D7_reset;
  D6_reset;
  D5_set;
  D4_reset;
  E_set;
  delay(25000); //1ms
  E_reset;
  delay(25000); //1ms
  //---------- Set Interface Length ----------
  //Write 0x2 - 4 bits
  D7_reset;
  D6_reset;
  D5_set;
  D4_reset;
  E_set;
  delay(25000); //1ms
  E_reset;
  delay(25000); //1ms
  //Write 0x8 - 2 lines, 5x7
  D7_set;
  D6_reset;
  D5_reset;
  D4_reset;
  E_set;
  delay(25000); //1ms
  E_reset;
  delay(25000); //1ms
  //---------- Turn off the Display ----------
  //Write 0x0
  D7_reset;
  D6_reset;
  D5_reset;
  D4_reset;
  E_set;
  delay(25000); //1ms
  E_reset;
  delay(25000); //1ms
  //Write 0x8
  D7_set;
  D6_reset;
  D5_reset;
  D4_reset;
  E_set;
  delay(25000); //1ms
  E_reset;
  delay(25000); //1ms
  //------------ Clear the Display ----------- 
  //Write 0x0
  D7_reset;
  D6_reset;
  D5_reset;
  D4_reset;
  E_set;
  delay(25000); //1ms
  E_reset;
  delay(25000); //1ms
  //Write 0x1
  D7_reset;
  D6_reset;
  D5_reset;
  D4_set;
  E_set;
  delay(25000); //1ms
  E_reset;
  delay(25000); //1ms
  //-------- Set Cursor Move Direction -------- 
  //Write 0x0
  D7_reset;
  D6_reset;
  D5_reset;
  D4_reset;
  E_set;
  delay(25000); //1ms
  E_reset;
  delay(25000); //1ms
  //Write 0x6 - Increment the Cursor
  D7_reset;
  D6_set;
  D5_set;
  D4_reset;
  E_set;
  delay(25000); //1ms
  E_reset;
  delay(25000); //1ms
  //---------- Enable Display/Cursor ----------
  //Write 0x0
  D7_reset;
  D6_reset;
  D5_reset;
  D4_reset;
  E_set;
  delay(25000); //1ms
  E_reset;
  delay(25000); //1ms
  //Write 0xF - Display on, cursor on, blink on 
  D7_set;
  D6_set;
  D5_set;
  D4_set;
  E_set;
  delay(25000); //1ms
  E_reset;
  delay(25000); //1ms
}

/*******************************************************************************
* Function Name  : LCDsendChar
* Description    : Send Char to LCD (Wyslanie znaku na LCD)
*    
* Input          : ch - is a ascii code of character or char from char_code.h
* Output         : None
* Return         : None
*******************************************************************************/
void LCDsendChar(u8 ch)		
{ 
  //4 MSB bits
  //4 starsze bity
  GPIO_Write(GPIO8, (ch>>4) & 0x0f);
  RS_set;
  E_set; 
  delay(25000);
  E_reset;	
  delay(25000);
  //4 LSB bits
  //4 mlodsze bity
  GPIO_Write(GPIO8, ch & 0x0f);
  RS_set;
  E_set; 
  delay(25000);
  E_reset;
  delay(25000);
}

/*******************************************************************************
* Function Name  : LCDsendCommand
* Description    : Send Command to LCD (Wyslanie rozkazu do LCD)
*    
* Input          : cmd - is a ascii code of command
* Output         : None
* Return         : None
*******************************************************************************/
void LCDsendCommand(u8 cmd)		
{ 
  //4 MSB bits
  //4 starsze bity
  GPIO_Write(GPIO8, (cmd>>4) & 0x0f);
  RS_reset;
  E_set; 
  delay(25000);
  E_reset;	
  delay(25000);
  //4 LSB bits
  //4 mlodsze bity
  GPIO_Write(GPIO8, cmd & 0x0f);
  RS_reset;
  E_set; 
  delay(25000);
  E_reset;
  delay(25000);
}

/*******************************************************************************
* Function Name  : LCDclr
* Description    : Clear LCD (Czyszczenie LCD)
*    
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void LCDclr(void)				
{
  LCDsendCommand(0x01);
}

/*******************************************************************************
* Function Name  : LCDhome
* Description    : LCD cursor home (Przesuniecie kursora na pozycje poczatkowa)
*    
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void LCDhome(void)			
{
  LCDsendCommand(0x02);
}

/*******************************************************************************
* Function Name  : LCDstring
* Description    : Outputs string to LCD (Wyswietl ciag znakow na LCD)
*    
* Input          : data - pointer to start of table, nBytes - nuber of bytes to send
* Output         : None
* Return         : None
*******************************************************************************/
void LCDstring(u8* data, u8 nBytes)	
{
  u8 count;
  //check to make sure we have a good pointer
  //sprawdzenie zgodnosci wskaznika
  if (!data) return;

  //print data
  //wyswietl znaki
  for(count=0; count<nBytes; count++)
  {
    LCDsendChar(data[count]);
  }
}

/*******************************************************************************
* Function Name  : LCDGotoXY
* Description    : Cursor to X Y position (Kursor na pozycje XY)
*    
* Input          : row - x position, column - y position
* Output         : None
* Return         : None
*******************************************************************************/
void LCDGotoXY(u8 row, u8 column)	
{
#define LCD_DDRAM             7	

#define LCD_LINE0_DDRAMADDR   0x00
#define LCD_LINE1_DDRAMADDR   0x40
#define LCD_LINE2_DDRAMADDR   0x14
#define LCD_LINE3_DDRAMADDR   0x54

	u8 DDRAMAddr;
	//remap lines into proper order
        //wyznaczenie adresu polozenia
	switch(column)
	{
	case 0:  DDRAMAddr = LCD_LINE0_DDRAMADDR + row; break;
	case 1:  DDRAMAddr = LCD_LINE1_DDRAMADDR + row; break;
	case 2:  DDRAMAddr = LCD_LINE2_DDRAMADDR + row; break;
	case 3:  DDRAMAddr = LCD_LINE3_DDRAMADDR + row; break;
	default: DDRAMAddr = LCD_LINE0_DDRAMADDR + row;
	}
	//set data address
        //wyslanie adresu
	LCDsendCommand(1<<LCD_DDRAM | DDRAMAddr);	
} 

/*******************************************************************************
* Function Name  : LCDshiftLeft
* Description    : Scrol n of characters Right (Przsuniecie znakow o n w prawo)
*    
* Input          : right - number of characters
* Output         : None
* Return         : None
*******************************************************************************/
void LCDshiftLeft(u8 right)	
{
u8 count;
  for (count=0;count<right;count++)
  {
    LCDsendCommand(0x1E);
  }
}

/*******************************************************************************
* Function Name  : LCDshiftRight
* Description    : Scrol n of characters Left (Przsuniecie znakow o n w lewo)
*    
* Input          : left - number of characters
* Output         : None
* Return         : None
*******************************************************************************/
void LCDshiftRight(u8 left)	
{
u8 count;
  for (count=0;count<left;count++)
  {
    LCDsendCommand(0x18);
  }
}

/*******************************************************************************
* Function Name  : LCDcursorOn
* Description    : Displays LCD cursor (Kursor aktywny)
*    
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void LCDcursorOn(void) 
{
  LCDsendCommand(0x0E);
}

/*******************************************************************************
* Function Name  : LCDcursorOnBlink
* Description    : Displays LCD blinking cursor (Migajacy kursor aktywny)
*    
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void LCDcursorOnBlink(void)	
{
  LCDsendCommand(0x0F);
}

/*******************************************************************************
* Function Name  : LCDcursorOFF
* Description    : Turns OFF cursor (Kursor wylaczony)
*    
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void LCDcursorOFF(void)	
{
  LCDsendCommand(0x0C);
}

/*******************************************************************************
* Function Name  : LCDblank
* Description    : Blanks LCD (LCD nieaktywny)
*    
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void LCDblank(void)		
{
  LCDsendCommand(0x08);
}

/*******************************************************************************
* Function Name  : LCDvisible
* Description    : Shows LCD (LCD aktywny)
*    
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void LCDvisible(void)		
{
  LCDsendCommand(0x0C);
}

/*******************************************************************************
* Function Name  : LCDcursorLeft
* Description    : Moves cursor by n poisitions left (Kursor n pozycji w lewo)
*    
* Input          : left - number of positions
* Output         : None
* Return         : None
*******************************************************************************/
void LCDcursorLeft(u8 left)	
{
u8 count;
  for (count=0;count<left;count++)
  {
    LCDsendCommand(0x10);
  }
}

/*******************************************************************************
* Function Name  : LCDcursorRight
* Description    : Moves cursor by n poisitions right (Kursor n pozycji w prawo)
*    
* Input          : right - number of positions
* Output         : None
* Return         : None
*******************************************************************************/
void LCDcursorRight(u8 right)	
{
u8 count;
  for (count=0;count<right;count++)
  {
    LCDsendCommand(0x14);
  }
}

/******************* (C) COPYRIGHT 2007 PROPOX *****END OF FILE****/
