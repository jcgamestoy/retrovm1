//
//  rvmPZXDecoder.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 14/10/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmPZXDecoder.h"

#import "rvmPulsesBlock.h"
#import "rvmPureDataBlock.h"

@implementation rvmPZXDecoder

-(instancetype)init
{
  self=[super init];
  if(self)
  {
    self.image=[NSImage imageNamed:@"PZXCassette"];
  }
  return self;
}

-(void)parseFile
{
  self.image=[NSImage imageNamed:@"PZXCassette"];
  void *pt=(void*)tap.bytes;
  void *last=pt+tap.length;
  
  rvmPZXBlockS *block=pt;
  pt+=8+block->size;
  uint polarity;
  
  if(block->tag==kPZXHeader)
  {
    rvmPZXHeaderS *header=(rvmPZXHeaderS*)block->data;
    if(header->major>1 || (header->major==1 && header->minor>0)) return;
    
    NSMutableArray *blocks=[NSMutableArray array];
    
    while(pt<last) //For all blocks
    {
      block=pt;
      pt+=8+block->size;
      
      switch(block->tag)
      {
        case kPZXPulses:
        {
          uint32 n=block->size>>1;
          rvmPulse *pulses=calloc(sizeof(rvmPulse)*n,1);
          uint16 *ppt=(uint16*)block->data;
          uint32 i=0,j=0;
          
          while(i<n)
          {
            uint32 d=ppt[i++];
            uint32 c=1;
            
            if(d>0x8000)
            {
              c=d&0x7fff;
              d=ppt[i++];
            }
            
            if(d>=0x8000)
            {
              d=((d & 0x7fff)<<16) | ppt[i++];
            }
            
            pulses[j].count=c;
            pulses[j++].length=d;
          }
          
          rvmPulsesBlockS *pb=calloc(sizeof(rvmPulsesBlockS),1);
          rvmInitPulsesBlock(pb, j, pulses, 0,YES);
          
          pb->length(pb);
          pb->startT=decoder.totalTStates;
          decoder.totalTStates+=pb->Tstates;
          //s->block=(rvmTapeBlockProtocolS*)b;
          [blocks addObject:[NSValue valueWithPointer:pb]];
          polarity=j&0x1;
          
          break;
        }
          
        case kPZXData:
        {
          rvmPZXDataS *bdata=(rvmPZXDataS*)block->data;
          
          rvmDataBlockS *db=calloc(sizeof(rvmDataBlockS),1);
          rvmInitDataBlock(db, bdata->count, bdata->tail, bdata->p0, bdata->p1, (uint16*)bdata->data, (uint16*)(bdata->data+(bdata->p0<<1)), bdata->data+((bdata->p0+bdata->p1)<<1),0);
          db->length(db);
          db->startT=decoder.totalTStates;
          decoder.totalTStates+=db->Tstates;
          
          [blocks addObject:[NSValue valueWithPointer:db]];
          polarity=(bdata->count&0x1)^(bdata->count>>31);
          break;
        }
          
        case kPZXPause:
        {
          rvmPulsesBlockS *pb=calloc(sizeof(rvmPulsesBlockS), 1);
          
          uint32 l=*((uint32*)block->data);
          rvmInitPauseBlock(pb, l & 0x7fffffff, l>>31);
          
          pb->length(pb);
          pb->startT=decoder.totalTStates;
          decoder.totalTStates+=pb->Tstates;
          
          [blocks addObject:[NSValue valueWithPointer:pb]];
          polarity=(l&0x1)^1;
          break;
        }
          
        case kPZXStop:
        {
          rvmPulsesBlockS *pb=calloc(sizeof(rvmPulsesBlockS), 1);
          
          uint16 l=*((uint16*)block->data);
          rvmInitPauseBlock(pb, ~(l & 0x1), 0);
          
          pb->length(pb);
          pb->startT=decoder.totalTStates;
          decoder.totalTStates+=pb->Tstates;
          
          [blocks addObject:[NSValue valueWithPointer:pb]];
          break;
        }
          
        default:
        {
          break;
        }
      }
    }
    
    rvmPulsesBlockS *tail=calloc(sizeof(rvmPulsesBlockS), 1);
    rvmInitPauseBlock(tail, 3500000, polarity);
    tail->length(tail);
    tail->startT=decoder.totalTStates;
    decoder.totalTStates+=tail->Tstates;
    [blocks addObject:[NSValue valueWithPointer:tail]];
    
    decoder.blocks=malloc(sizeof(void*)*blocks.count);
    decoder.numberOfBlocks=(uint32)blocks.count;
    uint j=0;
    for(NSValue *v in blocks)
    {
      decoder.blocks[j++]=v.pointerValue;
    }
  }
}

