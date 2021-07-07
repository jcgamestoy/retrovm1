//
//  rvmPs3GamepadView.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 1/4/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmPs3GamepadView.h"

#define sizeY 457
#define R(x,y,w,h) NSMakeRect(x,sizeY-y-h,w,h);

@interface rvmPs3GamepadView()
{
  CALayer *chasis;
  CALayer *ltrigger,*rtrigger;
  CALayer *bs,*bc,*bx,*bt;
  CALayer *cup,*cdw,*clf,*cri;
  CALayer *bsel,*bstr;
  CALayer *bps;
  CALayer *slf,*sri;
}

@end

@implementation rvmPs3GamepadView

-(void)awakeFromNib
{
  [self setWantsLayer:YES];
  
  ltrigger=[CALayer layer];
  ltrigger.frame=R(81,0,127,41)
  ltrigger.contents=[NSImage imageNamed:@"ps3LeftT"];
  
  [self.layer addSublayer:ltrigger];
  
  
  rtrigger=[CALayer layer];
  rtrigger.frame=R(522,0,126,41)
  rtrigger.contents=[NSImage imageNamed:@"ps3LeftT"];
  
  [self.layer addSublayer:rtrigger];
  
  chasis=[CALayer layer];
  chasis.frame=R(0,9,730,448)
  chasis.contents=[NSImage imageNamed:@"ps3Chasis"];

  [self.layer addSublayer:chasis];
  
  //Button
  bs=[CALayer layer];
  bs.frame=R(503,158,60,60)
  bs.contents=[NSImage imageNamed:@"ps3Square"];
  
  [self.layer addSublayer:bs];
  
  bc=[CALayer layer];
  bc.frame=R(617,158,61,60)
  bc.contents=[NSImage imageNamed:@"ps3Circle"];
  
  [self.layer addSublayer:bc];
  
  bx=[CALayer layer];
  bx.frame=R(559,214,61,60)
  bx.contents=[NSImage imageNamed:@"ps3Cross"];
  
  [self.layer addSublayer:bx];
  
  bt=[CALayer layer];
  bt.frame=R(559,98,61,60)
  bt.contents=[NSImage imageNamed:@"ps3Triangle"];
  
  [self.layer addSublayer:bt];
  
  //Button
  cup=[CALayer layer];
  cup.frame=R(108,126,58,64)
  cup.contents=[NSImage imageNamed:@"ps3Up"];
  
  [self.layer addSublayer:cup];
  
  cdw=[CALayer layer];
  cdw.frame=R(108,195,57,65)
  cdw.contents=[NSImage imageNamed:@"ps3Down"];
  
  [self.layer addSublayer:cdw];

  clf=[CALayer layer];
  clf.frame=R(69,163,63,59)
  clf.contents=[NSImage imageNamed:@"ps3Left"];
  
  [self.layer addSublayer:clf];

  cri=[CALayer layer];
  cri.frame=R(139,163,63,59)
  cri.contents=[NSImage imageNamed:@"ps3Right"];
  
  [self.layer addSublayer:cri];
  
  bsel=[CALayer layer];
  bsel.frame=R(270,176,60,43)
  bsel.contents=[NSImage imageNamed:@"ps3Select"];
  
  [self.layer addSublayer:bsel];
  
  bstr=[CALayer layer];
  bstr.frame=R(398,174,69,46)
  bstr.contents=[NSImage imageNamed:@"ps3Start"];
  
  [self.layer addSublayer:bstr];
  
  bps=[CALayer layer];
  bps.frame=R(332,209,61,60)
  bps.contents=[NSImage imageNamed:@"ps3PS"];
  
  [self.layer addSublayer:bps];

  slf=[CALayer layer];
  slf.frame=R(182,238,112,112)
  slf.contents=[NSImage imageNamed:@"ps3LeftStick"];
  
  [self.layer addSublayer:slf];

  sri=[CALayer layer];
  sri.frame=R(422,238,112,112)
  sri.contents=[NSImage imageNamed:@"ps3RightStick"];
  
  [self.layer addSublayer:sri];

  
}

-(void)resizeWithOldSuperviewSize:(NSSize)oldSize
{
  [super resizeWithOldSuperviewSize:oldSize];
  CATransform3D t=CATransform3DIdentity;
  //t=CATransform3DTranslate(t, self.frame.origin.x, self.frame.origin.y, 0);
  t=CATransform3DScale(t, self.frame.size.width/730
                       , self.frame.size.height/457.0, 1.0);
  self.layer.sublayerTransform=t;
}

@end
