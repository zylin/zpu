/*
 * $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/hw_sp605/bsp_zpuahb/software/include/common.h $
 * $Date$
 * $Author$
 * $Revision$
 */

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

#endif // COMMON_H
