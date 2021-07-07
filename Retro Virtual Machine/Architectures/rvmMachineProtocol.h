//
//  rvmMachineProtocol.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 11/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "rvmCommandDispatcher.h"
//#import "rvmCassettePlayer.h"
#import "rvmTapeDecoderProtocol.h"
#import "rvmDskDecoder.h"
#import "rvmTransitionViewController.h"
#import "rvmDeviceProtocol.h"

#import "rvmBufferChain.h"
//#import "rvmLuajit.h"

#import "rvmGamepad.h"
//#import "rvmAudioViewController.h"

#define kRvmStateStopped 0
#define kRvmStatePlaying 1
#define kRvmStatePaused  2
#define kRvmStateWarp    4

#define kMediaTape @1
#define kMediaDisk @2

@class rvmCommandDispatcher;
@class rvmAudioViewController;
@class rvmVideoViewController;

typedef struct
{
  int number;
  uint8 lines[8];
  uint8 codes[8];
  char *name;
}rvmMachineKeyS;

@protocol rvmMachineProtocol <NSObject>

@property rvmBufferChain *tripleBuffer;

@property (strong) id<rvmTapeDecoderProtocol> tapeDecoder;
@property (weak) id doc;
@property dispatch_queue_t queue;
@property NSDictionary *lastSnapshot;
@property uint keyboardType;

@property bool joyEmu;
@property uint32 control;

-(void)doFrame:(bool)fast;

-(void)stepInstruction;
-(void)keyDown:(uint8)code;
-(void)keyUp:(uint8)code;

-(void)resetMachine;
-(void)resetRam;
-(void)joyState:(uint8)state;

#pragma mark Audio
-(int16_t*)audioBuffer;
-(uint)audioLength;

-(NSViewController*)cassetteController;

//Disk interface
-(NSViewController*)diskController;
-(void)insertDisk:(rvmDskDecoder*)disk inDrive:(uint32)drive;
-(void)enableDrive:(uint32)drive;
-(void)disableDrive:(uint32)drive;
//Custom rom
-(void)loadCustomRom:(NSData*)romdata;
-(void)loadDefaultRom;


//VM Interface
-(rvmTransitionViewController*)configViewController;
-(rvmTransitionViewController*)configKeyboardViewController;

//@property bool paused;
//@property bool running;
-(NSDictionary*)createSnapshot;
-(NSDictionary*)createFastSnapshot;
-(void)loadSnapshot:(NSDictionary*)snap;
-(NSData*)imageSnapshot;

//LUA Representation
//-(void)luaInit:(lua_State*)L;
//-(void)registerCommands:(lua_State*)L;

//Keyboard
-(rvmMachineKeyS)keysForkey:(uint)keycode;
-(rvmMachineKeyS)keysForMachinekey:(uint)keycode;
-(void)changeKey:(uint)keycode keys:(rvmMachineKeyS*)key;
-(NSData*)machineKeysSnap;
-(void)loadMachineKeys:(NSData*)data;
//-(const char*)keyName:(rvmMachineKeyS*)key;

//Audio
-(rvmAudioViewController*)audioController;

//Video
-(rvmVideoViewController*)videoController;

-(NSData*)frameSnapshot:(NSData*)memory border:(uint8)border;

//Joystick
-(void)joy:(rvmGamepad*)g element:(uint)e value:(uint)v;
-(void)joyEmuType:(uint)type;

//OSD Event
@property (strong) void (^onOsdEvent)(NSString *msg,uint size,NSImage *img);
@property (strong) void (^onFastSnap)(NSImage *i);

//Devices
-(NSArray*)availableDevices;
-(NSArray*)attachedDevices;
-(void)attachDevice:(Class)device;
-(void)removeDevice:(id<rvmDeviceProtocol>)device;

-(void)initialize;

//Generic media support
-(NSArray*)supportedTypes;
-(void)loadMedia:(NSURL*)filename;
@end
