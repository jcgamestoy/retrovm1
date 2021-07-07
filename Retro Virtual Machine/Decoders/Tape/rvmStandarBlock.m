////
////  rvmTapeBlock.m
////  Retro Virtual Machine
////
////  Created by Juan Carlos González Amestoy on 31/12/13.
////  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
////
//
//#import "rvmStandarBlock.h"
//
//#define kSTART 0
//#define kPILOT 1
//#define kSYNC 2
//#define kDATA 3
//#define kSILENCE 4
//
//uint rvmStandarBlockStep(rvmStandarBlockS* b,uint *level)
//{
//  switch(b->state)
//  {
//    case kSTART:
//    {
//      *level=1;
//      b->state=kPILOT;
//      b->pcount=b->pilotC-1;
//      return b->pilotL;
//      break;
//    }
//    case kPILOT:
//    {
//      if(!--b->pcount)
//      {
//        b->state=kSYNC;
//        b->pcount=b->syncC;
//        b->si=0;
//        return b->syncL[b->si];
//      }
//      else
//        return b->pilotL;
//
//      break;
//    }
//    case kSYNC:
//    {
//      if(!--b->pcount)
//      {
//        b->state=kDATA;
//        b->shifter=0x7;
//        b->c=0;
//        b->pt=b->data;
//        if(((*b->pt)>>b->shifter) & 0x1)
//        {
//          return b->l1;
//        }
//        else
//        {
//          return b->l0;
//        }
//      }
//      else
//      {
//        b->si++;
//        return b->syncL[b->si];
//      }
//
//      break;
//    }
//    case kDATA:
//    {
//      b->c++;
//      if(!(b->c&0x1))
//      {
//        b->shifter--;
//        if(b->shifter<0 && b->pt!=(b->last-1))
//        //if(b->shifter<0)
//        {
//          b->pt++;
//
//          b->shifter=7;
//        }
//      }
//
//      if((b->pt==(b->last-1) && (7-b->shifter)==b->ub) || b->pt==b->last)
//      {
//        //if(*level) return 1000;
//        NSLog(@"End level: %d",*level);
//        b->state=kSILENCE;
//        return b->pauseMS*3600;
//      }
//
//      if(((*b->pt)>>b->shifter) & 0x1)
//      {
//        return b->l1;
//      }
//      else
//      {
//        return b->l0;
//      }
//      break;
//    }
//     
//  }
//  
//  return 0;
//}
//
//void rvmStandardBlockLength(rvmStandarBlockS *s)
//{
//  uint64 dLe=0;
//  
//  for(int i=0;i<s->syncC;i++)
//  {
//    dLe+=s->syncL[i];
//  }
//  
//  int shifter=0x7;
//  for(uint8* pt=s->data;pt<s->last;)
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
//  s->Tstates=s->pilotC*s->pilotL+dLe+s->pauseMS*3500;
//}
//
//void rvmInitStandarBlock(rvmStandarBlockS *s,uint8 *data,uint8 *last,uint pC,uint pL,uint sC,uint *sL,uint8 ub,uint l1,uint l0,uint pMS)
//{
//  s->step=(rvmTapeBlockProtocolStep)rvmStandarBlockStep;
//  s->length=(rvmTapeBlockProtocolLength)rvmStandardBlockLength;
//  s->data=data;
//  s->last=last;
//  s->pilotC=pC;
//  if(!(pC & 0x1)) s->pilotC++;
//  s->pilotL=pL;
//  s->syncC=sC;
//  s->syncL=(uint32*)malloc(sizeof(uint32)*sC);
//  
//  for(int i=0;i<sC;i++)
//  {
//    s->syncL[i]=sL[i];
//  }
//  
//  s->ub=ub;
//  s->l0=l0;
//  s->l1=l1;
//  s->pauseMS=pMS;
//  
//  s->state=kSTART;
//  s->pcount=s->pilotC;
//  
//  uint l=(uint)(s->last-s->data);
//  s->type=kRvmStandardTapeBlock;
//  if(l==19)
//  {
//    uint16 bl=*((uint16*)(s->data+12));
//    switch(*(s->data+1))
//    {
//      case 0: //Program
//      {
//        char name[11];
//        strncpy(name,(const char*) s->data+2, 10);
//        name[10]=0;
//        uint16 ma=*((uint16*)(s->data+14));
//        
//        if(ma & 0x8000)
//        {
//          sprintf(s->name, "Program: \"%s\"",name);
//        }
//        else
//        {
//          sprintf(s->name, "Program: \"%s\" Line %d",name,ma);
//        }
//        return;
//      }
//      
//      case 3: //Code
//      {
//        char name[11];
//        strncpy(name,(const char*) s->data+2, 10);
//        name[10]=0;
//        uint16 ma=*((uint16*)(s->data+14));
//        sprintf(s->name, "Code: \"%s\" %d,%d",name,ma,bl);
//        return;
//      }
//    }
//  }
//  
//  sprintf(s->name, "Data %d bytes",l);
//  
//
//}
//
//uint standarSpectrumSync[]={667,735};
//
//void rvmNewStandarBlock(rvmStandarBlockS *s,uint8 *data,uint8 *last)
//{
//  rvmInitStandarBlock(s, data, last, 8063, 2168, 2, standarSpectrumSync, 8, 1710, 855, 2000);
//}