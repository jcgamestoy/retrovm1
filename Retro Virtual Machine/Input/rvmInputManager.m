//
//  rvmInputManager.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 2/4/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmInputManager.h"
#import "rvmX360Gamepad.h"
#import "rvmPS3Controller.h"

@interface rvmInputManager()
{
  NSMutableDictionary *devices;
  NSMutableDictionary *configs;
  
  IOHIDManagerRef manager;
}

@end

static rvmInputManager* single;

void addD(void *inContext, IOReturn inResult, void *inSender, IOHIDDeviceRef device)
{
  rvmInputManager *im=(__bridge rvmInputManager *)(inContext);
  [im deviceAdd:device];
}

void removeD(void *inContext, IOReturn inResult, void *inSender, IOHIDDeviceRef device)
{
  rvmInputManager *im=(__bridge rvmInputManager *)(inContext);
  [im deviceRemoved:device];
}

@implementation rvmInputManager

+(rvmInputManager*)manager
{
  if(!single)
  {
    single=[rvmInputManager new];
    [single loadConfig];
    [single setup];
  }
  
  return single;
}


-(void)setup
{
  devices=[NSMutableDictionary dictionary];
  if(!configs) configs=[NSMutableDictionary dictionary];
  
  manager = IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDOptionsTypeNone);
  
  NSMutableDictionary *gamepadCriterion = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           @(kHIDPage_GenericDesktop), (NSString *)CFSTR(kIOHIDDeviceUsagePageKey),
                                           @(kHIDUsage_GD_GamePad), (NSString *)CFSTR(kIOHIDDeviceUsageKey),
                                           nil];
  NSMutableDictionary *joystickCriterion = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            @(kHIDPage_GenericDesktop), (NSString *)CFSTR(kIOHIDDeviceUsagePageKey),
                                            @(kHIDUsage_GD_Joystick), (NSString *)CFSTR(kIOHIDDeviceUsageKey),
                                            nil];
  
  IOHIDManagerSetDeviceMatchingMultiple(manager, (__bridge CFArrayRef)(@[gamepadCriterion,joystickCriterion]));
  IOHIDManagerRegisterDeviceMatchingCallback(manager, addD, (__bridge void *)self);
  IOHIDManagerRegisterDeviceRemovalCallback(manager, removeD, (__bridge void *)self);
  
  IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
}

-(void)deviceAdd:(IOHIDDeviceRef)dev
{
  rvmGamepad *g;
  uint vendor=0,product=0;
  CFTypeRef tCFTypeRef;
  CFTypeID numericTypeId = CFNumberGetTypeID();
  
  tCFTypeRef = IOHIDDeviceGetProperty(dev, CFSTR(kIOHIDVendorIDKey));
  if (tCFTypeRef && CFGetTypeID(tCFTypeRef) == numericTypeId)
    CFNumberGetValue((CFNumberRef)tCFTypeRef, kCFNumberSInt32Type, &vendor);
  
  tCFTypeRef = IOHIDDeviceGetProperty(dev, CFSTR(kIOHIDProductIDKey));
  if (tCFTypeRef && CFGetTypeID(tCFTypeRef) == numericTypeId)
    CFNumberGetValue((CFNumberRef)tCFTypeRef, kCFNumberSInt32Type, &product);
  
  if(vendor==1118 && (product==654 || product==655))
  {
    g=[[rvmX360Gamepad alloc] initWithDevice:dev];
  }
  else if(vendor==1356 && product==616) {
    //PS3
    g=[[rvmPS3Controller alloc] initWithDevice:dev];
  }
  else
  {
    g=[[rvmGamepad alloc] initWithDevice:dev];
  }
  
  devices[[NSString stringWithFormat:@"%p",dev]]=g;
  
  NSString *k=[NSString stringWithFormat:@"%x-%x",g.vendor,g.product];

  if(configs[k])
  {
    //NSData *d=[[NSData alloc] initWithBase64Encoding:configs[k]];
    NSData *d=[[NSData alloc] initWithBase64EncodedData:configs[k] options:0];
    g.config=d;
  }
  
  if(_onJoyPlugged) _onJoyPlugged(g);
}

