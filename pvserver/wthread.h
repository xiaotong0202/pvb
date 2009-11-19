/***************************************************************************
                          wthread.h  -  description
                             -------------------
    begin                : Sun Nov 12 2000
    copyright            : (C) 2000 by Rainer Lehrig
    email                : lehrig@t-online.de
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
/***********************************************************************************

Wrapper for posix threads (UNIX,VMS,windows)

(C) Rainer Lehrig 2000                                       lehrig@t-online.de

***********************************************************************************/

#ifndef _WTHREAD_H_
#define _WTHREAD_H_

#include "processviewserver.h"

#ifdef PVWIN32

#include <windows.h>
#include <winbase.h>
#include <stddef.h>
#include <string.h>

#ifndef _WRAPTHREAD_
#ifndef _RL_WTHREAD_H_
typedef unsigned long int pthread_t;

/* Attributes for threads */
struct __sched_param
{
  int sched_priority;
};

typedef struct
{
  int     __detachstate;
  int     __schedpolicy;
  struct  __sched_param __schedparam;
  int     __inheritsched;
  int     __scope;
  size_t  __guardsize;
  int     __stackaddr_set;
  void   *__stackaddr;
  size_t  __stacksize;
}pthread_attr_t;

typedef HANDLE pthread_mutex_t;
//old typedef CRITICAL_SECTION pthread_mutex_t;
typedef long             pthread_mutexattr_t;
#endif
#endif

#else  /* VMS or UNIX */
#include <pthread.h>
#endif /* end of MSWINDOWS */

#ifndef _WRAPTHREAD_
#ifndef _RL_WTHREAD_H_
typedef struct
{
#ifdef PVWIN32
  int    cmax;
  HANDLE hSemaphore;
#else
  int              cmax;
  int              nready;
  pthread_mutex_t  mutex;
  pthread_cond_t   cond;
#endif
}WSEMAPHORE;
#endif
#endif

/* function prototypes */
#ifndef __VMS
#ifdef __cplusplus
extern "C" {
#endif
#endif
int  pvthread_attr_init(pthread_attr_t *attr);
int  pvthread_create(pthread_t *tid, const pthread_attr_t *attr,
                      void *(*func)(void*), void *arg);
void pvthread_close_handle(pthread_t *tid);
void pvthread_exit(void *status);
int  pvthread_join(pthread_t tid, void **status);
int  pvthread_mutex_init(pthread_mutex_t *mptr, const pthread_mutexattr_t *attr);
int  pvthread_mutex_destroy(pthread_mutex_t *mptr);
int  pvthread_mutex_lock(pthread_mutex_t *mptr);
int  pvthread_mutex_trylock(pthread_mutex_t *mptr);
int  pvthread_mutex_unlock(pthread_mutex_t *mptr);
int  pvthread_cancel(pthread_t tid);
int  pvinit_semaphore(WSEMAPHORE *s, int cmax);
int  pvincrement_semaphore(WSEMAPHORE *s);
int  pvwait_semaphore(WSEMAPHORE *s);
int  pvthread_sleep(long msec);
#ifndef __VMS
#ifdef __cplusplus
};
#endif
#endif

#endif