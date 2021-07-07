//
//  rvmTZXDecoder.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 31/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmTZXDecoder.h"
#import "NSData+Gzip.h"
#import "rvmCSWDecoder.h"

@interface rvmTZXDecoder()
{
  bool addPause;
}

@end


@implementation rvmTZXDecoder

//static rvmPulse tailp[]={{1,1000},{1,10000}};

-(instancetype)init
{
  self=[super init];
  if(self)
  {
    self.image=[NSImage imageNamed:@"TZXCassette"];
    self->addPause=NO;
  }
  
  return self;
}

-(NSArray*)blockDivide:(void*)pt last:(void*)last
{
  NSMutableArray *b=[NSMutableArray new];
  
  while(pt<last)
  {
    void *bpt=pt;
    uint8 bid=*((uint8*)pt++);
    NSMutableDictionary *bd=[NSMutableDictionary dictionaryWithDictionary:@{@"id":[NSNumber numberWithChar:bid],@"pt":[NSValue valueWithPointer:pt]}];

                   
    switch(bid)
    {
      case 0x10: //Standard
      {
        rvmTZX10Block *b10=(rvmTZX10Block*)pt;
        pt+=4+b10->length;
        break;
      }
      case 0x11: //Turbo
      {
        rvmTZX11Block *b11=(rvmTZX11Block*)pt;
        uint32 l=b11->length[0]|(b11->length[1]<<8)|(b11->length[2]<<16);
        pt+=sizeof(rvmTZX11Block)+l;
        break;
      }
      case 0x12:
      {
        pt+=sizeof(rvmTZX12Block);
        break;
      }
      case 0x13:
      {
        uint8 n=*((uint8*)pt++);
        pt+=n<<1;
        break;
      }
      case 0x14:
      {
        rvmTZX14Block *b14=(rvmTZX14Block*)pt;
        uint32 l=b14->length[0]|(b14->length[1]<<8)|(b14->length[2]<<16);
        pt=b14->data+l;
        break;
      }
      case 0x15:
      {
        rvmTZX15Block *b15=(rvmTZX15Block*)pt;
        uint32 l=b15->length[0]+(b15->length[1]<<8)+(b15->length[2]<<16);
        pt+=sizeof(rvmTZX15Block)+l;
        break;
      }
      
      case 0x2a:
      {
        pt+=4;
        break;
      }
        
      case 0x18:
      {
        uint32 l=*((uint32*)pt);
        pt+=4+l;
        break;
      }
        
      case 0x19:
      {
        rvmTZX19Block *b19=(rvmTZX19Block*)pt;
        pt+=b19->length+4;
        break;
      }
      
      case 0x20:
      case 0x23:
      case 0x24:
      
      {
        pt+=2;
        break;
      }
      case 0x21:
      case 0x30:
      {
        uint32 n=*((uint8*)pt++);
        pt+=n;
        break;
      }
      case 0x22:
      case 0x25:
      case 0x27:
      {
        break;
      }
      
      case 0x26:
      {
        uint16 n=*((uint16*)pt);
        pt+=(n+1)<<1;
        break;
      }
        
      case 0x2b:
      {
        pt+=5;
        break;
      }
        
      case 0x31:
      {
        pt++;
        uint8 n=*((uint8*)pt++);
        pt+=n;
        break;
      }
        
      case 0x32:
      case 0x28:
      {
        uint16 l=*((uint16*)pt);
        pt+=2+l;
        break;
      }
        
      case 0x33:
      {
        uint8 n=*((uint8*)pt++);
        pt+=n*3;
        break;
      }
        
      case 0x35:
      {
        pt+=0x10;
        uint32 l=*((uint32*)pt);
        pt+=4+l;
        break;
      }
        
      case 0x5a:
      {
        pt+=9;
        break;
      }
       
      default:
      {
        NSLog(@"Unknow block %x!!!",bid);
        return nil;
      }
    }
    
    bd[@"length"]=[NSNumber numberWithInt:((uint32)(pt-bpt))];
    [b addObject:bd];
  }
  
  return b;
}

-(void)addBlockInfo:(rvmInfoBlockS*)ib block:(rvmTapeBlockProtocolS*)b
{
  if(!ib->skipBlocks)
  {
    ib->startT=b->startT;
  }
  
  ib->skipBlocks++;
}

