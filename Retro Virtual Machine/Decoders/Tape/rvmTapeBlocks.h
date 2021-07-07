//
//  rvmTapeBlocks.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 24/10/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "rvmTapeBlockProtocol.h"

typedef struct
{
  uint32 count;
  uint32 length;
}rvmPulse;

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
  
  uint32 n;
  rvmPulse *pulses;
  uint32 i,c,d;
  uint8 level;
}rvmPulsesBlockS;

void rvmInitPulsesBlock(rvmPulsesBlockS *s,uint32 n,rvmPulse *pulses,uint8 level,bool freeable);
void rvmInitPauseBlock(rvmPulsesBlockS* s,uint32 c,uint32 l);

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
  
  uint32 bits;
  uint16 tail;
  uint8 p0;
  uint8 p1;
  uint16 *s0;
  uint16 *s1;
  uint8* data;
  
  uint32 i,j,c,sh,bc;
  uint16 *pt;
  uint32 level;
}rvmDataBlockS;

void rvmInitDataBlock(rvmDataBlockS* s,uint32 bits,uint16 tail,uint8 p0,uint8 p1,uint16* s0,uint16* s1,uint8* data,uint32 freeable);


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
  
  uint32 skipBlocks;
  void *data;
  uint32 lengthB;
  uint32 tag;
}rvmInfoBlockS;

rvmInfoBlockS* rvmNewInfoBlock(const char *info,uint32 skip,void* data,uint32 lb);
rvmInfoBlockS* rvmNewInfoBlockF(const char *info,uint32 skip,void *data,uint32 lb);