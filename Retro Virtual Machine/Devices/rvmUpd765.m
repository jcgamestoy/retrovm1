//
//  rvmUpd765.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 29/06/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmUpd765.h"



#define RQM 0x80
#define DIO 0x40
#define NDM 0x20
#define CB 0x10

#define kReadTrack 0x2
#define kSpecify 0x3
#define kSenseDrive 0x4
#define kWriteData 0x5
#define kReadData 0x6
#define kRecalibrate 0x7
#define kWriteDeleteData 0x9
#define kSense 0x8
#define kReadDeleteData 0xc
#define kReadID 0xa
#define kFormat 0xd
#define kSeek 0xf
#define kScan 0x11
#define kScanLow 0x19
#define kScanHigh 0x1d

#define kInvalid 0x1f

#define kRvmUPD765StateIdle    0
#define kRvmUPD765StateRead    1
#define kRvmUPD765StateWrite   2
#define kRvmUPD765StateFormat  3
#define kRvmUPD765StateSeek    4
//#define kRvmUPD765StateResult  5
#define kRvmUPD765StateCommand 7

#define kRvmUPD765Seeking      8

#define kRvmUPD765Result 0x80

#define kRvmUPD765Halt 0xff

#define kDriveReady 0x20

#define k 0x10
#define kReadingData 0x11
#define kReadingDataEnd 0x12
#define kWritingData 0x13
#define kWritingDataEnd 0x14

#define kReadingTrackData 0x15

#define kScanningData 0x16
#define kScanningDataEnd 0x17

#define kS0NR 0x08

#define kMT 0x80
#define kMF 0x40
#define kSK 0x20

#define kC 0x1
#define kH 0x2
#define kR 0x3
#define kN 0x4
#define kEOT 0x5
#define kGPL 0x6
#define kDTL 0x7
#define kSTP 0x7

#define kBusy 0x10
#define kExec 0x20
#define kIO 0x40
#define kRM 0x80

static uint hutT[0x10]={
  0,
  128000,
  256000,
  384000,
  512000,
  640000,
  768000,
  896000,
  1024000,
  1152000,
  1280000,
  1408000,
  1536000,
  1664000,
  1792000,
  1920000,
};

static uint srtT[0x10]={
  113501,
  106407,
  99313,
  92219,
  85126,
  78032,
  70938,
  63844,
  56750,
  49657,
  42563,
  35469,
  28375,
  21281,
  14188,
  7094,
};

static uint8 com[32]={
  0, //0x0
  0, //0x1
  8, //0x2 Read Track
  2, //0x3 specify
  1, //0x4 sense drive
  8, //0x5 write data
  8, //0x6 read Data
  1, //0x7 recalibrate
  0, //0x8 sense
  8, //0x9 write deleted data
  1, //0xa readID
  0, //0xb
  8, //0xc read delete data
  5, //0xd format
  0, //0xe
  2, //0xf seek
  0, //0x10
  8, //0x11 scan equal
  0, //0x12
  0, //0x13
  0, //0x14
  0, //0x15
  0, //0x16
  0, //0x17
  0, //0x18
  8, //0x19 scan low
  0, //0x1a
  0, //0x1b
  0, //0x1c
  8, //0x1d scan high
  0, //0x1e
  0, //0x1f Invalid
};

static uint8 ecom[32]={
  0, //0x0
  0, //0x1
  0, //0x2
  1, //0x3 specify
  1, //0x4 sense drive
  0, //0x5 write data
  0, //0x6 read Data
  1, //0x7 recalibrate
  1, //0x8 sense
  0, //0x9 write deleted data
  0, //0xa readID
  0, //0xb
  0, //0xc read delete data
  0, //0xd format
  0, //0xe
  1, //0xf seek
  0, //0x10
  0, //0x11
  0, //0x12
  0, //0x13
  0, //0x14
  0, //0x15
  0, //0x16
  0, //0x17
  0, //0x18
  0, //0x19
  0, //0x1a
  0, //0x1b
  0, //0x1c
  0, //0x1d
  0, //0x1e
  0, //0x1f Invalid
};


@interface rvmUpd765()
{
  rvmUpd765S h;

};

@end

