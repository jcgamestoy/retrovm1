//
//  rvmMachine.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 21/9/15.
//  Copyright © 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmMachine.h"

@interface rvmMachine()
{
  NSMutableArray *avDevices;
  NSMutableArray *atDevices;
}

@end

@implementation rvmMachine

@synthesize tripleBuffer;
@synthesize doc;

@synthesize lastSnapshot;
@synthesize tapeDecoder;

@synthesize queue;
@synthesize joyEmu;
@synthesize control;

@synthesize onOsdEvent;
@synthesize onFastSnap;
@synthesize keyboardType;

#pragma mark Constructor

-(id)init
{
  self=[super init];
  if(self)
  {
    //luaVM=newLua();
    gamepads=[NSMutableDictionary dictionary];
    joyEmuType=0x100;
    [self initialize];
  }
  
  return self;
}

-(void)initialize
{
  
}

#pragma mark Run inteface
-(void)doFrame:(bool)fast
{
  return;
}

-(void)stepInstruction
{
  return;
}

-(void)resetMachine
{
  
}

#pragma mark Devices
-(NSArray *)availableDevices
{
  return avDevices;
}

-(NSArray *)attachedDevices
{
  return atDevices;
}

-(void)attachDevice:(Class)device
{
  id<rvmDeviceProtocol> d=[device new];
  
  [atDevices addObject:d];
  [avDevices removeObject:device];
}

-(void)removeDevice:(id<rvmDeviceProtocol>)device
{
  [atDevices removeObject:device];
  [avDevices addObject:device.class];
}

#pragma mark Keyboard
-(void)keyDown:(uint8)code
{
  
}

-(void)keyUp:(uint8)code
{
  
}

-(rvmMachineKeyS)keysForkey:(uint)keycode
{
  rvmMachineKeyS s={};
  return s;
}

-(rvmMachineKeyS)keysForMachinekey:(uint)keycode
{
  rvmMachineKeyS s={};
  return s;
}

-(void)changeKey:(uint)keycode keys:(rvmMachineKeyS *)key
{
  
}

#pragma mark Joystick
-(void)joyState:(uint8)state
{
  
}

-(void)joy:(rvmGamepad *)g element:(uint)e value:(uint)v
{
  
}

-(void)joyEmuType:(uint)type
{
  
}

#pragma mark Audio
-(int16_t *)audioBuffer
{
  return NULL;
}

-(uint)audioLength
{
  return 3840; //192khz / 50hz
}

#pragma mark View Controllers
-(NSViewController *)cassetteController
{
  return nil;
}

-(NSViewController *)diskController
{
  return nil;
}

-(rvmTransitionViewController *)configViewController
{
  return nil;
}

-(rvmTransitionViewController *)configKeyboardViewController
{
  return nil;
}

-(rvmAudioViewController *)audioController
{
  return nil;
}

-(rvmVideoViewController *)videoController
{
  return nil;
}

#pragma mark Disk
-(void)insertDisk:(rvmDskDecoder *)disk inDrive:(uint32)drive
{
  return;
}

-(void)enableDrive:(uint32)drive
{
  return;
}

-(void)disableDrive:(uint32)drive
{
  return;
}

#pragma mark Rom
-(void)loadCustomRom:(NSData *)romdata
{
  
}

-(void)loadDefaultRom
{
  
}

#pragma mark Snapshots
-(void)loadSnapshot:(NSDictionary *)snap
{
  
}

-(NSDictionary *)createSnapshot
{
  return nil;
}

-(NSDictionary *)createFastSnapshot
{
  return nil;
}

-(NSData *)imageSnapshot
{
  return nil;
}

-(NSData *)machineKeysSnap
{
  return nil;
}

-(void)loadMachineKeys:(NSData *)data
{
  
}

-(NSData *)frameSnapshot:(NSData *)memory border:(uint8)border
{
  return nil;
}

-(void)resetRam
{
  
}

-(NSArray *)supportedTypes
{
  return nil;
}

-(void)loadMedia:(NSURL *)filename
{
  
}
@end
