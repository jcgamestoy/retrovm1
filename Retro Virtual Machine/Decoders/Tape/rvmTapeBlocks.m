//
//  rvmTapeBlocks.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 24/10/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmTapeBlocks.h"


uint32 rvmPulsesBlockStep(rvmPulsesBlockS *s,uint32 *level)
{
start:
  if(s->c)
  {
    s->c--;
    *level=s->level;
    s->level=!s->level;
    return s->d;
  }
  
  while(s->i<s->n)
  {
    uint32 d=s->pulses[s->i].length;
    uint32 c=s->pulses[s->i++].count;
    
    //    *level=s->level;
    //    s->level=!s->level;
    
    if(d)
    {
      s->c=c;
      s->d=d;
      goto start;
      //return rvmPulsesBlock2Step(s, level);
    }
    else s->level=!s->level;
  }
  
  return 0;
}

void rvmPulsesBlockLength(rvmPulsesBlockS *s)
{
//  if(s->pulses[0].length>=0xfffffffe)
//  {
//    s->Tstates=0;
//    return;
//  }
  
  uint64 t=0;
  for(int i=0;i<s->n;i++)
  {
    if(s->pulses[i].length>=0xfffffffe) break;
    t+=s->pulses[i].count*s->pulses[i].length;
  }
  
  s->Tstates=t;
}

void rvmFreePulsesBlock(rvmPulsesBlockS *s)
{
  if(s->flags)
    free(s->pulses);
}

void rvmInitPulsesBlock(rvmPulsesBlockS *s,uint32 n,rvmPulse *pulses,uint8 level,bool freeable)
{
  NSLog(@"Pulses n:%d level:%d",n,level);
  
  s->n=n;
  s->pulses=pulses;
  s->level=level;
  s->i=0;
  s->step=(rvmTapeBlockProtocolStep)rvmPulsesBlockStep;
  s->length=(rvmTapeBlockProtocolLength)rvmPulsesBlockLength;
  s->free=(rvmTapeBlockFree)rvmFreePulsesBlock;
  
  sprintf(s->name,"Pulses Block");
  
  s->flags=(freeable)?1:0;
  
  s->type=kRvmPulsesBlock;
}



//Pause
//uint32 rvmPauseStep(rvmPauseBlockS *s,uint32 *level)
//{
//  uint32 r=s->count;
//  s->count=0;
//  if(r) *level=s->level;
//  return r;
//}
//
//void rvmPauseBlockLength(rvmPauseBlockS *s)
//{
//  if(s->count<0xfffffffe) s->Tstates=s->count;
//  else s->Tstates=0;
//}

#define kNoise 70000


void rvmInitPauseBlock(rvmPulsesBlockS* s,uint32 c,uint32 l)
{
  //  s->count=c;
  //  s->level=l;
  //  s->step=(rvmTapeBlockProtocolStep)rvmPauseStep;
  //  s->length=(rvmTapeBlockProtocolLength)rvmPauseBlockLength;
  //
  //  if(c>=0xfffffffe) sprintf(s->name,"Stop Block");
  //  else sprintf(s->name,"Pause Block");
  //
  
  if(c>=0xfffffffe)
  {
    uint n=1;
    if(l==2) n++;
    
    int i=0;
    rvmPulse *pulses=calloc(sizeof(rvmPulse), n);
    if(l==2)
    {
      pulses[i].count=1;
      pulses[i++].length=1000;
    }
    
    pulses[i].count=1;
    pulses[i].length=c;
    
    rvmInitPulsesBlock(s, n, pulses, l,YES);
    
    sprintf(s->name,"Stop Block");
    
    s->type=kRvmPauseBlock;
    
    return;
  }
  
  uint mp=c/kNoise;
  rvmPulse *pulses=calloc(sizeof(rvmPulse), mp<<1);
  uint i=0,j=0;
  
  while(i<c)
  {
    pulses[j].count=1;
    uint l=(rand()/(double)RAND_MAX)*(kNoise<<5)+kNoise;
    uint l1=(rand()/(double)RAND_MAX)*(kNoise);

    uint k=i;
    i+=l+l1;
    if(i<c)
    {
      pulses[j].length=l;
      j++;
      pulses[j].count=1;
      pulses[j++].length=l1;
    }
    else
      pulses[j++].length=c-k;
  }
  
//  rvmPulse *pulses=calloc(sizeof(rvmPulse), 1);
//  pulses[0].count=1;
//  pulses[0].length=c;
//  rvmInitPulsesBlock(s, 1, pulses, l, YES);
//
  rvmInitPulsesBlock(s, j, pulses, l,YES);
  
  sprintf(s->name,"Pause Block");
  
  s->type=kRvmPauseBlock;
}