void readData(rvmUpd765S *d)
{
  uint8 drive=d->buffer[0] & 0x3;
  uint8 side=(d->buffer[0]>>2) & 0x1;
  
  rvmDskSectorInfoS *sector;
  bool sk=d->command & kSK;
  bool ss=(d->command & 0x1f)==kReadDeleteData;
  
  if(d->disks[drive])
    while(true)
    {
      d->pt=d->disks[drive]->seek(d->disks[drive],side,d->pc[drive],d->buffer[kH],d->buffer[kC],d->buffer[kR],d->buffer[kN],(void**)&sector);
      if(!d->pt || ((sector->st2 & 0x40) && (!sk || ss)) || ((!(sector->st2 & 0x40)) && (!sk || !ss))) break;
      else
      {
        d->buffer[kR]++;
        if(d->buffer[kR]>d->buffer[kEOT]) break;
      }
    }
  else
    d->pt=NULL;
  
  if(d->pt) //Found
  {
    //d->length=(d->buffer[kN])?(0x80<<d->buffer[kN]):d->buffer[kDTL];
    d->length=sector->rsize;
    NSLog(@"Length: %d,status1:0x%.2x,status2:0x%.2x",d->length,sector->st1,sector->st2);
    // *Todo: Investigate the GPL command.
    d->status=(d->status & 0xf) | kIO | kBusy | kExec;
    d->delay=(rand()/((double)RAND_MAX))*10000+500; //Access time
    //Prepare result.
    if(d->buffer[kR]>=d->buffer[kEOT] || ((sector->st2&0x40) && !sk && (d->command & 0x1f)!=kReadDeleteData))
    {
      if(d->command & kMT)
      {
        d->buffer[0]^=0x4; //flip Side.
        d->buffer[kR]=1;
        d->buffer[kH]^=0x1;
        d->command^=kMT;
        d->led[drive]=1;
        d->rstate=d->sstate=kReadingData;
        return;
      }
      else
      {
        d->buffer[0x6]=d->buffer[kN];
        d->buffer[0x5]=d->buffer[kR];
        d->buffer[0x4]=d->buffer[kH];
        d->buffer[0x3]=d->buffer[kC]+1;
        //End of command
        //d->buffer[0]=d->rstatus[0];
        d->buffer[0]=d->buffer[0] & 0x7;
        d->buffer[1]=sector->st1;
        d->buffer[2]=sector->st2;
        if((d->command & 0x1f)==kReadDeleteData)
          d->buffer[2]&=0xbf; //???
        
        //d->status=(d->status & 0xf) | kIO | kBusy | kRM;
        d->bIndex=0;
        d->led[drive]=1;
        d->rstate=d->sstate=kReadingDataEnd;
        return;
      }
    }
    
    d->buffer[kR]++;
    d->led[drive]=1;
    d->rstate=d->sstate=kReadingData;
  }
  else
  {
    d->buffer[0x6]=d->buffer[kN];
    d->buffer[0x5]=d->buffer[kR];
    d->buffer[0x4]=d->buffer[kH];
    d->buffer[0x3]=d->buffer[kC];
    //End of command
    d->buffer[0]|=(d->buffer[0] & 0x7) | 0x40;
    d->buffer[1]=0x4;
    d->buffer[2]=0x0;
    d->status=(d->status & 0xf) | kIO | kBusy | kRM;
    d->bIndex=0;
    d->length=7;
    d->led[drive]=0;
    d->rstate=kRvmUPD765Result;
    d->sstate=kRvmUPD765StateIdle;
    return;
  }
}

void writeData(rvmUpd765S *d)
{
  uint8 drive=d->buffer[0] & 0x3;
  uint8 side=(d->buffer[0]>>2) & 0x1;
  
  rvmDskSectorInfoS *sector;
  
  if(d->disks[drive])
    d->pt=d->disks[drive]->seek(d->disks[drive],side,d->pc[drive],d->buffer[kH],d->buffer[kC],d->buffer[kR],d->buffer[kN],(void**)&sector);
  else
    d->pt=NULL;
  
  if(d->pt) //Found
  {
    d->length=(d->buffer[kN])?(0x80<<d->buffer[kN]):d->buffer[kDTL];
    d->disks[drive]->dirty=0x40;
    NSLog(@"W Length: %d,status1:0x%.2x,status2:0x%.2x",d->length,sector->st1,sector->st2);
    // *Todo: Investigate the GPL command.
    d->status=(d->status & 0xf) | kBusy | kExec;
    d->delay=(rand()/((double)RAND_MAX))*10000+500; //Access time
    d->pt--;
    //Prepare result.
    
    if((d->command & 0x1f)==kWriteDeleteData)
    {
      sector->st2|=0x40; //Set deleted data.
    }
    
    if(d->buffer[kR]==d->buffer[kEOT])
    {
      if(d->command & kMT)
      {
        d->buffer[0]^=0x4; //flip Side.
        d->buffer[kR]=1;
        d->buffer[kH]^=0x1;
        d->command^=kMT;
        d->led[drive]=1;
        d->wstate=d->sstate=kWritingData;
        return;
      }
      else
      {
        d->buffer[0x6]=d->buffer[kN];
        d->buffer[0x5]=d->buffer[kR];
        d->buffer[0x4]=d->buffer[kH];
        d->buffer[0x3]=d->buffer[kC]+1;
        //End of command
        //d->buffer[0]=d->rstatus[0];
        d->buffer[0]=d->buffer[0] & 0x7;
        d->buffer[1]=sector->st1;
        d->buffer[2]=sector->st2;
        //d->status=(d->status & 0xf) | kIO | kBusy | kRM;
        d->bIndex=0;
        d->led[drive]=1;
        d->wstate=d->sstate=kWritingDataEnd;
        return;
      }
    }
    

    d->buffer[kR]++;
    d->led[drive]=1;
    d->wstate=d->sstate=kWritingData;
  }
  else
  {
    d->buffer[0x6]=d->buffer[kN];
    d->buffer[0x5]=d->buffer[kR];
    d->buffer[0x4]=d->buffer[kH];
    d->buffer[0x3]=d->buffer[kC];
    //End of command
    d->buffer[0]|=(d->buffer[0] & 0x7) | 0x40;
    d->buffer[1]=0x4;
    d->buffer[2]=0x0;
    d->status=(d->status & 0xf) | kIO | kBusy | kRM;
    d->bIndex=0;
    d->length=7;
    d->led[drive]=0;
    d->rstate=kRvmUPD765Result;
    d->sstate=kRvmUPD765StateIdle;
    d->wstate=kRvmUPD765StateIdle;
    return;
  }
}

