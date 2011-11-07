/******************************************************************************
 *                              www.propox.com
 *  MMstr912 - Minimodu³ Ethernetowy z procesorem ARM9 STR912.
 *             Ethernet minimodule with ARM9 STR912 microcontroller.
 *
 *  LCD Test - wyswietla tekst 'www.propox.com' na LCD
 *             put text 'www.propox.com' on LCD
 *
 *  P8.0, P8.1, P8.2, P8.3 - D4, D5, D6, D7
 *  P8.4, P8.5 - RS, E
  
 * Includes ------------------------------------------------------------------*/
/* Pliki nag³ówkowe ----------------------------------------------------------*/
/* Library includes. */
#include "91x_lib.h"
#include "91x_gpio.h"
#include "91x_map.h"
#include "91x_scu.h"
#include "char_code.h"
#include "lcd_lib_91x.h"

//#include <targets/STR912FW44.h> rem BLa

/* Hardware Configuration */
/* Konfiguracja sprzetu */
void HardwareConf(void)
{
  //Main clock as exesternal oscillator 25MHz
  //G³ówny zegar to kwarc 25MHz
  SCU_MCLKSourceConfig(SCU_MCLK_OSC);
  //Disable reset for GPIO8
  //wylaczenie resetu na GPIO8
  SCU_APBPeriphReset(__GPIO8, DISABLE);
  //Enable clock for GPIO8
  //W³¹czenie zegara na GPIO8
  SCU_APBPeriphClockConfig(__GPIO8, ENABLE);
}


/* Ports Configuration */
/* Konfiguracja protow */
void LCD_DataLinesConfig()
{
  /* Private typedef */
  /* Deklaracja struktury */
  GPIO_InitTypeDef GPIO_InitStructure;

    /* Configure D7~D4 data lines in Output Push-Pull mode */
    /* Konfiguracja lini portu 8 jako wyjsc D7-D4 w trybie push-pull */
    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_0 | GPIO_Pin_1 | GPIO_Pin_2 | GPIO_Pin_3 | GPIO_Pin_4 | GPIO_Pin_5;
    GPIO_InitStructure.GPIO_Alternate = GPIO_OutputAlt1;
    GPIO_InitStructure.GPIO_Direction = GPIO_PinOutput;
    GPIO_InitStructure.GPIO_Type = GPIO_Type_PushPull;
    GPIO_Init(GPIO8, &GPIO_InitStructure);
    
}


int main()
{
u8 web[] = "www.propox.com";
u8 title[] = "MMstr912";

//Hardware Configuration
//Konfiguracja sprzetu
HardwareConf();
//Ports Configuration
//Konfiguracja portow 
LCD_DataLinesConfig();

LCDinit();
LCDcursorOFF();
LCDGotoXY(0,0);
LCDstring(web,14);
delay(250000);
LCDGotoXY(3,1);
LCDstring(title,8);

while(1)
{
  delay(500000);
  LCDshiftLeft(1);
  delay(100000);
  LCDshiftLeft(1);

  delay(500000);
  LCDshiftRight(1);
  delay(100000);
  LCDshiftRight(1);
}

return 0;
}
