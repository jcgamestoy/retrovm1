//
//  rvmTapeBlockProtocol.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 02/01/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kRvmPureDataBlock     2
#define kRvmPulsesBlock       3
#define kRvmPauseBlock        0
#define kRvmInfoBlock         1

typedef uint (*rvmTapeBlockProtocolStep)(void* data,uint *level);
typedef void (*rvmTapeBlockProtocolLength)(void* s);
typedef void (*rvmTapeBlockFree)(void*s);

typedef struct
{
  rvmTapeBlockProtocolStep step;
  rvmTapeBlockProtocolLength length;
  rvmTapeBlockFree free;
  uint32 type;
  char name[256];
  uint64 Tstates;
  uint64 startT;
  uint32 flags;
}rvmTapeBlockProtocolS;

