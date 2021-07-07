//
//  rvmZxSpectrumPlus3KeyboardView.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 02/09/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmZxSpectrumPlus3KeyboardView.h"

@implementation rvmZxSpectrumPlus3KeyboardView

-(void)makeChasis
{
  [super makeChasis];
  chasis.contents=[NSImage imageNamed:@"zx+3KChasis"];
}

-(void)makeLabels
{
  labels=[CALayer layer];
  labels.contents=[NSImage imageNamed:@"zx+3KLabels"];
  labels.frame=NSMakeRect(0, 12, 1783, 700);
}

-(void)makeKeys
{
  [super makeKeys];
  
  for(int i=0;i<58;i++)
  {
    CALayer *k=keys[i];
    NSRect r=k.frame;
    r.origin.x+=95.5;
    r.origin.y-=2;
    k.frame=r;
  }
}

@end