void readTrack(rvmUpd765S *d)
{
  uint8 drive=d->buffer[0] & 0x3;
  uint8 side=(d->buffer[0]>>2) & 0x1;
  
  rvmDskSectorInfoS *sector;
  
  if(d->disks[drive])
  {
    uint32 cyl=(d->disks[drive]->sidesN==2)?(d->pc[drive]<<1)+side:d->pc[drive];
    rvmDskTrackS *tr=d->disks[drive]->tracks[cyl];

    d->pt=NULL;
    
    if(tr && tr->nsector>d->rtrackI)
    {
      sector=tr->sectors[d->rtrackI++];
      d->pt=sector->data;
    }
    
  }
  else
    d->pt=NULL;
  
  if(d->pt) //Found
  {
    d->length=sector->rsize;
    NSLog(@"Length: %d,status1:0x%.2x,status2:0x%.2x",d->length,sector->st1,sector->st2);
   
    d->status=(d->status & 0xf) | kIO | kBusy | kExec;
    d->delay=(rand()/((double)RAND_MAX))*10000+500; //Access time
   
    if(d->rtrackI==d->buffer[kEOT])
    {
      {
        d->buffer[0x6]=d->buffer[kN];
        d->buffer[0x5]=d->buffer[kR]+d->buffer[kEOT];
        d->buffer[0x4]=d->buffer[kH];
        d->buffer[0x3]=d->buffer[kC]+1;
        d->buffer[0]=d->buffer[0] & 0x7;
        d->buffer[1]=0;//sector->st1;
        d->buffer[2]=0;//sector->st2;
        
        //d->status=(d->status & 0xf) | kIO | kBusy | kRM;
        d->bIndex=0;
        d->led[drive]=1;
        d->rstate=d->sstate=kReadingDataEnd;
        return;
      }
    }
    
    d->buffer[kR]++;
    d->led[drive]=1;
    d->rstate=d->sstate=kReadingTrackData;
  }
  else
  {
    d->buffer[0x6]=d->buffer[kN];
    d->buffer[0x5]=d->buffer[kR];
    d->buffer[0x4]=d->buffer[kH];
    d->buffer[0x3]=d->buffer[kC];
    //End of command
    d->buffer[0]|=(d->buffer[0] & 0x7) | 0x40;
    d->buffer[1]=0x4;
    d->buffer[2]=0x0;
    d->status=(d->status & 0xf) | kIO | kBusy | kRM;
    d->bIndex=0;
    d->length=7;
    d->led[drive]=0;
    d->rstate=kRvmUPD765Result;
    d->sstate=kRvmUPD765StateIdle;
    return;
  }
}

