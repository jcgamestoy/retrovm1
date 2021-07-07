//
//  rvmShaderLayer.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 22/4/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmShaderLayer.h"
#import <OpenGL/gl.h>
#include <sys/time.h>
#import "rvmShaders.h"
#import "rvmMatrix.h"

@interface rvmShaderLayer()
{
  bool init;
  struct timeval startT;
  rvmMatrix *projectionMatrix;
}

@end

@implementation rvmShaderLayer

+(rvmShaderLayer*)shaderLayer
{
  rvmShaderLayer *l=[rvmShaderLayer layer];
  l.asynchronous=YES;
  
  return l;
}

-(BOOL)canDrawInCGLContext:(CGLContextObj)ctx pixelFormat:(CGLPixelFormatObj)pf forLayerTime:(CFTimeInterval)t displayTime:(const CVTimeStamp *)ts
{
  if(!init)
  {
    [self setup];
  }
  return YES;
}

-(void)setup
{
  init=YES;
  gettimeofday(&startT, NULL);
  _program=[rvmGLProgram newWithVertexShader:rvmShader_normalVS fragmentShader:rvmShader_plasma attributes:@[@"pos"]];
  projectionMatrix=[rvmMatrix orthoFromRect:self.bounds];
}

-(void)drawInCGLContext:(CGLContextObj)ctx pixelFormat:(CGLPixelFormatObj)pf forLayerTime:(CFTimeInterval)t displayTime:(const CVTimeStamp *)ts
{
  if(!_program) return;
  
  CGLLockContext(ctx);
  glClear(GL_COLOR_BUFFER_BIT);
  NSSize size=self.bounds.size;
  
  glViewport(0, 0, size.width, size.height);
  [_program use];
  [_program uniformMatrix:projectionMatrix named:@"pm"];
  
  int p=[_program.attributes[@"pos"] intValue];
  //int tt=[_program.attributes[@"tc"] intValue];
  
  [_program uniformVec2X:size.width y:size.height named:@"size"];
  
  //time
  struct timeval timeS;
  gettimeofday(&timeS, NULL);
  double time=timeS.tv_sec-startT.tv_sec+(timeS.tv_usec/1000000.0);
  [_program uniformFloat:time named:@"time"];
  
  glBegin(GL_QUADS);
  //glColor4d(0, 1, 1, 1);
  //glVertexAttrib2d(tt, 0, 1);
  glVertexAttrib2d(p, 0, 0);
  //glVertexAttrib2d(tt, 1, 1);
  glVertexAttrib2d(p, size.width, 0);
  //glVertexAttrib2d(tt, 1, 0);
  glVertexAttrib2d(p, size.width, size.height);
  //glVertexAttrib2d(tt, 0, 0);
  glVertexAttrib2d(p, 0, size.height);
  glEnd();
  
  CGLUnlockContext(ctx);
}

@end
