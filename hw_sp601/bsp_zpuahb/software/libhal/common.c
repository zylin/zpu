
#include <peripherie.h>
#include <stdlib.h>       // utoa, dtostrf


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
unsigned char puthex( unsigned char dataType, unsigned long data) 
{
    unsigned char count = 8; // number of chars 
    unsigned char i;
    unsigned char temp;
    char          dataString[] = "        ";

    // dataType = bit width
    if (dataType == 4)  count = 1;
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

    return count; // return length
}



// http://www.mikrocontroller.net/articles/FAQ#itoa.28.29
unsigned char itoa( int z, char* Buffer )
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
    // Laengenkorrektur wg. Vorzeichen
    if (z < 0)
        i++;
    return i; // BLa: Laenge des BUffers zurueckgeben
}


void DecToString (unsigned char *str, unsigned int value, unsigned char max_chars, 
                  unsigned char type)

/*
This function converts a decimal number into a string. 
As it features some formatting, it can be used as a small 
replacement for sprintf().

str       = output string
value     = input integer
max_chars = number of output characters
type      = type of leading characters (0='0', 1=' ' )

Note: 
For less memory consumption this implementaion can only handle integers.
But if you adjust the type of the "value" and "factor" variables, this 
function can easily handle bigger numbers than integer!

written by Oliver Keller <oli@deswahnsinnsfettebeute.de>
06.04.2004
*/

{
  unsigned char i=0;
  unsigned char digit_count=0;
  unsigned char leading_count=0;  //number of _needed_  leading characters
  unsigned int  factor=1;
  unsigned char number=0;

  while(value / factor){       
    digit_count++;            //count digits
    factor = factor * 10;      //calculate factor
  }
 
  factor /= 10;

  if (digit_count)
  leading_count=max_chars - digit_count;
  else
  leading_count=max_chars - digit_count - 1;

  while(i < leading_count){      //fill up leading chars
     if(type){
       str[i++]=' ';  
     }
     else{
       str[i++]='0';
     }
  }

  if (digit_count){

     while(factor){        //convert into chars
  
       number = value / factor; 
       value %= factor;
       factor /= 10;
       str[i++] = number + 48;
     }
  }
  else{
   
    str[i++]='0';        //keep at least one zero!

  }

  str[i++]='\0';

}

unsigned char putuint( unsigned long data)
{
    char           str[20];
    unsigned char  length = 0;

    //length = utoa( data, str);
    DecToString( str, data, 19, ' ');
    putstr( str);
    return length;
}


unsigned char putint( long data)
{
    char           str[20];
    unsigned char  length;

    length = itoa( data, str);
    putstr( str);
    return length;
}


unsigned char putbool( int data)
{
    if (data)
    {
        putstr( "yes");
    }
    else
    {
        putstr( "no");
    }
    return 0;
}


unsigned char putfloat( float data)
{
    char           str[20];
    unsigned char  length;

    length = dtostrf( data, 2, 1, str);
    putstr( str);
    return length;
}


// p means pseudo float 
// (an integer with 3 significant digits after the point)
void putpfloat( unsigned long data)
{
    putint( (unsigned int)(data/1000));
    putchar( '.');
    putint( data%1000 );
}


/*
    print some spaces to make output alignment columnwise
*/
void fill( unsigned char length, unsigned char fillupto)
{
    while (length < fillupto)
    {
        putchar(' ');
        length++;
    }
}


