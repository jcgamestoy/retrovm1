//
//  rvmImageView.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 30/01/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmImageView.h"

@interface rvmImageView()
{
  NSImage *_image;
}

@end

@implementation rvmImageView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
  //[super drawRect:dirtyRect];
  [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
  
  NSRect fr;
  double h=_image.size.height;
  double f=self.bounds.size.width/_image.size.width;
  h*=f;
  
  if(h>self.bounds.size.height)
  {
    h=_image.size.width;
    f=self.bounds.size.height/_image.size.height;
    h*=f;
    fr=NSMakeRect((self.bounds.size.width-h)/2, 0, h, self.bounds.size.height);
  }
  else
    fr=NSMakeRect(0, (self.bounds.size.height-h)/2, self.bounds.size.width, h);

  [_image drawInRect:fr];
  //[_image drawInRect:self.bounds];
  
    // Drawing code here.
}

-(void)setImage:(NSImage *)image
{
  _image=image;
  [self setNeedsDisplay:YES];
}

-(NSImage *)image
{
  return _image;
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
