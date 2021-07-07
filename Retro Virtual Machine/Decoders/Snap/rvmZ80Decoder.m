//
//  rvmZ80Decoder.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 16/2/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmZ80Decoder.h"

@implementation rvmZ80Decoder

NSDictionary *model;

+(void)initModel
{
  model=@{
          @"48k":@0,
          @"128k":@4,
          @"Plus3":@7};
}

+(NSMutableData*)encodeMemory:(uint8*)pt tail:(BOOL*)tail
{
  NSMutableData *md=[NSMutableData new];
  
  uint8 *last=pt+0x4000;
  bool led=false;
  
  while(pt<last)
  {
    uint8 b=*pt;
    int c=1;
    
    while(pt[c]==b) c++;
      
    if((led && c>=6) || (!led && c>=5) || (c>1 && b==0xed)) //compress
    {
      do
      {
        if(led)
        {
          uint16 s=0x00ed | (b<<8);
          [md appendBytes:&s length:2];
          c--;
          pt++;
        }
        
        led=false;
        uint32 save;
        
        if(c>255)
        {
          save=0x00ffeded | (b<<24);
          c-=255;
          pt+=255;
        }
        else
        {
          save=0x0000eded | (c<<16) | (b<<24);
          pt+=c;
          c=0;
          
        }
        
        [md appendBytes:&save length:4];
        
        led=false;
      }while(c>0);
    }
    else
    {
      led=b==0xed;
      pt++;
      c=0;
      [md appendBytes:&b length:1];
    }
  }
  
  if(tail)
  {
    uint32 s=0x00eded00;
    [md appendBytes:&s length:2];
  }
  
  return md;
}


+(NSData*)decodeMemory:(uint8**)first size:(uint)size tail:(bool)tail;
{
  NSMutableData *r=[NSMutableData dataWithLength:size];
  
  uint8 *pt=*first;
  uint8 *rpt=(uint8*)r.bytes;

  uint8 *last=rpt+size;
  
  while(rpt<last)
  {
    if(pt[0]==0xed && pt[1]==0xed)
    {
      uint8 c=pt[2];
      uint8 d=pt[3];
      memset(rpt, d, c);
      rpt+=c;
      pt+=4;
    }
    else
    {
      *(rpt++)=*(pt++);
    }
  }
  
  if(tail)
  {
    if(tail && (pt[0]!=0x0 || pt[1]!=0xed || pt[2]!=0xed || pt[3]!=0x0)) return nil;
    pt+=4;
  }
  
  *first=pt;
  
  return r;
}

