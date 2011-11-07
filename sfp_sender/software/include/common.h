#ifndef COMMON_H
#define COMMON_H

////////////////////////////////////////
// specific stuff

char          putchar  ( char c);
void          putstr   ( const char *s);
void          putbin   ( unsigned char dataType, unsigned long data);
unsigned char puthex   ( unsigned char dataType, unsigned long data);
unsigned char itoa     ( int z, char* Buffer );
unsigned char putint   ( unsigned long data);
unsigned char putuint  ( long data);
void          putpfloat( unsigned long data);
void          fill     ( unsigned char length, unsigned char fillupto);

#endif // COMMON_H
