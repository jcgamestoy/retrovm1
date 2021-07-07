//
//  rvmTripleBufferBlock.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 4/3/16.
//  Copyright © 2016 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
  uint *buf;
  uint signa;
}rvmChainbufferS;

#define kRvmChainNone 0
#define kRvmChainSwap 1
#define kRvmChainBoth 2

@interface rvmBufferChain : NSObject
{
  @public
  //uint *work,*f0,*f1;
  rvmChainbufferS *work,*f0,*f1,*g0,*g1;
  uint ind;
  OSSpinLock lock;
}

+(rvmBufferChain*)bufferWithWidth:(uint32)x height:(uint32)y;

@property uint32 width;
@property uint32 height;

-(void)swap;
-(uint)select;

-(NSImage*)snapshot;
-(NSData*)dataSnapshot;

@end
