#ifndef TIMER_H_INCLUDED
#define TIMER_H_INCLUDED

#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include <pthread.h>
#include<malloc.h>
#include <sys/time.h>
#include <signal.h>
#include <unistd.h>
#include "ptp.h"
#include "../include/cnc_api.h"

#define BASE_TIMER 1000    //1ms = 1000 us

int timer_init(u16 set_time,u16 mul_imac,u16 master_imac);


#define TIMER_DEBUG 1

#if TIMER_DEBUG
	#define TIMER_DBG(args...) do{printf("TIMER-INFO:");printf(args);}while(0)
	#define TIMER_ERR(args...) do{printf("TIMER-ERROR:");printf(args);}while(0)
#else
	#define TIMER_DBG(args...)
	#define TIMER_DBG(args...)
#endif

#endif // TIMER_H_INCLUDED
