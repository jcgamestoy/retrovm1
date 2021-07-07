//
//  rvmTexturedButton.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 04/03/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmTexturedButton.h"

@interface rvmTexturedButton()
{
  bool over;
  NSImage *imageOver;
  NSImage *imageNormal;
  NSImage *imageHighlighted;
}

@end

@implementation rvmTexturedButton

-(void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
  NSImage *i;//=self.image;
  //NSRect r;
  
  if(self.isHighlighted || self.state)
  {
    if(!imageHighlighted)
    {
      imageHighlighted=[NSImage imageNamed:[NSString stringWithFormat:@"%@ on",_imageName]];
    }
    
    i=imageHighlighted;
    //r=_normalRect;
  }
  else if(over && _useHover)
  {
    if(!imageOver)
    {
      imageOver=[NSImage imageNamed:[NSString stringWithFormat:@"%@ over",_imageName]];
    }
    
    i=imageOver;
    //r=_overRect;
  }
  else
  {
    if(!imageNormal)
    {
      imageNormal=[NSImage imageNamed:_imageName];
    }
    
    i=imageNormal;
    //r=_normalRect;
  }
  
  [i drawInRect:cellFrame];
}

-(void)mouseEntered:(NSEvent *)event
{
  over=YES;
  [self.controlView setNeedsDisplay:YES];
}

-(void)mouseExited:(NSEvent *)event
{
  over=NO;
  [self.controlView setNeedsDisplay:YES];
}

-(BOOL)showsBorderOnlyWhileMouseInside
{
  return YES;
}
@end
