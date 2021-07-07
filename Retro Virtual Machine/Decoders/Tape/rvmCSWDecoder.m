//
//  rvmCSWDecoder.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 4/11/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmCSWDecoder.h"
//#import "GZIP.h"
#import "NSData+Gzip.h"

@interface rvmCSWDecoder()
{
  NSMutableData *pulses;
}

@end

@implementation rvmCSWDecoder

-(instancetype)init
{
  self=[super init];
  if(self)
  {
    self.image=[NSImage imageNamed:@"CSWCassette2"];
  }
  return self;
}

-(void)parseV1:(rvmCSWBlock1S*)block
{
  self.image=[NSImage imageNamed:@"CSWCassette1"];
  rvmPulsesBlockS *p=calloc(sizeof(rvmPulsesBlockS), 1);
  pulses=[NSMutableData dataWithLength:sizeof(rvmPulse)*1000];
  
  NSUInteger c=pulses.length;
  const uint32 inc=sizeof(rvmPulse);
  uint32 i=0;
  
  void *pt=block->data;
  const void *last=tap.bytes+tap.length;
  void *ins=pulses.mutableBytes;
  uint32 f=3500000/block->sampleRate;
  
  while(pt<last)
  {
    if(!c)
    {
      c=pulses.length;
      [pulses increaseLengthBy:pulses.length];
      ins=pulses.mutableBytes+c;
    }
    
    rvmPulse *pul=(rvmPulse*)(ins);
    ins+=inc;
    c-=inc;
    
    uint32 d=*((uint8*)pt++);
    
    if(!d)
    {
      d=*((uint32*)pt);
      pt+=4;
    }
    
    pul->count=1;
    pul->length=d*f;
    i++;
  }
  
  rvmInitPulsesBlock(p, i, pulses.mutableBytes, block->flags & 0x1, NO);
  p->length(p);
  p->startT=0;
  decoder.totalTStates=p->Tstates;
  decoder.numberOfBlocks=1;
  decoder.blocks=malloc(sizeof(void*));
  decoder.blocks[0]=p;
}

-(void)parseV2:(rvmCSWBlock2S*)block
{
  self.image=[NSImage imageNamed:@"CSWCassette2"];
  rvmPulsesBlockS *p=calloc(sizeof(rvmPulsesBlockS), 1);
  NSMutableArray *pu=[NSMutableArray array];
  
  uint32 i=block->hdr;
  int pulsesC=block->total;
  uint32 f=ceil(3500000.0/(double)block->sampleRate);
  
  void *pt=&block->data[i];
  NSData *d;
  if(block->compression==0x2)
  {
    uint32 l=(uint32)tap.length-(uint32)(pt-tap.bytes);
    d=[NSData dataWithBytes:pt length:l];
    d=[d inflate];
    pt=(void*)d.bytes;
  }
  
  
  while(pulsesC>0)
  {
    pulsesC--;
    uint32 d=*((uint8*)pt++);
    
    if(!d)
    {
      d=*((uint32*)pt);
      pt+=4;
      //pulses-=4;
    }
    
    [pu addObject:[NSNumber numberWithUnsignedInt:d]];
  }
  
  rvmPulse *pul=calloc(sizeof(rvmPulse), pu.count);
  
  for(int i=0;i<pu.count;i++)
  {
    NSNumber *n=pu[i];
    pul[i].count=1;
    pul[i].length=f*n.unsignedIntValue;
  }
  
  rvmInitPulsesBlock(p, (uint32)pu.count, pul, block->flags & 0x1, YES);
  p->length(p);
  p->startT=0;
  decoder.totalTStates=p->Tstates;
  decoder.numberOfBlocks=1;
  decoder.blocks=malloc(sizeof(void*));
  decoder.blocks[0]=p;
}

-(void)parseFile
{
  rvmCSWBlock2S *block=(rvmCSWBlock2S*)tap.bytes;
  
  
  if(block->major==2)
    [self parseV2:block];
  if(block->major==1)
    [self parseV1:(rvmCSWBlock1S*)block];
}

+(NSData *)compressRLE:(rvmPulse *)pulses count:(uint32)c sample:(uint32)s total:(uint32*)tot;
{
  NSMutableData *data=[NSMutableData new];
  uint8 zero=0,r=0;

  for(uint32 i=0;i<c;i++)
  {
    rvmPulse *p=&pulses[i];
    
    for(uint32 j=0;j<p->count;j++)
    {
      uint32 t=(p->length+r)/s;
      r=(p->length+r)-t*s;
      
      
      if(t)
      {
        (*tot)++;
        
        if(t<0x100)
        {
          [data appendBytes:&t length:1];
        }
        else
        {
          [data appendBytes:&zero length:1];
          [data appendBytes:&t length:4];
        }
      }
    }
  }
  
  return data;
}

-(void)extractBlocks:(rvmPulse *)pul count:(uint32)c
{
  [self addPulsesBlock:pul count:c];
}

-(void)saveFile
{
  NSMutableData *d=[NSMutableData new];
  uint32 tot=0;
  
  for(uint32 i=0;i<decoder.numberOfBlocks;i++)
  {
    rvmTapeBlockProtocolS *block=decoder.blocks[i];
    
    switch(block->type)
    {
      case kRvmPauseBlock:
      case kRvmPulsesBlock:
      {
        rvmPulsesBlockS *pb=(rvmPulsesBlockS*)block;
        NSData *rle=[rvmCSWDecoder compressRLE:pb->pulses count:pb->n sample:79 total:&tot];
        [d appendData:rle];
        //tot+=rle.length;
        break;
      }
        
      case kRvmPureDataBlock:
      {
        //Compress data.
        break;
      }
    }
  }
  
  NSMutableData *f=[NSMutableData new];
  
  rvmCSWBlock2S header;
  
  strncpy(header.sig, "Compressed Square Wave",22);
  header.terminator=0x1a;
  header.major=2;
  header.minor=0;
  header.sampleRate=ceil(3500000.0/79.0);
  header.total=tot;
  header.compression=0x2;
  header.flags=0;
  strncpy(header.tool,"RetroVM\0",8);
  
  [f appendBytes:&header length:sizeof(header)];
  [f appendData:[d deflate]];
  [f appendBytes:&header length:1]; //Dummy byte.
  
  [f writeToFile:self.path atomically:YES];
}
@end
