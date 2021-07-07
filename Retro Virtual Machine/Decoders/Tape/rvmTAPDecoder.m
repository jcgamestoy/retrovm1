//
//  rvmTAPDecoder.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 19/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmTAPDecoder.h"

#define kBetween(v,r,p) (v<=(r*(1+p)) && v>=(r*(1-p)))
#define kStop 0xffffffff
#define kStop48 0xfffffffe

@interface rvmTAPDecoder()
{
  NSMutableArray *blocksToRelease;
  uint32 buffer[16384*1024]; //16MB Save Buffer. (Make dinamyc ¿?)
}

@end

@implementation rvmTAPDecoder

@synthesize cassetteView;
@synthesize writeProtected;
@synthesize path;
@synthesize image;

uint rvmTapDecoderStep(rvmTAPDecoderS *d,uint32 *level)
{
  if(!d->running) return NO;
  
  uint r=0;
  if(d->block.step) r=d->block.step(&d->block,level);
  
  if(!r || (r>=kStop48))
  {
    //rvmTapDecoderNextBlock(d);
    d->blockIndex++;
    if(d->blockIndex>=d->numberOfBlocks)
    {
      d->blockIndex=d->numberOfBlocks;
      d->running=NO;
    }
    else
    {
      d->block=*((rvmDataBlockS*)d->blocks[d->blockIndex]);
      d->currentT=d->block.startT;
      //d->blockName=d->block.name;
    }
    
    if(!r)
        return rvmTapDecoderStep(d,level);
    else
    {
      //d->running=NO;
      return r;
    }
  }
  else
  {
    //*level=!*level;
    d->currentT+=r;
  }
  
  //NSLog(@"R:%d - L:%d",r,*level);
  return r;
}

void rvmTapDecoderStepRec(rvmTAPDecoderS *d,uint32 level)
{
  if(level==d->recLevel)
  {
    d->recCount++;
  }
  else
  {
    d->recBuffer[d->recIndex++]=d->recCount;
    //NSLog(@"recB:%p",d->recBuffer);
    d->recLevel=level;
    d->recCount=1;
  }
}

-(id)init
{
  self=[super init];
  if(self)
  {
    image=[NSImage imageNamed:@"TAPCassette"];
    blocksToRelease=[NSMutableArray array];
    decoder.step=(rvmTapeDecoderStep)rvmTapDecoderStep;
    decoder.stepRec=(rvmTapeDecoderStepRec)rvmTapDecoderStepRec;
    decoder.recBuffer=buffer;
    decoder.numberOfBlocks=0;
    decoder.currentT=0;
    decoder.blockIndex=0;
    decoder.totalTStates=0;
    writeProtected=YES;
  }
  
  return self;
}

-(void)load:(NSString *)p
{
  NSFileManager *fm=[NSFileManager defaultManager];

  path=p;
  tap=[fm contentsAtPath:path];
  //decoder.step=(rvmTapeDecoderStep)rvmTapDecoderStep;
  //decoder.stepRec=(rvmTapeDecoderStepRec)rvmTapDecoderStepRec;
  //decoder.last=(uint8*)tap.bytes+tap.length;
  //decoder.recBuffer=buffer;
  [self parseFile];
  [self reset];
}

rvmPulse pilot[]={
  {8063,2168},
  {1,667},
  {1,735}
};

rvmPulse pilotShort[]={
  {3223,2168},
  {1,667},
  {1,735}
};

uint16 s0[]={855,855};
uint16 s1[]={1710,1710};

