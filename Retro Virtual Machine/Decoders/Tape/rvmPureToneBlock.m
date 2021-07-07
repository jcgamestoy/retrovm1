////
////  rvmPulseBlock.m
////  Retro Virtual Machine
////
////  Created by Juan Carlos González Amestoy on 02/01/14.
////  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
////
//
//#import "rvmPureToneBlock.h"
//
//uint32 rvmPureBlockStep(rvmPureToneBlockS* b,uint32 *level)
//{  
//  if(b->n--)
//    return b->l;
//  else return 0;
//}
//
//void rvmPureToneBlockLength(rvmPureToneBlockS *s)
//{
//  s->Tstates=s->n*s->l;
//}
//
//void rvmInitPureToneBlock(rvmPureToneBlockS *s,uint32 n,uint32 l)
//{
//  s->n=n;
//  s->l=l;
//  sprintf(s->name,"Pure Tone %d x %dT",n,l);
//  s->type=kRvmPureToneBlock;
//  s->step=(rvmTapeBlockProtocolStep)rvmPureBlockStep;
//  s->length=(rvmTapeBlockProtocolLength)rvmPureToneBlockLength;
//}
////
////@interface rvmPureToneBlock()
////{
////  uint8 state;
////  uint32 c;
////}
////
////@end
////
////@implementation rvmPureToneBlock
////
//////@synthesize level;
////@synthesize count;
////
////-(bool)step
////{
////  if(c)
////  {
////    //level=!level;
////    c--;
////    return YES;
////  }
////  else
////    return NO;
////}
////
////-(void)reset:(uint8*)level
////{
////  c=_n;
////  count=_length;
////  level=0;
////}
////
////@end
