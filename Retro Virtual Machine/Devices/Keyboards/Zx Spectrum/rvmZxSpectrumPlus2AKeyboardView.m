//
//  rvmZxSpectrumPlus2AKeyboardView.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 02/09/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmZxSpectrumPlus2AKeyboardView.h"

@implementation rvmZxSpectrumPlus2AKeyboardView

static NSString* imageNames[7]={@"zx+2AKRegular",@"zx+2AKType2",@"zx+2AKType3",@"zx+2AKEnter",@"zx+2AKLShift",@"zx+2AKRShift",@"zx+2AKSpace"};

-(void)makeChasis
{
  [super makeChasis];
  chasis.contents=[NSImage imageNamed:@"zx+2AKChasis"];
}

-(void)makeLabels
{
  [super makeLabels];
  labels.contents=[NSImage imageNamed:@"zx+2AKLabels"];
}

-(NSImage *)keyImage:(uint)ki highlight:(bool)h
{
  if(h) return [super keyImage:ki highlight:h];
  
  return [NSImage imageNamed:imageNames[[self keyType:ki]]];
}


@end
