//
//  rvmTripleBufferBlock.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 4/3/16.
//  Copyright © 2016 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmBufferChain.h"

@interface rvmBufferChain()


@end

@implementation rvmBufferChain

+(id)bufferWithWidth:(uint32)x height:(uint32)y
{
  rvmBufferChain *r=[rvmBufferChain new];
  r->_width=x;
  r->_height=y;
  
  r->work=calloc(1,sizeof(rvmChainbufferS));
  r->work->signa=4;
  r->work->buf=calloc(x*y,sizeof(uint));
  
  r->f0=calloc(1,sizeof(rvmChainbufferS));
  r->f0->signa=3;
  r->f0->buf=calloc(x*y,sizeof(uint));
  
  r->f1=calloc(1,sizeof(rvmChainbufferS));
  r->f1->signa=2;
  r->f1->buf=calloc(x*y,sizeof(uint));
  
  r->g0=calloc(1,sizeof(rvmChainbufferS));
  r->g0->signa=1;
  r->g0->buf=calloc(x*y,sizeof(uint));
  
  r->g1=calloc(1,sizeof(rvmChainbufferS));
  r->g1->signa=0;
  r->g1->buf=calloc(x*y,sizeof(uint));
  
  r->lock=0;
  r->ind=5;
  return r;
}

-(void)swap
{
  OSSpinLockLock(&lock);
  rvmChainbufferS *t=f1;
  f1=f0;
  f0=work;
  work=t;
  work->signa=++ind;
  OSSpinLockUnlock(&lock);
}

-(uint)select
{
  int d=f0->signa-g0->signa;
  
  if(d && d>0)
  {
    OSSpinLockLock(&lock);
    if(d==1)
    {
      rvmChainbufferS *t=g1;
      g1=g0;
      g0=f0;
      f0=t;
      
      OSSpinLockUnlock(&lock);
      return kRvmChainSwap;
    }
    else
    {
      rvmChainbufferS *t=g1;
      g1=f1;
      f1=t;
      t=g0;
      g0=f0;
      f0=t;

      OSSpinLockUnlock(&lock);
      return kRvmChainBoth;
    }

  }
  
  return kRvmChainNone;
}

-(NSImage*)snapshot
{
  NSBitmapImageRep *br;
  OSSpinLockLock(&lock);
  {
    br=[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:_width pixelsHigh:_height bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bitmapFormat:0 bytesPerRow:_width<<2 bitsPerPixel:32];
    
    memcpy(br.bitmapData, g0->buf, _width*_height*4);
  }
  OSSpinLockUnlock(&lock);
  
  NSImage *r=[[NSImage alloc] initWithSize:NSMakeSize(_width, _height)];
  [r addRepresentations:@[br]];
  
  return r;
}

-(NSData*)dataSnapshot
{
  OSSpinLockLock(&lock);
  NSData *r=[NSData dataWithBytes:g0->buf length:_width*_height*4];
  OSSpinLockUnlock(&lock);
  return r;
}

@end
