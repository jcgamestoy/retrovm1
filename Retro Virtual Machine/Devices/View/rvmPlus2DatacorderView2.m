//
//  rvmPlus2DatacorderView2.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 13/11/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmPlus2DatacorderView2.h"

@implementation rvmPlus2DatacorderView2

-(NSImage *)chasisImage
{
  return [NSImage imageNamed:@"chasis+2.2"];
}

-(NSImage *)chasisDoorImage
{
  return [NSImage imageNamed:@"chasisDoor+2.2"];
}

-(CGRect)chasisFrame
{
  return CGRectMake(0, 0, 1238, 493);
}

-(CGRect)chasisDoorFrame
{
  return CGRectMake(847.8-2, 493-110.5-193.8-1, 330.1+3, 193.8+2);
}

-(CGRect)cassetteFrame
{
  return CGRectMake(95-3.5+782-19,17+504-198-142+2.5,305+8,190+8);
}

-(CGPoint)wheel1Point
{
  return CGPointMake(133+7+43+763,17+504-86-177-7+43);
}

-(CGPoint)wheel2Point
{
  return CGPointMake(133+7+129+43+763,17+504-86-177-7+43);
}

-(CGRect)cassetteNameFrame
{
  return CGRectMake(136+763,17+504-161-12,210,14);
}

-(CGRect)blockNameFrame
{
  return CGRectMake(136+763,17+504-175-12,260,14);
}

@end
