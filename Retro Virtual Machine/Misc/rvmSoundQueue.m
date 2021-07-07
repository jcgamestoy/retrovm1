//
//  rvmFifo.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 09/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmSoundQueue.h"

#define kRvmExponent 18 // 2^16 size

#define kRvmMask (cap - 1)
#define kRvmUsed ((w - r) & ((1<<kRvmExponent)-1))
#define kRvmSpace (cap - 1 - kRvmUsed)
#define kRvmSize  (cap - 1)

@interface rvmSoundQueue ()
{
  int16_t *buffer;
  int r,w,cap;
}

@property int capacity;

@end

@implementation rvmSoundQueue

+(rvmSoundQueue *)queue
{
  rvmSoundQueue *r=[rvmSoundQueue new];
  
  [r setup];
  
  return r;
}

-(void)setup
{
  cap=1<<kRvmExponent;
  buffer=malloc(cap<<1);
  r=w=0;
}

-(int)write:(int16_t*)data count:(uint)bytes
{
  if(!data) return 0;
  
  int t,i;
  
  t=kRvmSpace;
  
  if(bytes>t)
    bytes=t;
  else
    t=bytes;
  
  i=w;
  
  if((i+bytes)>cap)
  {
    memcpy(buffer+i, data, (cap-i)<<1);
    data+=cap-i;
    bytes-=cap-i;
    i=0;
  }
  
  memcpy(buffer+i, data, bytes<<1);
  w=i+bytes;
  
  //NSLog(@"%d %d %d",t,w,r);
  return t;
}

-(int)read:(int16_t*)data count:(uint)bytes
{
  int t,i;
  
  t=kRvmUsed;
  if(bytes>t)
    bytes=t;
  else
    t=bytes;
  
  i=r;
  
  if((i+bytes)>cap)
  {
    memcpy(data,buffer+i, (cap-i)<<1);
    data+=cap-i;
    bytes-=cap-i;
    i=0;
  }
  
  memcpy(data, buffer+i, bytes<<1);
  r=i+bytes;
  //NSLog(@"%d",r);
  
  return t;
}

-(int)used
{
  return kRvmUsed;
}

-(void)dealloc
{
  free(buffer);
}
@end
