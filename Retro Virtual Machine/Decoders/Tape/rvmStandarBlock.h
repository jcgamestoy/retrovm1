////
////  rvmTapeBlock.h
////  Retro Virtual Machine
////
////  Created by Juan Carlos González Amestoy on 31/12/13.
////  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
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
//  uint32 state,pcount,si,pilotC,pilotL,syncC,*syncL,l1,l0,pauseMS;
//  int shifter;
//  uint8 *pt,*data,*last,c,ub;
//}rvmStandarBlockS;
//
//void rvmInitStandarBlock(rvmStandarBlockS *s,uint8 *data,uint8 *last,uint pC,uint pL,uint sC,uint *sL,uint8 ub,uint l1,uint l0,uint pMS);
//void rvmNewStandarBlock(rvmStandarBlockS *s,uint8 *data,uint8 *last);
//
