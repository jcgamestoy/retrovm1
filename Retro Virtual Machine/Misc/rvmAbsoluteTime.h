//
//  rvmAbsoluteTime.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 22/01/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>

uint64 rvmGetTime(void);
double rvmGetTimeDiffNs(uint64 s,uint64 e);
