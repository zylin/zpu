/*
 * $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/software/test/schedule.h $
 * $Date$
 * $Author$
 * $Revision$
 */

#ifndef SCHEDULE_H
#define SCHEDULE_H

#define t_res uint16_t  // resolution for time

#define SECONDS(x)  ((t_res)(CLOCKS_PER_SECOND * x + 0.5))


typedef void (*funcp)(void);

void    scheduler_task_check(void);
uint8_t scheduler_task_add( funcp func, t_res delay );
uint8_t scheduler_task_remove( funcp func );
void    scheduler_init(void);

#endif // SCHEDULE_H
