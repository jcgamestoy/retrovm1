//
//  rvmPulsesBlock.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 02/01/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

//#import <Foundation/Foundation.h>
//#import "rvmTapeBlockProtocol.h"
//
//typedef struct
//{
//  rvmTapeBlockProtocolStep step;
//  rvmTapeBlockProtocolLength length;
//  uint32 type;
//  char name[256];
//  uint64 Tstates;
//  uint64 startT;
//  uint8 n;
//  uint16 *pulses;
//  uint32 i;
//}rvmPulsesBlockS;
//
//void rvmInitPulsesBlock(rvmPulsesBlockS *s,uint8 n,uint16 *pulses);
//
//typedef struct
//{
//  uint32 count;
//  uint32 length;
//}rvmPulse;
//
//typedef struct
//{
//  rvmTapeBlockProtocolStep step;
//  rvmTapeBlockProtocolLength length;
//  uint32 type;
//  char name[256];
//  uint64 Tstates;
//  uint64 startT;
//  uint32 n;
//  rvmPulse *pulses;
//  uint32 i,c,d;
//  uint8 level;
//}rvmPulsesBlock2S;
//
//void rvmInitPulsesBlock2(rvmPulsesBlock2S *s,uint32 n,rvmPulse *pulses,uint8 level);
//
////typedef struct
////{
////  rvmTapeBlockProtocolStep step;
////  rvmTapeBlockProtocolLength length;
////  uint32 type;
////  char name[256];
////  uint64 Tstates;
////  uint64 startT;
////  
////  uint32 count;
////  uint32 level;
////}rvmPauseBlockS;
//
//void rvmInitPauseBlock(rvmPulsesBlock2S* s,uint32 c,uint32 l);
