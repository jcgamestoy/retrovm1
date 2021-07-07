//
//  rvmAlphaButton.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 21/02/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmAlphaButton.h"

@implementation rvmAlphaButton

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      NSTrackingArea *ta=[[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingActiveAlways | NSTrackingMouseEnteredAndExited owner:self userInfo:nil];
      [self addTrackingArea:ta];
      [self setAlphaValue:0.5];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	//[super drawRect:dirtyRect];
	
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
  if(_image)
  {
    [_image drawInRect:self.bounds];
  }
}

-(void)mouseEntered:(NSEvent *)theEvent
{
  [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
    [context setDuration:0.5];
    [self.animator setAlphaValue:1];
  } completionHandler:^{
    
  }];
}

-(void)mouseExited:(NSEvent *)theEvent
{
  [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
    [context setDuration:0.5];
    [self.animator setAlphaValue:0.5];
  } completionHandler:^{
    
  }];
}


-(void)mouseDown:(NSEvent *)e
{
  if(e.clickCount>1)
  {
    if(_onDoubleClick) _onDoubleClick(self);
  }
  else
  {
    if(_onClick) _onClick(self);
  }
}
@end
