//
//  rvmNSImage+Extensions.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 7/3/16.
//  Copyright © 2016 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmNSImage+Extensions.h"

@implementation NSImage(rvmNSImage)

-(NSImage *)imageWithRect:(NSRect)rect
{
  NSImage *r=[[NSImage alloc] initWithSize: rect.size];
  
  [r lockFocus];
  [self drawInRect:NSMakeRect(0, 0, rect.size.width, rect.size.height) fromRect:rect operation:NSCompositeCopy fraction:1.0];
  [r unlockFocus];
  return r;
}

-(NSImage *)subImageFromOffsetX:(double)ox Y:(double)oy
{
  NSRect r=NSMakeRect(ox, oy, self.size.width-2*ox, self.size.height-2*ox);
  return [self imageWithRect:r];
}

@end
