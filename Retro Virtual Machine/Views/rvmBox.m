//
//  rvmBox.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 14/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmBox.h"

@implementation rvmBox

-(instancetype)initWithCoder:(NSCoder *)coder
{
  self=[super initWithCoder:coder];
  
  if(self)
  {
    [self setup];
  }
  
  return self;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      [self setup];
    }
    return self;
}

-(void)setup
{
  _backgroundColor=[NSColor colorWithRed:1 green:1 blue:1 alpha:0.15];
  _lineColor=[NSColor colorWithRed:1 green:1 blue:1 alpha:0.8];
  _cornerRadious=6;
  _lineWidth=2;

}

- (void)drawRect:(NSRect)dirtyRect
{
  NSBezierPath *bz=[NSBezierPath bezierPathWithRoundedRect:self.bounds xRadius:_cornerRadious yRadius:_cornerRadious];
  
  [_backgroundColor setFill];
  [bz fill];
  
  if(_lineWidth>0)
  {
  [_lineColor setStroke];
  [bz setLineWidth:_lineWidth];
  [bz stroke];
  }
}

-(void)setCornerRadious:(double)cornerRadious
{
  _cornerRadious=cornerRadious;
  [self setNeedsDisplay:YES];
}

-(void)setLineWidth:(double)lineWidth
{
  _lineWidth=lineWidth;
  [self setNeedsDisplay:YES];
}

@end
