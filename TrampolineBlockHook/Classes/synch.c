//
//  synch.cpp
//  TimeProfiler
//
//  Created by tsuijunxi on 14/3/2023.
//

#include "synch.h"
#include "semaphore.h"
#include <stdlib.h>

struct my_semaphore {
    sem_t mutex;
};

sema_t semaphore_C(void) {
    struct my_semaphore * sem = (struct my_semaphore *)malloc(sizeof(struct my_semaphore));
    return sem;
}
void semaphore_I(sema_t p_semaphore, int count) {
    struct my_semaphore * sem = (struct my_semaphore *) p_semaphore;
    if (p_semaphore != NULL)
        sem_init(&sem->mutex, 0, count);
}
void semaphore_P(sema_t p_semaphore) {
    struct my_semaphore * sem = (struct my_semaphore *) p_semaphore;
    if (p_semaphore != NULL) {
        sem_wait(&sem->mutex);
    }
}

void semaphore_V(sema_t p_semaphore) {
    struct my_semaphore * sem = (struct my_semaphore *) p_semaphore;
    if (p_semaphore != NULL) {
        sem_post(&sem->mutex);
    }
}

void semaphore_D(sema_t p_semaphore) {
    struct my_semaphore * sem = (struct my_semaphore *) p_semaphore;
    if (p_semaphore != NULL) {
        sem_destroy(&sem->mutex);
    }
}
