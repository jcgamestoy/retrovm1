//
//  rvmAbsoluteTime.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 22/01/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmAbsoluteTime.h"
#import <mach/mach.h>
#import <mach/mach_time.h>

static mach_timebase_info_data_t info;
static double factor;

uint64 rvmGetTime(void)
{
  return mach_absolute_time();
}

double rvmGetTimeDiffNs(uint64 s,uint64 e)
{
  if(!info.denom)
  {
    mach_timebase_info(&info);
    factor=info.numer/info.denom;
  }
  
  return (e-s)*factor;
}
