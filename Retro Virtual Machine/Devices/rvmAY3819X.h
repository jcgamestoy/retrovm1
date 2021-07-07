//
//  rvmAY3819X.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 08/04/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmDevice.h"

typedef struct _rvmAY3819XT
{
  rvmDeviceT handle;
  rvmDeviceAudioT audioHandle;
  uint8 r[16];
  uint aC,bC,cC,nC,eC,eH,eRs;
  int eI;
  uint aL,bL,cL,nL,eL;
  uint count;
  
  void *tag;
  
  //*TODO: AY I/O
  rvmDeviceIOInF deviceAIn;
  rvmDeviceIOInF deviceBIn;
}rvmAY3819XT;

@interface rvmAY3819X : rvmDevice

-(NSMutableDictionary*)snapshotAy;
-(void)loadAy:(NSDictionary*)ay;

@end