void scanData(rvmUpd765S *d)
{
  uint8 drive=d->buffer[0] & 0x3;
  uint8 side=(d->buffer[0]>>2) & 0x1;
  
  uint8 dis=d->buffer[kSTP]==2?2:1;
  
  rvmDskSectorInfoS *sector;
  bool sk=d->command & kSK;
  //bool ss=(d->command & 0x1f)==kReadDeleteData;
  
  if(d->disks[drive])
    while(true)
    {
      d->pt=d->disks[drive]->seek(d->disks[drive],side,d->pc[drive],d->buffer[kH],d->buffer[kC],d->buffer[kR],d->buffer[kN],(void**)&sector);
      if(!d->pt || ((!(sector->st2 & 0x40)) || (!sk))) break;
      else
      {
        d->buffer[kR]+=dis;
        if(d->buffer[kR]>d->buffer[kEOT]) break;
      }
    }
  else
    d->pt=NULL;
  
  if(d->pt) //Found
  {
    //d->length=(d->buffer[kN])?(0x80<<d->buffer[kN]):d->buffer[kDTL];
    d->length=sector->rsize;
    NSLog(@"Length: %d,status1:0x%.2x,status2:0x%.2x",d->length,sector->st1,sector->st2);
    // *Todo: Investigate the GPL command.
    d->status=(d->status & 0xf) | kBusy | kExec;
    d->delay=(rand()/((double)RAND_MAX))*10000+500; //Access time
    //Prepare result.
    d->rstatus[2]=0x8;
    
    if(d->buffer[kR]==d->buffer[kEOT] || ((sector->st2&0x40) && !sk))
    {
      if(d->command & kMT)
      {
        d->buffer[0]^=0x4; //flip Side.
        d->buffer[kR]=1;
        d->buffer[kH]^=0x1;
        d->command^=kMT;
        d->led[drive]=1;
        d->wstate=d->sstate=kScanningData;
        return;
      }
      else
      {
        d->buffer[0x6]=d->buffer[kN];
        d->buffer[0x5]=d->buffer[kR];
        d->buffer[0x4]=d->buffer[kH];
        d->buffer[0x3]=d->buffer[kC]+1;
        //End of command
        //d->buffer[0]=d->rstatus[0];
        d->buffer[0]=d->buffer[0] & 0x7;
        d->buffer[1]=0;
        d->buffer[2]=d->rstatus[2];
        
        //d->status=(d->status & 0xf) | kIO | kBusy | kRM;
        d->bIndex=0;
        d->led[drive]=1;
        d->wstate=d->sstate=kScanningDataEnd;
        return;
      }
    }
    
    d->buffer[kR]+=dis;
    d->led[drive]=1;
    d->wstate=d->sstate=kScanningData;
  }
  else
  {
    d->buffer[0x6]=d->buffer[kN];
    d->buffer[0x5]=d->buffer[kR];
    d->buffer[0x4]=d->buffer[kH];
    d->buffer[0x3]=d->buffer[kC];
    //End of command
    d->buffer[0]|=(d->buffer[0] & 0x7) | 0x40;
    d->buffer[1]=0x4;
    d->buffer[2]=0x4;
    d->status=(d->status & 0xf) | kIO | kBusy | kRM;
    d->bIndex=0;
    d->length=7;
    d->led[drive]=0;
    d->wstate=kRvmUPD765StateIdle;
    d->rstate=kRvmUPD765Result;
    d->sstate=kRvmUPD765StateIdle;
    return;
  }
}



