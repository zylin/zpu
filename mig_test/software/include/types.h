/*
 * $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/hw_sp605/bsp_zpuahb/software/include/types.h $
 * $Date$
 * $Author$
 * $Revision$
 */


#ifndef TYPES_H
#define TYPES_H

////////////////////
// common types

typedef signed char         int8_t;
typedef unsigned char       uint8_t;
                            
typedef short               int16_t;
typedef unsigned short      uint16_t;
                            
typedef long                int32_t;
typedef unsigned long       uint32_t;

typedef long long           int64_t;
typedef unsigned long long  uint64_t;

#define TRUE  (1==1)
#define FALSE (1==0)


////////////////////////////////////////
// common defines

#define set_bit(mem, bv)                  ((mem) |= bv)
#define clear_bit(mem, bv)                ((mem) &= ~bv)
#define toggle_bit(mem, bv)               ((mem) ^= bv)
#define bit_is_set(mem, bv)               (mem & bv)
#define bit_is_clear(mem, bv)             (!(mem & bv))
#define loop_until_bit_is_set(mem, bv)    do {} while( bit_is_clear(mem, bv))
#define loop_until_bit_is_clear(mem, bv)  do {} while( bit_is_set(mem, bv))


#endif // TYPES_H