-(void)deviceRemoved:(IOHIDDeviceRef)device
{
  NSString *k=[NSString stringWithFormat:@"%p",device];
  rvmGamepad *g=devices[k];
  [devices removeObjectForKey:k];
  
  if(_onJoyUnplugged) _onJoyUnplugged(g);
}

-(void)receivedEvent:(rvmGamepad*)gamepad value:(IOHIDValueRef)value
{
  IOHIDElementRef element = IOHIDValueGetElement(value);
  int usagePage = IOHIDElementGetUsagePage(element);
  int usage = IOHIDElementGetUsage(element);
  long max=IOHIDElementGetPhysicalMax(element);
  long min=IOHIDElementGetPhysicalMin(element);
  long d=max-min;
  
  if (usagePage == kHIDPage_GenericDesktop)
  {
    switch(usage)
    {
      case kHIDUsage_GD_X:
      case kHIDUsage_GD_Y:
      {
        uint a=(usage-kHIDUsage_GD_X)*2;
        long v=IOHIDValueGetIntegerValue(value);
        double p=((v-min)/(double)d)*100;
        NSLog(@"P:%f",p);
        if(_onJoy) {
          if(p<25) {
            _onJoy(gamepad,a,1);
            _onJoy(gamepad,a+1,0);
          }else if(p>75)
          {
            _onJoy(gamepad,a+1,1);
            _onJoy(gamepad,a,0);
          }
          else {
            _onJoy(gamepad,a,0);
            _onJoy(gamepad,a+1,0);
          }
        }
        
        //if(_onJoy) _onJoy(gamepad,a,p);
      }
    }
  }
  else if(usagePage==kHIDPage_Button)
  {
    uint u=usage+100;
    long v=IOHIDValueGetIntegerValue(value);
//    
//    if(u==gamepad.padRight) gamepad.digitalState=(v)?gamepad.digitalState|0x1:gamepad.digitalState&0xfe;
//    if(u==gamepad.padLeft) gamepad.digitalState=(v)?gamepad.digitalState|0x2:gamepad.digitalState&0xfd;
//    if(u==gamepad.padDown) gamepad.digitalState=(v)?gamepad.digitalState|0x4:gamepad.digitalState&0xfb;
//    if(u==gamepad.padUp || u==102) gamepad.digitalState=(v)?gamepad.digitalState|0x8:gamepad.digitalState&0xf7;
//    
//    NSLog(@"Button: %d",100+usage);

    if(_onJoy) _onJoy(gamepad,u,v?1:0);
  }
}

-(void)addConfig:(rvmGamepad*)gamepad data:(NSData*)data
{
  NSString *k=[NSString stringWithFormat:@"%x-%x",gamepad.vendor,gamepad.product];
  
  configs[k]=[data base64EncodedStringWithOptions:0];
  
  gamepad.config=data;
  
  [self saveConfig];
}

-(void)saveConfig
{
  NSArray *p=NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
  NSString *dPath=[NSString stringWithFormat:@"%@/Retro Virtual Machine",p[0]];
  
  NSFileManager *f=[NSFileManager defaultManager];
  
  NSError *e;
  BOOL r=[f createDirectoryAtPath:dPath withIntermediateDirectories:YES attributes:nil error:&e];
  if(!r)
  {
    NSException *e=[NSException exceptionWithName:@"Error" reason:@"Error creating application support directory." userInfo:nil];
    @throw e;
  }
  
  [[NSJSONSerialization dataWithJSONObject:configs options:0 error:nil] writeToFile:[NSString stringWithFormat:@"%@/gamepads.json",dPath] atomically:YES];
}

-(void)loadConfig
{
  NSArray *p=NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
  NSString *dPath=[NSString stringWithFormat:@"%@/Retro Virtual Machine",p[0]];
  
  NSFileManager *f=[NSFileManager defaultManager];
  
  NSError *e;
  BOOL r=[f createDirectoryAtPath:dPath withIntermediateDirectories:YES attributes:nil error:&e];
  if(!r)
  {
    NSException *e=[NSException exceptionWithName:@"Error" reason:@"Error creating application support directory." userInfo:nil];
    @throw e;
  }
  
  NSData *rm=[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/gamepads.json",dPath]];
  if(rm)
    configs=[NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:rm options:0 error:nil]];
}

//-(void)disable
//{
//  
//}

@end