-(void)parseFile
{
  image=[NSImage imageNamed:@"TAPCassette"];
  
  void *pt=(void*)tap.bytes;
  void *last=pt+tap.length;
  NSMutableArray *blocks=[NSMutableArray array];
  
  decoder.totalTStates=0;
  while(YES)
  {
    if(pt>=last) break;
    
    uint16 l=*((uint16*)pt);
    
    char name[0x100];
    sprintf(name, "Tap block length: %d bytes",l);
    
    rvmInfoBlockS *ib=rvmNewInfoBlock(name, 3, pt, 2+l);
    [blocks addObject:[NSValue valueWithPointer:ib]];
    ib->startT=decoder.totalTStates;
    
    rvmPulsesBlockS *pb=calloc(sizeof(rvmPulsesBlockS), 1);
    rvmPulse *pi=(*((uint8*)pt+2)>=0x80)?pilotShort:pilot;
    rvmInitPulsesBlock(pb, 3, pi, 0,NO);
    pb->length(pb);
    pb->startT=decoder.totalTStates;
    decoder.totalTStates+=pb->Tstates;
    [blocks addObject:[NSValue valueWithPointer:pb]];
    rvmDataBlockS *db=calloc(sizeof(rvmDataBlockS), 1);
    rvmInitDataBlock(db, (l<<3)+0x80000000, 1000, 2, 2, s0, s1, pt+2,0);
    db->length(db);
    db->startT=decoder.totalTStates;
    decoder.totalTStates+=db->Tstates;
    [blocks addObject:[NSValue valueWithPointer:db]];
    rvmPulsesBlockS *pab=calloc(sizeof(rvmPulsesBlockS), 1);
    rvmInitPauseBlock(pab, 2000*3500, 0);
    pab->length(pab);
    pab->startT=decoder.totalTStates;
    decoder.totalTStates+=pab->Tstates;
    [blocks addObject:[NSValue valueWithPointer:pab]];
    pt+=2+l;
  }
  
  decoder.blocks=malloc(sizeof(void*)*blocks.count);
  decoder.numberOfBlocks=(uint32)blocks.count;
  uint j=0;
  for(NSValue *v in blocks)
  {
    decoder.blocks[j++]=v.pointerValue;
  }
}

-(void)saveFile
{
  NSMutableData *data=[NSMutableData new];
  
  for(uint32 i=0;i<decoder.numberOfBlocks;i++)
  {
    rvmInfoBlockS *ib=decoder.blocks[i];
    
    if(ib && ib->type==kRvmInfoBlock)
    {
      [data appendBytes:ib->data length:ib->lengthB];
    }
  }
  
  [data writeToFile:path atomically:YES];
//  NSMutableData *d=[NSMutableData dataWithCapacity:16384];
//  
//  for(uint i=0;i<decoder.numberOfBlocks;i++)
//  {
//    rvmStandarBlockS *s=decoder.blocks[i];
//    uint16 l=(uint16)(s->last-s->data);
//    [d appendBytes:&l length:2];
//    [d appendBytes:s->data length:l];
//  }
//  
//  [d writeToFile:path atomically:YES];
}

-(void)reset
{
  decoder.running=NO;
  decoder.blockIndex=0;
  decoder.currentT=0;
  if(decoder.blocks && decoder.blocks[0]) decoder.block=*((rvmDataBlockS*)decoder.blocks[0]);
  //decoder.blockName=decoder.block.name;
}

-(void)go:(uint)index
{
  if(index>decoder.numberOfBlocks) return;
  
  if(index==decoder.numberOfBlocks)
  {
    decoder.blockIndex=index;
    decoder.currentT=decoder.totalTStates;
  }
  else
  {
    decoder.blockIndex=index;
    decoder.block=*((rvmDataBlockS*)decoder.blocks[index]);
    decoder.currentT=decoder.block.startT;
    
    //return [NSString stringWithFormat:@"%s",decoder.block.name];
  }
}

-(rvmTapeDecoderProtocolS*)decoder
{
  return (rvmTapeDecoderProtocolS*)&decoder;
}

-(double)progress
{
  return decoder.currentT / (double)decoder.totalTStates;
}

-(double)length
{
  return decoder.totalTStates;
}

