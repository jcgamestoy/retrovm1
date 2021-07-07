//
//  rvmAudioLeds.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 2/1/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmAudioLeds.h"
#import "NSColor+rvmNSColors.h"

@interface rvmAudioLeds()
{
  double _value;
  bool _horizontal;
}

@end

@implementation rvmAudioLeds

static NSArray *colors;
static NSArray *colorsD;

-(void)prepareForInterfaceBuilder
{
  [self initColor];
}

-(void)awakeFromNib
{
  [self initColor];
}

-(void)initColor
{
  if(!colors)
  {
    colors=@[[NSColor lime],[NSColor gold],[NSColor red]];
    colorsD=@[[[NSColor lime] blendedColorWithFraction:0.75 ofColor:[NSColor black]],
              [[NSColor gold] blendedColorWithFraction:0.75 ofColor:[NSColor black]],
              [[NSColor red] blendedColorWithFraction:0.75 ofColor:[NSColor black]]];
  }
}

-(void)drawRect:(NSRect)dirtyRect
{
  if(_horizontal)
  {
    [self drawRectH];
  }
  else
    [self drawRectV];
}

-(void)drawRectV
{
  double y=0;
  double max=(12*_width*0.5+_width/3.0)*_value;
  NSGradient *gb=[[NSGradient alloc] initWithColors:colorsD];
  NSBezierPath *bp=[NSBezierPath bezierPath];
  for(int i=0;i<12;i++)
  {
    [bp appendBezierPathWithRect:NSMakeRect(0, y, _width, _width/3.0)];
    [[NSColor red] setFill];
    [gb drawInBezierPath:bp angle:90];
    
    y+=_width*0.5;
  }
  
  if(max>1.0)
  {
  NSBezierPath *bclip=[NSBezierPath bezierPathWithRect:NSMakeRect(0, 0, _width, max)];
  [bclip setClip];
  
  gb=[[NSGradient alloc] initWithColors:colors];
  [gb drawInBezierPath:bp angle:90];
  }
}

-(void)drawRectH
{
  double x=0;
  double max=(12*_width*0.5+_width/3.0)*_value;
  NSGradient *gb=[[NSGradient alloc] initWithColors:colorsD];
  NSBezierPath *bp=[NSBezierPath bezierPath];
  for(int i=0;i<12;i++)
  {
    [bp appendBezierPathWithRect:NSMakeRect(x, 0, _width/3.0, _width)];
    [gb drawInBezierPath:bp angle:0];
    
    x+=_width*0.5;
  }
  
  if(max>1.0)
  {
    NSBezierPath *bclip=[NSBezierPath bezierPathWithRect:NSMakeRect(0, 0, max, _width)];
    [bclip setClip];
    
    gb=[[NSGradient alloc] initWithColors:colors];
    [gb drawInBezierPath:bp angle:0];
  }
}


-(void)setHorizontal:(BOOL)horizontal
{
  _horizontal=horizontal;
  [self setNeedsDisplay:YES];
}

-(void)setValue:(double)value
{
  double d=_value*_factor+value*(1-_factor);
  _value=(d<0.0)?0.0:((d>1.0)?1.0:d);
  [self setNeedsDisplay:YES];
}

-(double)value
{
  return _value;
}

-(BOOL)horizontal
{
  return _horizontal;
}
@end
