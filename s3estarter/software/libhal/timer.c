#include <peripherie.h>

////////////////////////////////////////
// timer functions


// wait for a given time in micro seconds
void usleep(uint32_t usec)
{
    uint32_t tcr;

    // 1 usec = 6
    timer0->e[0].reload = (F_CPU/TIMER_PRESCALER/1000000)*usec;
    timer0->e[0].ctrl   = TIMER_ENABLE | TIMER_LOAD;

    do 
    {
        tcr = timer0->e[0].ctrl;
    } while ( (tcr & TIMER_ENABLE));
}


// wait for given time in milli seconds
void msleep(uint32_t msec)
{
    uint32_t tcr;

    // 1 msec    = 6250
    // 167 msec  = 2**20 (20 bit counter) 391 slices
    // 2684 msec = 2**24 (24 bit counter) 450 slices
    //           = 2**32 (32 bit counter) 572 slices
    timer0->e[0].reload = (F_CPU/TIMER_PRESCALER/1000)*msec;
    timer0->e[0].ctrl   = TIMER_ENABLE | TIMER_LOAD;

    do 
    {
        tcr = timer0->e[0].ctrl;
    } while ( (tcr & TIMER_ENABLE));
}


// wait for given time in seconds
void sleep(uint32_t sec)
{
    uint32_t timer;

    for (timer=0; timer<sec; timer++)
    {
        msleep( 166);
        msleep( 166);
        msleep( 166);
        msleep( 166);
        msleep( 166);
        msleep( 166);
    }
}


// deliver the clocks from timer 0.1
uint32_t clocks( void)
{
    return( timer0->e[1].value);
}


// just a loop
void wait( uint32_t value)
{
    uint32_t i;

    for (i=0; i<value; i++) {}
}


// initialisation for the timer
void timer_init( void)
{
    timer0->scaler_reload = TIMER_PRESCALER-1; // set prescaler
   
    // set timer 0.1 to free running in msec 
    timer0->e[1].reload = (F_CPU/TIMER_PRESCALER/CLOCKS_PER_SECOND);
    timer0->e[1].ctrl   = TIMER_ENABLE | TIMER_RESTART | TIMER_LOAD;
}


