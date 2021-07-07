//
//  rvmPlus3FddView.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 06/07/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmPlus3FddView.h"
#import <Quartz/Quartz.h>
#import "NSColor+rvmNSColors.h"


static NSSound *eject,*insert;

@interface rvmPlus3FddView()
//{
//  CALayer *chasis,*led,*diskLome;
//  CATextLayer *diskName;
//}

@end

@implementation rvmPlus3FddView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

-(void)initPositions
{
  chasis.frame=NSMakeRect(0, 0, 379, 210);
  led.frame=NSMakeRect(85, 34, 15, 5);
  diskLome.frame=NSMakeRect(79, 57, 275, 18);
  diskName.frame=NSMakeRect(130,55, 170, 18);
  
  led.backgroundColor=[NSColor darkRed].CGColor;
}

-(void)setChasisImage
{
  chasis.contents=[NSImage imageNamed:@"Plus3Fdd"];
}

-(void)awakeFromNib
{
  if(!eject)
  {
    eject=[[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Resources/Disk Sounds/Eject" ofType:@"aiff"] byReference:YES];
    insert=[[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Resources/Disk Sounds/Insert" ofType:@"aiff"] byReference:YES];
  }
  chasis=[CALayer layer];
  [self setChasisImage];
  //chasis.contents=[NSImage imageNamed:@"Plus3Fdd"];
  //chasis.frame=NSMakeRect(0, 0, 379, 210);
  
  led=[CALayer layer];
  
  //led.frame=NSMakeRect(85, 34, 15, 5);
  
  diskLome=[CALayer layer];
  diskLome.contents=[NSImage imageNamed:@"DiskLome"];
  //diskLome.frame=NSMakeRect(79, 57, 275, 18);
  diskLome.opacity=0;
  
  diskName=[CATextLayer layer];
  diskName.string=@"";
  //diskName.frame=NSMakeRect(130,55, 170, 18);
  diskName.font=(__bridge CFTypeRef)(@"AmericanTypewriter");
  diskName.fontSize=12.0;
  diskName.foregroundColor=[NSColor navy].CGColor;
  diskName.wrapped=NO;
  diskName.truncationMode=kCATruncationEnd;
  diskName.opacity=0;
  diskName.minificationFilter=kCAFilterNearest;
  diskName.magnificationFilter=kCAFilterNearest;
  
  [self initPositions];
  
  [self.layer addSublayer:chasis];
  [self.layer addSublayer:led];
  [self.layer addSublayer:diskLome];
  [self.layer addSublayer:diskName];
}

-(void)animateIn
{
  self.layer.opacity=1;
}

-(void)animateOut
{
  self.layer.opacity=0;
}

-(void)setDiskTitle:(NSString *)diskTitle
{
  diskName.string=diskTitle;
}

-(NSString *)diskTitle
{
  return diskName.string;
}

-(void)showDisk
{
  diskLome.opacity=diskName.opacity=1;
  [insert play];
}

-(void)hideDisk
{
  if(diskLome.opacity!=0)
  {
    diskLome.opacity=diskName.opacity=0;
    [eject play];
  }
}

-(void)led:(uint32)i
{
  [CATransaction begin];
  [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
  led.backgroundColor=[NSColor colorWithDeviceRed:0.5+(i/70908.0) green:0 blue:0 alpha:1].CGColor;
  //change background colour
  [CATransaction commit];

  //[self.layer setNeedsDisplay];
}
@end
