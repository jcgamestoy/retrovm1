//
//  rvmTripleBuffer.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 23/01/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmTripleBuffer.h"

@interface rvmTripleBuffer()
{
  uint32 *buffers[3],*work,*finished,*selected;
  bool dirty;
}

@end

@implementation rvmTripleBuffer

+(rvmTripleBuffer*)tripleBufferWithWidth:(uint32)x height:(uint32)y
{
  rvmTripleBuffer *r=[rvmTripleBuffer new];
  
  for(int i=0;i<3;i++)
  {
    r->buffers[i]=calloc(x*y,4);
  }
  
  r->dirty=YES;
  r->work=r->buffers[0];
  r->finished=r->buffers[1];
  r->selected=r->buffers[2];
  r.width=x; r.height=y;
  return r;
}

-(void)dealloc
{
  for(int i=0;i<3;i++)
  {
    free(buffers[i]);
  }
}

-(uint32*)get
{
  if(dirty) return NULL;
  
  @synchronized(self)
  {
    uint32 *t=finished;
    finished=selected;
    selected=t;
    dirty=YES;
  }
  
  return selected;
}

-(uint32*)swap
{
  @synchronized(self)
  {
    uint32 *t=work;
    work=finished;
    finished=t;
    dirty=NO;
  }
  
  return work;
}

-(uint32*)selected
{
  return selected;
}

-(uint32*)work
{
  return work;
}

-(NSImage*)snapshot
{
  NSBitmapImageRep *br;
  @synchronized(self)
  {
    br=[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:_width pixelsHigh:_height bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bitmapFormat:0 bytesPerRow:_width<<2 bitsPerPixel:32];
    
    memcpy(br.bitmapData, selected, _width*_height*4);
  }
  
  NSImage *r=[[NSImage alloc] initWithSize:NSMakeSize(_width, _height)];
  [r addRepresentations:@[br]];
  
  return r;
}

-(NSData*)dataSnapshot
{
  @synchronized(self)
  {
    return [NSData dataWithBytes:selected length:_width*_height*4];
  }
}
@end
