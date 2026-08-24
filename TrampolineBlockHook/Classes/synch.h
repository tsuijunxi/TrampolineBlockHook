//
//  synch.h
//  TimeProfiler
//
//  Created by tsuijunxi on 14/3/2023.
//

#ifndef __SYNCH_H__
#define __SYNCH_H__

typedef void * sema_t;

sema_t semaphore_C(void);
void semaphore_I(sema_t p_semaphore, int count);
void semaphore_P(sema_t p_semaphore);
void semaphore_V(sema_t p_semaphore);
void semaphore_D(sema_t p_semaphore);

#endif /* SYNCH_H_ */
