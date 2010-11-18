#ifndef COMMON_H
#define COMMON_H

// function pointer for putchar
extern char (* putchar_fp) ();

////////////////////////////////////////
// specific stuff

void putstr(const char *s);
void putbin(unsigned char dataType, unsigned long data);
void puthex(unsigned char dataType, unsigned long data);
void itoa( int z, char* Buffer );
void putint(uint32_t data);

#endif // COMMON_H
