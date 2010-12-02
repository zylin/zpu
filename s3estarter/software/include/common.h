#ifndef COMMON_H
#define COMMON_H

////////////////////////////////////////
// specific stuff

char putchar( char c);
void putstr(const char *s);
void putbin(unsigned char dataType, unsigned long data);
void puthex(unsigned char dataType, unsigned long data);
void itoa( int z, char* Buffer );
void putint(unsigned long data);

#endif // COMMON_H
