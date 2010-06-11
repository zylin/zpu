#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>

/* Compile: gcc stdio_h_test.c -o stdio_h_test.sun */
#define OUTPUT stdout
#define INPUT  stdin

int vhdlleft(char *s) { int n=strlen(s)+1+1; return atoi(s+n); }

int vhdlright(char *s) { int n=strlen(s)+1+1; return atoi(strchr(s+n, ':')); }

#define VSTRING           'S'
#define VLINE             'L'
#define VBIT              'b'
#define VBIT_VECTOR       'b'
#define VSTD_LOGIC        's'
#define VSTD_LOGIC_VECTOR 's'
#define VARIABLE           char*

char *vhdlptr(char *buf) { char *p; sscanf(buf, "%p", &p); return p; } 

void vhdlptrnew(char *buf, char *new) {
  sprintf(buf, "%p", new); strcpy(buf+strlen(buf)+1, "L");
}
char *vhdlinit(char vtype, int left, int right, char *value) {
  char t[1024], w[1024], *p, new[1024]; int i, j, n, m;

  /* printf("vhdlinit: vtype=%c left=%d right=%d value=%s\n", vtype, left, right, value); */
  if (vtype==VLINE) { n=128; vhdlptrnew(new, 0); } 
  else { 
    n=(left<right)?right-left+1:left-right+1; m=value?strlen(value):0;
    if (m && m!=n) {
      fprintf(stderr, "vhdlinit(%c,%d,%d,%s): initialization value does not match array length\n",
              vtype, left, right, value?value:"");
      exit(1);
    }
    for(i=0; i<n; i++) { new[i]='0'; } new[i]=0; /* default fill */

    if (left<right) {  /* ascending */
      strcpy(new, value?value:"");
    }
    else { /* always store as little endian, array indexing is consistant */
      if (value) { i=0; for(j=strlen(value)-1; j>0; j--) { new[i++]=value[j]; } }
    }
  }
  sprintf(t, "%c%d:%d", vtype, left, right);
  p=(char *)malloc(n+1+strlen(t)+1);
  strcpy(p, new); n=strlen(new);
  strcpy(p+1+n, t);
  return p;
}
char *STRING(int left, int right, char *value) {
  return vhdlinit(VSTRING, left, right, value);
}
char *LINE(char *value) { return vhdlinit(VLINE, 0, 0, value); }

char *BIT(char *value) {
  return vhdlinit(VBIT_VECTOR, 0, 0, value);
}
char *BIT_VECTOR(int left, int right, char *value) {
  return vhdlinit(VBIT_VECTOR, left, right, value);
}
char *STD_LOGIC(char *value) {
  return vhdlinit(VSTD_LOGIC_VECTOR, 0, 0, value);
}
char *STD_LOGIC_VECTOR(int left, int right, char *value) {
  return vhdlinit(VSTD_LOGIC_VECTOR, left, right, value);
}
int vhdltype(char *s) { return *(s+strlen(s)+1); }

char *vhdlcpy(char *d, char *s) {
  int i;
  for(i=0; s[i]; i++) { d[i]=s[i]; }
  d[i]=s[i]; /* first zero */
  for(i=0; s[i]; i++) { d[i]=s[i]; }
  d[i]=s[i]; /* second zero */
  return d;
} 
void DEALLOCATE(char *buf) {
  char *p = vhdlptr(buf);
  if (vhdltype(buf)==VLINE && p) { free(p); vhdlptrnew(buf, 0); }
}
void WRITELINE(FILE *fp, char *buf) { fprintf(fp, "%s\n", vhdlptr(buf)); DEALLOCATE(buf); }

void WRITE(char *buf, char *s) {
  int n; char *p;
  if (vhdltype(buf)==VLINE) {
    if (vhdlptr(buf)) { n=strlen(vhdlptr(buf)); } else { n=0; }
    p=(char *)malloc(n+strlen(s));
    if (vhdlptr(buf)) { strcpy(p, vhdlptr(buf)); DEALLOCATE(buf); }
    if (s)   { strcpy(p, s); }
    vhdlptrnew(buf, p);
  }
}
int uint_pf(char *x) {
  int i, ax=0, n=x?strlen(x):0;

  for(i=n-1; i>=0; i--) { if(x[i]=='1') { ax=2*ax+1; } else { ax=2*ax; } }
  return ax;
}
int int_pf(char *x) {
  int i, ax=0, p, n=x?strlen(x):0;

  for(i=n-1; i>=0; i--) { if(x[i]=='1') { ax=2*ax+1; } else { ax=2*ax; } }
  if (x[n-1]=='1') { p=1; for(i=0; i<n-1; i++) { p=2*p+1; } ax=ax|~p; }
  return ax;
}
char *pf_i(char *s, int i) { static char t[2]; t[0]=s[i]; t[1]=0; return t; }

char *pf(char *x) { /* always return big endian (internal format little endian) */
  int i, j=0, n=x?strlen(x):0; static char t[1024];

  for(i=n-1; i>=0; i--) { t[j++]=x[i]; } t[j]=0;
  return t;
}
char *string(char *s) { return s; }

