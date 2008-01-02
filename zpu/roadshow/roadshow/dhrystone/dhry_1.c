/*
 ****************************************************************************
 *
 *                   "DHRYSTONE" Benchmark Program
 *                   -----------------------------
 *                                                                            
 *  Version:    C, Version 2.1
 *                                                                            
 *  File:       dhry_1.c (part 2 of 3)
 *
 *  Date:       May 25, 1988
 *
 *  Author:     Reinhold P. Weicker
 *
 ****************************************************************************
 */

#include "dhry.h"
#include <stdarg.h>

static int
_cvt(int val, char *buf, int radix, char *digits)
{
    char temp[80];
    char *cp = temp;
    int length = 0;

    if (val == 0) {
        /* Special case */
        *cp++ = '0';
    } else {
        while (val) {
            *cp++ = digits[val % radix];
            val /= radix;
        }
    }
    while (cp != temp) {
        *buf++ = *--cp;
        length++;
    }
    *buf = '\0';
    return (length);
}

#define is_digit(c) ((c >= '0') && (c <= '9'))


#ifndef TINY
static int
_vprintf(void (*putc)(char c, void **param), void **param, const char *fmt, va_list ap)
{
    char buf[sizeof(long long)*8];
    char c, sign, *cp=buf;
    int left_prec, right_prec, zero_fill, pad, pad_on_right, 
        i, islong, islonglong;
    long long val = 0;
    int res = 0, length = 0;

    while ((c = *fmt++) != '\0') {
        if (c == '%') {
            c = *fmt++;
            left_prec = right_prec = pad_on_right = islong = islonglong = 0;
            sign = '\0';
            // Fetch value [numeric descriptors only]
            switch (c) {
            case 'd':
                    val = (long long)va_arg(ap, int);
                if ((c == 'd') || (c == 'D')) {
                    if (val < 0) {
                        sign = '-';
                        val = -val;
                    }
                } else {
                    // Mask to unsigned, sized quantity
                    if (islong) {
                        val &= ((long long)1 << (sizeof(long) * 8)) - 1;
                    } else{
                        val &= ((long long)1 << (sizeof(int) * 8)) - 1;
                    }
                }
                break;
            default:
                break;
            }
            // Process output
            switch (c) {
            case 'd':
                switch (c) {
                case 'd':
                    length = _cvt(val, buf, 10, "0123456789");
                    break;
                }
                cp = buf;
                break;
            case 's':
                cp = va_arg(ap, char *);
                length = 0;
                while (cp[length] != '\0') length++;
                break;
            case 'c':
                c = va_arg(ap, int /*char*/);
                (*putc)(c, param);
                res++;
                continue;
            default:
                (*putc)('%', param);
                (*putc)(c, param);
                res += 2;
                continue;
            }
            while (length-- > 0) {
                c = *cp++;
                (*putc)(c, param);
                res++;
            }
        } else {
            (*putc)(c, param);
            res++;
        }
    }
    return (res);
}
#endif

// Default wrapper function used by diag_printf
static void
_diag_write_char(char c, void **param)
{
	if (c=='\n')
	{
		outbyte('\r');
	}
	outbyte(c);
}

int
small_printf(const char *fmt, ...)
{
#ifndef TINY
    va_list ap;
    int ret;

    va_start(ap, fmt);
    ret = _vprintf(_diag_write_char, (void **)0, fmt, ap);
    va_end(ap);
    return (ret);
#else
	return 0;
#endif
}




/* Global Variables: */

Rec_Pointer     Ptr_Glob,
                Next_Ptr_Glob;
int             Int_Glob;
Boolean         Bool_Glob;
char            Ch_1_Glob,
                Ch_2_Glob;
int             Arr_1_Glob [50];
int             Arr_2_Glob [50] [50];

Enumeration     Func_1 ();
  /* forward declaration necessary since Enumeration may not simply be int */

#ifndef REG
        Boolean Reg = false;
#define REG
        /* REG becomes defined as empty */
        /* i.e. no register variables   */
#else
        Boolean Reg = true;
#endif

/* variables for time measurement: */

#ifdef TIMES
struct tms      time_info;
                /* see library function "times" */
#define Too_Small_Time 120
                /* Measurements should last at least about 2 seconds */
#endif
#ifdef TIME
extern long     time();
                /* see library function "time"  */
#define Too_Small_Time 2
                /* Measurements should last at least 2 seconds */
#endif

long long           Begin_Time,
                End_Time,
                User_Time;
long long            Microseconds,
                Dhrystones_Per_Second,
                Vax_Mips;
                
/* end of variables for time measurement */

int             Number_Of_Runs = 50000;

extern long long _readMicroseconds();


