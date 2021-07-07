//
//  rvmGLFloatTexture.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 15/04/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmGLFloatTexture.h"
#import <OpenGL/gl.h>

@implementation rvmGLFloatTexture

+(rvmGLFloatTexture *)initWithWidth:(int)w height:(int)h
{
  rvmGLFloatTexture *t=[rvmGLFloatTexture new];
  t.width=w; t.height=h;
  [t create];
  
  return t;
}

-(void)create
{
  glGenTextures(1, &tid);
  
  glBindTexture(GL_TEXTURE_2D, tid);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE32F_ARB, self.width, self.height, 0, GL_LUMINANCE, GL_FLOAT, NULL);
  [self nearest];
}

-(void)update:(void*)data
{
  glBindTexture(GL_TEXTURE_2D, tid);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, self.width, self.height, 0, GL_LUMINANCE, GL_FLOAT, data);
  glBindTexture(GL_TEXTURE_2D, 0);
}

@end