-(void)startRec
{
  //decoder.recBuffer=calloc(1, sizeof(uint32)*kRvmTapeDecoderBufferLength);
  decoder.recCount=decoder.recIndex=decoder.recLevel=0;
  //decoder.recLevel=1;
  decoder.recording=true;
}

-(void)endRec
{
  decoder.recBuffer[decoder.recIndex++]=decoder.recCount;
  [self parseRec];
  [self saveFile];
  //free(decoder.recBuffer);
  decoder.recording=false;
}

-(void)insertBlock:(void*)block index:(uint)i
{
  void **newList;
  
  newList=calloc(1, sizeof(void*)*(decoder.numberOfBlocks+1));
  if(i) memcpy(newList,decoder.blocks, sizeof(void*)*i);
  
  newList[i]=block;
  
  uint r=decoder.numberOfBlocks-i;
  if(r) memcpy(newList+i+1,decoder.blocks+i,  sizeof(void*)*r);

  free(decoder.blocks);
  decoder.numberOfBlocks++;
  decoder.blocks=newList;
}

#define dFactor 0.05
#define daFactor 0.05

-(void)parseRec
{
  //Add pulses block
  
  rvmPulse *pulses=calloc(sizeof(rvmPulse), decoder.recIndex);
  
  uint j=0;
  double a=0;
  
  for(int l=0;l<decoder.recIndex;l++)
  {
    if(a && kBetween(decoder.recBuffer[l], a, dFactor))
    {
      pulses[j-1].count++;
      a+=(decoder.recBuffer[l]-a)/((double)pulses[j-1].count);
    }
    else
    {
      //if(j) NSLog(@"j:%d c:%d l:%d",j-1,pulses[j-1].count,pulses[j-1].length);
      pulses[j].count=1; pulses[j].length=decoder.recBuffer[l];
      a=pulses[j].length;
      j++;
    }
  }
  
  [self extractBlocks:pulses count:j];
//  rvmPulsesBlockS *pb=calloc(sizeof(rvmPulsesBlockS), 1);
//  rvmInitPulsesBlock(pb, decoder.recIndex, pulses, 0, YES);
//  pb->length(pb);
//  [self insertBlock:pb index:decoder.blockIndex++];
  free(pulses);
  [self updateMetrics];
}

-(void)extractBlocks:(rvmPulse*)pulses count:(uint32)c
{
  uint32 i,j;
  
  for(i=0,j=0;i<c;i++)
  {
    if(kBetween(pulses[i].length, 2168, dFactor) && kBetween(pulses[i+1].length, 667, dFactor) && kBetween(pulses[i+2].length, 735, dFactor))
    {
      uint32 k=i+3; //Mirar los 0;
      //while(kBetween(pulses[k].length, 1710, daFactor) || kBetween(pulses[k].length, 855, daFactor)) k++;
      
      
      
      //if(!(pulses[k].length>5000)) continue;
      
      //NSLog(@"Break k:%d length:%d",k,pulses[k].length);
      
      uint32 bits;
      NSData *d=[self compactBlock:pulses index:&k max:c bits:&bits];

      if(!d) continue;
      
      if(j<i)
      {
        [self addPulsesBlock:&pulses[j] count:i-j];
      }
      
      [self addStandardBlock:d pilotCount:pulses[i].count bits:bits];
      
      i=j=k-1;
    }
  }
  
  if(j<i)
  {
    [self addPulsesBlock:&pulses[j] count:i-j];
  }
}

