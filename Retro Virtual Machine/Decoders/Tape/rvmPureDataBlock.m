////
////  rvmPureDataBlock.m
////  Retro Virtual Machine
////
////  Created by Juan Carlos González Amestoy on 02/01/14.
////  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
////
//
//#import "rvmPureDataBlock.h"
//
//#define kDATA 0
//#define kSILENCE 1
//
//uint32 rvmPureDataBlockStep(rvmPureDataBlockS *b,uint32 *level)
//{
//  if(b->state==kDATA)
//  {
//    b->c++;
//    if(!(b->c&0x1))
//    {
//      b->shifter--;
//      if(b->shifter<0 && b->pt!=(b->last-1))
//      {
//        b->pt++;
//
//        b->shifter=7;
//      }
//    }
//
//    if((b->pt==(b->last-1) && (7-b->shifter)==b->ub) || b->pt==b->last)
//    {
//      //if(*level) return 1000;
//      b->state=kSILENCE;
//      return b->pauseMS*3500;
//    }
//
//    if(((*b->pt)>>b->shifter) & 0x1)
//    {
//      return b->l1;
//    }
//    else
//    {
//      return b->l0;
//    }
//  }
//  else
//    return 0;
//}
//
//void rvmPureDataBlockLength(rvmPureDataBlockS *s)
//{
//  uint64 dLe=0;
//  
//  int shifter=0x7;
//  for(uint8* pt=s->pt;pt<s->last;)
//  {
//    if(pt==(s->last-1) && (7-shifter)==s->ub) break;
//    
//    dLe+=((*pt>>shifter) & 0x1)?s->l1<<1:s->l0<<1;
//    shifter--;
//    if(shifter<0)
//    {
//      pt++;
//      shifter=0x7;
//    }
//  }
//  
//  s->Tstates=dLe+s->pauseMS*3500;
//}
//
//
//
//void rvmInitPureDataBlock(rvmPureDataBlockS *s,uint8 *data,uint8 *last,uint32 l0,uint32 l1,uint8 ub,uint32 pause)
//{
//  //NSLog(@"len:%ld,0:%d,1:%d,ub:%d,p:%d",last-data,l0,l1,ub,pause);
//  s->pt=data;
//  s->last=last;
//  s->l0=l0;
//  s->l1=l1;
//  s->ub=ub;
//  s->state=kDATA;
//  s->c=-1;
//  s->shifter=8;
//  s->pauseMS=pause;
//  sprintf(s->name,"Pure Data Block (%d bytes)",(uint)(s->last-s->pt));
//  s->step=(rvmTapeBlockProtocolStep)rvmPureDataBlockStep;
//  s->length=(rvmTapeBlockProtocolLength)rvmPureDataBlockLength;
//  
//  s->type=kRvmPureDataBlock;
//}
//
////--------------------
//
//uint32 rvmDataBlockStep(rvmDataBlockS *s,uint32 *level)
//{
//start:
//  while(s->c) //Quedan repeticiones
//  {
//    s->c--;
//    uint32 d=s->pt[s->i++];
//    *level=s->level;
//    s->level=!s->level;
//    //NSLog(@"D:%d",d);
//    if(d) return d;
//  }
//  
//  //Next bit
//  if(s->bc && s->sh--)
//  {
//    s->bc--;
//    if((s->data[s->j]>>s->sh) & 0x1) //1
//    {
//      s->pt=s->s1;
//      s->c=s->p1;
//      s->i=0;
//      //NSLog(@"Bit:%d - 1 - sh:%d",s->bc,s->sh);
//      //return rvmDataBlockStep(s, level);
//      goto start;
//    }
//    else //0
//    {
//      s->pt=s->s0;
//      s->c=s->p0;
//      s->i=0;
//      //NSLog(@"Bit:%d - 0 - sh:%d",s->bc,s->sh);
//      //return rvmDataBlockStep(s, level);
//      goto start;
//    }
//  }
//  
//  if(s->bc)
//  {
//    s->sh=8;
//    s->j++;
//    //return rvmDataBlockStep(s, level);
//    goto start;
//  }
//  else
//  {
//    if(s->tail)
//    {
//      *level=s->level;
//      s->level=!s->level;
//      uint32 t=s->tail;
//      s->tail=0;
//      return t;
//    }
//  }
//  
//  return 0;
//}
//
//void rvmDataBlockLength(rvmDataBlockS *s)
//{
//  uint32 l0=0,l1=0,l=0;
//  
//  for(int i=0;i<s->p0;i++)
//  {
//    l0+=s->s0[i];
//  }
//  
//  for(int i=0;i<s->p1;i++)
//  {
//    l1+=s->s1[i];
//  }
//  
//  for(int i=0,j=0,sh=8;i<s->bits;i++,j=(sh)?j:++j,sh=(sh)?--sh:8)
//  {
//    l+=((s->data[j]>>sh)&0x1)?l1:l0;
//  }
//  
//  s->Tstates=l;
//}
//
//void rvmInitDataBlock(rvmDataBlockS* s,uint32 bits,uint16 tail,uint8 p0,uint8 p1,uint16* s0,uint16* s1,uint8* data)
//{
//  s->data=data;
//  s->bits=bits & 0x7fffffff;
//  s->tail=tail;
//  s->p0=p0;
//  s->p1=p1;
//  s->s0=s0;
//  s->s1=s1;
//  s->step=(rvmTapeBlockProtocolStep)rvmDataBlockStep;
//  s->length=(rvmTapeBlockProtocolLength)rvmDataBlockLength;
//  s->level=(bits & 0x80000000)>>31;
//  sprintf(s->name,"Pure Data Block");
//  s->type=kRvmPureDataBlock;
//  
//  s->sh=8;
//  s->bc=s->bits;
//}
