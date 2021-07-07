//
//  rvmPS3Controller.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 13/4/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmPS3Controller.h"

@implementation rvmPS3Controller

-(uint)joyDefaultFunction:(uint)e
{
  switch(e)
  {
    case 108:
    case 0:
      return rvmJoyLeft;
    case 106:
    case 1:
      return rvmJoyRight;
    case 105:
    case 102:
    case 2:
      return rvmJoyUp;
    case 107:
    case 3:
      return rvmJoyDown;
    case 117:
      return rvmJoySystem;
    case 101:
      return rvmJoySelect;
    case 104:
      return rvmJoyStart;
    default:
      return rvmJoyButton;
  }
}

-(NSImage*)gamepadImage
{
  return [NSImage imageNamed:@"ps3"];
}

@end