void rvmUpd765Step(rvmUpd765S* d)
{
  uint power=0;
  
  for(int i=0;i<4;i++)
  {
    if(!d->headBlock[i] && d->headUnload[i])
    {
      d->headUnload[i]--;
      power++;
    }
  }
  
  if(d->delay)
  {
    power++;
    d->delay--;
    return;
  }
  
  if(d->sstate || d->wstate || d->rstate) power++;
  d->power=power;
  
  switch(d->sstate)
  {
    case kReadingTrackData:
    case kReadingDataEnd:
    case kReadingData:
    {
      uint drive=d->buffer[0] & 0x3;
      if(!d->headUnload[drive])
      {
        d->delay=d->hlt;
        d->headUnload[drive]=d->hut;
        d->headBlock[drive]=YES;
      }
      else
      {
        
        if(d->length==0)
        {
          if(d->sstate==kReadingDataEnd)
          {
            d->length=7;
            d->bIndex=0;
            d->status=(d->status & 0xf) | kIO | kBusy | kRM;
            d->rstate=kRvmUPD765Result;
            d->headBlock[drive]=NO;
            d->sstate=kRvmUPD765StateIdle;
            d->led[drive]=0;
            return;
          }
          else
          {
            if(d->sstate==kReadingData)
              readData(d);
            else
              readTrack(d);
          }
        }
        
        if(!d->pt) return;
        
        if(d->status & kRM)
        {
          NSLog(@"Overrun %d",d->length);
          d->buffer[1]|=0x10;
          //if(d->sstate==kReadData)
            d->sstate=d->rstate=kReadingDataEnd;
        }
        
        d->data=*d->pt;
        d->pt++;
        d->status=d->status | kRM;
        d->length--;
        d->delay=16*8;
      }
      return;
    }
      
    case kScanningDataEnd:
    case kScanningData:
    {
      uint drive=d->buffer[0] & 0x3;
      if(!d->headUnload[drive])
      {
        d->delay=d->hlt;
        d->headUnload[drive]=d->hut;
        d->headBlock[drive]=YES;
      }
      else
      {
        
        if(d->length==0)
        {
          if(d->sstate==kScanningDataEnd || (d->rstatus[2] & 0x8))
          {
            d->length=7;
            d->bIndex=0;
            d->status=(d->status & 0xf) | kIO | kBusy | kRM;
            d->wstate=kRvmUPD765StateIdle;
            d->rstate=kRvmUPD765Result;
            d->headBlock[drive]=NO;
            d->sstate=kRvmUPD765StateIdle;
            d->led[drive]=0;
            return;
          }
          else
          {
            scanData(d);
          }
        }
        
        if(!d->pt) return;
        
        if(d->status & kRM)
        {
          NSLog(@"Overrun %d",d->length);
          d->buffer[1]|=0x10;
          //if(d->sstate==kReadData)
          d->sstate=d->wstate=kScanningDataEnd;
        }
        
        d->data=*d->pt;
        d->pt++;
        d->status=d->status | kRM;
        d->length--;
        d->delay=16*8;
      }
      return;
    }
      
    case kWritingDataEnd:
    case kWritingData:
    {
      uint drive=d->buffer[0] & 0x3;
      if(!d->headUnload[drive])
      {
        d->delay=d->hlt;
        d->headUnload[drive]=d->hut;
        d->headBlock[drive]=YES;
      }
      else
      {
        
        if(d->length==0)
        {
          if(d->sstate==kWritingDataEnd)
          {
            d->length=7;
            d->bIndex=0;
            d->status=(d->status & 0xf) | kIO | kBusy | kRM;
            d->rstate=kRvmUPD765Result;
            d->headBlock[drive]=NO;
            d->sstate=kRvmUPD765StateIdle;
            d->wstate=kRvmUPD765StateIdle;
            d->led[drive]=0;
            return;
          }
          else
            readData(d);
        }
        
        if(!d->pt) return;
        
        if(d->status & kRM)
        {
          NSLog(@"Overrun %d",d->length);
          d->buffer[1]|=0x10;
          d->sstate=d->wstate=kWritingDataEnd;
        }
        
        //d->data=*d->pt;
        d->pt++;
        d->status=d->status | kRM;
        d->length--;
        d->delay=16*8;
      }
      return;
    }
      
    case kRvmUPD765StateFormat:
    {
      d->status=d->status | kRM;
      d->sstate=kRvmUPD765StateIdle;
      return;
    }
    
    case kRvmUPD765Seeking:
    {
      bool done=true;
      
      for(int i=0;i<3;i++)
      {
        if(d->dstatus[i] & 0x1) //seeking
        {
          done=false;
          
          //if(!(d->dstatus[i] & kDriveReady))
          if(!(d->dstatus[i] & kDriveReady) || !d->disks[i])
          {
            d->dstatus[i]=d->dstatus[i] & 0xfc;
            d->rstatus[0]=(d->rstatus[0] & 0x17) | 0x68;
            return;
          }
          
          if(d->dpc[i]!=d->pc[i])
          {
            d->delay=d->srt;
            
            uint ds=d->pc[i]+((d->dpc[i]>d->pc[i])?1:-1);
            NSLog(@"desired: %d",ds);
            if(d->disks[i]->chtrack(d->disks[i],ds))
              d->pc[i]=ds;
          }
          else
          {
            //Error recalibrating
            if((d->dstatus[i] & 0x2) && d->pc[i])
            {
              d->rstatus[0]=(d->rstatus[0] & 0x0f) | 0x70;
            }
            else
            {
              d->rstatus[0]=(d->rstatus[0] & 0x1f) | 0x20;
            }
            
            d->dstatus[i]=d->dstatus[i] & 0xfc;
            d->lastPCN=d->pc[i];
          }
        }
      }
      
      if(done)
      {
        d->irq=1;
        //[seek stop];
        NSLog(@"END SEEK");
        d->led[0]=d->led[1]=d->led[2]=d->led[3]=0;
        d->sstate=d->wstate=kRvmUPD765StateIdle;
      }
      return;
    }
      
      
  }
}

uint8 rvmUpd765In(rvmUpd765S* d,uint16 a)
{
  //NSLog(@"Reading from upd765 adress: %.4x",a);
  if(a)
  {
    switch(d->rstate)
    {
      case kRvmUPD765Result:
      {
        if(!--d->length)
        {
          d->status=(d->status & 0xf) | kRM;
          d->rstate=kRvmUPD765StateIdle;
        }
        
        return d->buffer[d->bIndex++];
      }
  
      case kReadingDataEnd:
      case kReadingData:
      case kReadingTrackData:
      {
        d->status&=0x7f;
        return d->data;
      }
        
      default:
        return 0xff;
    }
  }
  else //status register
  {
    return d->status;
  }
}

bool checkDrive(rvmUpd765S *d,uint drive)
{
  if(!d->disks[drive])
  {
    d->buffer[0]=(d->buffer[0] & 0x7) | 0x88;
    d->buffer[1]=0;
    d->buffer[2]=0;
    d->buffer[3]=0;
    d->buffer[4]=0;
    d->buffer[5]=0;
    d->buffer[6]=0;
    d->length=7;
    d->bIndex=0;
    d->status=(d->status & 0xf) | kIO | kBusy | kRM;
    d->rstate=kRvmUPD765Result;
    d->wstate=kRvmUPD765StateIdle;
    return NO;
  }
  
  return YES;
}