uint32 rvmDataBlockStep(rvmDataBlockS *s,uint32 *level)
{
start:
  while(s->c) //Quedan repeticiones
  {
    s->c--;
    uint32 d=s->pt[s->i++];
    *level=s->level;
    s->level=!s->level;
    //NSLog(@"D:%d",d);
    if(d) return d;
  }
  
  //Next bit
  if(s->bc && s->sh--)
  {
    s->bc--;
    if((s->data[s->j]>>s->sh) & 0x1) //1
    {
      s->pt=s->s1;
      s->c=s->p1;
      s->i=0;
      //NSLog(@"Bit:%d - 1 - sh:%d",s->bc,s->sh);
      //return rvmDataBlockStep(s, level);
      goto start;
    }
    else //0
    {
      s->pt=s->s0;
      s->c=s->p0;
      s->i=0;
      //NSLog(@"Bit:%d - 0 - sh:%d",s->bc,s->sh);
      //return rvmDataBlockStep(s, level);
      goto start;
    }
  }
  
  if(s->bc)
  {
    s->sh=8;
    s->j++;
    //return rvmDataBlockStep(s, level);
    goto start;
  }
  else
  {
    if(s->tail)
    {
      *level=s->level;
      s->level=!s->level;
      uint32 t=s->tail;
      s->tail=0;
      return t;
    }
  }
  
  return 0;
}

void rvmDataBlockLength(rvmDataBlockS *s)
{
  uint32 l0=0,l1=0,l=0;
  
  for(int i=0;i<s->p0;i++)
  {
    l0+=s->s0[i];
  }
  
  for(int i=0;i<s->p1;i++)
  {
    l1+=s->s1[i];
  }
  
  for(int i=0,j=0,sh=8;i<s->bits;i++,j=(sh)?j:j+1,sh=(sh)?sh-1:8)
  {
    l+=((s->data[j]>>sh)&0x1)?l1:l0;
  }
  
  s->Tstates=l;
}

void rvmDataBlockFree(rvmDataBlockS* s)
{
  if(s->flags & 0x1) {
    free(s->s0);
    free(s->s1);
  }
  
  if(s->flags &0x2) {
    free(s->data);
  }
}

void rvmInitDataBlock(rvmDataBlockS* s,uint32 bits,uint16 tail,uint8 p0,uint8 p1,uint16* s0,uint16* s1,uint8* data,uint32 freeable)
{
  NSLog(@"Data bits:%d tail:%d p0:%d p1:%d data:%.8x level:%d",bits & 0x7fffffff,tail,p0,p1,*(uint32*)data,(bits&0x80000000)>>31);
  s->data=data;
  s->bits=bits & 0x7fffffff;
  s->tail=tail;
  s->p0=p0;
  s->p1=p1;
  s->s0=s0;
  s->s1=s1;
  s->step=(rvmTapeBlockProtocolStep)rvmDataBlockStep;
  s->length=(rvmTapeBlockProtocolLength)rvmDataBlockLength;
  s->free=(rvmTapeBlockFree)rvmDataBlockFree;
  
  s->level=(bits & 0x80000000)>>31;
  sprintf(s->name,"Pure Data Block (%d,%d)",s->bits,s->level);
  s->type=kRvmPureDataBlock;
  s->flags=freeable;
  
  s->sh=8;
  s->bc=s->bits;
}

uint32 rvmInfoBlockStep(rvmInfoBlockS *s,uint32 *level)
{
  return 0;
}

void rvmInfoBlockLength(rvmInfoBlockS *s)
{
  return;
}

void rvmInfoBlockFree(rvmInfoBlockS *s)
{
  if(s->flags)
    free(s->data);
  
  return;
}

rvmInfoBlockS* rvmNewInfoBlock(const char *info,uint32 skip,void* data,uint32 lb)
{
  rvmInfoBlockS *r=calloc(sizeof(rvmInfoBlockS), 1);
  
  r->step=(rvmTapeBlockProtocolStep)rvmInfoBlockStep;
  r->length=(rvmTapeBlockProtocolLength)rvmInfoBlockLength;
  r->free=(rvmTapeBlockFree)rvmInfoBlockFree;
  
  uint32 l=(uint32)strlen(info);
  l=(l>256)?256:l;
  strncpy(r->name, info, l);
  
  r->skipBlocks=skip;
  r->data=data;
  r->lengthB=lb;
  r->tag=0;
  r->type=kRvmInfoBlock;
  return r;
}


rvmInfoBlockS* rvmNewInfoBlockF(const char *info,uint32 skip,void *data,uint32 lb)
{
  rvmInfoBlockS *r=rvmNewInfoBlock(info, skip, data, lb);
  r->flags=0x1;
  return r;
}
