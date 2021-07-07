//
//  rvmZ80Decoder.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 16/2/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "rvmMachineProtocol.h"
#import "rvmSnapshotDecoderProtocol.h"

typedef struct __attribute__ ((__packed__))
{
  uint8 a;
  uint8 f;
  uint16 bc;
  uint16 hl;
  uint16 pc;
  uint16 sp;
  uint8 i;
  uint8 r;
  uint8 flags1;
  uint16 de;
  uint16 bcp;
  uint16 dep;
  uint16 hlp;
  uint8 ap;
  uint8 fp;
  uint16 iy;
  uint16 ix;
  uint8 iff;
  uint8 iff2;
  uint8 flags2;
}snapZ80S;

typedef struct __attribute__ ((__packed__))
{
  snapZ80S s;
  uint16 length;
  uint16 pc;
  uint8 hardwareMode;
  uint8 l7ffd;
  uint8 if1;
  uint8 remu;
  uint8 lfffd;
  uint8 ay[16];
  uint16 lowT;
  uint8 highT;
  uint8 flagQl;
  uint8 mgtrom;
  uint8 multiface;
  uint8 rams0;
  uint8 rams1;
  uint8 keyboard[10];
  uint8 keys[10];
  uint8 mgtType;
  uint8 discipleI;
  uint8 discipleF;
  uint8 l11fd;
}snapZ80S2;

typedef struct __attribute__ ((__packed__))
{
  uint16 length;
  uint8 page;
  //uint8 data[];
}snapZ80PS;

@interface rvmZ80Decoder : NSObject<rvmSnapshotDecoderProtocol>

@end
