//
//  rvmDiskView.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 20/07/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmDiskView.h"
#import <Quartz/Quartz.h>
#import "NSColor+rvmNSColors.h"

@interface rvmDiskView()
{
  CALayer *disk;
  CATextLayer *label;
}

@end

@implementation rvmDiskView


-(void)prepareForInterfaceBuilder
{
}

-(void)awakeFromNib
{
  disk=[CALayer layer];
  
  label=[CATextLayer layer];
  label.string=@"";
  
  label.font=(__bridge CFTypeRef)(@"AmericanTypewriter");
  label.fontSize=12.0;
  label.foregroundColor=[NSColor navy].CGColor;
  label.wrapped=NO;
  label.truncationMode=kCATruncationEnd;
  label.minificationFilter=kCAFilterNearest;
  label.magnificationFilter=kCAFilterNearest;
  
  //[self setTracks:40 type:1 name:@"En un lugar de la mancha de cuyo nombre no quiero acordarme"];
  [self clear];
  [self.layer addSublayer:disk];
  [self.layer addSublayer:label];
}

-(void)configureImage:(NSImage*)i
{
  double h=i.size.height;
  double f=self.bounds.size.width/i.size.width;
  h*=f;
  
  disk.contents=i;
  disk.frame=NSMakeRect(0, (self.bounds.size.height-h)/2, self.bounds.size.width, h);
}

-(void)clear
{
  [self setTracks:0 type:0xff name:nil];
}

-(void)setTracks:(uint)tracks type:(uint)type name:(NSString*)name;
{
  NSString *imageName;
  NSImage *i;
  
  switch(type) //Edsk
  {
    case 1:
    {
      if(tracks>45)
      {
        imageName=@"DiskEDsk80";

      }
      else
      {
        imageName=@"DiskEDsk40";
      }
      break;
    }
  
    case 0:
    {
      if(tracks>45)
      {
        imageName=@"DiskDsk80";
      }
      else
      {
        imageName=@"DiskDsk40";
      }
      break;
    }
      
    default:
      imageName=@"NoDisk";
  }

  if(tracks>45)
  {
    label.frame=NSMakeRect(35, 120, 185, 40);
  }
  else
  {
    label.frame=NSMakeRect(20, 35, 220, 40);
  }
  label.string=name;
  
//#if !TARGET_INTERFACE_BUILDER
//  NSBundle *bundle = [NSBundle mainBundle];
//#else
//  NSBundle *bundle = [NSBundle bundleForClass:[self class]];
//#endif
  
  //i=[[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:imageName ofType:@"png"]];
  i=[NSImage imageNamed:imageName];
  [self configureImage:i];
}

#if TARGET_INTERFACE_BUILDER
-(void)drawRect:(NSRect)dirtyRect
{
  [[NSColor darkRed] setFill];
  NSRectFill(dirtyRect);
}
#endif
@end