-(NSData*)encodePulseBlock:(rvmPulsesBlockS*)block
{
  NSMutableData *md=[NSMutableData dataWithCapacity:block->n];
  
  for(uint i=0;i<block->n;i++)
  {
    uint32 c=block->pulses[i].count;
    uint32 l=block->pulses[i].length;
    
    do
    {
      uint32 ll=l & 0x7fffffff;
      l-=ll;
      
      do
      {
        uint16 cc=c & 0x7fff;
        c-=cc;
      
        if(c!=1)
        {
          cc|=0x8000;
          [md appendBytes:&cc length:2];
        }
        
        if(ll>0x7fff)
        {
          uint16 lll=((ll>>16) & 0x7fff) | 0x8000;
          [md appendBytes:&lll length:2];
        }
        
        uint16 lll=ll & 0x7fff;
        [md appendBytes:&lll length:2];
      }while(c);
      
      if(l)
      {
        uint16 lll=1;
        
        //[md appendBytes:&lll length:2];
        lll=0;
        [md appendBytes:&lll length:2];
      }
    }while(l);
  }
  
  return md;
}

-(void)saveFile
{
  NSMutableData *d=[NSMutableData dataWithCapacity:16384];
  
  rvmPZXBlockS header;
  header.size=2;
  header.tag=kPZXHeader;
  
  [d appendBytes:&header length:sizeof(header)];
  
  uint16 v=0x0001;
  [d appendBytes:&v length:2];
  
  for(uint i=0;i<decoder.numberOfBlocks;i++)
  {
    rvmPulsesBlockS *b=decoder.blocks[i];
    if(b->type==kRvmPulsesBlock)
    {
      header.tag=kPZXPulses;
      NSData *bd=[self encodePulseBlock:b];
      header.size=(uint32)bd.length;
      [d appendBytes:&header length:sizeof(header)];
      [d appendData:bd];
    }
    
    if(b->type==kRvmPureDataBlock)
    {
      rvmDataBlockS *db=(rvmDataBlockS*)b;
      
      header.tag=kPZXData;
      NSMutableData *md=[NSMutableData new];
      uint32 ll=db->bits | (db->level<<31);
      [md appendBytes:&ll length:4];
      [md appendBytes:&db->tail length:2];
      [md appendBytes:&db->p0 length:1];
      [md appendBytes:&db->p1 length:1];
      
      [md appendBytes:db->s0 length:db->p0<<1];
      [md appendBytes:db->s1 length:db->p1<<1];
      
      uint32 l=ceil(db->bits/(double)8.0);
      [md appendBytes:db->data length:l];
      
      header.size=(uint32)md.length;
      [d appendBytes:&header length:sizeof(header)];
      [d appendData:md];
    }
    
    if(b->type==kRvmPauseBlock)
    {
      uint32 l=0;
      for(uint i=0;i<b->n;i++)
      {
        l+=b->pulses[i].length*b->pulses[i].count;
      }
      
      l|=(b->level<<31);
      
      header.tag=kPZXPause;
      header.size=4;
      [d appendBytes:&header length:sizeof(header)];
      [d appendBytes:&l length:4];
    }
  }
  
  [d writeToFile:self.path atomically:YES];
}

