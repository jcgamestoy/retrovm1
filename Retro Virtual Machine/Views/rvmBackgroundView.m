//
//  rvmBackgroundView.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 14/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmBackgroundView.h"
#import "rvmTexturedButton.h"
#import "NSColor+rvmNSColors.h"

#import "NSView+AutolayoutExtension.h"
#import <QuartzCore/QuartzCore.h>

@interface rvmBackgroundView ()
{
  //NSVisualEffectView *vib;
  CAGradientLayer *gl;
}

@property (strong) IBOutlet rvmTexturedButton *ejectB;
@end

@implementation rvmBackgroundView

-(instancetype)init
{
  self=[super init];
  if(self) {
    [self setup];
  }
  
  return self;
};

-(instancetype)initWithCoder:(NSCoder *)coder
{
  self=[super initWithCoder:coder];
  if(self)
  {
    [self setup];
  }
  
  return self;
};

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
  _backColor=[NSColor transparent];
  self.wantsLayer=YES;
}

-(void)awakeFromNib
{

}

-(CALayer *)makeBackingLayer
{
  gl=[CAGradientLayer layer];
  gl.locations=@[@0,@1];
  return gl;
}
//-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
//{
//  CGContextSaveGState(ctx);
//  CGContextSetPatternPhase(ctx, CGSizeMake(0, self.frame.size.height));
//  CGContextSetFillColorWithColor(ctx, _backColor.CGColor);
//  CGContextFillRect(ctx, self.bounds);
//  CGContextRestoreGState(ctx);
//}

//- (void)drawRect:(NSRect)dirtyRect
//{
  //[super drawRect:dirtyRect];
//	NSGraphicsContext *c=[NSGraphicsContext currentContext];
//  
//  [c saveGraphicsState];
//  [c setPatternPhase:NSMakePoint(0, self.frame.size.height)];
//  [_backColor setFill];
//  NSRectFill(self.bounds);
//  [c restoreGraphicsState];
//}
//
//-(void)setBackgroundColor:(NSColor *)backgroundColor
//{
//  _backgroundColor=backgroundColor;
//  [self setNeedsDisplay:YES];
//}

-(void)setBackColor:(NSColor*)backColor
{
  _backColor=backColor;
  if(_backColor2)
  {
    gl.colors=@[(id)_backColor.CGColor,(id)_backColor2.CGColor];
  }
  else
    self.layer.backgroundColor=_backColor.CGColor;
}

-(void)setBackgroundImage:(NSImage *)backgroundImage
{
  _backgroundImage=backgroundImage;
  self.backColor=[NSColor colorWithPatternImage:backgroundImage];
}

-(void)setBackColor2:(NSColor *)backColor2
{
  _backColor2=backColor2;
  
  if(backColor2)
  {
    if(!gl)
    {
//      gl=[CAGradientLayer layer];
//      gl.frame=self.layer.bounds;
//      gl.locations=@[@0,@1];
//      //gl.startPoint=CGPointMake(0, 0);
//      //gl.endPoint=CGPointMake(0, 300);
//      [[self layer] insertSublayer:gl atIndex:0];
    }
    gl.colors=@[(id)_backColor.CGColor,(id)_backColor2.CGColor];
  }
  else
  {
//    if(gl)
//    {
//      [gl removeFromSuperlayer];
//      gl=nil;
//    }
  }
}

-(void)setVibrance:(BOOL)vibrance
{
  _vibrance=vibrance;
//  if([NSVisualEffectView class])
//  {
//    if(vibrance)
//    {
//      if(!vib)
//      {
//      vib=[[NSVisualEffectView alloc] initWithFrame:self.frame];
//      vib.appearance=[NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
//        [vib setTranslatesAutoresizingMaskIntoConstraints:NO];
//        vib.state=NSVisualEffectStateActive;
//        [self addSubview:vib positioned:NSWindowBelow relativeTo:nil];
//        self.appearance=[NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
//      [self addStringConstraints:@[@"|-0-[d]-0-|",@"V:|-0-[d]-0-|"]  names:@{@"d":vib}];
//        [self layoutSubtreeIfNeeded];
//      }
//      
//    }
//    else
//    {
//      [vib removeFromSuperview];
//    }
//  }
}

//-(void)layoutSublayersOfLayer:(CALayer *)layer
//{
//  if (layer == self.layer)
//  {
//    if(gl)
//      gl.frame = layer.bounds;
//  }
//}

-(void)mouseDown:(NSEvent *)e
{
  [_mouseDelegate rvmMouseDown:self];
}

-(void)prepareForInterfaceBuilder
{
  self.wantsLayer=YES;
}
@end