int main ()
/*****/

  /* main program, corresponds to procedures        */
  /* Main and Proc_0 in the Ada version             */
{
        One_Fifty       Int_1_Loc;
  REG   One_Fifty       Int_2_Loc;
        One_Fifty       Int_3_Loc;
  REG   char            Ch_Index;
        Enumeration     Enum_Loc;
        Str_30          Str_1_Loc;
        Str_30          Str_2_Loc;
  REG   int             Run_Index;

  /* Initializations */

  Next_Ptr_Glob = (Rec_Pointer) malloc (sizeof (Rec_Type));
  Ptr_Glob = (Rec_Pointer) malloc (sizeof (Rec_Type));

  Ptr_Glob->Ptr_Comp                    = Next_Ptr_Glob;
  Ptr_Glob->Discr                       = Ident_1;
  Ptr_Glob->variant.var_1.Enum_Comp     = Ident_3;
  Ptr_Glob->variant.var_1.Int_Comp      = 40;
  strcpy (Ptr_Glob->variant.var_1.Str_Comp, 
          "DHRYSTONE PROGRAM, SOME STRING");
  strcpy (Str_1_Loc, "DHRYSTONE PROGRAM, 1'ST STRING");

  Arr_2_Glob [8][7] = 10;
        /* Was missing in published program. Without this statement,    */
        /* Arr_2_Glob [8][7] would have an undefined value.             */
        /* Warning: With 16-Bit processors and Number_Of_Runs > 32000,  */
        /* overflow may occur for this array element.                   */
  small_printf ("\n");
  small_printf ("Dhrystone Benchmark, Version 2.1 (Language: C)\n");
  small_printf ("\n");
  if (Reg)
  {
    small_printf ("Program compiled with 'register' attribute\n");
    small_printf ("\n");
  }
  else
  {
    small_printf ("Program compiled without 'register' attribute\n");
    small_printf ("\n");
  }
  Number_Of_Runs;

  small_printf ("Execution starts, %d runs through Dhrystone\n", Number_Of_Runs);

  /***************/
  /* Start timer */
  /***************/

#if 0
#ifdef TIMES
  times (&time_info);
  Begin_Time = (long) time_info.tms_utime;
#endif
#ifdef TIME
  Begin_Time = time ( (long *) 0);
#endif
#else
  Begin_Time = _readMicroseconds();
#endif
  for (Run_Index = 1; Run_Index <= Number_Of_Runs; ++Run_Index)
  {

    Proc_5();
    Proc_4();
      /* Ch_1_Glob == 'A', Ch_2_Glob == 'B', Bool_Glob == true */
    Int_1_Loc = 2;
    Int_2_Loc = 3;
    strcpy (Str_2_Loc, "DHRYSTONE PROGRAM, 2'ND STRING");
    Enum_Loc = Ident_2;
    Bool_Glob = ! Func_2 (Str_1_Loc, Str_2_Loc);
      /* Bool_Glob == 1 */
    while (Int_1_Loc < Int_2_Loc)  /* loop body executed once */
    {
      Int_3_Loc = 5 * Int_1_Loc - Int_2_Loc;
        /* Int_3_Loc == 7 */
      Proc_7 (Int_1_Loc, Int_2_Loc, &Int_3_Loc);
        /* Int_3_Loc == 7 */
      Int_1_Loc += 1;
    } /* while */
      /* Int_1_Loc == 3, Int_2_Loc == 3, Int_3_Loc == 7 */
    Proc_8 (Arr_1_Glob, Arr_2_Glob, Int_1_Loc, Int_3_Loc);
      /* Int_Glob == 5 */
    Proc_1 (Ptr_Glob);
    for (Ch_Index = 'A'; Ch_Index <= Ch_2_Glob; ++Ch_Index)
                             /* loop body executed twice */
    {
      if (Enum_Loc == Func_1 (Ch_Index, 'C'))
          /* then, not executed */
        {
        Proc_6 (Ident_1, &Enum_Loc);
        strcpy (Str_2_Loc, "DHRYSTONE PROGRAM, 3'RD STRING");
        Int_2_Loc = Run_Index;
        Int_Glob = Run_Index;
        }
    }
      /* Int_1_Loc == 3, Int_2_Loc == 3, Int_3_Loc == 7 */
    Int_2_Loc = Int_2_Loc * Int_1_Loc;
    Int_1_Loc = Int_2_Loc / Int_3_Loc;
    Int_2_Loc = 7 * (Int_2_Loc - Int_3_Loc) - Int_1_Loc;
      /* Int_1_Loc == 1, Int_2_Loc == 13, Int_3_Loc == 7 */
    Proc_2 (&Int_1_Loc);
      /* Int_1_Loc == 5 */

  } /* loop "for Run_Index" */

  /**************/
  /* Stop timer */
  /**************/
  
#if 0
#ifdef TIMES
  times (&time_info);
  End_Time = (long) time_info.tms_utime;
#endif
#ifdef TIME
  End_Time = time ( (long *) 0);
#endif
#else
  End_Time = _readMicroseconds();
#endif
  
  small_printf ("Execution ends\n");
  small_printf ("\n");
  small_printf ("Final values of the variables used in the benchmark:\n");
  small_printf ("\n");
  small_printf ("Int_Glob:            %d\n", Int_Glob);
  small_printf ("        should be:   %d\n", 5);
  small_printf ("Bool_Glob:           %d\n", Bool_Glob);
  small_printf ("        should be:   %d\n", 1);
  small_printf ("Ch_1_Glob:           %c\n", Ch_1_Glob);
  small_printf ("        should be:   %c\n", 'A');
  small_printf ("Ch_2_Glob:           %c\n", Ch_2_Glob);
  small_printf ("        should be:   %c\n", 'B');
  small_printf ("Arr_1_Glob[8]:       %d\n", Arr_1_Glob[8]);
  small_printf ("        should be:   %d\n", 7);
  small_printf ("Arr_2_Glob[8][7]:    %d\n", Arr_2_Glob[8][7]);
  small_printf ("        should be:   Number_Of_Runs + 10\n");
  small_printf ("Ptr_Glob->\n");
  small_printf ("  Ptr_Comp:          %d\n", (int) Ptr_Glob->Ptr_Comp);
  small_printf ("        should be:   (implementation-dependent)\n");
  small_printf ("  Discr:             %d\n", Ptr_Glob->Discr);
  small_printf ("        should be:   %d\n", 0);
  small_printf ("  Enum_Comp:         %d\n", Ptr_Glob->variant.var_1.Enum_Comp);
  small_printf ("        should be:   %d\n", 2);
  small_printf ("  Int_Comp:          %d\n", Ptr_Glob->variant.var_1.Int_Comp);
  small_printf ("        should be:   %d\n", 17);
  small_printf ("  Str_Comp:          %s\n", Ptr_Glob->variant.var_1.Str_Comp);
  small_printf ("        should be:   DHRYSTONE PROGRAM, SOME STRING\n");
  small_printf ("Next_Ptr_Glob->\n");
  small_printf ("  Ptr_Comp:          %d\n", (int) Next_Ptr_Glob->Ptr_Comp);
  small_printf ("        should be:   (implementation-dependent), same as above\n");
  small_printf ("  Discr:             %d\n", Next_Ptr_Glob->Discr);
  small_printf ("        should be:   %d\n", 0);
  small_printf ("  Enum_Comp:         %d\n", Next_Ptr_Glob->variant.var_1.Enum_Comp);
  small_printf ("        should be:   %d\n", 1);
  small_printf ("  Int_Comp:          %d\n", Next_Ptr_Glob->variant.var_1.Int_Comp);
  small_printf ("        should be:   %d\n", 18);
  small_printf ("  Str_Comp:          %s\n",
                                Next_Ptr_Glob->variant.var_1.Str_Comp);
  small_printf ("        should be:   DHRYSTONE PROGRAM, SOME STRING\n");
  small_printf ("Int_1_Loc:           %d\n", Int_1_Loc);
  small_printf ("        should be:   %d\n", 5);
  small_printf ("Int_2_Loc:           %d\n", Int_2_Loc);
  small_printf ("        should be:   %d\n", 13);
  small_printf ("Int_3_Loc:           %d\n", Int_3_Loc);
  small_printf ("        should be:   %d\n", 7);
  small_printf ("Enum_Loc:            %d\n", Enum_Loc);
  small_printf ("        should be:   %d\n", 1);
  small_printf ("Str_1_Loc:           %s\n", Str_1_Loc);
  small_printf ("        should be:   DHRYSTONE PROGRAM, 1'ST STRING\n");
  small_printf ("Str_2_Loc:           %s\n", Str_2_Loc);
  small_printf ("        should be:   DHRYSTONE PROGRAM, 2'ND STRING\n");
  small_printf ("\n");

  User_Time = End_Time - Begin_Time;
  small_printf ("User time: %d\n", (int)User_Time);
  
  if (User_Time < Too_Small_Time)
  {
    small_printf ("Measured time too small to obtain meaningful results\n");
    small_printf ("Please increase number of runs\n");
    small_printf ("\n");
  }
/*   else */
  {
#if 0
#ifdef TIME
    Microseconds = (User_Time * Mic_secs_Per_Second )
                        /  Number_Of_Runs;
    Dhrystones_Per_Second =  Number_Of_Runs / User_Time;
    Vax_Mips = (Number_Of_Runs*1000) / (1757*User_Time);
#else
    Microseconds = (float) User_Time * Mic_secs_Per_Second 
                        / ((float) HZ * ((float) Number_Of_Runs));
    Dhrystones_Per_Second = ((float) HZ * (float) Number_Of_Runs)
                        / (float) User_Time;
    Vax_Mips = Dhrystones_Per_Second / 1757.0;
#endif
#else
    Microseconds = User_Time  / Number_Of_Runs;
    Dhrystones_Per_Second =  ((long long)Number_Of_Runs*1000000) / User_Time;
    Vax_Mips = (((long long)Number_Of_Runs)*1000000000) / (1757*User_Time);
#endif 
    small_printf ("Microseconds for one run through Dhrystone: ");
    small_printf ("%d \n", (int)Microseconds);
    small_printf ("Dhrystones per Second:                      ");
    small_printf ("%d \n", (int)Dhrystones_Per_Second);
    small_printf ("VAX MIPS rating * 1000 = %d \n",(int)Vax_Mips);
    small_printf ("\n");
  }
  
  return 0;
}


