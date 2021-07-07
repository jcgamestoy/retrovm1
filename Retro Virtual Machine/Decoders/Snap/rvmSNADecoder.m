//
//  rvmSNADecoder.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 9/2/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmSNADecoder.h"

@implementation rvmSNADecoder

+(NSData *)export:(NSDictionary *)snap
{
  if([snap[@"model"][@"model"] isEqualToString:@"48k"])
  {
    return [rvmSNADecoder exportSNA48K:snap];
  }
  else
  {
    return [rvmSNADecoder exportSNA128k:snap];
  }
}

+(NSData*)exportSNA128k:(NSDictionary*)snap
{
  NSMutableData *md=[NSMutableData new];
  
  snaHeader sna;
  
  sna.i=[snap[@"cpu"][@"ir"] unsignedShortValue] >> 8;
  sna.hlp=[snap[@"cpu"][@"hlp"] unsignedShortValue];
  sna.dep=[snap[@"cpu"][@"dep"] unsignedShortValue];
  sna.bcp=[snap[@"cpu"][@"bcp"] unsignedShortValue];
  sna.afp=[snap[@"cpu"][@"afp"] unsignedShortValue];
  sna.hl=[snap[@"cpu"][@"hl"] unsignedShortValue];
  sna.de=[snap[@"cpu"][@"de"] unsignedShortValue];
  sna.bc=[snap[@"cpu"][@"bc"] unsignedShortValue];
  sna.ix=[snap[@"cpu"][@"ix"] unsignedShortValue];
  sna.iy=[snap[@"cpu"][@"iy"] unsignedShortValue];
  
  sna.inte=[snap[@"cpu"][@"iffw"] unsignedShortValue] >> 6;
  sna.r=[snap[@"cpu"][@"ir"] unsignedShortValue];
  
  sna.af=[snap[@"cpu"][@"af"] unsignedShortValue];
  sna.sp=[snap[@"cpu"][@"sp"] unsignedShortValue];
  
  sna.iMode=[snap[@"cpu"][@"imodew"] unsignedShortValue];
  
  sna.bColor=[snap[@"spectrum"][@"border"] unsignedCharValue];
  NSArray *r;
  uint8 m7=[snap[@"spectrum"][@"memory7f"] unsignedCharValue];
  
  NSString *uKey=[NSString stringWithFormat:@"ram%d",m7 & 0x7];
  
  r=@[
      [[NSMutableData alloc] initWithBase64EncodedString:snap[@"memory"][@"ram5"] options:0],
      [[NSMutableData alloc] initWithBase64EncodedString:snap[@"memory"][@"ram2"] options:0],
      [[NSMutableData alloc] initWithBase64EncodedString:snap[@"memory"][uKey] options:0]];
  
  [md appendBytes:&sna length:sizeof(sna)];
  [md appendData:r[0]];
  [md appendData:r[1]];
  [md appendData:r[2]];
  
  snaHeader128k h128;
  h128.pc=[snap[@"cpu"][@"pc"] unsignedShortValue];
  h128.m7=m7;
  h128.trdos=0;
  
  [md appendBytes:&h128 length:sizeof(h128)];
  
  for(int i=0;i<8;i++)
  {
    if(i==2 || i==5 || i==(m7 & 0x7)) continue;
    
    NSString *key=[NSString stringWithFormat:@"ram%d",i];
    [md appendData:[[NSMutableData alloc] initWithBase64EncodedString:snap[@"memory"][key] options:0]];
  }
  
  return md;
}