-(NSMutableArray *)groupBlocks:(NSMutableArray *)r
{
  NSMutableArray *rr=[NSMutableArray new];
  
  for(uint32 i=0;i<r.count;i++)
  {
    NSDictionary *bd=r[i];
    
    uint32 ii=(uint32)[bd[@"index"] unsignedIntValue];
    
    rvmTapeBlockProtocolS *b=decoder.blocks[ii];
    
    if(b->type==kRvmPulsesBlock)
    {
      rvmPulsesBlockS *pb=(rvmPulsesBlockS*)b;
      
      if(pb->n==3 && pb->pulses[0].length==2168 && pb->pulses[1].length==667 && pb->pulses[2].length==735 && (ii+1)<decoder.numberOfBlocks && ((rvmTapeBlockProtocolS*)decoder.blocks[ii+1])->type==kRvmPureDataBlock)
      {
        rvmDataBlockS *db=(rvmDataBlockS*)decoder.blocks[ii+1];
        
        NSString *bName;
        
        if(db->bits==152)
        {
          bName=[self standardBlockName:db->data index:ii];
        }
        
        if(bName)
        {
          NSMutableArray *ch=[NSMutableArray arrayWithArray:@[r[i],r[i+1]]];
          
          uint j=ii+2;
          
          if(j<decoder.numberOfBlocks && ((rvmTapeBlockProtocolS*)decoder.blocks[j])->type==kRvmPauseBlock)
          {
            [ch addObject:r[j++]];
          }
          
          if((j+1)<decoder.numberOfBlocks && ((rvmTapeBlockProtocolS*)decoder.blocks[j])->type==kRvmPulsesBlock && ((rvmTapeBlockProtocolS*)decoder.blocks[j+1])->type==kRvmPureDataBlock)
          {
            [ch addObject:r[j++]];
            [ch addObject:r[j++]];
          }
          else
          {
            [rr addObject:r[i]];
            continue;
          }
          
          if(j<decoder.numberOfBlocks && ((rvmTapeBlockProtocolS*)decoder.blocks[j])->type==kRvmPauseBlock)
          {
            [ch addObject:r[j++]];
          }
          
          [rr addObject:@{@"name":bName,
                          @"count":[NSNumber numberWithLong:ch.count],
                          @"index":bd[@"index"],
                          @"childs":ch
                          }];
          i+=ch.count-1;
          continue;
        }
      }
    }
    
    [rr addObject:r[i]];
  }
  
  [rr addObject:@{@"name":@"End of tape",
                  @"count":@0,
                  @"index":[NSNumber numberWithUnsignedInt:decoder.numberOfBlocks]
                  }];
  
  return rr;
}

-(void)addPulsesBlock:(rvmPulse *)pulses count:(uint32)c
{
  rvmPulsesBlockS *pb=calloc(sizeof(rvmPulsesBlockS),1);
  
  uint32 pl=0;
  for(uint32 i=0;i<c;i++)
  {
    uint32 pll=pulses[i].length;
    if(!pll || pll>10000) pl+=pulses[i].length;
    else
    {
      pl=0;
      break;
    }
  }
  
  if(pl) //Pause
  {
    rvmInitPauseBlock(pb, pl, 0);
  }
  else
  {
    rvmPulse *s=calloc(sizeof(rvmPulse), c);
    memcpy(s,pulses,c*sizeof(rvmPulse));
    rvmInitPulsesBlock(pb, c, s, 0,YES);
  }
  
  pb->length(pb);
  pb->startT=decoder.totalTStates;
  decoder.totalTStates+=pb->Tstates;
  
  [self insertBlock:pb index:decoder.blockIndex++];
}

-(void)addStandardBlock:(NSData *)data pilotCount:(uint32)c bits:(uint32)bits
{
  rvmPulsesBlockS *pb=calloc(sizeof(rvmPulsesBlockS), 1);
  rvmPulse *p=calloc(sizeof(rvmPulse), 3);
  
  p[0].count=(c & 0x1) ? c : c+1; p[0].length=2168;
  p[1].count=p[2].count=1; p[1].length=667; p[2].length=735;
  
  rvmInitPulsesBlock(pb, 3, p, 0, YES);
  pb->length(pb);
  pb->startT=decoder.totalTStates;
  decoder.totalTStates+=pb->Tstates;
  [self insertBlock:pb index:decoder.blockIndex++];
  
  rvmDataBlockS *db=calloc(sizeof(rvmDataBlockS), 1);
  void* dp=calloc(1, data.length);
  
  memcpy(dp, data.bytes, data.length);
  rvmInitDataBlock(db, 0x80000000 | bits, 1000, 2, 2, s0, s1, dp, 0x2);
  db->length(db);
  db->startT=decoder.totalTStates;
  decoder.totalTStates+=db->Tstates;
  [self insertBlock:db index:decoder.blockIndex++];
}

@end
