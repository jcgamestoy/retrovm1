//
//  rvmSnowView.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 22/4/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmShaderView.h"
#import "rvmShaderLayer.h"
#import "rvmGLProgram.h"
#import "rvmShaders.h"

@interface rvmShaderView()
{
  NSString *prog;
  rvmShaderLayer *shaderL;
}

@end

@implementation rvmShaderView

-(void)awakeFromNib
{
  self.wantsLayer=YES;
}

-(CALayer *)makeBackingLayer
{
  shaderL=[rvmShaderLayer shaderLayer];
  //if(prog) [self createProgram:prog];
  return shaderL;
}

//-(NSString *)programName
//{
//  return prog;
//}
//
//-(void)setProgramName:(NSString *)programName
//{
//  prog=programName;
//  [self createProgram:prog];
//}
//
//-(void)createProgram:(NSString*)programName
//{
//  shaderL.program=[rvmGLProgram newWithVertexShader:rvmShader_normalVS fragmentShader:rvmShader_plasma attributes:@[@"pos"]];
//}

@end
