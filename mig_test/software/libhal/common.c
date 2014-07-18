/*
 * $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWF_Internals/FPGA/hw_sp605/bsp_zpuahb/software/libhal/common.c $
 * $Date$
 * $Author$
 * $Revision$
 */


#include <peripherie.h>
#include <stdlib.h>         // utoa, dtostrf (actually not implemented)

////////////////////////////////////////
// common stuff


// libgloss/zpu/syscalls.c work with inbyte and outbyte
char putchar( char c)
{
    return stdout( c);
}



void putstr(const char *s)
{
    while (*s) 
        putchar( *s++);
}
        

/*
    print data in binary format
    prepend 0b
    parameter: dataType - number of bits
*/
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
unsigned char itoa( long z, char* Buffer )
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
    return i; // BLa: Laenge des Buffers zurueckgeben
}

unsigned char utoa( unsigned long i, char *p)
{
    unsigned char length;

    length = 0;
	do {
		*--p = '0' + i % 10;
		i /= 10;
        length++;
	} while (i > 0);
	return length;
}


unsigned char putuint( unsigned long data)
{
    char           str[20];
    unsigned char  length;

    length = utoa( data, str);
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
/*
        putint(       1000); putchar('\n'); // ok
        putint(      10000); putchar('\n'); // ok
        putint(     100000); putchar('\n'); // ok
        putint(    1000000); putchar('\n'); // ok
        putint(   10000000); putchar('\n'); // ok
        putint(  100000000); putchar('\n'); // ok
        putint(  200000000); putchar('\n'); // ok
        putint(  400000000); putchar('\n'); // ok
        putint(  800000000); putchar('\n'); // ok
        putint( 1000000000); putchar('\n'); // ok
        putint( 2000000000); putchar('\n'); // ok
        putint( 4000000000); putchar('\n'); // -294967296 warning: this decimal constant is unsigned only in ISO C90
        putint( 8000000000); putchar('\n'); // -589934592 warning: integer constant is too large for "long" type
*/

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
    putint( data/1000);
    putchar( '.');
    putint( data%1000 );
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

