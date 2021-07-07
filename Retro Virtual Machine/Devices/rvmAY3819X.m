//
//  rvmAY3819X.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 08/04/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmAY3819X.h"

@interface rvmAY3819X()
{
  rvmAY3819XT h;
  double channel[3];
}

@end

@implementation rvmAY3819X

static uint8 rvmAY3819Xin(rvmAY3819XT *h,uint16 a)
{
  a=a & 0xf;
  switch(a)
  {
    case 0:
    case 2:
    case 4:
    case 11:
    case 12:
      return h->r[a];
    case 1:
    case 3:
    case 5:
    case 13:
      return h->r[a] & 0xf;
    case 6:
    case 8:
    case 9:
    case 10:
      return h->r[a] & 0x1f;
    case 14:
      if(h->r[7] & 0x40)
      {
        return h->r[a];
      }
      else
      {
        if(h->deviceAIn)
          return h->deviceAIn((rvmDeviceT*)h,a);
        else
          return 0xff;
      }
    case 15:
      if(h->r[7] & 0x80)
      {
        return h->r[a];
      }
      else
      {
        if(h->deviceBIn)
          return h->deviceBIn((rvmDeviceT*)h,a);
        else
          return 0xff;
      }
  }
  
  //Si estamos aqui es que a==14 o 15

  return h->r[a & 0xf];
}

static void rvmAY3819Xout(rvmAY3819XT *h,uint16 a,uint8 v)
{
  //NSLog(@"AY Register write: %.4x %2.x",a,v);
  a=a & 0xf;
  h->r[a]=v;
  h->eRs=(a==0xd)?1:h->eRs;
}

static double vol[16]={
  0.0000,
  0.0079,
  0.0141,
  0.0202,
  0.0299,
  0.0404,
  0.0580,
  0.0773,
  0.1107,
  0.1485,
  0.2109,
  0.2812,
  0.4007,
  0.5351,
  0.7583,
  1.0000
};

static void rvmAY3819Xstep(rvmAY3819XT *h)
{
  h->count++;
  
  if(!(h->count & 0x7))
  {
    //A
    h->aC++;
    if(h->aC>=(h->r[0])+((h->r[1] & 0xf)<<8))
    {
      h->aL=(h->aL>0)?0:1;
      h->aC=0;
    }
    
    //B
    h->bC++;
    if(h->bC>=(h->r[2])+((h->r[3] & 0xf)<<8))
    {
      h->bL=(h->bL>0)?0:1;
      h->bC=0;
    }
    
    //C
    h->cC++;
    if(h->cC>=(h->r[4])+((h->r[5] & 0xf)<<8))
    {
      h->cL=(h->cL>0)?0:1;
      h->cC=0;
    }
    
    //N
    if(!(h->count & 0x10))
    {
      h->nC++;
      if(h->nC>=(h->r[6] & 0x1f))
      {
        h->nC=0;
        h->nL=rand() & 0x1;
      }
    }
    
    //E
    h->eC++;
    if(h->eRs)
    {
      if(h->r[13] & 0x4)
      {
        h->eL=0; h->eI=1;
      }
      else
      {
        h->eL=31; h->eI=-1;
      }
      h->eH=0;
      h->eRs=0;
    }
    else if(h->eC>=((h->r[12]<<8)+h->r[11]))
    {
      h->eC=0;
      
      //Envelope
      bool ib=h->eL==0;
      bool ibp=h->eL==1;
      bool itp=h->eL==30;
      bool it=h->eL==31;

      if(!h->eH)
      {
        h->eL=(h->eL+h->eI) & 0x1f;
      }
      
      //h->eH=0;
      
      if(!(h->r[13] & 0x8))
      {
        if(h->eI<0)
        {
          if(ibp) h->eH=1;
        }
        else
        {
          if(it) h->eH=1;
        }
      }
      else
      {
        if(h->r[13] & 0x1)
        {
          if(h->eI<0)
          {
            if(h->r[13] & 0x2)
            {
              if(ib) h->eH=1;
            }
            else
            {
              if(ibp) h->eH=1;
            }
          }
          else
          {
            if(h->r[13] & 0x2)
            {
              if(it) h->eH=1;
            }
            else
            {
              if(itp) h->eH=1;
            }
          }
        }
        else if(h->r[13] & 0x2)
        {
          if(h->eI<0)
          {
            if(ibp) h->eH=1;
            if(ib)
            {
              h->eH=0;
              h->eI=1;
            }
          }
          else
          {
            if(itp) h->eH=1;
            if(it)
            {
              h->eH=0;
              h->eI=-1;
            }
          }
        }
      }
    }
  }
  
  rvmDeviceAudioT *audio=&h->audioHandle;
  
  uint d;
  double v;
  //if(!(h->r[7] & 0x1)) //channel A
  //{
  d=((h->r[7] & 0x1) | h->aL) & (((h->r[7] & 0x8)>>3) | h->nL);
  v=vol[(h->r[8] & 0x10)?h->eL>>1:h->r[8] & 0xf];
  audio->channel[0]=((d*v));
  //}
  
  //if(!(h->r[7] & 0x2)) //channel B
  //{
  d=(((h->r[7] & 0x2)>>1) | h->bL) & (((h->r[7] & 0x10)>>4) | h->nL);
  v=vol[(h->r[9] & 0x10)?h->eL>>1:h->r[9] & 0xf];
  audio->channel[1]=((d*v));
  //}
  
  //if(!(h->r[7] & 0x4)) //channel C
  //{
  d=(((h->r[7] & 0x4)>>2) | h->cL) & (((h->r[7] & 0x20)>>5) | h->nL);
  v=vol[(h->r[0xa] & 0x10)?h->eL>>1:h->r[0xa] & 0xf];
  audio->channel[2]=((d*v));
  //}
}

