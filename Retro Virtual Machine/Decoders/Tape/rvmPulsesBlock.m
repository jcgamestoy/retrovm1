////
////  rvmPulsesBlock.m
////  Retro Virtual Machine
////
////  Created by Juan Carlos González Amestoy on 02/01/14.
////  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
////
//
//#import "rvmPulsesBlock.h"
//
//void rvmPulsesBlockLength(rvmPulsesBlockS *s)
//{
//  uint64 t=0;
//  for(int i=0;i<s->n;i++)
//    t+=s->pulses[i];
//  
//  s->Tstates=t;
//}
//
//uint32 rvmPulsesBlockStep(rvmPulsesBlockS *b,uint32 *level)
//{
//  return (b->i<b->n) ? b->pulses[b->i++] : 0;
//}
//
//void rvmInitPulsesBlock(rvmPulsesBlockS *s,uint8 n,uint16 *pulses)
//{
//  s->n=n;
//  s->pulses=pulses;
//  s->step=(rvmTapeBlockProtocolStep)rvmPulsesBlockStep;
//  s->length=(rvmTapeBlockProtocolLength)rvmPulsesBlockLength;
//  s->i=0;
//  
//  sprintf(s->name,"Pulses Block");
//  
//  s->type=kRvmPulsesBlock;
//}
//
////--------------------
//
//uint32 rvmPulsesBlock2Step(rvmPulsesBlock2S *s,uint32 *level)
//{
//start:
//  if(s->c)
//  {
//    s->c--;
//    *level=s->level;
//    s->level=!s->level;
//    return s->d;
//  }
//  
//  while(s->i<s->n)
//  {
//    uint32 d=s->pulses[s->i].length;
//    uint32 c=s->pulses[s->i++].count;
//    
////    *level=s->level;
////    s->level=!s->level;
//    
//    if(d)
//    {
//      s->c=c;
//      s->d=d;
//      goto start;
//      //return rvmPulsesBlock2Step(s, level);
//    }
//  }
//  
//  return 0;
//}
//
//void rvmPulsesBlock2Length(rvmPulsesBlock2S *s)
//{
//  if(s->pulses[0].length>=0xfffffffe)
//  {
//    s->Tstates=0;
//    return;
//  }
//  
//  uint64 t=0;
//  for(int i=0;i<s->n;i++)
//    t+=s->pulses[i].count*s->pulses[i].length;
//  
//  s->Tstates=t;
//}
//
//void rvmInitPulsesBlock2(rvmPulsesBlock2S *s,uint32 n,rvmPulse *pulses,uint8 level)
//{
//  s->n=n;
//  s->pulses=pulses;
//  s->level=level;
//  s->i=0;
//  s->step=(rvmTapeBlockProtocolStep)rvmPulsesBlock2Step;
//  s->length=(rvmTapeBlockProtocolLength)rvmPulsesBlock2Length;
//  
//  sprintf(s->name,"Pulses Block");
//  
//  s->type=kRvmPulsesBlock;
//}
//
////Pause
////uint32 rvmPauseStep(rvmPauseBlockS *s,uint32 *level)
////{
////  uint32 r=s->count;
////  s->count=0;
////  if(r) *level=s->level;
////  return r;
////}
////
////void rvmPauseBlockLength(rvmPauseBlockS *s)
////{
////  if(s->count<0xfffffffe) s->Tstates=s->count;
////  else s->Tstates=0;
////}
//
//#define kNoise 70000
//
//void rvmInitPauseBlock(rvmPulsesBlock2S* s,uint32 c,uint32 l)
//{
////  s->count=c;
////  s->level=l;
////  s->step=(rvmTapeBlockProtocolStep)rvmPauseStep;
////  s->length=(rvmTapeBlockProtocolLength)rvmPauseBlockLength;
////  
////  if(c>=0xfffffffe) sprintf(s->name,"Stop Block");
////  else sprintf(s->name,"Pause Block");
////
//  
//  if(c>=0xfffffffe)
//  {
//    uint n=1;
//    if(l==2) n++;
//    
//    int i=0;
//    rvmPulse *pulses=calloc(sizeof(rvmPulse), n);
//    if(l==2)
//    {
//      pulses[i].count=1;
//      pulses[i++].length=1000;
//    }
//    
//    pulses[i].count=1;
//    pulses[i].length=c;
//    
//    rvmInitPulsesBlock2(s, n, pulses, l);
//    
//    sprintf(s->name,"Stop Block");
//    
//    s->type=kRvmPulsesBlock;
//    
//    return;
//  }
//  
//  uint mp=c/kNoise;
//  rvmPulse *pulses=calloc(sizeof(rvmPulse), mp<<1);
//  uint i=0,j=0;
//
//  while(i<c)
//  {
//    pulses[j].count=1;
//    uint l=(rand()/(double)RAND_MAX)*(kNoise<<5)+kNoise;
//    uint l1=(rand()/(double)RAND_MAX)*(kNoise);
//    i+=l+l1;
//    pulses[j].length=l;
//    j++;
//    pulses[j].count=1;
//    pulses[j++].length=l1;
//  }
//  
//  rvmInitPulsesBlock2(s, j, pulses, l);
//  
//  sprintf(s->name,"Pause Block");
//  
//  s->type=kRvmPulsesBlock;
//}