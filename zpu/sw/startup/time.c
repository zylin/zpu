#include <_ansi.h>
#include <sys/types.h>
#include <sys/stat.h>

extern long long _readCycles();


extern volatile int *MHZ;

long long _readMicroseconds()
{
	int Hz;
	long long clock;
	Hz=(*MHZ&0xff);
	clock=_readCycles();
	return clock/(long long)Hz;
}




time_t
time (time_t *tloc)
{
	time_t t;
	t=(time_t)(_readMicroseconds()/(long long )1000000);
	if (tloc!=NULL)
	{
		*tloc=t;
	}
	return t;
}
