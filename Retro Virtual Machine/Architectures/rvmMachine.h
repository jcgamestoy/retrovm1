//
//  rvmMachine.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 21/9/15.
//  Copyright © 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "rvmMachineProtocol.h"

@interface rvmMachine : NSObject<rvmMachineProtocol>
{
  NSMutableDictionary *gamepads;
  uint joyEmuS[0x100];
  uint8 joyEmuState;
  uint joyEmuType;
}

@end
