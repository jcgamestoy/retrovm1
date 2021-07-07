//
//  rvmGamepad.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 2/4/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOKit/hid/IOHIDLib.h>

typedef enum {
  rvmGamepadGeneric,
  rvmGamepadXBOX360,
  rvmGamepadPS3,
}rvmGamepadTypes;

#define rvmJoyButton 0
#define rvmJoyUp   1
#define rvmJoyDown 2
#define rvmJoyLeft 3
#define rvmJoyRight 4
#define rvmJoySelect 5
#define rvmJoyStart 6
#define rvmJoySystem 7

@interface rvmGamepad : NSObject

@property int vendor;
@property int product;
@property int location;
@property int serial;
@property NSString* name;

@property NSData* config;



-(instancetype)initWithDevice:(IOHIDDeviceRef)dev;
-(uint)joyFunction:(uint)e;
-(uint)joyDefaultFunction:(uint)e;
-(NSImage*)gamepadImage;

@end
