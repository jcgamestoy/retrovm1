//
//  rvmButton.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 23/08/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmButton.h"

@interface rvmButton()
{
  NSImage *currentImage;
}

@end

@implementation rvmButton

-(instancetype)initWithCoder:(NSCoder *)coder
{
  self=[super initWithCoder:coder];
  if(self)
  {
    [self initialize];
  }
  
  return self;
}

-(instancetype)initWithFrame:(NSRect)frameRect
{
  self=[super initWithFrame:frameRect];
  if(self)
  {
    [self initialize];
  }
  return self;
}

-(void)initialize
{
  NSTrackingArea *ta=[[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingMouseMoved | NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways owner:self userInfo:nil];
  [self addTrackingArea:ta];
}

- (void)drawRect:(NSRect)dirtyRect {
  [super drawRect:dirtyRect];
  
  if(!currentImage) currentImage=_image;
  
  [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
  if(currentImage)
  {
    [currentImage drawInRect:self.bounds];
  }
}

-(void)mouseEntered:(NSEvent *)event
{
  currentImage=(_imageOver)?_imageOver:_image;
  [self setNeedsDisplay:YES];
}

-(void)mouseExited:(NSEvent *)event
{
  currentImage=_image;
  [self setNeedsDisplay:YES];
}

-(void)mouseDown:(NSEvent *)event
{
  if(_onClick) _onClick();
}
@end
