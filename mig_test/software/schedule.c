/*
 * $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/hw_sp605/bsp_zpuahb/software/schedule.c $
 * $Date$
 * $Author$
 * $Revision$
 */

#include <types.h>
#include "schedule.h"

#define MAXTIMERS    10
#define T_FREE      254                     // > MAXTIMERS
#define T_LAST      255

typedef struct{
    uint8_t next;                           // next in list or end mark
    t_res   delta;                          // delta to previous entry
    funcp   func;
} t_ctrl_struct;


t_ctrl_struct t_ctrl_lst[MAXTIMERS];
t_res   t_delay;                            // count down until next service
uint8_t t_first;                            // point to first entry


void scheduler_task_check(void)
{
    t_ctrl_struct  *p;                      // for faster access

    --t_delay;
    while( t_delay == 0 ){                  // serve if delay = 0
        if( t_first == T_LAST )             // no function to serve
            break;
        p = &t_ctrl_lst[t_first];
        t_first = p->next;                  // point to next
        p->next = T_FREE;                   // mark free
        t_delay = t_ctrl_lst[t_first].delta; // next delay delta
        p->func();                          // execute function
    }
}


uint8_t scheduler_task_add( funcp func, t_res delay )
{
    uint8_t n;
    uint8_t i;                              // index
    uint8_t ipre;                           // previous index
    t_res d1;                               // last delta delay
    t_ctrl_struct  *p;                      // for faster access

    for( n = 0;; ){
        p = &t_ctrl_lst[n];
        if( p->next == T_FREE )
            break;
        n++;
        if( n == MAXTIMERS )
            return 1;                       // error, list full
    }

    i = t_first;
    d1 = t_delay;
    while( i != T_LAST ){                   // check until end
        if( d1 >= delay ){                  // last >= new
            t_ctrl_lst[i].delta = d1 - delay; // correct following entry
            break;
        }else{
            delay -= d1;                    // remaining delay
            ipre   = i;                     // previous entry
            i      = t_ctrl_lst[i].next;    // index of next entry
            d1     = t_ctrl_lst[i].delta;   // next delay delta
        }
    }                                       // insert new entry

    p->next  = i;                           // following entry
    p->delta = delay;                       // store remaining delay
    p->func  = func;

    if( i == t_first ){                     // insert at first
        t_first = n;
        t_delay = delay;
    }else{
        t_ctrl_lst[ipre].next = n;          // previous entry
    }
    return 0;                               // successful
}


uint8_t scheduler_task_remove( funcp func )
{
    uint8_t ipre;                           // previous index
    uint8_t irem;                           // index to be removed
    uint8_t ifol = t_first;                 // following index
    t_ctrl_struct  *p;                      // for faster access

    do{
        if( ifol == T_LAST )
            return 1;                       // not found
        ipre = irem;
        irem = ifol;
        p = &t_ctrl_lst[irem];
        ifol = p->next;                     // get next
    }while( p->func != func );              // found it

    p->next = T_FREE;                       // mark it as free
    if( irem == t_first ){
        t_first = ifol;                     // serve next entry
        t_delay += t_ctrl_lst[ifol].delta;  // correct current delta
    }else{
        t_ctrl_lst[ipre].next = ifol;       // skip index
        if( ifol != T_LAST )                // correct following delta
            t_ctrl_lst[ifol].delta += p->delta;
    }
    return 0;                               // successful
}


void scheduler_init(void)
{
    uint8_t i;

    for( i = MAXTIMERS; i; i-- )
        t_ctrl_lst[i-1].next = T_FREE;      // mark all free
    t_first = T_LAST;                       // set no timer served
}


uint32_t scheduler_tasklist( void)
{
    uint8_t i;

    for( i = MAXTIMERS; i; i-- )
    {
        if ( t_ctrl_lst[i-1].next != T_FREE)
        {
            putint( i);
            putstr(":  func: ");
            puthex( 32, t_ctrl_lst[i-1].func);
            putchar('\n');
        }
    }

    return 0;
}
