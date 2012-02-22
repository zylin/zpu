//
// $Date$
// $Author$
// $Revision$
//

#include <peripherie.h>

#ifndef TIMER_H
#define TIMER_H


////////////////////////////////////////
// timer functions


// wait for a given time in micro seconds
void usleep(uint32_t usec);

// wait for given time in milli seconds
void msleep(uint32_t msec);


// wait for given time in seconds
void sleep(uint32_t sec);


// deliver the milli seconds from timer 0.1
uint32_t msecs( void);

// deliver the seconds from timer 0.2
uint32_t seconds( void);

// deliver the time (in seconds and fraction) from timer
uint32_t get_time( void);

// just a loop
void wait( uint32_t value);


// initialisation for the timer
void timer_init( void);

#define TIMER_STOP      timer0->e[1].ctrl   &= ~TIMER_ENABLE;
#define TIMER_RUN       timer0->e[1].ctrl   |= TIMER_ENABLE;

#endif // TIMER_H