Proc_1 (Ptr_Val_Par)
/******************/

REG Rec_Pointer Ptr_Val_Par;
    /* executed once */
{
  REG Rec_Pointer Next_Record = Ptr_Val_Par->Ptr_Comp;  
                                        /* == Ptr_Glob_Next */
  /* Local variable, initialized with Ptr_Val_Par->Ptr_Comp,    */
  /* corresponds to "rename" in Ada, "with" in Pascal           */
  
  structassign (*Ptr_Val_Par->Ptr_Comp, *Ptr_Glob); 
  Ptr_Val_Par->variant.var_1.Int_Comp = 5;
  Next_Record->variant.var_1.Int_Comp 
        = Ptr_Val_Par->variant.var_1.Int_Comp;
  Next_Record->Ptr_Comp = Ptr_Val_Par->Ptr_Comp;
  Proc_3 (&Next_Record->Ptr_Comp);
    /* Ptr_Val_Par->Ptr_Comp->Ptr_Comp 
                        == Ptr_Glob->Ptr_Comp */
  if (Next_Record->Discr == Ident_1)
    /* then, executed */
  {
    Next_Record->variant.var_1.Int_Comp = 6;
    Proc_6 (Ptr_Val_Par->variant.var_1.Enum_Comp, 
           &Next_Record->variant.var_1.Enum_Comp);
    Next_Record->Ptr_Comp = Ptr_Glob->Ptr_Comp;
    Proc_7 (Next_Record->variant.var_1.Int_Comp, 10, 
           &Next_Record->variant.var_1.Int_Comp);
  }
  else /* not executed */
    structassign (*Ptr_Val_Par, *Ptr_Val_Par->Ptr_Comp);
} /* Proc_1 */


