//
//  rvmDevice.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 08/04/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kRvmDeviceSimple 0
#define kRvmDeviceAudio  1
#define kRvmDeviceFDC    2

struct _rvmDeviceT;
struct _rvmDeviceAudioT;

typedef void (*rvmDeviceStepF)(struct _rvmDeviceT *h);
typedef uint8 (*rvmDeviceIOInF)(struct _rvmDeviceT *h,uint16 a);
typedef void (*rvmDeviceIOOutF)(struct _rvmDeviceT *h,uint16 a,uint8 v);

typedef struct _rvmDeviceT
{
  rvmDeviceStepF step;
  rvmDeviceIOInF in;
  rvmDeviceIOOutF out;
}rvmDeviceT;

typedef struct _rvmDeviceAudioT
{
  double *channel;
  uint numChannels;
}rvmDeviceAudioT;

@interface rvmDevice : NSObject

@property rvmDeviceT *handle;
@property uint type;

-(void)reset;

@end