+(NSData*)export:(NSDictionary *)snap
{
  NSMutableData *d=[NSMutableData new];
  
  if(!model) [rvmZ80Decoder initModel];
  
  snapZ80S2 s;
  snapZ80S *s1=(snapZ80S*)&s;
  
  s1->f=[snap[@"cpu"][@"af"] unsignedShortValue] & 0xff;
  s1->a=[snap[@"cpu"][@"af"] unsignedShortValue] >> 8;
  s1->bc=[snap[@"cpu"][@"bc"] unsignedShortValue];
  s1->hl=[snap[@"cpu"][@"hl"] unsignedShortValue];
  s1->pc=0; //Version 2/3
  s1->sp=[snap[@"cpu"][@"sp"] unsignedShortValue];
  s1->i=[snap[@"cpu"][@"ir"] unsignedShortValue] >> 8;
  s1->r=[snap[@"cpu"][@"ir"] unsignedShortValue] & 0x7f;
  uint8 bor=[snap[@"spectrum"][@"border"] unsignedCharValue]& 0x7;
  s1->flags1=(([snap[@"cpu"][@"ir"] unsignedShortValue] >> 7) & 0x1 ) | (bor<<1) ;
  s1->de=[snap[@"cpu"][@"de"] unsignedShortValue];
  s1->bcp=[snap[@"cpu"][@"bcp"] unsignedShortValue];
  s1->dep=[snap[@"cpu"][@"dep"] unsignedShortValue];
  s1->hlp=[snap[@"cpu"][@"hlp"] unsignedShortValue];
  s1->fp=[snap[@"cpu"][@"afp"] unsignedShortValue] & 0xff;
  s1->ap=[snap[@"cpu"][@"afp"] unsignedShortValue] >> 8;
  s1->iy=[snap[@"cpu"][@"iy"] unsignedShortValue];
  s1->ix=[snap[@"cpu"][@"ix"] unsignedShortValue];
  s1->iff2=s1->iff=[snap[@"cpu"][@"iffw"] unsignedShortValue] & 0xff;
  s1->flags2=[snap[@"cpu"][@"imodew"] unsignedShortValue];
  
  //Version 2/3
  s.length=55;
  s.pc=[snap[@"cpu"][@"pc"] unsignedShortValue];
  uint8 m=[model[snap[@"model"][@"model"]] unsignedCharValue];
  s.hardwareMode=m;
  
  if(m>0) //128k machine
  {
    s.l7ffd=[snap[@"spectrum"][@"memory7f"] unsignedCharValue];
    
    if(m==7) //Plus3
    {
      s.l11fd=[snap[@"spectrum"][@"memory1f"] unsignedCharValue];
    }
    else
    {
      s.l11fd=0;
    }
    
    s.if1=0x4; //AY
    
    for(int i=0;i<16;i++)
    {
      s.ay[i]=[snap[@"spectrum"][@"ay"][@"r"][i] unsignedCharValue];
    }
    
    [d appendBytes:&s length:sizeof(s)];
    
    for(int i=0;i<8;i++)
    {
      NSData *p=[[NSMutableData alloc] initWithBase64EncodedString:snap[@"memory"][[NSString stringWithFormat:@"ram%d",i]] options:0];
      p=[rvmZ80Decoder encodeMemory:(void*)p.bytes tail:NULL];
      
      snapZ80PS page;
      page.length=p.length;
      page.page=3+i;
      
      [d appendBytes:&page length:sizeof(page)];
      [d appendData:p];
    }
  }
  else //48k machine
  {
    s.l7ffd=0;
    s.l11fd=0;
    s.if1=0x0;

    [d appendBytes:&s length:sizeof(s)];
    snapZ80PS page;
    
    NSData *p=[[NSMutableData alloc] initWithBase64EncodedString:snap[@"memory"][@"ram0"] options:0];
    p=[rvmZ80Decoder encodeMemory:(void*)p.bytes tail:NULL];
    page.length=p.length;
    page.page=8;
    [d appendBytes:&page length:sizeof(page)];
    [d appendData:p];
    
    p=[[NSMutableData alloc] initWithBase64EncodedString:snap[@"memory"][@"ram1"] options:0];
    p=[rvmZ80Decoder encodeMemory:(void*)p.bytes tail:NULL];
    page.length=p.length;
    page.page=4;
    [d appendBytes:&page length:sizeof(page)];
    [d appendData:p];
    
    p=[[NSMutableData alloc] initWithBase64EncodedString:snap[@"memory"][@"ram2"] options:0];
    p=[rvmZ80Decoder encodeMemory:(void*)p.bytes tail:NULL];
    page.length=p.length;
    page.page=5;
    [d appendBytes:&page length:sizeof(page)];
    [d appendData:p];
  }
  
  return d;
}

+(NSMutableDictionary*)cpu:(snapZ80S *)header
{
  NSMutableDictionary *cpu=[NSMutableDictionary new];
  
  cpu[@"bc"]=[NSNumber numberWithUnsignedShort:header->bc];
  cpu[@"de"]=[NSNumber numberWithUnsignedShort:header->de];
  cpu[@"hl"]=[NSNumber numberWithUnsignedShort:header->hl];
  cpu[@"af"]=[NSNumber numberWithUnsignedShort:header->a<<8 | header->f];
  
  cpu[@"ix"]=[NSNumber numberWithUnsignedShort:header->ix];
  cpu[@"iy"]=[NSNumber numberWithUnsignedShort:header->iy];
  cpu[@"pc"]=[NSNumber numberWithUnsignedShort:header->pc];
  cpu[@"sp"]=[NSNumber numberWithUnsignedShort:header->sp];
  
  cpu[@"bcp"]=[NSNumber numberWithUnsignedShort:header->bcp];
  cpu[@"dep"]=[NSNumber numberWithUnsignedShort:header->dep];
  cpu[@"hlp"]=[NSNumber numberWithUnsignedShort:header->hlp];
  cpu[@"afp"]=[NSNumber numberWithUnsignedShort:header->ap<<8 | header->fp];
  
  cpu[@"tm"]=[NSNumber numberWithUnsignedShort:0];
  cpu[@"aux"]=[NSNumber numberWithUnsignedShort:0];
  cpu[@"iffw"]=[NSNumber numberWithUnsignedShort:header->iff];
  cpu[@"imodew"]=[NSNumber numberWithUnsignedShort:header->flags2 & 0x3];
  
  cpu[@"ir"]=[NSNumber numberWithUnsignedShort:header->i<<8 | header->r];
  cpu[@"mptr"]=[NSNumber numberWithUnsignedShort:0];
  
  cpu[@"flags"]=[NSNumber numberWithUnsignedChar:0];
  cpu[@"T"]=[NSNumber numberWithUnsignedInt:0];
  
  return cpu;
}