+(NSData *)exportSNA48K:(NSDictionary *)snap
{
  NSMutableData *md=[NSMutableData new];
  
  snaHeader sna;
  
  sna.i=[snap[@"cpu"][@"ir"] unsignedShortValue] >> 8;
  sna.hlp=[snap[@"cpu"][@"hlp"] unsignedShortValue];
  sna.dep=[snap[@"cpu"][@"dep"] unsignedShortValue];
  sna.bcp=[snap[@"cpu"][@"bcp"] unsignedShortValue];
  sna.afp=[snap[@"cpu"][@"afp"] unsignedShortValue];
  sna.hl=[snap[@"cpu"][@"hl"] unsignedShortValue];
  sna.de=[snap[@"cpu"][@"de"] unsignedShortValue];
  sna.bc=[snap[@"cpu"][@"bc"] unsignedShortValue];
  sna.ix=[snap[@"cpu"][@"ix"] unsignedShortValue];
  sna.iy=[snap[@"cpu"][@"iy"] unsignedShortValue];
  
  sna.inte=[snap[@"cpu"][@"iffw"] unsignedShortValue] >> 6;
  sna.r=[snap[@"cpu"][@"ir"] unsignedShortValue];
  
  sna.af=[snap[@"cpu"][@"af"] unsignedShortValue];
  sna.sp=[snap[@"cpu"][@"sp"] unsignedShortValue];
  
  sna.iMode=[snap[@"cpu"][@"imodew"] unsignedShortValue];
  
  NSArray *r;
  if([snap[@"model"][@"submodel"] isEqualToString:@"48k"])
  {
    r=@[
               [[NSMutableData alloc] initWithBase64EncodedString:snap[@"memory"][@"ram0"] options:0],
               [[NSMutableData alloc] initWithBase64EncodedString:snap[@"memory"][@"ram1"] options:0],
               [[NSMutableData alloc] initWithBase64EncodedString:snap[@"memory"][@"ram2"] options:0]];
  }
  else
  {
    NSMutableData *v=[NSMutableData dataWithLength:0x4000];
    r=@[
        [[NSMutableData alloc] initWithBase64EncodedString:snap[@"memory"][@"ram0"] options:0],
        v,
        v];
  }
  
  if(sna.sp<0x4002) return nil; //Error no stack space.
  
  int i=(sna.sp>>14)-1;
  sna.sp--;
  ((uint8*)(((NSMutableData*)r[i]).mutableBytes))[sna.sp & 0x3fff]=[snap[@"cpu"][@"pc"] unsignedShortValue] >> 8;
  sna.sp--;
  ((uint8*)(((NSMutableData*)r[i]).mutableBytes))[sna.sp & 0x3fff]=[snap[@"cpu"][@"pc"] unsignedShortValue] & 0xff;
  
  sna.bColor=[snap[@"spectrum"][@"border"] unsignedCharValue];
  
  [md appendBytes:&sna length:sizeof(sna)];
  [md appendData:r[0]];
  [md appendData:r[1]];
  [md appendData:r[2]];
  
  return md;
}

