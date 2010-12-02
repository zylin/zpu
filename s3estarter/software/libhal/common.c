
#include "peripherie.h"

////////////////////////////////////////
// common stuff



char putchar( char c)
{
    return putchar_fp( c);
}


void putstr(const char *s)
{
    while (*s) 
        putchar( *s++);
}
        

void putbin( unsigned char dataType, unsigned long data) 
{
    unsigned char i, temp;
    char dataString[] = "0b                                ";

    for(i=dataType; i>0; i--)
    {
        temp = data % 2;
        dataString [i+1] = temp + 0x30;
        data = data/2;
    }
    putstr( dataString);
}


// http://asalt-vehicle.googlecode.com/svn› trunk› src› uart.c
void puthex( unsigned char dataType, unsigned long data) 
{
    unsigned char count = 8; // number of chars 
    unsigned char i;
    unsigned char temp;
    char          dataString[] = "        ";

    // dataType = bit width
    if (dataType == 8)  count = 2;
    if (dataType == 16) count = 4;

    for(i=count; i>0; i--)
    {
        temp = data % 16;
        if (temp<10) dataString [i-1] = temp + 0x30;
        else         dataString [i-1] = (temp - 10) + 0x41;

        data = data/16;
    }
    dataString[count] = '\0';
    putstr( dataString);
}



// http://www.mikrocontroller.net/articles/FAQ#itoa.28.29
void itoa( int z, char* Buffer )
{
  int i = 0;
  int j;
  char tmp;
  unsigned u;    // In u bearbeiten wir den Absolutbetrag von z.
  
    // ist die Zahl negativ?
    // gleich mal ein - hinterlassen und die Zahl positiv machen
    if( z < 0 ) {
      Buffer[0] = '-';
      Buffer++;
      // -INT_MIN ist idR. größer als INT_MAX und nicht mehr 
      // als int darstellbar! Man muss daher bei der Bildung 
      // des Absolutbetrages aufpassen.
      u = ( (unsigned)-(z+1) ) + 1; 
    }
    else { 
      u = (unsigned)z;
    }
    // die einzelnen Stellen der Zahl berechnen
    do {
      Buffer[i++] = '0' + u % 10;
      u /= 10;
    } while( u > 0 );
 
    // den String in sich spiegeln
    for( j = 0; j < i / 2; ++j ) {
      tmp = Buffer[j];
      Buffer[j] = Buffer[i-j-1];
      Buffer[i-j-1] = tmp;
    }
    Buffer[i] = '\0';
}


void putint( unsigned long data)
{
    char           str[20];

    itoa( data, str);
    putstr( str);
}