+(void)importV1:(NSMutableDictionary*)snap data:(NSData*)data machine:(id<rvmMachineProtocol>)machine onError:(void (^)(NSString *))onerror
{
  snapZ80S *header=(snapZ80S*)data.bytes;
  
  NSMutableDictionary *cpu=[self cpu:header];
  
  NSMutableDictionary *s=[NSMutableDictionary new];
  uint8 b=(header->flags1>>1) & 0x7;
  s[@"border"]=[NSNumber numberWithUnsignedInt:b];
  //s[@"bcol"]=[NSNumber numberWithUnsignedInt:b];
  //s[@"bl"]=[NSNumber numberWithUnsignedInt:b];
  
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
  
  uint8 *pt=(uint8*)data.bytes+30;

  uint8 *pti=pt;
  NSArray *r;
  NSData *m;
  
  if(header->flags1 & 0x20)
  {
    m=[self decodeMemory:&pt size:0x4000*3 tail:YES];
    
    pti=(uint8*)m.bytes;
  }
  r=@[[NSData dataWithBytes:pti length:0x4000],
      [NSData dataWithBytes:pti+0x4000 length:0x4000],
      [NSData dataWithBytes:pti+0x8000 length:0x4000]];
  
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
    s[@"ay"]=@{@"r":@[@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0]};
    
    s[@"memory1f"]=[NSNumber numberWithUnsignedChar:0x04];
  }
  
  snap[@"cpu"]=cpu;
  snap[@"memory"]=ram;
  snap[@"spectrum"]=s;
  
  //NSMutableData *d=[NSMutableData dataWithLength:320*240*4];
  
  snap[@"thumb"]=@{@"w":[NSNumber numberWithUnsignedInt:384],
                   @"h":[NSNumber numberWithUnsignedInt:288],
                   @"payload":[[machine frameSnapshot:r[0] border:b] base64EncodedStringWithOptions:0]};
}


+(NSDictionary*)extractRam:(NSData*)data
{
  snapZ80S2 *header=(snapZ80S2*)data.bytes;
  //NSMutableArray *ram=[NSMutableArray arrayWithArray:@[@0,@0,@0,@0,@0,@0,@0,@0]];
  NSMutableDictionary *ram=[NSMutableDictionary new];
  int pi[]={-1,-1,-1,0,1,2,3,4,5,6,7,-1};
  
  uint8 *pt=(uint8*)data.bytes+32+header->length;
  uint8 *last=(uint8*)data.bytes+data.length;
  
  while(pt<last)
  {
    snapZ80PS *page=(snapZ80PS*)pt;
    
    int i=pi[page->page];
    if(i>=0)
    {
      uint8* rpt=pt+3;
      
      ram[[NSNumber numberWithInt:i]]=[self decodeMemory:&rpt size:0x4000 tail:NO];
    }
    
    pt+=3+((page->length==0xffff)?0x4000:page->length);
  }
  
  return ram;
}

