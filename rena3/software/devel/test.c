//#include <stdio.h>

#include "peripherie.h"

////////////////////
// timer functions

void msleep(uint32_t msec)
{
    uint32_t tcr;

    timer0->e[0].reload = (F_CPU/TIMER_PRESCALER/1000)*msec;
    timer0->e[0].ctrl   = TIMER_ENABLE | TIMER_LOAD;

    do 
    {
        tcr = timer0->e[0].ctrl;
    } while ( (tcr & TIMER_ENABLE));
}

void nsleep(uint32_t nsec)
{
    uint32_t tcr;

    timer0->e[0].reload = (F_CPU/TIMER_PRESCALER/1000000)*nsec;
    timer0->e[0].ctrl   = TIMER_ENABLE | TIMER_LOAD;

    do 
    {
        tcr = timer0->e[0].ctrl;
    } while ( (tcr & TIMER_ENABLE));
}

void wait( uint32_t value)
{
    uint32_t i;

    for (i=0; i<value; i++) {}
}

void init_timer_prescaler( void)
{
    timer0->scaler_reload = TIMER_PRESCALER-1; // set prescaler
}


void init_light( void)
{
    // enable output drivers
    gpio0->dir = 0x000000FF;
}

void running_light( void)
{
//  unsigned int pattern = 0x01800180;
	unsigned int pattern = 0x01003007;

    while (1)
    {
        gpio0->out = pattern;
        //wait( 400000);
        msleep( 125);
        pattern = (pattern << 1) | (pattern >> 31);
    }

}




int main(void)
{

    init_timer_prescaler();
    init_light();

    running_light();

    //puts("end.");
    abort();
}
