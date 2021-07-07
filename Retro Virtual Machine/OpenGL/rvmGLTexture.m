//
//  rvmGLTexture.m
//  rvmSpectrum
//
//  Created by Juan Carlos González Amestoy on 07/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmGLTexture.h"
#import <OpenGL/gl.h>

@interface rvmGLTexture ()


@end

@implementation rvmGLTexture

+(rvmGLTexture *)initWithWidth:(int)w height:(int)h
{
  rvmGLTexture *t=[rvmGLTexture new];
  t.width=w; t.height=h;
  [t create];
  
  return t;
}

-(void)create
{
  glGenTextures(1, &tid);

  glBindTexture(GL_TEXTURE_2D, tid);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _width, _height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
  [self nearest];
}

-(void)update:(void*)data
{
  glBindTexture(GL_TEXTURE_2D, tid);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _width, _height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
  glBindTexture(GL_TEXTURE_2D, 0);
}

-(void)nearest
{
  glBindTexture(GL_TEXTURE_2D, tid);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glBindTexture(GL_TEXTURE_2D, 0);
}

-(void)linear
{
  glBindTexture(GL_TEXTURE_2D, tid);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glBindTexture(GL_TEXTURE_2D, 0);
}

-(void)repeat
{
  glBindTexture(GL_TEXTURE_2D, tid);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,GL_REPEAT);
  glBindTexture(GL_TEXTURE_2D, 0);
}

-(void)use:(int)target
{
  glActiveTexture(GL_TEXTURE0+target);
  glBindTexture(GL_TEXTURE_2D,tid);
}

-(void)destroy
{
  glDeleteTextures(1, &tid);
}

@end