void rvmUpd765Out(rvmUpd765S *d,uint16 a,uint8 v)
{
  //NSLog(@"Writing to upd765 adress: %.4x,value:%.2x",a,v);
  if(a==0xffff) //motor
  {
    d->motorStatus=v;
    return;
  }
  
  if(a)
  {
    d->power=1;
    switch(d->wstate)
    {
      case kWritingData:
      case kWritingDataEnd:
      {
        d->status&=0x7f;
        *d->pt=v;
        return;
      }
        
      case kScanningData:
      case kScanningDataEnd:
      {
        d->status&=0x7f;
        if(v!=0xff & d->data!=0xff)
        {
          switch(d->command & 0x1f)
          {
            case kScan:
            {
              if(v!=d->data) //fail
              {
                d->rstatus[2]&=0xf7;
              }
              break;
            }
              
            case kScanLow:
            {
              if(v>d->data) //fail
              {
                d->rstatus[2]&=0xf7;
              }
              break;
            }
              
            case kScanHigh:
            {
              if(v<d->data) //fail
              {
                d->rstatus[2]&=0xf7;
              }
              break;
            }
          }
        }
        
        return;
      }
        
      case kRvmUPD765Seeking:
        if(!(v==0x7 || v==0xf || v==0x8))
          v=0x1F;
        
      case kRvmUPD765StateIdle:
      {
        d->command=v;
        d->bIndex=0;
        d->length=com[v & 0x1f];
        NSLog(@"Command: %.2x",v);
        if(d->command==0x8 && d->irq) //Sense
        {
          d->buffer[0]=d->rstatus[0];
          d->buffer[1]=d->lastPCN;
          NSLog(@"Sense: 0x%.2x 0x%.2x",d->buffer[0],d->buffer[1]);
          d->length=2;
          d->bIndex=0;
          d->rstatus[0]=0;
          d->status=(d->status & 0x0) | kRM | kIO | kBusy;
          d->irq=0;
          d->rstate=kRvmUPD765Result;
        }
        else
        {
          if(d->command==0x1f || (d->command==0x8 && !d->irq) || /*d->irq ||*/ (ecom[(d->command & 0x1f)] && (d->command & 0xe0))) //Invalid
          {
            d->buffer[0]=(d->rstatus[0] & 0x3f) | 0x80;
            d->rstatus[0]=0;
            d->length=1;
            d->bIndex=0;
            d->status=(d->status & 0xf) | kRM | kIO | kBusy;
            d->rstate=kRvmUPD765Result;
            return;
          }
          
          d->status=(d->status & 0xf) | kRM | kBusy;
          d->wstate=kRvmUPD765StateCommand;
        }
        return;
      }
      
      case kRvmUPD765StateCommand:
      {
        d->buffer[d->bIndex++]=v;
        if(!(--d->length)) //exec
        {
          switch(d->command & 0x1f)
          {
            case kReadDeleteData:
            case kReadData:
            {
              NSLog(@"Read data: %d:%d,%d,%d,%d",d->buffer[0],d->buffer[1],d->buffer[2],d->buffer[3],d->buffer[4]);
              readData(d);
              d->wstate=kRvmUPD765StateIdle;
              return;
            }
              
            case kScan:
            case kScanLow:
            case kScanHigh:
            {
              NSLog(@"Scan data: %d:%d,%d,%d,%d",d->buffer[0],d->buffer[1],d->buffer[2],d->buffer[3],d->buffer[4]);
              scanData(d);
              //d->wstate=kRvmUPD765StateIdle;
              return;
            }
              
            case kWriteDeleteData:
            case kWriteData:
            {
              NSLog(@"Write data: %d:%d,%d,%d,%d",d->buffer[0],d->buffer[1],d->buffer[2],d->buffer[3],d->buffer[4]);
              uint drive=d->buffer[0] & 0x3;
              
              
              if(d->disks[drive]->writeProtect)
              {
                d->wstate=kRvmUPD765StateIdle;
                d->rstate=kRvmUPD765Result;
                d->buffer[6]=d->buffer[3];
                d->buffer[5]=d->buffer[2]+1;
                d->buffer[4]=d->buffer[1];
                d->buffer[3]=d->buffer[0];
                d->buffer[0]=0x40 | drive;
                d->buffer[1]=0x2; //Write protected.
                d->buffer[2]=0;
                d->bIndex=0;
                d->length=7;
                d->status=(d->status & 0xf) | kIO | kBusy | kRM;
                return;
              }
              writeData(d);
              d->rstate=kRvmUPD765StateIdle;
              return;
            }
            
            case kReadID:
            {
              uint drive=d->buffer[0] & 0x3;
              uint side=(d->buffer[0] & 0x4) >>2;
              NSLog(@"Read id: %d",d->pc[drive]);
              //uint cyl=(d->disks[drive]->sidesN==2)?(d->pc[drive]<<1)+side:d->pc[drive];
              if(!checkDrive(d,drive)) return;
              
              rvmDskSectorInfoS *sector=d->disks[drive]->first(d->disks[drive],d->pc[drive],side);
              d->delay=(rand()/((double)RAND_MAX))*10000+500; //Access time
              if(sector) //OK
              {
                d->buffer[0]=d->buffer[0] & 0x7;
                d->buffer[1]=0;//sector->st1;
                d->buffer[2]=0;
                d->buffer[3]=sector->track;
                d->buffer[4]=sector->side;
                d->buffer[5]=sector->sID;
                d->buffer[6]=sector->sSize;
                d->length=7;
                d->bIndex=0;
                d->status=(d->status & 0xf) | kIO | kBusy | kRM;
              }
              else
              {
                d->buffer[0]=(d->buffer[0] & 0x7) | 0x40;
                d->buffer[1]=0x1;
                d->buffer[2]=0;
                d->buffer[3]=0;
                d->buffer[4]=0;
                d->buffer[5]=0;
                d->buffer[6]=0;
                d->length=7;
                d->bIndex=0;
                d->status=(d->status & 0xf) | kIO | kBusy | kRM;
              }
              d->rstate=kRvmUPD765Result;
              d->wstate=kRvmUPD765StateIdle;
              return;
            }
              
            case kSeek:
            {
              NSLog(@"Seek drive: %.2x track:%.2x",d->buffer[0] & 0x7,d->buffer[1]);
              uint8 drive=d->buffer[0] & 0x3;
              //Check if drive is ready
              d->dpc[drive]=d->buffer[1];
              d->status=(d->status & 0xf) | kRM  | (1<<drive);
              //[seek play];
              d->led[drive]=2;
              d->rstatus[0]=d->buffer[0]&0x7;
              d->sstate=d->wstate=kRvmUPD765Seeking;
              d->dstatus[drive]|=0x1;
              return;
            }
              
            case kRecalibrate:
            {
              uint8 drive=d->buffer[0] & 0x3;
              NSLog(@"Recalibrating drive: %.2x",drive);
              int dd=d->pc[drive]-77;
              d->dpc[drive]=(dd<0)?0:dd;
              d->status=(d->status & 0xf) | kRM | (1<<drive);
              //[seek play];
              d->led[drive]=2;
              d->rstatus[0]=d->buffer[0]&0x7;
              d->sstate=d->wstate=kRvmUPD765Seeking;
              d->dstatus[drive]|=0x3;
              return;
            }
              
            case kSpecify:
            {
              d->hut=hutT[d->buffer[0]&0xf];
              d->srt=srtT[(d->buffer[0]&0xf0)>>4];
              d->hlt=4000*(d->buffer[1]>>1);
              d->mode=d->buffer[1] & 0x1;
              d->status=(d->status & 0xf) | kRM;
              d->wstate=kRvmUPD765StateIdle;
              return;
            }
              
            case kSenseDrive:
            {
              uint drive=d->buffer[0] & 0x3;
              uint wp=(d->disks[drive]?(d->disks[drive]->writeProtect?0x40:0):(d->dstatus[drive]&0x40));
              
              d->buffer[0]=(d->dstatus[drive] & 0xa8) | (d->buffer[0] & 0x7) | ((d->pc[drive])?0:0x10) | wp | 0x8;
              d->length=1;
              d->bIndex=0;
              d->status=(d->status & 0xf) | kRM | kIO | kBusy;
              d->rstate=kRvmUPD765Result;
              d->wstate=kRvmUPD765StateIdle;
              return;
            }
              
            case kFormat:
            {
              uint drive=d->buffer[0] & 0x3;
              uint side=(d->buffer[0] & 0x4) >>2;
              
              if(d->disks[drive]->writeProtect)
              {
                d->wstate=kRvmUPD765StateIdle;
                d->rstate=kRvmUPD765Result;
                d->buffer[6]=d->buffer[3];
                d->buffer[5]=d->buffer[2]+1;
                d->buffer[4]=d->buffer[1];
                d->buffer[3]=d->buffer[0]+1;
                d->buffer[0]=0x40 | (d->buffer[0] & 0xf);
                d->buffer[1]=0x2; //Write protected.
                d->buffer[2]=0;
                d->bIndex=0;
                d->length=7;
                d->status=(d->status & 0xf) | kIO | kBusy | kRM;
                return;
              }
              
            
              d->formatingTrack=NULL;
              d->formatingTrack=d->disks[drive]->ftrack(d->disks[drive],d->pc[drive],side,d->buffer[1],d->buffer[2],d->buffer[3],d->buffer[4]);
              d->flength=d->buffer[2];
              d->fdrive=drive;
              d->findex=0;
              d->fside=side;
              d->length=4;
              d->bIndex=0;
              d->status=(d->status & 0xf) | kRM | kBusy |kExec;
              d->sstate=kRvmUPD765StateIdle;
              d->rstate=kRvmUPD765StateIdle;
              d->wstate=kRvmUPD765StateFormat;
              d->disks[drive]->dirty=0x40;
              return;
            }
              
            case kReadTrack:
            {
              NSLog(@"Read Track data: %d:%d,%d,%d,%d",d->buffer[0],d->buffer[1],d->buffer[2],d->buffer[3],d->buffer[4]);
              d->rtrackI=0;
              readTrack(d);
              d->wstate=kRvmUPD765StateIdle;
              return;
            }
              
            default:
            {
              NSLog(@"Unrecognized command.");
              d->buffer[0]=(d->rstatus[0] & 0x3f) | 0x80;
              d->rstatus[0]=0;
              d->length=1;
              d->bIndex=0;
              d->status=(d->status & 0xf) | kRM | kIO | kBusy;
              d->rstate=kRvmUPD765Result;
              return;
            }
          }
        }
        break;
      }
        
      case kRvmUPD765StateFormat:
      {
        d->buffer[d->bIndex++]=v;
        if(!(--d->length)) //exec
        {
          
          d->disks[d->fdrive]->fsector(d->disks[d->fdrive],d->formatingTrack,d->findex++,d->buffer[0],d->buffer[1],d->buffer[2],d->buffer[3]);
          if(d->findex==d->flength)
          {
            d->wstate=kRvmUPD765StateIdle;
            d->buffer[6]=d->buffer[3];
            d->buffer[5]=d->buffer[2];
            d->buffer[4]=d->buffer[1];
            d->buffer[3]=d->buffer[0]+1;
            d->buffer[0]=d->fdrive | (d->fside<<2);
            d->buffer[1]=0;
            d->buffer[2]=0;
            d->length=7;
            d->bIndex=0;
            d->status=(d->status & 0xf) | kIO | kBusy | kRM;
            d->rstate=kRvmUPD765Result;
          }
          else
          {
            d->length=4;
            d->bIndex=0;
            //d->findex=0;
            d->status=(d->status & 0xf) | kExec | kBusy;
            d->delay=(0x80<<d->buffer[3])*16*8;
            d->sstate=kRvmUPD765StateFormat;
          }
        }
      }
    }
  }
}

