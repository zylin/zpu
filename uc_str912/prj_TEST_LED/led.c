/****************************************************************************** 
 *                              www.propox.com
 *  MMstr912 - Minimodu³ Ethernetowy z procesorem ARM9 STR912.
 *             Ethernet minimodule with ARM9 STR912 microcontroller.
 *
 *  LED Test - efekt swietlny na diodach led
 *             light effect on LEDs
 *
 *  Do GPIO8 podlaczyc diody (Connect LEDs o GPIO8)
  
 * Includes ------------------------------------------------------------------*/
/* Pliki nag³ówkowe ----------------------------------------------------------*/
/* Library includes. */
#include "91x_lib.h"
#include "91x_gpio.h"
#include "91x_map.h"
#include "91x_scu.h"

//#include <targets/STR912FW44.h> rem Bla


/* Port 8 Configuration */
/* Konfiguracja protu 8 */
void HardwareConf(void)
{
  //Disable reset for GPIO8
  //wylaczenie resetu na GPIO8
  SCU_APBPeriphReset(__GPIO8, DISABLE);
  //Enable clock for GPIO8
  //W³¹czenie zegara na GPIO8
  SCU_APBPeriphClockConfig(__GPIO8, ENABLE);
}


/* Port 8 Configuration */
/* Konfiguracja protu 8 */
void LED_DataLinesConfig()
{
  /* Private typedef */
  /* Deklaracja struktury */
  GPIO_InitTypeDef GPIO_InitStructure;

    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_All;
    /* Configure D0~D7 lines in Output Push-Pull mode */
    /* Konfiguracja lini portu 8 jako wyjsc w trybie push-pull */
    GPIO_InitStructure.GPIO_Alternate = GPIO_OutputAlt1;
    GPIO_InitStructure.GPIO_Direction = GPIO_PinOutput;
    GPIO_InitStructure.GPIO_Type = GPIO_Type_PushPull;

  GPIO_Init(GPIO8, &GPIO_InitStructure);
}

 
/* Delay */
/* Opoznienie */
void delay(int time)
{
  while(time--) 
	asm volatile ("nop");  
}

/******************** LEDs Functions **************************/
/**************************************************************/
/* LED Flashing */
/* Miganie diody LED */
void LEDflashing(int GPIO_Pin_x)
{
  /* Reset pin P8.x */
  GPIO_WriteBit(GPIO8, GPIO_Pin_x, Bit_RESET);
  delay(200000);
  /* Set pin P8.x */
  GPIO_WriteBit(GPIO8, GPIO_Pin_x, Bit_SET);
  delay(200000);
}
/* LED on */
/* zapalenie diody LED */
void LEDon(int GPIO_Pin_x)
{
  /* Reset pin P8.x */
  GPIO_WriteBit(GPIO8, GPIO_Pin_x, Bit_RESET);
}
/* LED off */
/* zgaszenie diody LED */
void LEDoff(int GPIO_Pin_x)
{
  /* Set pin P8.x */
  GPIO_WriteBit(GPIO8, GPIO_Pin_x, Bit_SET);
}
/**************************************************************/


int main()
{
//Hardware Configuration
//Konfiguracja sprzetu
HardwareConf();
//Port Configuration
//Konfiguracja portu 
LED_DataLinesConfig();

while(1)
{
  LEDflashing(GPIO_Pin_0);
  delay(5000);
  LEDflashing(GPIO_Pin_1);
  delay(5000);
  LEDflashing(GPIO_Pin_2);
  delay(5000);
  LEDflashing(GPIO_Pin_3);
  delay(5000);
  LEDflashing(GPIO_Pin_4);
  delay(5000);
  LEDflashing(GPIO_Pin_5);
  delay(5000);
  LEDflashing(GPIO_Pin_6);
  delay(5000);
  LEDflashing(GPIO_Pin_7);
  delay(5000);
}

return 0;
}
