//
//  rvmBackgroundViewDraw.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 10/10/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmBackgroundViewDraw.h"

@implementation rvmBackgroundViewDraw

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

  if(_backgroundColor)
  {
    [_backgroundColor setFill];
    NSRectFill(dirtyRect);
  }
}

-(void)mouseDown:(NSEvent *)theEvent
{
  if(_onClick) _onClick();
}

@end