@implementation rvmUpd765

-(id)init
{
  self=[super init];
  if(self)
  {
    
    h.handle.in=(rvmDeviceIOInF)rvmUpd765In;
    h.handle.out=(rvmDeviceIOOutF)rvmUpd765Out;
    h.handle.step=(rvmDeviceStepF)rvmUpd765Step;
    
    self.handle=(rvmDeviceT*)&h;
    
    [self reset];
  }
  
  return self;
}


#define kVoid 0x0
#define kInsert 0x20
#define kTS 0x8

-(void)insertDisk:(rvmDskDecoder*)dsk inDrive:(uint)slot
{
  if(slot>=4)
  {
    //NSLog(@"Drive %d invalid!",slot);
    return;
  }
  
  if(disks[slot]!=dsk)
  {
    h.irq=1;
    h.rstatus[0]=0xc0 | slot | ((dsk)?0:0x8);
  }
  
  disks[slot]=dsk;
  if(dsk)
  {
    h.disks[slot]=[dsk handle];
    h.dstatus[slot]=(h.dstatus[slot]&0x40) | ((h.disks[slot]->sidesN>1)?(kInsert | kTS):kInsert);
  }
  else
  {
    h.disks[slot]=NULL;
    h.dstatus[slot]=(h.dstatus[slot]&0x40) |kVoid;
  }
}