+(void)importV1:(NSMutableDictionary*)snap header:(snaHeader*)header data:(NSData*)data machine:(id<rvmMachineProtocol>)machine
{
  NSMutableDictionary *cpu=[NSMutableDictionary new];
  
  cpu[@"bc"]=[NSNumber numberWithUnsignedShort:header->bc];
  cpu[@"de"]=[NSNumber numberWithUnsignedShort:header->de];
  cpu[@"hl"]=[NSNumber numberWithUnsignedShort:header->hl];
  cpu[@"af"]=[NSNumber numberWithUnsignedShort:header->af];
  
  cpu[@"ix"]=[NSNumber numberWithUnsignedShort:header->ix];
  cpu[@"iy"]=[NSNumber numberWithUnsignedShort:header->iy];
  //cpu[@"pc"]=[NSNumber numberWithUnsignedShort:speccy->cpu->r.pc];
  
  cpu[@"bcp"]=[NSNumber numberWithUnsignedShort:header->bcp];
  cpu[@"dep"]=[NSNumber numberWithUnsignedShort:header->dep];
  cpu[@"hlp"]=[NSNumber numberWithUnsignedShort:header->hlp];
  cpu[@"afp"]=[NSNumber numberWithUnsignedShort:header->afp];
  
  cpu[@"tm"]=[NSNumber numberWithUnsignedShort:0];
  cpu[@"aux"]=[NSNumber numberWithUnsignedShort:0];
  cpu[@"iffw"]=[NSNumber numberWithUnsignedShort:header->inte>>2 && 0x1];
  cpu[@"imodew"]=[NSNumber numberWithUnsignedShort:header->iMode];
  
  cpu[@"ir"]=[NSNumber numberWithUnsignedShort:header->i<<8 | header->r];
  cpu[@"mptr"]=[NSNumber numberWithUnsignedShort:0];
  
  cpu[@"flags"]=[NSNumber numberWithUnsignedChar:0];
  cpu[@"T"]=[NSNumber numberWithUnsignedInt:0];
  
  NSArray *r=@[[NSData dataWithBytes:data.bytes+27 length:0x4000],
               [NSData dataWithBytes:data.bytes+27+0x4000 length:0x4000],
               [NSData dataWithBytes:data.bytes+27+0x8000 length:0x4000]];
  
  uint8 i=header->sp>>14;
  uint16 o=header->sp & 0x3fff;
  cpu[@"pc"]=[NSNumber numberWithUnsignedShort:*((uint16*)([r[i-1] bytes]+o))];
  
  cpu[@"sp"]=[NSNumber numberWithUnsignedShort:header->sp+2];
  NSMutableDictionary *s=[NSMutableDictionary new];
  
  s[@"border"]=[NSNumber numberWithUnsignedInt:header->bColor];
  //s[@"bcol"]=[NSNumber numberWithUnsignedInt:header->bColor];
  //s[@"bl"]=[NSNumber numberWithUnsignedInt:header->bColor];
  
  s[@"fg"]=[NSNumber numberWithUnsignedInt:0];
  s[@"bg"]=[NSNumber numberWithUnsignedInt:0];
  
  s[@"line"]=[NSNumber numberWithInt:0];
  s[@"t"]=[NSNumber numberWithInt:0];
  s[@"T"]=[NSNumber numberWithInt:0];
  
  s[@"M"]=[NSNumber numberWithInt:0];
  s[@"frame"]=[NSNumber numberWithInt:0];
  s[@"so"]=[NSNumber numberWithInt:0];
  s[@"soundIndex"]=[NSNumber numberWithInt:0];
  
  s[@"soc"]=[NSNumber numberWithFloat:0];
  
  s[@"pixel"]=[NSNumber numberWithUnsignedChar:0];
  s[@"attr"]=[NSNumber numberWithUnsignedChar:0];
  s[@"pl"]=[NSNumber numberWithUnsignedChar:0];
  s[@"al"]=[NSNumber numberWithUnsignedChar:0];
  
  s[@"mic"]=[NSNumber numberWithUnsignedChar:0];
  s[@"ear"]=[NSNumber numberWithUnsignedChar:0];
  s[@"joyState"]=[NSNumber numberWithUnsignedChar:0];
  
  s[@"level"]=[NSNumber numberWithUnsignedInt:0];
  s[@"cassetteT"]=[NSNumber numberWithUnsignedInt:0];
  
  NSMutableDictionary *ram=[NSMutableDictionary new];
  
  if([snap[@"model"][@"model"] isEqualToString:@"48k"])
  {
    s[@"soundChannels"]=@[@0];
    ram[@"ram0"]=[r[0] base64EncodedStringWithOptions:0];
    ram[@"ram1"]=[r[1] base64EncodedStringWithOptions:0];
    ram[@"ram2"]=[r[2] base64EncodedStringWithOptions:0];
  }
  else if([snap[@"model"][@"model"] isEqualToString:@"Inves"])
  {
    NSData *d=[NSMutableData dataWithLength:0x4000];
    uint8* pt=(uint8*)d.bytes;
    for(uint i=0;i<0x4000;i+=2) pt[i]=0xff;
    
    ram[@"ram0"]=[d base64EncodedDataWithOptions:0];
    ram[@"ram1"]=[r[0] base64EncodedStringWithOptions:0];
    ram[@"ram2"]=[r[1] base64EncodedStringWithOptions:0];
    ram[@"ram3"]=[r[2] base64EncodedStringWithOptions:0];
  }
  else
  {
    s[@"soundChannels"]=@[@0,@0,@0,@0];
    
    ram[@"ram5"]=[r[0] base64EncodedStringWithOptions:0];
    ram[@"ram2"]=[r[1] base64EncodedStringWithOptions:0];
    ram[@"ram0"]=[r[2] base64EncodedStringWithOptions:0];
    
    ram[@"ram1"]=[r[2] base64EncodedStringWithOptions:0];
    ram[@"ram3"]=[r[2] base64EncodedStringWithOptions:0];
    ram[@"ram4"]=[r[2] base64EncodedStringWithOptions:0];
    ram[@"ram6"]=[r[2] base64EncodedStringWithOptions:0];
    ram[@"ram7"]=[r[2] base64EncodedStringWithOptions:0];
    
    s[@"memory7f"]=[NSNumber numberWithUnsignedChar:0x30]; //rom1 blocked ram0
    s[@"aySelect"]=[NSNumber numberWithUnsignedChar:0];
    //s[@"ay"]=@{@"r":@[@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0]};
    
    s[@"memory1f"]=[NSNumber numberWithUnsignedChar:0x04];
  }
  
  snap[@"cpu"]=cpu;
  snap[@"memory"]=ram;
  snap[@"spectrum"]=s;
  
  //NSMutableData *d=[NSMutableData dataWithLength:320*240*4];
  
  
  
  snap[@"thumb"]=@{@"w":[NSNumber numberWithUnsignedInt:384],
                   @"h":[NSNumber numberWithUnsignedInt:288],
                   @"payload":[[machine frameSnapshot:r[0] border:header->bColor] base64EncodedStringWithOptions:0]};
}

