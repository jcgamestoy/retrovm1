//
//  rvmGamepad.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 2/4/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmGamepad.h"
#import "rvmInputManager.h"

@interface rvmGamepad()
{
  IOHIDDeviceRef device;
  rvmInputManager *manager;
}

@end

static void inputCb(void *context, IOReturn result, void *sender, IOHIDValueRef value)
{
  rvmGamepad *pad=(__bridge rvmGamepad *)(context);
  [[rvmInputManager manager] receivedEvent:pad value:value];
}

@implementation rvmGamepad

-(instancetype)initWithDevice:(IOHIDDeviceRef)dev
{
  if(self=[self init])
  {
    //IOObjectRetain(dev);
    manager=[rvmInputManager manager];
    
    device=dev;
    _vendor=0;
    _product=0;
    
    CFTypeRef tCFTypeRef;
    CFTypeID numericTypeId = CFNumberGetTypeID();
    
    tCFTypeRef = IOHIDDeviceGetProperty(dev, CFSTR(kIOHIDVendorIDKey));
    if (tCFTypeRef && CFGetTypeID(tCFTypeRef) == numericTypeId)
      CFNumberGetValue((CFNumberRef)tCFTypeRef, kCFNumberSInt32Type, &_vendor);
    
    tCFTypeRef = IOHIDDeviceGetProperty(dev, CFSTR(kIOHIDProductIDKey));
    if (tCFTypeRef && CFGetTypeID(tCFTypeRef) == numericTypeId)
      CFNumberGetValue((CFNumberRef)tCFTypeRef, kCFNumberSInt32Type, &_product);
    
    tCFTypeRef = IOHIDDeviceGetProperty(dev, CFSTR(kIOHIDLocationIDKey));
    if (tCFTypeRef && CFGetTypeID(tCFTypeRef) == numericTypeId)
      CFNumberGetValue((CFNumberRef)tCFTypeRef, kCFNumberSInt32Type, &_location);
    
    tCFTypeRef = IOHIDDeviceGetProperty(dev, CFSTR(kIOHIDSerialNumberKey));
    if (tCFTypeRef && CFGetTypeID(tCFTypeRef) == numericTypeId)
      CFNumberGetValue((CFNumberRef)tCFTypeRef, kCFNumberSInt32Type, &_location);
    
    _name=[NSString stringWithFormat:@"%@",(__bridge NSString *)(IOHIDDeviceGetProperty(device, CFSTR(kIOHIDProductKey)))];
    
//    if(_vendor==1118 && (_product==654 || _product==655)) //Xbox360
//    {
//      _type=rvmGamepadXBOX360;
//      _systemButton=111;
//      
//      _padUp=112;
//      _padDown=113;
//      _padLeft=114;
//      _padRight=115;
//      
//      _select=110;
//      _start=109;
//    }
//    else if(_vendor==1356 && _product==616) //PS3
//    {
//      _type=rvmGamepadPS3;
//      _systemButton=117;
//      
//      _padUp=105;
//      _padDown=107;
//      _padLeft=108;
//      _padRight=106;
//      
//      _select=101;
//      _start=104;
//    }
//    else
//    {
//      _type=rvmGamepadGeneric;
//      
//      _systemButton=0xFFFFFFFF;
//      _padDown=3;
//      _padUp=2;
//      _padLeft=0;
//      _padRight=1;
//      _select=_start=0xFFFFFFFF;
//    }
//    
    IOHIDDeviceOpen(device, kIOHIDOptionsTypeNone);
    IOHIDDeviceRegisterInputValueCallback(device, inputCb, (__bridge void *)(self));
  }
  
  return self;
}

-(uint)joyFunction:(uint)e
{
  if(_config)
  {
    uint8 b=(uint8)e;
    uint8 *pt=(uint8*)_config.bytes;
    for(int i=0;i<7;i++)
      if(pt[i]==b)
      {
        return i+1;
      }
    
    return [self joyDefaultFunction:e];
  }
  else
  {
    return [self joyDefaultFunction:e];
  }
}

-(uint)joyDefaultFunction:(uint)e
{
  switch(e)
  {
    case 0:
      return rvmJoyLeft;
    case 1:
      return rvmJoyRight;
    case 2:
      return rvmJoyUp;
    case 3:
      return rvmJoyDown;
    default:
      return rvmJoyButton;
  }
}

-(NSImage*)gamepadImage
{
  return [NSImage imageNamed:@"x360"];
}


@end