-(void)enableDrive:(uint32)n
{
  h.dstatus[n]|=0x40; //kInsert|kTS;
}

-(void)disableDrive:(uint32)n
{
  h.dstatus[n]&=0xbf; // kVoid;
}

-(void)reset
{
  h.status=0x80;
  h.data=0;
  for(int i=0;i<8;i++) h.buffer[i]=0;
  for(int i=0;i<4;i++)
  {
    h.dpc[i]=h.pc[i];
    //h.dstatus[i]=h.rstatus[i]=0;
  }
  
  h.bIndex=0;
  h.lastPCN=0;
  h.length=0;
  h.delay=0;
  h.sstate=h.rstate=h.wstate=0;
  h.command=0;
  h.motorStatus=0;
  h.irq=0;
  h.power=0;
  h.irq=0;
  h.mode=1;
}

-(NSDictionary*)save {
  NSMutableDictionary *md=[NSMutableDictionary new];
  
  md[@"status"]=[NSNumber numberWithUnsignedChar:h.status];
  md[@"wstate"]=[NSNumber numberWithUnsignedInt:h.wstate];
  md[@"hut"]=[NSNumber numberWithUnsignedInt:h.hut];
  md[@"srt"]=[NSNumber numberWithUnsignedInt:h.srt];
  md[@"hlt"]=[NSNumber numberWithUnsignedInt:h.hlt];
  md[@"mode"]=[NSNumber numberWithUnsignedInt:h.mode];
  
  return md;
}

-(void)load:(NSDictionary*)snap {
  h.status=[snap[@"status"] unsignedCharValue];
  h.wstate=[snap[@"wstate"] unsignedIntValue];
  h.hut=[snap[@"hut"] unsignedIntValue];
  h.srt=[snap[@"srt"] unsignedIntValue];
  h.hlt=[snap[@"hlt"] unsignedIntValue];
  h.mode=[snap[@"mode"] unsignedIntValue];
}
@end
