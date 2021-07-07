//
//  rvmRoundedButtonCell.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 24/02/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmRoundedButtonCell.h"
#import "NSColor+rvmNSColors.h"

@implementation rvmRoundedButtonCell

-(id)init
{
  self=[super init];
  if(self)
  {
    [self initialize];
  }
  
  return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
  self=[super initWithCoder:aDecoder];
  if(self)
  {
    [self initialize];
  }
  
  return self;
}

-(id)initImageCell:(NSImage *)image
{
  self=[super initImageCell:image];
  if(self)
  {
    [self initialize];
  }
  
  return self;
}

-(id)initTextCell:(NSString *)aString
{
  self=[super initTextCell:aString];
  if(self)
  {
    [self initialize];
  }
  
  return self;
}

-(void)initialize
{
  _angle=_angleHighlighted=_angleOver=90;
  
  _roundCorner=10;
  
  _backgroundGradient=[[NSGradient alloc]
                       initWithColors:@[[NSColor black],
                                        [NSColor gray]]];
  
  _overGradient=[[NSGradient alloc]
                 initWithColors:@[[NSColor gray],
                                  [NSColor black]]];
  
  _highlightedGradient=[[NSGradient alloc]
                        initWithColors:@[[NSColor red],
                                         [NSColor orange]]];
  
  _color=[NSColor white];
  _colorOver=[NSColor yellow];
  _colorHighlighted=[NSColor black];
  
  _lineWidth=_lineOverWidth=_lineHighlightedWidth=2.0;
  
  _lineColor=_lineOverColor=[NSColor white];
  _lineHighlightedColor=[NSColor yellow];
}

-(void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
  
  NSAttributedString *at;
  NSMutableParagraphStyle *st=[[NSParagraphStyle defaultParagraphStyle] mutableCopy];
  [st setAlignment:NSCenterTextAlignment];
  //NSColor *imageColor;
  
  if(self.isHighlighted || self.state)
  {
    CGFloat r=_lineHighlightedWidth / 2.0;
    CGRect ir=NSInsetRect(cellFrame, r, r);
    
    NSBezierPath *bz=[NSBezierPath bezierPathWithRoundedRect:ir xRadius:_roundCorner yRadius:_roundCorner];
    
    [_highlightedGradient drawInBezierPath:bz angle:_angleHighlighted];
    at=[[NSAttributedString alloc] initWithString:self.title attributes:@{NSForegroundColorAttributeName:_colorHighlighted,NSParagraphStyleAttributeName:st}];
    
    //imageColor=_colorHighlighted;
    [_lineHighlightedColor setStroke];
    [bz stroke];
  }
  else if(_over)
  {
    CGFloat r=_lineOverWidth / 2.0;
    CGRect ir=NSInsetRect(cellFrame, r, r);
    
    NSBezierPath *bz=[NSBezierPath bezierPathWithRoundedRect:ir xRadius:_roundCorner yRadius:_roundCorner];
    
    [_overGradient drawInBezierPath:bz angle:_angleOver];
    at=[[NSAttributedString alloc] initWithString:self.title attributes:@{NSForegroundColorAttributeName:_colorOver,NSParagraphStyleAttributeName:st}];
    
    //imageColor=_colorOver;
    [_lineOverColor setStroke];
    [bz stroke];
  }
  else
  {
    CGFloat r=_lineWidth / 2.0;
    CGRect ir=NSInsetRect(cellFrame, r, r);
    
    NSBezierPath *bz=[NSBezierPath bezierPathWithRoundedRect:ir xRadius:_roundCorner yRadius:_roundCorner];
    
    [_backgroundGradient drawInBezierPath:bz angle:_angle];
    at=[[NSAttributedString alloc] initWithString:self.title attributes:@{NSForegroundColorAttributeName:_color,NSParagraphStyleAttributeName:st}];
    
    //imageColor=_color;
    [_lineColor setStroke];
    [bz stroke];
  }
  
  if(!self.image) [self drawTitle:at withFrame:cellFrame inView:controlView];
  else
  {
    [self.image drawInRect:cellFrame];
  }
}

-(void)mouseEntered:(NSEvent *)event
{
  _over=YES;
  [self.controlView setNeedsDisplay:YES];
}

-(void)mouseExited:(NSEvent *)event
{
  _over=NO;
  [self.controlView setNeedsDisplay:YES];
}

-(BOOL)showsBorderOnlyWhileMouseInside
{
  return YES;
}
@end
