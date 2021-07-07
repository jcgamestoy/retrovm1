//
//  rvmSnowLayer.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 18/02/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmSnowLayer.h"
#import <OpenGL/gl.h>
#import "rvmGLTexture.h"
#import "rvmGLProgram.h"
#import "rvmShaders.h"
#import "rvmMatrix.h"

#define kWidth 384
#define kHeight 288

@interface rvmSnowLayer()
{
  //uint32 *buffer;
  rvmGLTexture *texture;
  rvmGLProgram *mainProgram,*whiteNoise;
  rvmMatrix *projectionMatrix;
}

@end

@implementation rvmSnowLayer

+(rvmSnowLayer*)snowLayer
{
  rvmSnowLayer *l=[rvmSnowLayer layer];
  l.asynchronous=YES;
  l.cornerRadius=20.0;
  l.masksToBounds=YES;
  
  return l;
}

-(void)initialize
{
  texture=[rvmGLTexture initWithWidth:[_machine.tripleBuffer width] height:[_machine.tripleBuffer height]];
  [texture linear];
  mainProgram=[rvmGLProgram newWithVertexShader:rvmShader_normalVS fragmentShader:rvmShader_normalFS attributes:@[@"pos",@"tc"]];
  whiteNoise=[rvmGLProgram newWithVertexShader:rvmShader_normalVS fragmentShader:rvmShader_whiteNoise attributes:@[@"pos",@"tc"]];
  projectionMatrix=[rvmMatrix orthoFromRect:self.bounds];
  
  //buffer=(uint32*)malloc(sizeof(uint32)*kWidth*kHeight);
}

-(void)update
{
  if(!_machine || !(_machine.control & 0x1))
  {
//  for(int i=0;i<(kWidth*kHeight);i++)
//  {
//    uint32 r= rand() & 0xff;
//    r=(r<<16) | (r<<8) | r | 0xff000000;
//    buffer[i]=r;
//  }
//  
//  [texture update:buffer];
  }
  else
  {
    [texture update:_machine.tripleBuffer->g0->buf];
  }
}

-(BOOL)canDrawInCGLContext:(CGLContextObj)ctx pixelFormat:(CGLPixelFormatObj)pf forLayerTime:(CFTimeInterval)t displayTime:(const CVTimeStamp *)ts
{
  if(_machine)
  {
    if(!texture) [self initialize];
    [self update];
  }
  return YES;
}

-(void)drawInCGLContext:(CGLContextObj)ctx pixelFormat:(CGLPixelFormatObj)pf forLayerTime:(CFTimeInterval)t displayTime:(const CVTimeStamp *)ts
{
    @synchronized(NSApplication.sharedApplication) {
  CGLLockContext(ctx);
  glViewport(0, 0, self.bounds.size.width, self.bounds.size.height);
  glClear(GL_COLOR_BUFFER_BIT);
  
  rvmGLProgram *prog;
  
  if(_machine && (_machine.control & kRvmStatePlaying))
  {
    prog=mainProgram;
  }
  else
  {
    prog=whiteNoise;
  }
  
  [prog use];
  [prog uniformMatrix:projectionMatrix named:@"pm"];
  int p=[prog.attributes[@"pos"] intValue];
  int tt=[prog.attributes[@"tc"] intValue];
  
  //[textures[textureSelected] use:0];
  [texture use:0];
  [prog uniformTextureUnit:0 named:@"sam"];
  [prog uniformTextureUnit:0 named:@"previous"];
  float seed=(rand()/(float)RAND_MAX);
  [prog uniformFloat:seed named:@"seed"];
  //[prog uniformFloat:320 named:@"x"];
  //[prog uniformFloat:240 named:@"y"];
  [prog uniformVec2X:320 y:240 named:@"screen"];
  [prog uniformVec2X:768 y:576 named:@"size"];
  
  [prog uniformFloat:1.0 named:@"saturation"];
  [prog uniformFloat:1.0 named:@"contrast"];
  [prog uniformFloat:0.0 named:@"brightness"];
  [prog uniformFloat:0.0 named:@"scanlines"];
  [prog uniformFloat:0.0 named:@"noise"];
  [prog uniformFloat:0.0 named:@"offset"];
  [prog uniformFloat:0.0 named:@"interlaced"];
  [prog uniformVec2X:0.0 y:0.0 named:@"ghostIntensity"];
  [prog uniformFloat:0.0 named:@"ghostIntensity"];
  
  [prog uniformFloat:(clock()/(double)CLOCKS_PER_SEC) named:@"time"];
  
  double w=self.bounds.size.width;
  double h=self.bounds.size.height;
  
#define kLow 7.0/120.0
#define kHigh 113.0/120.0
      
  glBegin(GL_QUADS);
  glColor4d(0, 1, 1, 1);
  glVertexAttrib2d(tt, kLow, kHigh);
  glVertexAttrib2d(p, 0, 0);
  glVertexAttrib2d(tt, kHigh, kHigh);
  glVertexAttrib2d(p, w, 0);
  glVertexAttrib2d(tt, kHigh, kLow);
  glVertexAttrib2d(p, w, h);
  glVertexAttrib2d(tt, kLow, kLow);
  glVertexAttrib2d(p, 0, h);
  glEnd();
  
  CGLUnlockContext(ctx);
    }
}
@end
