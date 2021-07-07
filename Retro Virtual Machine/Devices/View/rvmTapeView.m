//
//  rvmTapeView.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 28/12/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmTapeView.h"
#import <Quartz/Quartz.h>
#import "NSColor+rvmNSColors.h"

#define kMaxR 130
#define kMaxR2 kMaxR-72

@interface rvmTapeView()
{
  CALayer *chassis,*wheel1,*wheel2,*reel1,*reel2;
  CATextLayer *label;
}

@end

@implementation rvmTapeView

-(void)awakeFromNib
{
  if(!_chassisImage)
  {
    _chassisImage=[NSImage imageNamed:@"NoTape"];
  }
  
  _length=100;
  
  chassis=[CALayer layer];
  chassis.contents=_chassisImage;
  chassis.frame=CGRectMake(0,0,312,198);
  chassis.minificationFilter=kCAFilterTrilinear;
  chassis.magnificationFilter=kCAFilterTrilinear;
  
  wheel1=[CALayer layer];
  wheel1.contents=[NSImage imageNamed:@"cassetteWheel"];
  wheel1.frame=CGRectMake(0,0,86,86);
  wheel1.position=CGPointMake(91.5,110.5);
  
  wheel2=[CALayer layer];
  wheel2.contents=[NSImage imageNamed:@"cassetteWheel"];
  wheel2.frame=CGRectMake(0,0,86,86);
  wheel2.position=CGPointMake(220.5,110.5);
  
  reel1=[CALayer layer];
  reel1.delegate=(id)self;
  reel1.frame=CGRectMake(0, 0, kMaxR, kMaxR);
  reel1.position=wheel1.position;

  reel2=[CALayer layer];
  reel2.delegate=(id)self;
  reel2.frame=CGRectMake(0, 0, kMaxR, kMaxR);
  reel2.position=wheel2.position;
  
  label=[CATextLayer layer];
  label.string=@"";
  label.frame=CGRectMake(44,164,210,14);
  label.font=(__bridge CFTypeRef)(@"AmericanTypewriter");
  label.fontSize=12.0;
  label.foregroundColor=[NSColor navy].CGColor;
  label.minificationFilter=kCAFilterNearest;
  label.magnificationFilter=kCAFilterNearest;
  
  [self.layer addSublayer:reel1];
  [self.layer addSublayer:reel2];
  [self.layer addSublayer:wheel1];
  [self.layer addSublayer:wheel2];
  
  [self.layer addSublayer:chassis];
  
  [self.layer addSublayer:label];
  
  [reel1 setNeedsDisplay];
  [reel2 setNeedsDisplay];
  [self hide];
}

-(void)show
{
  label.hidden=reel1.hidden=reel2.hidden=wheel1.hidden=wheel2.hidden=NO;
}

-(void)hide
{
  label.hidden=reel1.hidden=reel2.hidden=wheel1.hidden=wheel2.hidden=YES;
}

-(void)setChassisImage:(NSImage *)chassisImage
{
  _chassisImage=chassisImage;
  if(_chassisImage)
  {
    chassis.frame=CGRectMake(0,0,312,198);
    chassis.contents=_chassisImage;
  }
  else
  {
    chassis.frame=CGRectMake(57,0,198,198);
    chassis.contents=[NSImage imageNamed:@"NoTape"];
  }
  
  if(_chassisImage) [self show];
  else [self hide];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
  if(layer==self.layer)
  {
    return;
  }
  
  //if(isnan(_delta)) return;
  
  double l=(_length/2.0)-36;
  double r=(layer==reel2)?36+l*0:36+l*(1-0);
  
  NSGraphicsContext *c=[NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:NO];
  [NSGraphicsContext saveGraphicsState];
  [NSGraphicsContext setCurrentContext:c];
  
  [[NSColor colorWithSRGBRed:0.23 green:0.13 blue:0 alpha:1] setFill];
  NSBezierPath *b=[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(layer.bounds.size.width/2.0-r, layer.bounds.size.height/2.0-r, r*2, r*2)];
  NSRect re=NSMakeRect(layer.bounds.size.width/2.0-36, layer.bounds.size.height/2.0-36, 72, 72);
  [b appendBezierPathWithOvalInRect:re];
  [b setWindingRule:NSEvenOddWindingRule];
  [b fill];
  
  [NSGraphicsContext restoreGraphicsState];
}

-(void)setCassetteImage:(NSImage*)i length:(double)l name:(NSString*)name
{
  label.string=name;
  self.chassisImage=i;
  self.length=l;
}

-(void)setLength:(double)l
{
  double ls=l/3.5e6;
  double ll=(ls*(kMaxR-72))/(15.0*60.0);
  _length=72+((ll<kMaxR2)?ll:kMaxR2);
  [reel1 setNeedsDisplay];
  [reel2 setNeedsDisplay];
}

//-(void)resizeWithOldSuperviewSize:(NSSize)oldSize
//{
//  [super resizeWithOldSuperviewSize:oldSize];
//  CATransform3D t=CATransform3DIdentity;
//  //t=CATransform3DTranslate(t, self.frame.origin.x, self.frame.origin.y, 0);
//  t=CATransform3DScale(t, self.frame.size.width/312.0, self.frame.size.height/198.0, 1.0);
//  self.layer.sublayerTransform=t;
//}

#if TARGET_INTERFACE_BUILDER
-(void)drawRect:(NSRect)dirtyRect
{
  [[NSColor darkRed] setFill];
  NSRectFill(dirtyRect);
}
#endif
@end
