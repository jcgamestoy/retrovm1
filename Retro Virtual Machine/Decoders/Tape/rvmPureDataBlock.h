////
////  rvmPureDataBlock.h
////  Retro Virtual Machine
////
////  Created by Juan Carlos González Amestoy on 02/01/14.
////  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
////
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
//  uint32 state,l0,l1,pauseMS;
//  int shifter,c;
//  uint8 *pt,*last,ub;
//}rvmPureDataBlockS;
//
//void rvmInitPureDataBlock(rvmPureDataBlockS *s,uint8 *data,uint8 *last,uint32 l0,uint32 l1,uint8 ub,uint32 pause);
//
//typedef struct
//{
//  rvmTapeBlockProtocolStep step;
//  rvmTapeBlockProtocolLength length;
//  uint32 type;
//  char name[256];
//  uint64 Tstates;
//  uint64 startT;
//  
//  uint32 bits;
//  uint16 tail;
//  uint8 p0;
//  uint8 p1;
//  uint16 *s0;
//  uint16 *s1;
//  uint8* data;
//  
//  uint32 i,j,c,sh,bc;
//  uint16 *pt;
//  uint32 level;
//}rvmDataBlockS;
//
//void rvmInitDataBlock(rvmDataBlockS* s,uint32 bits,uint16 tail,uint8 p0,uint8 p1,uint16* s0,uint16* s1,uint8* data);
