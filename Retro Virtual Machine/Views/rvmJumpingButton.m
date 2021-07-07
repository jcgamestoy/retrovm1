//
//  rvmJumpingButton.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 7/4/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmJumpingButton.h"

@implementation rvmJumpingButton

-(void)mouseDown:(NSEvent *)theEvent
{
  if(self.onClick) self.onClick(self);
  
  [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
    context.allowsImplicitAnimation=YES;
    context.duration=0.25;
    NSRect r=self.frame;
    r.origin.y+=20.0;
    self.frame=r;
  } completionHandler:^{
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
      context.allowsImplicitAnimation=YES;
      context.duration=0.25;
      NSRect r=self.frame;
      r.origin.y-=20.0;
      self.frame=r;
    } completionHandler:^{
      //if(self.onClick) self.onClick(self);
    }];
  }];
}

@end
