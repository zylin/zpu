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


// deliver the clocks from timer 0.1
uint32_t clocks( void);


// just a loop
void wait( uint32_t value);


// initialisation for the timer
void timer_init( void);


#endif // TIMER_H
