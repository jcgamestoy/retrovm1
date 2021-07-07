//
//  rvmX360Gamepad.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 12/4/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmX360Gamepad.h"

@implementation rvmX360Gamepad

-(uint)joyDefaultFunction:(uint)e
{
  switch(e)
  {
    case 114:
    case 0:
      return rvmJoyLeft;
    case 115:
    case 1:
      return rvmJoyRight;
    case 112:
    case 102:
    case 2:
      return rvmJoyUp;
    case 113:
    case 3:
      return rvmJoyDown;
    case 111:
      return rvmJoySystem;
    case 110:
      return rvmJoySelect;
    case 109:
      return rvmJoyStart;
    default:
      return rvmJoyButton;
  }
}

@end
