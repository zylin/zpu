//#include <stdio.h>

#include <peripherie.h>


////////////////////////////////////////
// common defines

#define bit_is_set(mem, bv)               (mem & bv)
#define bit_is_clear(mem, bv)             (!(mem & bv))
#define loop_until_bit_is_set(mem, bv)    do {} while( bit_is_clear(mem, bv))
#define loop_until_bit_is_clear(mem, bv)  do {} while( bit_is_set(mem, bv))

////////////////////////////////////////
// specific stuff

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



uint8_t vga_line;
uint8_t vga_column;

void vga_init( void)
{
    vga0->background_color = 0x00000000;
    vga0->foreground_color = 0x00ffffff;
    vga_line               = 0;
    vga_column             = 0;
}



void vga_clear( void)
{
    uint32_t count;
    uint32_t count_max = 37*80;

    for(count = 0; count< count_max; count++)
        vga0->data = count<<8;

    vga_line               = 0;
    vga_column             = 0;
}


void vga_putchar( char c)
{

    vga0->data = (( vga_line * 80 + vga_column)<<8) | c;
    if ( (c == '\n') || (vga_column == 79) )
    {
        if (vga_line<36) 
            vga_line++;
        else
            vga_line = 0;

        vga_column = 0;
    }
    else
    {
        vga_column++;
    }
        
}


void vga_putstr(char *s)
{
    while (*s)
        vga_putchar( *s++);
}


void vga_putint(uint32_t data)
{
    char           str[20];

    itoa( data, str);
    vga_putstr( str);
}


void vga_putbin(unsigned char dataType, unsigned long data) 
{
    unsigned char i, temp;
    char dataString[] = "0b                                ";

    for(i=dataType; i>0; i--)
    {
        temp = data % 2;
        dataString [i+1] = temp + 0x30;
        data = data/2;
    }
    vga_putstr( dataString);
}


void vga_puthex(unsigned char dataType, unsigned long data) 
{
    unsigned char count, i, temp;
    char dataString[] = "0x        ";

    if (dataType == 8) count = 2;
    if (dataType == 16) count = 4;
    if (dataType == 32) count = 8;

    for(i=count; i>0; i--)
    {
        temp = data % 16;
        if (temp<10) dataString [i+1] = temp + 0x30;
        else         dataString [i+1] = (temp - 10) + 0x41;

        data = data/16;
    }
    vga_putstr( dataString);
}