-(NSData*)compactBlock:(rvmPulse*)pulses index:(uint32*)c  max:(uint32)m bits:(uint32*)bits
{
  NSMutableData *md=[NSMutableData new];
  
  int sh=7;
  uint8 data=0;
  uint8 pa=0;
  *bits=0;
  uint32 ac=0;
  while(1)
  {
    if(*c>=m) return nil;
    
    rvmPulse *p=&pulses[(*c)++];
    
    for(uint i=0;i<p->count;i++)
    {
      if(!ac)
      {
        ac=p->length;
      }
      else
      {
        ac+=p->length;
        
        if(ac>4800)
        {
          if(!pa) //parity ok
          {
            return md;
          }
          else
            return nil;
          //end
        }
        else if(ac>2400)
        {
          //1
          data|=1<<sh;
        }
        
        ac=0;
        sh--;
        (*bits)++;
        
        if(sh<0)
        {
          sh=7;
          [md appendBytes:&data length:1];
          pa=pa^data;
          data=0;
        }
      }
    }
  }
}


-(void)addPulsesBlock:(rvmPulse*)pulses count:(uint32)c
{
  //Res aqui
}

-(void)addStandardBlock:(NSData*) data pilotCount:(uint32)c bits:(uint32)bits
{
  uint8* md=(uint8*)calloc(sizeof(uint8), data.length+2);
  uint16* ld=(uint16*)md;
  *ld=(uint16)data.length;
  memcpy(md+2, data.bytes, data.length);
  char name[0x100];
  sprintf(name, "Tap block length: %d bytes",(uint32)data.length);
  
  rvmInfoBlockS *ib=rvmNewInfoBlockF(name, 3, (void*)md, (uint32)data.length+2);
  [self insertBlock:ib index:decoder.blockIndex++];
  ib->startT=decoder.totalTStates;
  
  rvmPulsesBlockS *pb=calloc(sizeof(rvmPulsesBlockS), 1);
  rvmPulse *pi=(*((uint8*)data.bytes)>=0x80)?pilotShort:pilot;
  rvmInitPulsesBlock(pb, 3, pi, 0,NO);
  pb->length(pb);
  pb->startT=decoder.totalTStates;
  decoder.totalTStates+=pb->Tstates;
  [self insertBlock:pb index:decoder.blockIndex++];

  rvmDataBlockS *db=calloc(sizeof(rvmDataBlockS), 1);
  uint8 *bdata=calloc(sizeof(uint8), data.length);
  memcpy(bdata, data.bytes, data.length);
  rvmInitDataBlock(db, (uint32)((data.length<<3)+0x80000000), 1000, 2, 2, s0, s1, bdata,0x2);
  db->length(db);
  db->startT=decoder.totalTStates;
  decoder.totalTStates+=db->Tstates;
  [self insertBlock:db index:decoder.blockIndex++];
  //[blocks addObject:[NSValue valueWithPointer:db]];
  rvmPulsesBlockS *pab=calloc(sizeof(rvmPulsesBlockS), 1);
  rvmInitPauseBlock(pab, 2000*3500, 0);
  pab->length(pab);
  pab->startT=decoder.totalTStates;
  decoder.totalTStates+=pab->Tstates;
  [self insertBlock:pab index:decoder.blockIndex++];
}



-(void)updateMetrics
{
  uint64 ss=0;
  for(int i=0;i<decoder.numberOfBlocks;i++)
  {
    rvmDataBlockS *s=decoder.blocks[i];
    if(s)
    {
      s->startT=ss;
      ss+=s->Tstates;
    }
  }
  
  decoder.totalTStates=ss;
}

-(NSString*)standardBlockName:(uint8*)pt index:(uint32)ii
{
  uint8 flag=pt[1];
  uint16 ma=*((uint16*)(pt+14));
  char name[11];
  name[10]=0;
  strncpy(name,(const char*)(pt+2), 10);
  
  switch(flag)
  {
    case 0:
    {
      if(ma & 0x8000)
      {
        return [NSString stringWithFormat:@"%.2d: Program '%s'",ii,name];
      }
      else
      {
        return [NSString stringWithFormat:@"%.2d: Program '%s' line %d",ii,name,ma];
      }
    }
      
    case 1:
      return [NSString stringWithFormat:@"%.2d: Number array '%s'",ii,name];
      
    case 2:
      return [NSString stringWithFormat:@"%.2d: Char array '%s'",ii,name];
      
    case 3:
    {
      return [NSString stringWithFormat:@"%.2d: Bytes '%s' %d,%d",ii,name,ma,*((uint16*)(pt+12))];
    }
      
    default:
    {
      return nil;
    }
  }
}