int main() {
  VARIABLE buf=LINE("");
  VARIABLE x07=BIT_VECTOR(0, 7, "01111111");
  VARIABLE b07=BIT_VECTOR(0, 7, "00110101");
  VARIABLE b70=BIT_VECTOR(7, 0, "11001010");
  VARIABLE s  =STRING(    1, 256, "");
  int i;

#if 0
    for(i=0; i<256; i++) {
      printf("i=%2x isdigit=%d iscntrl=%d isprint=%d\n", i, isdigit(i), iscntrl(i), isprint(i));
    }
#endif

    WRITE(buf, string("--begin test;")); WRITELINE(OUTPUT, buf);

    printf("abc ");
    printf("def\n");

    printf("x07 signed   decimal %%d=%d == -2\n",int_pf(x07));

    printf("variable b07: bit_vector(0 to 7):=00110101; --initialize as little endian\n");
    printf("b07(7)=%s ",  pf_i(b07,7));
    printf("b07(6)=%s ",  pf_i(b07,6));
    printf("b07(5)=%s ",  pf_i(b07,5));
    printf("b07(4)=%s ",  pf_i(b07,4));
    printf("b07(3)=%s ",  pf_i(b07,3));
    printf("b07(2)=%s ",  pf_i(b07,2));
    printf("b07(1)=%s ",  pf_i(b07,1));
    printf("b07(0)=%s\n", pf_i(b07,0));

    printf("b07 unsigned string  %%s=%s == 10101100 (print as big endian)\n", pf(b07));
    printf("b07 unsigned hex     %%x=%x == ac\n", uint_pf(b07));
    printf("b07 unsigned octal   %%o=%o == 254\n",uint_pf(b07));
    printf("b07 unsigned decimal %%u=%u == 172\n",uint_pf(b07));
    printf("b07 signed   decimal %%d=%d == -84\n",int_pf(b07));
    printf("b07 %%5x=[%5x] == [   ac]\n",         uint_pf(b07));
    printf("b07 %%05x=%05x == 000ac\n",           uint_pf(b07));
    printf("b07 %%#x=%#x == 0xac\n",              uint_pf(b07));
    printf("b07 %%X=%X == AC\n",                  uint_pf(b07));
    printf("b07 %%#X=[%#X] == [0XAC]\n",          uint_pf(b07));
    printf("b07 %%#1X=[%#1X] == [0XAC]\n",        uint_pf(b07));
    printf("b07 %%#5X=[%#5X] == [ 0XAC]\n",       uint_pf(b07));
    printf("b07 %%#9X=[%#9X] == [     0XAC]\n",   uint_pf(b07));
    printf("b07 %%-#9X=[%-#9X] == [0XAC     ]\n", uint_pf(b07));
    printf("b07 %%-#09X=[%-#9X] == [0XAC     ]\n",uint_pf(b07));
    printf("b07 %%#05X=[%#05X] == [0X0AC]\n",     uint_pf(b07));
    printf("b07 %%#09X=[%#09X] == [0X00000AC]\n", uint_pf(b07));
    printf("b07 %%-x=%-x == ac\n",                uint_pf(b07));
    printf("b07 %%+x=%+x == ac\n",                uint_pf(b07));
    printf("b07 %%1d=[%1d] == [-84]\n",           int_pf(b07));
    printf("b07 %%5d=[%5d] == [  -84]\n",         int_pf(b07));
    printf("b07 %%9d=[%9d] == [      -84]\n",     int_pf(b07));
    printf("b07 %%-9d=[%-9d] == [-84      ]\n",   int_pf(b07));
    printf("b07 %%09d=[%09d] == [-00000084]\n",   int_pf(b07));

    printf("\nvariable b70: bit_vector(7 downto 0):=11001010; --initialize as big endian\n");
    printf("b70(7)=%s b70(6)=%s b70(5)=%s b70(4)=%s b70(3)=%s b70(2)=%s b70(1)=%s b70(0)=%s\n",
            pf_i(b70,7), pf_i(b70,6), pf_i(b70,5), pf_i(b70,4),
            pf_i(b70,3), pf_i(b70,2), pf_i(b70,1), pf_i(b70,0));

    printf("b70 %%#s=%#s == 11001010\n", pf(b70));
    printf("b70 %%#x=%#x == 0xca\n",     uint_pf(b70));
    printf("b70 %%#o=%#o == 0312\n",     uint_pf(b70));
    printf("b70 %%#d=%#d == -54\n",      int_pf(b70));
    printf("\n");

    vhdlcpy(b70, b07); /* b70:= b07; */
    printf("\nb70 := b07; --effects of mis-matched endian copy\n");
    printf("b70(7 DOWNTO 0):= b07(0 TO 7); --same as b70:=b07;\n\n");
    printf("b70(7)=%s b70(6)=%s b70(5)=%s b70(4)=%s b70(3)=%s b70(2)=%s b70(1)=%s b70(0)=%s\n",
            pf_i(b70,7), pf_i(b70,6), pf_i(b70,5), pf_i(b70,4),
            pf_i(b70,3), pf_i(b70,2), pf_i(b70,1), pf_i(b70,0));
    printf("b70 %%s=%s\n",  pf(b70));
    printf("b70 %%x=%x\n",  uint_pf(b70));


  return 0;
}