+(void)importV2:(NSMutableDictionary*)snap data:(NSData*)data machine:(id<rvmMachineProtocol>)machine onError:(void (^)(NSString *))onerror
{
  snapZ80S2 *header=(snapZ80S2*)data.bytes;
  
  NSMutableDictionary *cpu=[self cpu:(snapZ80S*)header];
  
  cpu[@"pc"]=[NSNumber numberWithUnsignedShort:header->pc];
  
  uint version=4;
  
  if(header->length==23)
  {
    version=2;
  }
  else if(header->length==54)
  {
    version=3;
  }
  
  NSMutableDictionary *s=[NSMutableDictionary new];
  uint8 b=(header->s.flags1>>1) & 0x7;
  s[@"border"]=[NSNumber numberWithUnsignedInt:b];
  //s[@"bcol"]=[NSNumber numberWithUnsignedInt:b];
  //s[@"bl"]=[NSNumber numberWithUnsignedInt:b];
  
  s[@"fg"]=[NSNumber numberWithUnsignedInt:0];
  s[@"bg"]=[NSNumber numberWithUnsignedInt:0];
  
  s[@"line"]=[NSNumber numberWithInt:0];
  s[@"t"]=[NSNumber numberWithInt:30000];
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
  
  NSDictionary *r=[self extractRam:data];
  
  if([snap[@"model"][@"model"] isEqualToString:@"48k"])
  {
    if(r.count>3)
    {
      if(onerror) onerror(@"This snapshot is unsupported in a ZX Spectrum 48k machine");
      snap[@"Error"]=@"Error";
      return;
    }
    s[@"soundChannels"]=@[@0];
    ram[@"ram0"]=[r[@5] base64EncodedStringWithOptions:0];
    ram[@"ram1"]=[r[@1] base64EncodedStringWithOptions:0];
    ram[@"ram2"]=[r[@2] base64EncodedStringWithOptions:0];
  }
  else if([snap[@"model"][@"model"] isEqualToString:@"Inves"])
  {
    if(r.count>3)
    {
      if(onerror) onerror(@"This snapshot is unsupported in a Inves Spectrum + machine");
      snap[@"Error"]=@"Error";
      return;
    }
    
    NSData *d=[NSMutableData dataWithLength:0x4000];
    uint8* pt=(uint8*)d.bytes;
    for(uint i=0;i<0x4000;i+=2) pt[i]=0xff;
    
    ram[@"ram0"]=[d base64EncodedDataWithOptions:0];
    ram[@"ram1"]=[r[@5] base64EncodedStringWithOptions:0];
    ram[@"ram2"]=[r[@1] base64EncodedStringWithOptions:0];
    ram[@"ram3"]=[r[@2] base64EncodedStringWithOptions:0];
  }
  else
  {
    s[@"soundChannels"]=@[@0,@0,@0,@0];

    ram[@"ram5"]=[r[@5] base64EncodedStringWithOptions:0];

    ram[@"ram2"]=[(r[@0])?r[@2]:r[@1] base64EncodedStringWithOptions:0];
    ram[@"ram0"]=[(r[@0])?r[@0]:r[@2] base64EncodedStringWithOptions:0];
    
    ram[@"ram1"]=[(r[@0])?r[@1]:r[@1] base64EncodedStringWithOptions:0];
    ram[@"ram3"]=[(r[@3])?r[@3]:r[@1] base64EncodedStringWithOptions:0];
    ram[@"ram4"]=[(r[@4])?r[@4]:r[@1] base64EncodedStringWithOptions:0];
    ram[@"ram6"]=[(r[@6])?r[@6]:r[@1] base64EncodedStringWithOptions:0];
    ram[@"ram7"]=[(r[@7])?r[@7]:r[@1] base64EncodedStringWithOptions:0];
    
    s[@"memory7f"]=[NSNumber numberWithUnsignedChar:(r[@0])?header->l7ffd:0x30];
    s[@"aySelect"]=[NSNumber numberWithUnsignedChar:header->lfffd];
    
    NSMutableArray *ayr=[NSMutableArray new];
    
    for(int i=0;i<16;i++)
    {
      ayr[i]=[NSNumber numberWithUnsignedChar:header->ay[i]];
    }
    
    s[@"ay"]=@{@"r":ayr};
    
    s[@"memory1f"]=[NSNumber numberWithUnsignedChar:(version==4)?header->l11fd:0x4];
  }
  
  snap[@"cpu"]=cpu;
  snap[@"memory"]=ram;
  snap[@"spectrum"]=s;
  
  //NSMutableData *d=[NSMutableData dataWithLength:320*240*4];
  
  snap[@"thumb"]=@{@"w":[NSNumber numberWithUnsignedInt:384],
                   @"h":[NSNumber numberWithUnsignedInt:288],
                   @"payload":[[machine frameSnapshot:(header->l7ffd&0x8)?r[@7]:r[@5] border:b] base64EncodedStringWithOptions:0]};
}

+(NSDictionary *)import:(NSDictionary *)model data:(NSData *)data machine:(id<rvmMachineProtocol>)machine onError:(void (^)(NSString *))onerror
{
  NSMutableDictionary *snap=[NSMutableDictionary new];
  
  snapZ80S *header=(snapZ80S*)data.bytes;
  
  snap[@"model"]=model;
  //NSString *m=model[@"model"];
  NSString *sm=model[@"submodel"];
  
  if([sm isEqualToString:@"16k"])
  {
    if(onerror) onerror(@"This snapshot is unsupported in a ZX Spectrum 16k machine");
    
    return nil;
  }
  
  if(header->pc)
    [self importV1:snap data:data machine:machine onError:onerror];
  else
    [self importV2:snap data:data machine:machine onError:onerror];
  
  return (snap[@"Error"])?nil:snap;
}
@end
