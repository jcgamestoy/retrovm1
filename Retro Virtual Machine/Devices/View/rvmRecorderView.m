//
//  rvmRecorderView.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 27/05/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmRecorderView.h"

@implementation rvmRecorderView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(NSImage *)chasisImage
{
  return [NSImage imageNamed:@"chasisRecorder"];
}

-(NSImage *)chasisDoorImage
{
  return [NSImage imageNamed:@"chasisDoorRecorder"];
}

-(CGRect)chasisFrame
{
  return CGRectMake(0, 0, 431, 730);
}

-(CGRect)chasisDoorFrame
{
  return CGRectMake(48,730-194-353, 321, 194);
}

-(CGRect)cassetteFrame
{
  return CGRectMake(54-3.5,730-190-356-5.5,305+8,190+8);
}

-(CGPoint)wheel1Point
{
  return CGPointMake(92+7+43,730-86-391-7+43);
}

-(CGPoint)wheel2Point
{
  return CGPointMake(92+7+129+43,730-86-391-7+43);
}

-(CGRect)cassetteNameFrame
{
  return CGRectMake(100,504-149-12,210,14);
}

-(CGRect)blockNameFrame
{
  return CGRectMake(100,504-163-12,210,14);
}
@end
