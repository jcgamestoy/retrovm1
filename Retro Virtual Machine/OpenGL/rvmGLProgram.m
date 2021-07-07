//
//  rvmGLProgram.m
//  rvmSpectrum
//
//  Created by Juan Carlos González Amestoy on 06/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmGLProgram.h"
#include <OpenGL/gl.h>
#include <stdlib.h>

#import "rvmMatrix.h"

@interface rvmGLProgram()

@property const char* vertexShader;
@property const char* fragmentShader;
@property BOOL compiled;
@property NSArray *attributeNames;

@property int pid,vid,fid;

@property NSMutableDictionary *uniformsNames;

@end

@implementation rvmGLProgram

+(rvmGLProgram *)newWithVertexShader:(const char *)vs fragmentShader:(const char *)fs attributes:(NSArray*)attributeNames
{
  rvmGLProgram *o=[rvmGLProgram new];
  
  o.vertexShader=vs;
  o.fragmentShader=fs;
  o.attributeNames=attributeNames;
  
  return o;
}

-(id)init
{
  self=[super init];
  
  if(self)
  {
    _compiled=NO;
    _uniformsNames=[NSMutableDictionary dictionary];
  }
  
  return self;
}

-(int)compileShader:(const char*)source type:(int)type
{

  int sid=glCreateShader(type);
  glShaderSource(sid, 1, &source, NULL);
  glCompileShader(sid);
  
  int error;
  glGetShaderiv(sid, GL_COMPILE_STATUS, &error);
  
  if(!error)
  {
    char b[1024];
    int l;
    
    glGetShaderInfoLog(sid, 1024, &l, b);
    [NSException raise:@"Compile Shader Exception" format:@"Error compiling shader:\n%s\n\nSource:\n%s",b,source];
  }
  
  return sid;
}

-(void)compile
{
  _vid=[self compileShader:_vertexShader type:GL_VERTEX_SHADER];
  _fid=[self compileShader:_fragmentShader type:GL_FRAGMENT_SHADER];
  
  _pid=glCreateProgram();
  glAttachShader(_pid, _vid);
  glAttachShader(_pid, _fid);
  
  int i=0;
  NSMutableDictionary *d=[NSMutableDictionary dictionary];
  
  for(NSString *a in _attributeNames)
  {
    glBindAttribLocation(_pid, i, [a UTF8String]);
    d[a]=[NSNumber numberWithInt:i];
    i++;
  }
  
  _attributes=d;
  
  glLinkProgram(_pid);
  
  int error;
  glGetProgramiv(_pid, GL_LINK_STATUS, &error);
  
  if(!error)
  {
    int l;
    glGetProgramiv(_pid,GL_INFO_LOG_LENGTH, &l);
    char *buf=malloc(l);
    glGetProgramInfoLog(_pid, l, NULL, buf);
    
    [NSException raise:@"Link Program Exception" format:@"Error linking program:\n%s",buf];
    free(buf);
  }
  
  _compiled=YES;
}

-(void)use
{
  if(!_compiled) [self compile];
  
  glUseProgram(_pid);
}

#pragma mark - Uniforms

-(void)uniformFloat:(float)f named:(NSString*)name
{
  NSNumber *n=_uniformsNames[name];
  if(!n)
  {
    n=[NSNumber numberWithInt:glGetUniformLocation(_pid, [name UTF8String])];
    _uniformsNames[name]=n;
  }
  
  //glUniformMatrix4fv([n intValue], 1, NO, matrix.ptr);
  glUniform1f([n intValue], f);
}

-(void)uniformVec2X:(float)x y:(float)y named:(NSString*)name
{
  NSNumber *n=_uniformsNames[name];
  if(!n)
  {
    n=[NSNumber numberWithInt:glGetUniformLocation(_pid, [name UTF8String])];
    _uniformsNames[name]=n;
  }
  
  glUniform2f([n intValue], x, y);
}

-(void)uniformMatrix:(rvmMatrix*)matrix named:(NSString*)name
{
  NSNumber *n=_uniformsNames[name];
  if(!n)
  {
    n=[NSNumber numberWithInt:glGetUniformLocation(_pid, [name UTF8String])];
    _uniformsNames[name]=n;
  }
  
  glUniformMatrix4fv([n intValue], 1, NO, matrix.ptr);
}


-(void)uniformTextureUnit:(int)unit named:(NSString*)name
{
  NSNumber *n=_uniformsNames[name];
  if(!n)
  {
    n=[NSNumber numberWithInt:glGetUniformLocation(_pid, [name UTF8String])];
    _uniformsNames[name]=n;
  }
  
  glUniform1i([n intValue], unit);
}

-(void)destroy
{
  glDeleteProgram(_pid);
  glDeleteShader(_vid);
  glDeleteShader(_fid);
}
@end