-(id)init
{
  self=[super init];
  if(self)
  {
    h.handle.in=(rvmDeviceIOInF)rvmAY3819Xin;
    h.handle.out=(rvmDeviceIOOutF)rvmAY3819Xout;
    h.handle.step=(rvmDeviceStepF)rvmAY3819Xstep;
    
    //h.audioHandle.audioStep=(rvmDeviceAudioStepF)rvmAY3819XAudioStep;
    h.audioHandle.channel=channel;
    h.audioHandle.numChannels=3;
    
    for(int i=0;i<0x10;i++)
      h.r[i]=0x0;
    
    h.r[7]=0xff;
    
    self.type=kRvmDeviceAudio;
    self.handle=(rvmDeviceT*)&h;
  }
  
  return self;
}

-(void)reset
{
  h.aC=h.aL=h.bC=h.bL=h.cC=h.cL=h.count=h.eC=h.eH=h.eI=h.eL=h.eRs=h.nC=h.nL=0;
  for(int i=0;i<0x10;i++) h.r[i]=0;
}

-(NSMutableDictionary *)snapshotAy
{
  NSMutableDictionary *d=[NSMutableDictionary new];
  
  d[@"r"]=@[[NSNumber numberWithUnsignedChar:h.r[0]],
            [NSNumber numberWithUnsignedChar:h.r[1]],
            [NSNumber numberWithUnsignedChar:h.r[2]],
            [NSNumber numberWithUnsignedChar:h.r[3]],
            [NSNumber numberWithUnsignedChar:h.r[4]],
            [NSNumber numberWithUnsignedChar:h.r[5]],
            [NSNumber numberWithUnsignedChar:h.r[6]],
            [NSNumber numberWithUnsignedChar:h.r[7]],
            [NSNumber numberWithUnsignedChar:h.r[8]],
            [NSNumber numberWithUnsignedChar:h.r[9]],
            [NSNumber numberWithUnsignedChar:h.r[10]],
            [NSNumber numberWithUnsignedChar:h.r[11]],
            [NSNumber numberWithUnsignedChar:h.r[12]],
            [NSNumber numberWithUnsignedChar:h.r[13]],
            [NSNumber numberWithUnsignedChar:h.r[14]],
            [NSNumber numberWithUnsignedChar:h.r[15]]];
  
  return d;
}

-(void)loadAy:(NSDictionary *)ay
{
  NSArray *r=ay[@"r"];
  
  for(int i=0;i<16;i++)
    h.r[i]=[r[i] unsignedCharValue];
}

@end