-(NSMutableArray *)groupBlocks:(NSMutableArray *)r
{
  NSMutableArray *rr=[NSMutableArray new];
  
  for(uint32 i=0;i<r.count;i++)
  {
    NSDictionary *bd=r[i];
    uint32 ii=(uint32)[bd[@"index"] unsignedIntegerValue];
    
    rvmInfoBlockS *ib=decoder.blocks[ii];
    
    if(ib->lengthB==21)
    {
      NSString *bName=[self standardBlockName:(ib->data+2) index:ii];
      
      if(bName)
      {
        [rr addObject:@{@"name":bName,
                        @"count":@2,
                        @"index":bd[@"index"],
                        @"childs":@[
                            r[i],
                            r[i+1]
                            ]
                        }];
        i++;
      }
      else
        [rr addObject:r[i]];
    }
    else
      [rr addObject:r[i]];
  }
  
  [rr addObject:@{@"name":@"End of tape",
                  @"count":@0,
                  @"index":[NSNumber numberWithUnsignedInt:decoder.numberOfBlocks]
                  }];
  return rr;
}

-(NSArray *)tapeBlocksDescription
{
  NSMutableArray *r=[NSMutableArray new];
  
  //Pass 1
  for(uint32 i=0;i<decoder.numberOfBlocks;i++)
  {
    rvmTapeBlockProtocolS *b=decoder.blocks[i];
    
    NSMutableDictionary *bd=[NSMutableDictionary new];
    bd[@"name"]=[NSString stringWithFormat:@"%.2d: %s",i,b->name];
    bd[@"index"]=[NSNumber numberWithUnsignedInt:i];
    
    if(b->type!=kRvmInfoBlock)
      bd[@"count"]=@0;
    else
    {
      rvmInfoBlockS *ib=(rvmInfoBlockS*)b;
      NSMutableArray *aa=[NSMutableArray new];
      
      for(uint j=1;j<=ib->skipBlocks;j++)
      {
        rvmTapeBlockProtocolS *bb=decoder.blocks[i+j];
        [aa addObject:@{@"name":[NSString stringWithFormat:@"%.2d: %s",i+j,bb->name],
                        @"index":[NSNumber numberWithUnsignedInt:i+j],
                        @"count":@0}];
      }
      
      i+=ib->skipBlocks;
      bd[@"childs"]=aa;
      bd[@"count"]=[NSNumber numberWithUnsignedInt:ib->skipBlocks];
    }
    
    [r addObject:bd];
  }
  
  return [self groupBlocks:r];
}

-(void)dealloc
{
  for(uint i=0;i<decoder.numberOfBlocks;i++)
  {
    bool finded=false;
    
    for(uint j=0;j<i;j++)
    {
      if(decoder.blocks[i]==decoder.blocks[j])
      {
        finded=true;
        break;
      }
    }
    
    if(!finded)
    {
      ((rvmTapeBlockProtocolS*)decoder.blocks[i])->free(decoder.blocks[i]);
      free(decoder.blocks[i]);
    }
  }
  
  free(decoder.blocks);
}

-(void)removeFromBlock:(uint)min to:(uint)max
{
  uint c=max-min+1;
  void **ant=decoder.blocks;
  
  decoder.blocks=malloc(sizeof(void*)*decoder.numberOfBlocks-c);
  
  uint j=0;
  for(int i=0;i<decoder.numberOfBlocks;i++)
  {
    if(i<min || i>max) decoder.blocks[j++]=ant[i];
    else free(ant[i]);
  }
  
  decoder.numberOfBlocks-=c;
  
  free(ant);
}


@end