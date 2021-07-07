//
//  rvmInputManager.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 2/4/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOKit/hid/IOHIDLib.h>
#import "rvmGamepad.h"



@interface rvmInputManager : NSObject

+(rvmInputManager*)manager;

-(void)deviceAdd:(IOHIDDeviceRef)device;
-(void)deviceRemoved:(IOHIDDeviceRef)device;

-(void)receivedEvent:(rvmGamepad*)gamepad value:(IOHIDValueRef)value;
-(void)addConfig:(rvmGamepad*)gamepad data:(NSData*)data;

@property (strong) void (^onJoy)(rvmGamepad* gamepad,uint elementId,uint value);
@property (strong) void (^onJoyPlugged)(rvmGamepad *gamepad);
@property (strong) void (^onJoyUnplugged)(rvmGamepad *gamepad);

@end