Proc_2 (Int_Par_Ref)
/******************/
    /* executed once */
    /* *Int_Par_Ref == 1, becomes 4 */

One_Fifty   *Int_Par_Ref;
{
  One_Fifty  Int_Loc;  
  Enumeration   Enum_Loc;

  Int_Loc = *Int_Par_Ref + 10;
  do /* executed once */
    if (Ch_1_Glob == 'A')
      /* then, executed */
    {
      Int_Loc -= 1;
      *Int_Par_Ref = Int_Loc - Int_Glob;
      Enum_Loc = Ident_1;
    } /* if */
  while (Enum_Loc != Ident_1); /* true */
} /* Proc_2 */


Proc_3 (Ptr_Ref_Par)
/******************/
    /* executed once */
    /* Ptr_Ref_Par becomes Ptr_Glob */

Rec_Pointer *Ptr_Ref_Par;

{
  if (Ptr_Glob != Null)
    /* then, executed */
    *Ptr_Ref_Par = Ptr_Glob->Ptr_Comp;
  Proc_7 (10, Int_Glob, &Ptr_Glob->variant.var_1.Int_Comp);
} /* Proc_3 */


Proc_4 () /* without parameters */
/*******/
    /* executed once */
{
  Boolean Bool_Loc;

  Bool_Loc = Ch_1_Glob == 'A';
  Bool_Glob = Bool_Loc | Bool_Glob;
  Ch_2_Glob = 'B';
} /* Proc_4 */


Proc_5 () /* without parameters */
/*******/
    /* executed once */
{
  Ch_1_Glob = 'A';
  Bool_Glob = false;
} /* Proc_5 */


        /* Procedure for the assignment of structures,          */
        /* if the C compiler doesn't support this feature       */
#ifdef  NOSTRUCTASSIGN
memcpy (d, s, l)
register char   *d;
register char   *s;
register int    l;
{
        while (l--) *d++ = *s++;
}
#endif