+(void)importV2:(NSMutableDictionary*)snap header:(snaHeader*)header data:(NSData*)data machine:(id<rvmMachineProtocol>)machine
{
  NSMutableDictionary *cpu=[NSMutableDictionary new];
  
  cpu[@"bc"]=[NSNumber numberWithUnsignedShort:header->bc];
  cpu[@"de"]=[NSNumber numberWithUnsignedShort:header->de];
  cpu[@"hl"]=[NSNumber numberWithUnsignedShort:header->hl];
  cpu[@"af"]=[NSNumber numberWithUnsignedShort:header->af];
  
  cpu[@"ix"]=[NSNumber numberWithUnsignedShort:header->ix];
  cpu[@"iy"]=[NSNumber numberWithUnsignedShort:header->iy];
  
  cpu[@"bcp"]=[NSNumber numberWithUnsignedShort:header->bcp];
  cpu[@"dep"]=[NSNumber numberWithUnsignedShort:header->dep];
  cpu[@"hlp"]=[NSNumber numberWithUnsignedShort:header->hlp];
  cpu[@"afp"]=[NSNumber numberWithUnsignedShort:header->afp];
  
  cpu[@"tm"]=[NSNumber numberWithUnsignedShort:0];
  cpu[@"aux"]=[NSNumber numberWithUnsignedShort:0];
  cpu[@"iffw"]=[NSNumber numberWithUnsignedShort:header->inte>>2 & 0x1];
  cpu[@"imodew"]=[NSNumber numberWithUnsignedShort:header->iMode];
  
  cpu[@"ir"]=[NSNumber numberWithUnsignedShort:header->i<<8 | header->r];
  cpu[@"mptr"]=[NSNumber numberWithUnsignedShort:0];
  
  cpu[@"flags"]=[NSNumber numberWithUnsignedChar:0];
  cpu[@"T"]=[NSNumber numberWithUnsignedInt:0];
  
  NSArray *r=@[[NSData dataWithBytes:data.bytes+27 length:0x4000],
               [NSData dataWithBytes:data.bytes+27+0x4000 length:0x4000],
               [NSData dataWithBytes:data.bytes+27+0x8000 length:0x4000]];
  
  cpu[@"sp"]=[NSNumber numberWithUnsignedShort:header->sp];
  NSMutableDictionary *s=[NSMutableDictionary new];
  
  s[@"border"]=[NSNumber numberWithUnsignedInt:header->bColor];
  //s[@"bcol"]=[NSNumber numberWithUnsignedInt:header->bColor];
  //s[@"bl"]=[NSNumber numberWithUnsignedInt:header->bColor];
  
  s[@"fg"]=[NSNumber numberWithUnsignedInt:0];
  s[@"bg"]=[NSNumber numberWithUnsignedInt:0];
  
  s[@"line"]=[NSNumber numberWithInt:0];
  s[@"t"]=[NSNumber numberWithInt:0];
  s[@"T"]=[NSNumber numberWithInt:0];
  
  s[@"M"]=[NSNumber numberWithInt:0];
  s[@"frame"]=[NSNumber numberWithInt:0];
  s[@"so"]=[NSNumber numberWithInt:0];
  s[@"soundIndex"]=[NSNumber numberWithInt:0];
  
  s[@"soc"]=[NSNumber numberWithFloat:0];
  
  s[@"pixel"]=[NSNumber numberWithUnsignedChar:0];
  s[@"attr"]=[NSNumber numberWithUnsignedChar:0];
  s[@"pl"]=[NSNumber numberWithUnsignedChar:0];
  s[@"al"]=[NSNumber numberWithUnsignedChar:0];
  
  s[@"mic"]=[NSNumber numberWithUnsignedChar:0];
  s[@"ear"]=[NSNumber numberWithUnsignedChar:0];
  s[@"joyState"]=[NSNumber numberWithUnsignedChar:0];
  
  s[@"level"]=[NSNumber numberWithUnsignedInt:0];
  s[@"cassetteT"]=[NSNumber numberWithUnsignedInt:0];
  
  NSMutableDictionary *ram=[NSMutableDictionary new];
  
  s[@"soundChannels"]=@[@0,@0,@0,@0];
  
  snaHeader128k *h128=(snaHeader128k*)(data.bytes+49179);
  
  cpu[@"pc"]=[NSNumber numberWithUnsignedShort:h128->pc];
  uint8 b[8]={0,0,1,0,0,1,0,0};
  
  uint paged=h128->m7 & 0x7;
  b[paged]=1;
  
  ram[@"ram5"]=[r[0] base64EncodedStringWithOptions:0];
  ram[@"ram2"]=[r[1] base64EncodedStringWithOptions:0];
  ram[[NSString stringWithFormat:@"ram%d",paged]]=[r[2] base64EncodedStringWithOptions:0];
  
  uint c=0;
  NSData *r7;
  for(int i=0;i<8;i++)
  {
    if(!b[i])
    {
      NSData *r=[NSData dataWithBytes:data.bytes+49179+4+c*0x4000 length:0x4000];
      ram[[NSString stringWithFormat:@"ram%d",i]]=[r base64EncodedStringWithOptions:0];
      if(i==7) r7=r;
      c++;
    }
  }
  
  if(!r7) r7=r[2];
  
  s[@"memory7f"]=[NSNumber numberWithUnsignedChar:h128->m7]; //rom1 blocked ram0
  s[@"aySelect"]=[NSNumber numberWithUnsignedChar:0];
  //s[@"ay"]=@{@"r":@[@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0]};
  
  s[@"memory1f"]=[NSNumber numberWithUnsignedChar:0x04];
  
  
  snap[@"cpu"]=cpu;
  snap[@"memory"]=ram;
  snap[@"spectrum"]=s;
  
  snap[@"thumb"]=@{@"w":[NSNumber numberWithUnsignedInt:384],
                   @"h":[NSNumber numberWithUnsignedInt:288],
                   @"payload":[[machine frameSnapshot:(h128->m7 & 0x8)?r7:r[0] border:header->bColor] base64EncodedStringWithOptions:0]};
}

+(NSDictionary *)import:(NSDictionary *)model data:(NSData *)data machine:(id<rvmMachineProtocol>)machine onError:(void (^)(NSString* err))onerror
{
  NSMutableDictionary *snap=[NSMutableDictionary new];
  
  NSString *sm=model[@"submodel"];
  NSString *m=model[@"model"];
  
  snap[@"model"]=model;
  
  if(data.length==49179) //v1
  {
    if([sm isEqualToString:@"16k"]) {
      if(onerror) onerror(@"This snapshot is unsupported in a ZX Spectrum 16k machine");
      return nil;
    }
    
    snaHeader *header=(snaHeader*)data.bytes;
    
    [self importV1:snap header:header data:data machine:machine];
  }
  else
  {
    if([m isEqualToString:@"48k"]) {
      if(onerror) onerror(@"This snapshot is unsupported in a ZX Spectrum 48k machine");

      return nil;
    }
    
    if([m isEqualToString:@"Inves"]) {
      if(onerror) onerror(@"This snapshot is unsupported in a Inves Spectrum + machine");
      
      return nil;
    }
    snaHeader *header=(snaHeader*)data.bytes;
    
    [self importV2:snap header:header data:data machine:machine];
  }
  
  return snap;
}


@end