-(void)parseFile
{
  self.image=[NSImage imageNamed:@"TZXCassette"];
  
  void *pt=(void*)tap.bytes;
  void *last=pt+tap.length;
  
  rvmTZXHeader *header=pt;
  
  if(header->sig[0]!='Z') return;
  if(header->sig[1]!='X') return;
  if(header->sig[2]!='T') return;
  if(header->sig[3]!='a') return;
  if(header->sig[4]!='p') return;
  if(header->sig[5]!='e') return;
  if(header->sig[6]!='!') return;
  if(header->sig[7]!=0x1a) return;

  pt+=sizeof(rvmTZXHeader);

  NSArray *tzxBlocks=[self blockDivide:pt last:last];
  NSMutableArray *blocks=[NSMutableArray array];
  
  //int loopIndex=-1,loopCount=0;
  
  uint polarity=0;
  decoder.totalTStates=0;
  
  
  rvmPulsesBlockS *headerP=calloc(sizeof(rvmPulsesBlockS), 1);
  
  rvmInitPauseBlock(headerP, 3500000, polarity);
  headerP->length(headerP);
  headerP->startT=decoder.totalTStates;
  decoder.totalTStates+=headerP->Tstates;
  [blocks addObject:[NSValue valueWithPointer:headerP]];
  
  uint iBlock=0;
  uint loopCounter=0,loopI=0;
  uint calls=0,returnB=0;
  int16_t *callsI=NULL;
  
  while(iBlock<tzxBlocks.count)
  {
    //uint bid=*((uint8*)pt++);
    NSDictionary *tzxb=tzxBlocks[iBlock];
    NSUInteger bid=[tzxb[@"id"] unsignedIntegerValue];
    NSLog(@"Block: %lx",(unsigned long)bid);
    pt=[tzxb[@"pt"] pointerValue];
    uint32 blen=(uint32)[tzxb[@"length"] unsignedIntegerValue];
    
    switch(bid)
    {
      case 0x10:
      {
        rvmTZX10Block *b10=(rvmTZX10Block*)pt;
        
        rvmPulsesBlockS *pb=calloc(sizeof(rvmPulsesBlockS), 1);
        rvmPulse *pi=(*b10->data>=0x80)?pilotShort:pilot;
        
        char name[0x100];
        sprintf(name, "Standard block tzx:0x10 length:%d",b10->length);
        rvmInfoBlockS *ib=rvmNewInfoBlock(name,0,b10-1,blen);
        ib->tag=1;
        [blocks addObject:[NSValue valueWithPointer:ib]];
        
        rvmInitPulsesBlock(pb, 3, pi, 0,NO);
        pb->length(pb);
        pb->startT=decoder.totalTStates;
        decoder.totalTStates+=pb->Tstates;
        [blocks addObject:[NSValue valueWithPointer:pb]];
        [self addBlockInfo:ib block:(rvmTapeBlockProtocolS*)pb];
        rvmDataBlockS *db=calloc(sizeof(rvmDataBlockS), 1);
        rvmInitDataBlock(db, (b10->length<<3)+0x80000000, 1000, 2, 2, s0, s1, b10->data,0);
        db->length(db);
        db->startT=decoder.totalTStates;
        decoder.totalTStates+=db->Tstates;
        [blocks addObject:[NSValue valueWithPointer:db]];
        [self addBlockInfo:ib block:(rvmTapeBlockProtocolS*)db];
        rvmPulsesBlockS *pab=calloc(sizeof(rvmPulsesBlockS), 1);
        rvmInitPauseBlock(pab, b10->pause*3500, 0);
        pab->length(pab);
        pab->startT=decoder.totalTStates;
        decoder.totalTStates+=pab->Tstates;
        [blocks addObject:[NSValue valueWithPointer:pab]];
        [self addBlockInfo:ib block:(rvmTapeBlockProtocolS*)pab];
        polarity=0;
        break;
      }
      case 0x11:
      {
        rvmTZX11Block *b11=(rvmTZX11Block*)pt;
        uint32 l=b11->length[0]|(b11->length[1]<<8)|(b11->length[2]<<16);
        
        char name[0x100];
        sprintf(name, "Turbo block tzx:0x11 length:%d",l);
        rvmInfoBlockS *ib=rvmNewInfoBlock(name,0,b11-1,blen);
        [blocks addObject:[NSValue valueWithPointer:ib]];
        
        //Pilot
        rvmPulsesBlockS *pb=calloc(sizeof(rvmPulsesBlockS), 1);
        rvmPulse *pi=calloc(sizeof(rvmPulse), 3);
        pi[0].count=b11->pilotC; pi[0].length=b11->pilotL;
        pi[1].count=pi[2].count=1;
        pi[1].length=b11->sync1; pi[2].length=b11->sync2;
        rvmInitPulsesBlock(pb, 3, pi, polarity,YES);
        pb->length(pb);
        pb->startT=decoder.totalTStates;
        decoder.totalTStates+=pb->Tstates;
        [blocks addObject:[NSValue valueWithPointer:pb]];
        [self addBlockInfo:ib block:(rvmTapeBlockProtocolS*)pb];
        
        uint p=(b11->pilotC+polarity) &0x1;
        
        //Data
        uint16 *l0=calloc(sizeof(uint16), 2);
        l0[0]=b11->l0; l0[1]=b11->l0;

        uint16 *l1=calloc(sizeof(uint16), 2);
        l1[0]=b11->l1; l1[1]=b11->l1;
        
        rvmDataBlockS *db=calloc(sizeof(rvmDataBlockS), 1);
        
        uint32 bits=((l-1)<<3)+b11->usedBits;
        rvmInitDataBlock(db, bits+((p)?0x80000000:0), 0, 2, 2, l0, l1, b11->data,0x1);
        db->length(db);
        db->startT=decoder.totalTStates;
        decoder.totalTStates+=db->Tstates;
        [blocks addObject:[NSValue valueWithPointer:db]];
        [self addBlockInfo:ib block:(rvmTapeBlockProtocolS*)db];
        
        polarity=(bits+p)&0x1;
        
        //Pause
        if(b11->pause)
        {
          rvmPulsesBlockS *pab=calloc(sizeof(rvmPulsesBlockS), 1);
          rvmInitPauseBlock(pab, b11->pause*3500, polarity);
          pab->length(pab);
          pab->startT=decoder.totalTStates;
          decoder.totalTStates+=pab->Tstates;
          [blocks addObject:[NSValue valueWithPointer:pab]];
          [self addBlockInfo:ib block:(rvmTapeBlockProtocolS*)pab];
          polarity=polarity?0:1;
        }
        break;
      }
      case 0x12:
      {
        //rvmPureToneBlockS *b=(rvmPureToneBlockS*)malloc(sizeof(rvmPureToneBlockS));
        rvmTZX12Block *b12=(rvmTZX12Block*)pt;
//        rvmInitPureToneBlock(b, b12->n, b12->length);
//
//        b->length(b);
//        b->startT=decoder.totalTStates;
//        decoder.totalTStates+=b->Tstates;
//        
//        [blocks addObject:[NSValue valueWithPointer:b]];
        char name[0x100];
        sprintf(name, "Pure tone block tzx:0x12");
        rvmInfoBlockS *ib=rvmNewInfoBlock(name,0,b12-1,blen);
        [blocks addObject:[NSValue valueWithPointer:ib]];
        
        rvmPulsesBlockS *pb=calloc(sizeof(rvmPulsesBlockS), 1);
        rvmPulse *pi=calloc(sizeof(rvmPulse), 1);
        pi[0].count=b12->n; pi[0].length=b12->length;
        rvmInitPulsesBlock(pb, 1, pi, polarity,YES);
        pb->length(pb);
        pb->startT=decoder.totalTStates;
        decoder.totalTStates+=pb->Tstates;
        [blocks addObject:[NSValue valueWithPointer:pb]];
        [self addBlockInfo:ib block:(rvmTapeBlockProtocolS*)pb];
        polarity=(b12->n+polarity) & 0x1;
        
        pt=pt+sizeof(rvmTZX12Block);
        break;
      }
      case 0x13:
      {
        char name[0x100];
        sprintf(name, "Pulse sequence block tzx:0x13");
        rvmInfoBlockS *ib=rvmNewInfoBlock(name,0,pt-1,blen);
        [blocks addObject:[NSValue valueWithPointer:ib]];
        
        rvmPulsesBlockS *pb=calloc(sizeof(rvmPulsesBlockS), 1);
        uint32 n=*((uint8*)pt++);
        rvmPulse *pi=calloc(sizeof(rvmPulse), n);
        for(int i=0;i<n;i++)
        {
          pi[i].count=1;
          pi[i].length=*((uint16*)pt);
          pt+=2;
        }
        
        
        
        //NSLog(@"Polarity before pulses: %d",polarity);
        rvmInitPulsesBlock(pb, n, pi, polarity,YES);
        pb->length(pb);
        pb->startT=decoder.totalTStates;
        decoder.totalTStates+=pb->Tstates;
        [blocks addObject:[NSValue valueWithPointer:pb]];
        [self addBlockInfo:ib block:(rvmTapeBlockProtocolS*)pb];
        polarity=(n+polarity) & 0x1;
        //NSLog(@"Polarity after %d pulses: %d",n,polarity);
        //pt+=b->n<<1;
        break;
      }
      case 0x14:
      {
        rvmTZX14Block *b14=(rvmTZX14Block*)pt;
        
        //Data
        uint16 *l0=calloc(sizeof(uint16), 2);
        l0[0]=b14->l0; l0[1]=b14->l0;
        
        uint16 *l1=calloc(sizeof(uint16), 2);
        l1[0]=b14->l1; l1[1]=b14->l1;
        
        rvmDataBlockS *db=calloc(sizeof(rvmDataBlockS), 1);
        uint32 l=b14->length[0]|(b14->length[1]<<8)|(b14->length[2]<<16);
        
        char name[0x100];
        sprintf(name, "Pure data block tzx:0x14 length:%d",l);
        rvmInfoBlockS *ib=rvmNewInfoBlock(name,0,b14-1,blen);
        [blocks addObject:[NSValue valueWithPointer:ib]];
        
        uint32 bits=((l-1)<<3)+b14->ub;
        rvmInitDataBlock(db, bits+((polarity)?0x80000000:0), (b14->pause)?1000:0, 2, 2, l0, l1, b14->data,0x1);
        NSLog(@"Data level:%d",db->level);
        db->length(db);
        db->startT=decoder.totalTStates;
        decoder.totalTStates+=db->Tstates;
        [blocks addObject:[NSValue valueWithPointer:db]];
        [self addBlockInfo:ib block:(rvmTapeBlockProtocolS*)db];
        
        //Pause
        NSLog(@"Data pause:%d",b14->pause);
        if(b14->pause)
        {
          rvmPulsesBlockS *pab=calloc(sizeof(rvmPulsesBlockS), 1);
          rvmInitPauseBlock(pab, b14->pause*3500, 0);
          pab->length(pab);
          pab->startT=decoder.totalTStates;
          decoder.totalTStates+=pab->Tstates;
          [blocks addObject:[NSValue valueWithPointer:pab]];
          [self addBlockInfo:ib block:(rvmTapeBlockProtocolS*)pab];
          polarity=0;
        }
        
        pt=b14->data+l;
        break;
      }
        
      case 0x15: //Direct recording.
      {
        char name[0x100];
        sprintf(name, "Direct recording block tzx:0x15");
        rvmInfoBlockS *ib=rvmNewInfoBlock(name,0,pt-1,blen);
        [blocks addObject:[NSValue valueWithPointer:ib]];
        
        rvmTZX15Block *b15=(rvmTZX15Block*)pt;
        uint32 length=b15->length[0]+(b15->length[1]<<8)+(b15->length[2]<<16);
        
        NSMutableData *data=[NSMutableData dataWithLength:length<<6];
        uint32 j=1,k=0;
        int shifter=6;
        
        uint32 bits=((length-1)<<3)+b15->used;
        uint8 byte=b15->data[0];

        uint8 state=b15->data[0]>>7;
        uint32 first=state;
        uint32 acum=b15->T;
        
        rvmPulse *pul=data.mutableBytes;
        rvmPulsesBlockS *p=calloc(sizeof(rvmPulsesBlockS), 1);
        
        for(int i=1;i<bits;i++)
        {
          if(shifter<0) //Next byte
          {
            byte=b15->data[j++];
            shifter=7;
          }
          
          if((byte>>(shifter--))&0x1) //1
          {
            if(state)
            {
              acum+=b15->T;
            }
            else
            {
              //NSLog(@"1: %d",acum);
              pul[k].count=1;
              pul[k++].length=acum;
              acum=b15->T;
              state=1;
            }
          }
          else //0
          {
            if(!state)
            {
              acum+=b15->T;
            }
            else
            {
              //NSLog(@"0: %d",acum);
              pul[k].count=1;
              pul[k++].length=acum;
              acum=b15->T;
              state=0;
            }
          }
        }
        
        pul[k].count=1;
        pul[k++].length=acum;
        
        rvmPulse *pulses=malloc(sizeof(rvmPulse)*k);
        memcpy(pulses, data.mutableBytes, sizeof(rvmPulse)*k);
        rvmInitPulsesBlock(p, k, pulses, first, YES);
        
        p->length(p);
        p->startT=decoder.totalTStates;
        decoder.totalTStates+=p->Tstates;
        [blocks addObject:[NSValue valueWithPointer:p]];
        [self addBlockInfo:ib block:(rvmTapeBlockProtocolS*)p];
        polarity=!state;
        
        if(b15->pause)
        {
          rvmPulsesBlockS *pab=calloc(sizeof(rvmPulsesBlockS), 1);
          rvmInitPauseBlock(pab, b15->pause*3500, 0);
          pab->length(pab);
          pab->startT=decoder.totalTStates;
          decoder.totalTStates+=pab->Tstates;
          [blocks addObject:[NSValue valueWithPointer:pab]];
          [self addBlockInfo:ib block:(rvmTapeBlockProtocolS*)pab];
          polarity=0;
        }
        
        break;
      }
        
      case 0x18: //CSW
      {
        char name[0x100];
        sprintf(name, "Csw block tzx:0x18");
        rvmInfoBlockS *ib=rvmNewInfoBlock(name,0,pt-1,blen);
        [blocks addObject:[NSValue valueWithPointer:ib]];
        
        rvmTZX18Block *b18=pt;
        rvmPulsesBlockS *p=calloc(sizeof(rvmPulsesBlockS), 1);
        NSMutableArray *pu=[NSMutableArray array];
        
        //uint32 i=0;
        int pulsesC=b18->pulses;
        uint32 sr=b18->sampling[0]+b18->sampling[1]*0x100+b18->sampling[2]*0x10000;
        uint32 f=ceil(3500000.0/(double)sr);
        
        void *pt=b18->data;
        NSData *d;
        if(b18->compression==0x2)
        {
          uint32 l=b18->length-10;
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
        
        rvmInitPulsesBlock(p, (uint32)pu.count, pul, polarity, YES);
        p->length(p);
        p->startT=decoder.totalTStates;
        decoder.totalTStates=p->Tstates;
        decoder.numberOfBlocks++;
        
        polarity=polarity^(b18->pulses & 0x1);
        [blocks addObject:[NSValue valueWithPointer:p]];
        [self addBlockInfo:ib block:(rvmTapeBlockProtocolS*)p];
        break;
      }
        
      case 0x19: //GDB
      {
        char name[0x100];
        sprintf(name, "Gdb block tzx:0x19");
        rvmInfoBlockS *ib=rvmNewInfoBlock(name,0,pt-1,blen);
        [blocks addObject:[NSValue valueWithPointer:ib]];
    
        rvmTZX19Block *b19=(rvmTZX19Block*)pt;
        
        //Pilot
        rvmPulsesBlockS *pb=calloc(sizeof(rvmPulsesBlockS), 1);
        //uint32 nmax=b19->totp*b19->npp;//+b19->totd*b19->npd;
        rvmPulse *pi;//=calloc(sizeof(rvmPulse), nmax);
        rvmPulse *pulses=NULL;
        
        uint i=0,pregl;
        rvmTZXSymdef *table;
        uint level=polarity;
        
        if(b19->totp)
        {
          table=(rvmTZXSymdef*)b19->data;
          pregl=(b19->npp<<1) + 1;
          rvmTZXPRle *pdata=(rvmTZXPRle*)(b19->data+(pregl*b19->asp));
         
          uint pmax=0;
          for(int m=0;m<b19->totp;m++)
          {
            pmax+=pdata[m].count;
          }
          pmax*=b19->npp;
          pi=calloc(sizeof(rvmPulse), pmax);
          
          for(int j=0;j<b19->totp;j++)
          {
            //NSLog(@"Do nothing");
            for(int k=0;k<pdata[j].count;k++)
            {
              //rvmTZXSymdef *s=&(table[pdata[j].sym]);
              rvmTZXSymdef *s=(void*)b19->data+ (pregl*pdata[j].sym);
              
              int l=0;
              
              if(i && (s->flags==0x1 || ((s->flags==0x2 && level) || (s->flags==0x3 && !level))))
              {
                pi[i-1].count=1;
                pi[i-1].length=s->data[l++];
                
                if(s->flags==0x2) level=1;
                else if(s->flags==0x3) level=0;
                else level=!level;
              }
              
              for(;l<b19->npp;l++,i++)
              {
                if(!s->data[l]) break;
                pi[i].count=1;
                pi[i].length=s->data[l];
                level=!level;
              }
            }
          }
        }
        
        //uint n=ceil(log2(b19->asd));
        //Data
        uint32 asd=(b19->asd)?b19->asd:256;
        table=(rvmTZXSymdef*)(b19->data+((b19->totp)?(pregl*b19->asp):0)+b19->totp*3);
        uint dregl=(b19->npd<<1) + 1;
        uint8 *pdata=(uint8*)(b19->data+((b19->totp)?(pregl*b19->asp):0)+b19->totp*3+dregl*asd);
        rvmDataBlockS *datab=NULL;
        uint32 kk=0;
        uint32 ppol=level;
        
        if(b19->asd==2)
        {
          //To data block
          datab=calloc(sizeof(rvmDataBlockS), 1);
          
          rvmTZXSymdef *sd0=table;
          rvmTZXSymdef *sd1=((void*)table)+dregl;
          //First the polarity
          uint fi=pdata[0]>>7; //First bit
          uint pol=0;
          
          if(fi)
          {
            //First bit 1
            switch(sd1->flags)
            {
              case 0: //level polarity
                pol=(level)?0x80000000:0;
                break;
              case 1:
                pol=(!level)?0x80000000:0;
                break;
              case 2:
                pol=0;
                break;
              case 3:
                pol=0x80000000;
                break;
            }
            
          }
          else
          {
            switch(sd0->flags)
            {
              case 0: //level polarity
                pol=(level)?0x80000000:0;
                break;
              case 1:
                pol=(!level)?0x80000000:0;
                break;
              case 2:
                pol=0;
                break;
              case 3:
                pol=0x80000000;
                break;
            }
          }
          int p0,p1;
          for(p0=0;p0<b19->asd && sd0->data[p0];p0++);
          for(p1=0;p1<b19->asd && sd1->data[p1];p1++);
          
          //NSLog(@"GDB Data: pol:%d p0:%d p1:%d pdata:%d",pol,p0,p1,*(uint32*)pdata);
          rvmInitDataBlock(datab, b19->totd | pol, 0, p0, p1, sd0->data, sd1->data, pdata,0x0);
          
      
        }
        else
        {
          
          uint32 nb=ceil(log2(asd));
          pulses=calloc(sizeof(rvmPulse), b19->totd*b19->npd);
          
          uint32 jj=0;
          uint8 byte;
          int shifter=-1;
          uint8 mask=pow(2,nb)-1;

          
          for(int ii=0;ii<b19->totd;ii++)
          {
            
            if(shifter<0) //next byte
            {
              byte=pdata[jj++];
              shifter=8-nb;
            }
            
            uint index=(byte>>shifter) & mask;
            shifter-=nb;
            
            rvmTZXSymdef *s=(void*)table+ (dregl*index);
            
            int l=0;
            
            if(kk && (s->flags==0x1 || ((s->flags==0x2 && level) || (s->flags==0x3 && !level))))
            {
              pulses[kk-1].count=1;
              pulses[kk-1].length=s->data[l++];
              
              if(s->flags==0x2) level=1;
              else if(s->flags==0x3) level=0;
              else level=!level;
            }
            
            for(;l<b19->npd;l++,kk++)
            {
              if(!s->data[l]) break;
              pulses[kk].count=1;
              pulses[kk].length=s->data[l];
              level=!level;
            }
          }
          
          //NSLog(@"Not Supported");
        }
          
        
        //NSLog(@"Polarity before pulses: %d",polarity);
        //NSLog(@"GDB Pulse: i:%d pol:%d",i,polarity);
        
        rvmInitPulsesBlock(pb, i, pi, polarity,YES);
        pb->length(pb);
        pb->startT=decoder.totalTStates;
        decoder.totalTStates+=pb->Tstates;
        [blocks addObject:[NSValue valueWithPointer:pb]];
        [self addBlockInfo:ib block:(rvmTapeBlockProtocolS*)pb];
        if(datab)
        {
          datab->length(datab);
          datab->startT=decoder.totalTStates;
          decoder.totalTStates+=datab->Tstates;
          [blocks addObject:[NSValue valueWithPointer:datab]];
          [self addBlockInfo:ib block:(rvmTapeBlockProtocolS*)pb];
        }
        
        if(pulses)
        {
          rvmPulsesBlockS *pb=calloc(sizeof(rvmPulsesBlockS), 1);
          rvmInitPulsesBlock(pb, kk, pulses, ppol, YES);
          pb->length(pb);
          pb->startT=decoder.totalTStates;
          decoder.totalTStates+=pb->Tstates;
          [blocks addObject:[NSValue valueWithPointer:pb]];
          [self addBlockInfo:ib block:(rvmTapeBlockProtocolS*)pb];
        }
        
        //polarity=(i+polarity) & 0x1;
        polarity=level;
        
        if(b19->pause)
        {
          rvmPulsesBlockS *pb=calloc(sizeof(rvmPulsesBlockS), 1);
          rvmInitPauseBlock(pb, b19->pause*3500, polarity);
          pb->length(pb);
          pb->startT=decoder.totalTStates;
          decoder.totalTStates+=pb->Tstates;
          [blocks addObject:[NSValue valueWithPointer:pb]];
          [self addBlockInfo:ib block:(rvmTapeBlockProtocolS*)pb];
          polarity=0;
        }
        //NSLog(@"Polarity after %d pulses: %d",n,polarity);
        pt=((void*)b19)+b19->length+4;
        break;
      }
        
      case 0x20:
      {
        uint32 l=*((uint16*)pt)*3500;
        char name[0x100];
        sprintf(name, l?"Pause block tzx:0x20":"Stop block tzx:0x20");
        rvmInfoBlockS *ib=rvmNewInfoBlock(name,0,pt-1,blen);
        [blocks addObject:[NSValue valueWithPointer:ib]];
        
        rvmPulsesBlockS *pab=calloc(sizeof(rvmPulsesBlockS), 1);
        
        if(l==0) l=0xffffffff;
        //rvmInitPauseBlock(pab, l, 2);
        rvmInitPauseBlock(pab, l, 0);
        pab->length(pab);
        pab->startT=decoder.totalTStates;
        decoder.totalTStates+=pab->Tstates;
        [blocks addObject:[NSValue valueWithPointer:pab]];
        [self addBlockInfo:ib block:(rvmTapeBlockProtocolS*)pab];
        polarity=0;
        pt+=2;
        break;
      }
        
      case 0x21:
      {
        uint32 n=*((uint8*)pt++);
        NSString *str=[[NSString alloc] initWithBytes:pt length:n encoding:NSASCIIStringEncoding];
        char name[0x100];
        sprintf(name, "Group block '%s' tzx:0x21",[str UTF8String]);
        rvmInfoBlockS *ib=rvmNewInfoBlock(name,0,pt-1,blen);
        [blocks addObject:[NSValue valueWithPointer:ib]];
        ib->startT=decoder.totalTStates;
        //NSLog(@"Group Name: %@ (%d)",str,n);
        pt+=n;
        break;
      }
        
      case 0x22:
      {
        char name[0x100];
        sprintf(name, "Group end block tzx:0x22");
        rvmInfoBlockS *ib=rvmNewInfoBlock(name,0,pt-1,blen);
        [blocks addObject:[NSValue valueWithPointer:ib]];
        ib->startT=decoder.totalTStates;
        break;
      }
        
      case 0x23: //Jump
      {
        int16_t j=*((int16_t*)pt);
        iBlock+=j;
        continue;
      }
        
      case 0x24: //Loop Start
      {
        loopCounter=*((uint16*)pt);
        loopI=++iBlock;
        
        continue;
      }
        
      case 0x26: //Call
      {
        returnB=iBlock+1;
        calls=*((uint16*)pt)-1;
        pt+=2;
        callsI=pt;
        iBlock+=*callsI;
        callsI++;
        continue;
      }
        
      case 0x27: //return
      {
        if(calls)
        {
          calls--;
          iBlock=*callsI;
          callsI++;
        }
        else
        {
          iBlock=returnB;
        }
        continue;
      }
        
      case 0x25:
      {
        if(loopCounter--)
        {
          iBlock=loopI;
          continue;
        }
        break;
        
      }
        
      case 0x2a:
      {
        uint32 l=0xfffffffe;
        char name[0x100];
        sprintf(name, "Stop48k block tzx:0x2a");
        rvmInfoBlockS *ib=rvmNewInfoBlock(name,0,pt-1,blen);
        [blocks addObject:[NSValue valueWithPointer:ib]];
        
        rvmPulsesBlockS *pab=calloc(sizeof(rvmPulsesBlockS), 1);
        
        rvmInitPauseBlock(pab, l, 0);
        pab->length(pab);
        pab->startT=decoder.totalTStates;
        decoder.totalTStates+=pab->Tstates;
        [blocks addObject:[NSValue valueWithPointer:pab]];
        polarity=0;
        pt+=2;
        break;
      }
      case 0x32:
      {
        char name[0x100];
        sprintf(name, "Info block tzx:0x32");
        rvmInfoBlockS *ib=rvmNewInfoBlock(name,0,pt-1,blen);
        [blocks addObject:[NSValue valueWithPointer:ib]];
        
        rvmTZX32Block *b32=(rvmTZX32Block*)pt;

        rvmTZXText *t=&b32->str;
        for(int i=0;i<b32->n;i++)
        {
          //NSString *str=[[NSString alloc] initWithBytes:&t->str length:t->length encoding:NSASCIIStringEncoding];
          //NSLog(@"tid: %d str: %@",t->tid,str);
          t=(rvmTZXText*)(((void*)t)+2+t->length);
        }

        pt=(uint8*)t;
        break;
      }
      case 0x30:
      {
        uint32 n=*((uint8*)pt++);
        NSString *str=[[NSString alloc] initWithBytes:pt length:n encoding:NSASCIIStringEncoding];
        char name[0x100];
        sprintf(name, "Text block '%s' tzx:0x30",[str UTF8String]);
        rvmInfoBlockS *ib=rvmNewInfoBlock(name,0,pt-1,blen);
        [blocks addObject:[NSValue valueWithPointer:ib]];
        ib->startT=decoder.totalTStates;
        NSLog(@"Text description: %@",str);
        pt+=n;
        //return parseBlock(s);
        break;
      }
        
      case 0x33:
      {
        char name[0x100];
        sprintf(name, "Hardware info block tzx:0x33");
        rvmInfoBlockS *ib=rvmNewInfoBlock(name,0,pt-1,blen);
        [blocks addObject:[NSValue valueWithPointer:ib]];
        ib->startT=decoder.totalTStates;
        break;
      }
        
      case 0x35:
      {
        char name[0x100];
        sprintf(name, "Custom block tzx:0x35");
        rvmInfoBlockS *ib=rvmNewInfoBlock(name,0,pt-1,blen);
        [blocks addObject:[NSValue valueWithPointer:ib]];
        ib->startT=decoder.totalTStates;
      }
        
      case 0x5a: //Glue block
      {
        char name[0x100];
        sprintf(name, "Glue block tzx:0x5a");
        rvmInfoBlockS *ib=rvmNewInfoBlock(name,0,pt-1,blen);
        [blocks addObject:[NSValue valueWithPointer:ib]];
        ib->startT=decoder.totalTStates;
        break;
      }
        
      default:
      {
        NSLog(@"Unimplemented block id:%lx stopping",(unsigned long)bid);
        pt=last;
        break;
      }
    }
    iBlock++;
  }
  
  //if(polarity)
  //{
  rvmPulsesBlockS *tail=calloc(sizeof(rvmPulsesBlockS), 1);

  rvmInitPauseBlock(tail, 3500000, polarity);
  tail->length(tail);
  tail->startT=decoder.totalTStates;
  decoder.totalTStates+=tail->Tstates;
  [blocks addObject:[NSValue valueWithPointer:tail]];
  //}
  
  decoder.blocks=malloc(sizeof(void*)*blocks.count);
  decoder.numberOfBlocks=(uint32)blocks.count;
  uint j=0;
  for(NSValue *v in blocks)
  {
    decoder.blocks[j++]=v.pointerValue;
  }
}

-(NSMutableArray *)groupBlocks:(NSMutableArray *)r
{
  NSMutableArray *rr=[NSMutableArray new];
  
  for(uint32 i=0;i<r.count;i++)
  {
    NSDictionary *bd=r[i];
    
    uint32 ii=(uint32)[bd[@"index"] unsignedIntValue];
    
    rvmInfoBlockS *ib=decoder.blocks[ii];
    
    if(ib->tag)
    {
      rvmDataBlockS *db=decoder.blocks[ii+2];
      
      NSString *bName;
      
      if(db->bits==152)
        bName=[self standardBlockName:db->data index:ii];
      
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

-(void)addPulsesBlock:(rvmPulse *)pulses count:(uint32)c
{
  uint lp=0;
  
//  if(addPause)
//  {
//    addPause=NO;
//    uint32 i=0;
//    
//    for(i=0;i<c;i++)
//    {
//      if(pulses[i].length && pulses[i].length<6000) break;
//      lp+=pulses[i].length;
//    }
//    
//    rvmPulsesBlockS *ps=calloc(sizeof(rvmPulsesBlockS), 1);
//    rvmInitPauseBlock(ps, lp, 0);
//    ps->length(ps);
//    ps->startT=decoder.totalTStates;
//    decoder.totalTStates+=ps->Tstates;
//    [self insertBlock:ps index:decoder.blockIndex++];
//    
//    if(i>=c) return;
//    pulses=pulses+i;
//    c-=i;
//  }
  
  //Trim pause block
  uint32 i=0;
  lp=0;
  for(i=0;i<c;i++)
  {
    if(pulses[i].length && pulses[i].length<6000) break;
    lp+=pulses[i].length;
  }
  
  lp=lp/3500;
  if(lp)
  {
    if(!addPause)
    {
      //addPause=NO;
      char name[0x100];
      sprintf(name, "Pause block tzx:0x20");
      uint8 *data=calloc(3, 1);
      data[0]=0x20;
      lp=(lp>0xffff)?0xffff:lp;
      uint16 *dp=(uint16*)(data+1);
      *dp=lp;
      rvmInfoBlockS *ibb=rvmNewInfoBlock(name,1,data,3);
      [self insertBlock:ibb index:decoder.blockIndex++];
    }
    else
      addPause=NO;
    
    rvmPulsesBlockS *ps=calloc(sizeof(rvmPulsesBlockS), 1);
    rvmInitPauseBlock(ps, lp*3500, 0);
    ps->length(ps);
    ps->startT=decoder.totalTStates;
    decoder.totalTStates+=ps->Tstates;
    [self insertBlock:ps index:decoder.blockIndex++];
    
    if(i>=c) return;
    pulses=pulses+i;
    c-=i;
  }
  
  uint32 tot=0;
  NSData *rle=[rvmCSWDecoder compressRLE:pulses count:c sample:79 total:&tot];
  NSData *rlez=[rle deflate];
  
  uint32 l=(uint32)(sizeof(rvmTZX18Block)+rlez.length)+1;
  uint8 *dd=calloc(l, 1);
  rvmTZX18Block *b=(rvmTZX18Block*)(dd+1);
  
  dd[0]=0x18;
  b->pause=lp;
  b->length=(uint32)rlez.length+10;
  b->compression=0x2;
  b->pulses=tot;
  b->sampling[0]=0x0f;
  b->sampling[1]=0xad;
  b->sampling[2]=0;
  memcpy(b->data, rlez.bytes, rlez.length);

  char name[0x100];
  sprintf(name, "Csw block tzx:0x18");
  rvmInfoBlockS *ib=rvmNewInfoBlockF(name,1,dd,l);
  [self insertBlock:ib index:decoder.blockIndex++];
  [super addPulsesBlock:pulses count:c];
}

-(void)addStandardBlock:(NSData *)data pilotCount:(uint32)c bits:(uint32)bits
{
  uint32 l=(uint32)(sizeof(rvmTZX10Block)+data.length)+1;
  uint8 *dd=calloc(l, 1);
  rvmTZX10Block *b=(rvmTZX10Block*)(dd+1);
  
  dd[0]=0x10;
  b->pause=1000;
  b->length=data.length;
  memcpy(b->data, data.bytes, data.length);
  
  char name[0x100];
  sprintf(name, "Standard block tzx:0x10 length:%d",b->length);
  rvmInfoBlockS *ib=rvmNewInfoBlock(name,3,dd,l);
  ib->tag=1;
  [self insertBlock:ib index:decoder.blockIndex++];
  [super addStandardBlock:data pilotCount:c bits:bits];
  addPause=YES;
}

const char tzxsig[10]={'Z','X','T','a','p','e','!',0x1a,0x1,20};

-(void)saveFile
{
  
  NSMutableData *md=[NSMutableData new];
  
  [md appendBytes:tzxsig length:10];
  

  
  uint i=0;
  while(i<decoder.numberOfBlocks)
  {
    NSData *d=[self detectStandardBlock:&i];
    if(!d) d=[self detectTurboBlock:&i];
    if(!d) d=[self detectBlock:&i];
    
    if(d) [md appendData:d];
  }
  
  [md writeToFile:self.path atomically:YES];
  //Res de moment.
}

-(NSData*)dataToDrec:(rvmDataBlockS*)data rate:(uint)rate
{
  rvmDirectEncoder *d=[rvmDirectEncoder new];
  d.rate=rate;
  
  int sh=-1;
  uint8 ac=0;
  uint8 *pt=data->data;
  uint level=data->level;
  
  for(int i=0;i<data->bits;i++)
  {
    if(sh<0)
    {
      ac=*(pt++);
      sh=7;
    }
    
    if((ac>>sh--) & 0x1) //1
    {
      for(int i=0;i<data->p1;i++,level=!level)
      {
        [d addPulse:data->s1[i] level:level];
      }
    }
    else //0
    {
      for(int i=0;i<data->p0;i++,level=!level)
      {
        [d addPulse:data->s0[i] level:level];
      }
    }
  }
  
  if(data->tail)
  {
    [d addPulse:data->tail level:level];
    level=!level;
  }
  
  [d finish];
  
  return d.data;
}

//Block detectors.
-(NSData*)detectBlock:(uint*)index
{
  if(*index>decoder.numberOfBlocks) return nil;
  
  while(1)
  {
    rvmTapeBlockProtocolS *block=decoder.blocks[*index];
    
    switch(block->type)
    {
      case kRvmInfoBlock:
      {
        (*index)++;
        return nil;
      }
        
      case kRvmPulsesBlock:
      {
        rvmDirectEncoder *d=[rvmDirectEncoder new];
        d.rate=158;
        
        rvmPulsesBlockS *pb=(rvmPulsesBlockS*)block;
        
        uint level=pb->level;
        for(int i=0;i<pb->n;i++)
        {
          uint lbits=pb->pulses[i].length;
          
          for(int k=0;k<pb->pulses[i].count;k++,level=!level)
          {
            //NSLog(@"%d:%d",i,k);
            [d addPulse:lbits level:level];
          }
        }
        
        [d finish];
        
        (*index)++;
        return d.data;
      }
        
      case kRvmPureDataBlock:
      {
        rvmDataBlockS *db=(rvmDataBlockS*)block;
        
        if(db->p0==db->p1 && db->p0==2 && db->s0[0]==db->s0[1] && db->s1[0]==db->s1[1]) //Codificable como pure data.
        {
          NSMutableData *md=[NSMutableData data];
          
          rvmTZX14Block pure;
          uint l=db->bits>>3;
          l+=(db->bits & 0x7)?1:0;
          
          pure.length[0]=l & 0xff;
          pure.length[1]=(l>>8) & 0xff;
          pure.length[2]=(l>>16) & 0xff;
          
          pure.ub=(db->bits & 0x7)?db->bits & 0x7:8;
          
          pure.l0=db->s0[0];
          pure.l1=db->s1[0];
          
          pure.pause=0;
          
          uint8 bt=0x14;
          [md appendBytes:&bt length:1];
          [md appendBytes:&pure length:sizeof(pure)];
          [md appendBytes:db->data length:l];
          
          (*index)++;
          return md;
        }
        else
        {
          (*index)++;
          return [self dataToDrec:db rate:158];
        }
      }
      case kRvmPauseBlock:
      {
        rvmPulsesBlockS *pb=(rvmPulsesBlockS*)block;
        NSMutableData *d=[NSMutableData new];
        (*index)++;
        
        if(pb->n==1 || pb->n==2)
        {
          if(pb->pulses[0].length==0xfffffffe || pb->pulses[1].length==0xfffffffe)
          {
            //Stop block 48k;
            uint8 bid=0x2a;
            uint32 l=0x0;
            
            [d appendBytes:&bid length:1];
            [d appendBytes:&l length:4];
            
            return d;
          }
          
          if(pb->pulses[0].length==0xffffffff || pb->pulses[1].length==0xffffffff)
          {
            //Stop block 48k;
            uint8 bid=0x20;
            uint16 l=0x0;
            
            [d appendBytes:&bid length:1];
            [d appendBytes:&l length:2];
            
            return d;
          }
        }
        
        uint32 l=0;
        
        for(int i=0;i<pb->n;i++)
        {
          l+=pb->pulses[i].length*pb->pulses[i].count;
        }
        
        l=l / 3500; // to ms
        
        uint8 bid=0x20;
        [d appendBytes:&bid length:1];
        [d appendBytes:&l length:2];
        
         //De moment;
        return d;
      }
    }
  }
}

-(uint)extractPause:(uint*)index
{
  uint l=0;
  
  while(*index<decoder.numberOfBlocks)
  {
    rvmTapeBlockProtocolS *block=decoder.blocks[*(index)];
    
    if(block->type==kRvmPauseBlock)
    {
      
      rvmPulsesBlockS *pb=(rvmPulsesBlockS*)block;
      
      if(pb->n<=2 && (pb->pulses[0].length>=0xfffffffe || pb->pulses[1].length>=0xfffffffe))
      {
        //Is a stop block;
        (*index)--;
        break;
      }
      else
      {
        (*index)++;
        for(int i=0;i<pb->n;i++)
        {
          l+=pb->pulses[i].length*pb->pulses[i].count;
        }
      }
    }
    else break;
  }
  
  return l / 3500;
}

-(NSData*)detectTurboBlock:(uint*)index
{
  uint ind=*index;
  rvmTapeBlockProtocolS *block=decoder.blocks[ind++];
  
  if(block->type==kRvmPulsesBlock)
  {
    rvmPulsesBlockS *pb=(rvmPulsesBlockS*)block;
    
    if(ind>=decoder.numberOfBlocks) return nil;
    block=decoder.blocks[ind++];
    
    if(pb->n==3 && block->type==kRvmPureDataBlock)
    {
      NSMutableData *d=[NSMutableData new];
      rvmDataBlockS *db=(rvmDataBlockS*)block;
      //ok...
      if(db->p0!=2 || db->p1!=2 || db->s0[0]!=db->s0[1] || db->s1[0]!=db->s1[1]) return nil;
      
      rvmTZX11Block b11;
      
      b11.pilotL=pb->pulses[0].length;
      b11.pilotC=pb->pulses[0].count;
      b11.sync1=pb->pulses[1].length;
      b11.sync2=pb->pulses[2].length;
      
      uint l=db->bits>>3;
      l+=(db->bits & 0x7)?1:0;
      
      b11.length[0]=l & 0xff;
      b11.length[1]=(l>>8) & 0xff;
      b11.length[2]=(l>>16) & 0xff;
      
      b11.usedBits=db->bits & 0x7;
      b11.usedBits=(b11.usedBits)?b11.usedBits:8;
      
      b11.l0=db->s0[0];
      b11.l1=db->s1[1];
      
      uint pl=[self extractPause:&ind];
      b11.pause=pl;
      *index=ind;
      
      uint8 bid=0x11;
      [d appendBytes:&bid length:1];
      [d appendBytes:&b11 length:sizeof(b11)];
      [d appendBytes:db->data length:l];
      
      return d;
    }
  }
  
  return nil;
}

-(NSData*)detectStandardBlock:(uint*)index
{
  uint ind=*index;
  rvmTapeBlockProtocolS *block=decoder.blocks[ind++];
  
  if(block->type==kRvmPulsesBlock)
  {
    rvmPulsesBlockS *pb=(rvmPulsesBlockS*)block;
    
    if(ind>=decoder.numberOfBlocks) return nil;
    block=decoder.blocks[ind++];
    
    if(pb->n==3 && pb->pulses[0].length==2168 && pb->pulses[1].length==667 && pb->pulses[2].length==735 &&  block->type==kRvmPureDataBlock)
    {
      NSMutableData *d=[NSMutableData new];
      rvmDataBlockS *db=(rvmDataBlockS*)block;
      //ok...
      if(db->p0!=2 || db->p1!=2 || db->s0[0]!=db->s0[1] || db->s1[0]!=db->s1[1]) return nil;
      
      rvmTZX10Block b10;
      
      
      
      uint l=db->bits>>3;
      l+=(db->bits & 0x7)?1:0;
      
      b10.length=l;
      
      uint pl=[self extractPause:&ind];
      b10.pause=pl;
      *index=ind;
      
      uint8 bid=0x10;
      [d appendBytes:&bid length:1];
      [d appendBytes:&b10 length:sizeof(b10)];
      [d appendBytes:db->data length:l];
      
      return d;
    }
  }
  
  return nil;
}

@end


@interface rvmDirectEncoder()
{
  uint8 ac;
  int sh;
  double rc;
}

@end


//Direct Encoder
@implementation rvmDirectEncoder

-(instancetype)init
{
  self=[super init];
  
  if(self)
  {
    ac=0;
    sh=7;
    _data=[NSMutableData data];
    rvmTZX15Block h;
    uint8 bt=0x15;
    [_data appendBytes:&bt length:1];
    
    [_data appendBytes:&h length:sizeof(h)];
  }
  
  return self;
}

-(void)addPulse:(uint)T level:(uint)level
{
  double i=T*_rate;
  uint bits=ceil(rc+i)-ceil(rc);
  
  for(int i=0;i<bits;i++)
  {
    if(level)
    {
      ac=ac | (0x1<<sh);
    }
    
    sh--;
    
    if(sh<0)
    {
      [_data appendBytes:&ac length:1];
      sh=7;
      ac=0;
    }
  }
  
  rc+=i;
}

-(void)finish
{
  rvmTZX15Block *h=(rvmTZX15Block*)(_data.bytes+1);
  
  if(sh!=7) [_data appendBytes:&ac length:1];
  
  uint l=(uint)(_data.length-sizeof(rvmTZX15Block)-1);
  
  h->length[0]=l & 0xff;
  h->length[1]=(l>>8) & 0xff;
  h->length[2]=(l>>16) & 0xff;
  
  h->used=7-sh;
  h->used=(h->used)?h->used:8;
  
  h->pause=0;
}

-(void)setRate:(double)rate
{
  _rate=1/rate;
  
  rvmTZX15Block *h=(rvmTZX15Block*)(_data.bytes+1);
  h->T=rate;
}

@end
