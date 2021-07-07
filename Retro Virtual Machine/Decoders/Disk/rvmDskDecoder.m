//
//  rvmDskDecoder.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 29/06/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmDskDecoder.h"

@interface rvmDskDecoder()
{
}

@end

static int counter;

rvmDskSectorInfoS* firstSector(rvmDskS *disk,uint8 track,uint8 side)
{
  uint cyl=(disk->sidesN==1)?track:((track<<1)+side);
  uint mt=disk->tracksN*disk->sidesN;
  
  if(cyl>mt) return NULL;
  
  rvmDskTrackS *tr=disk->tracks[cyl];
  if(!tr) return NULL;
  rvmDskSectorInfoS *si=tr->sectors[0];

  return si;
}

bool checkTrack(rvmDskS *disk,uint cyl)
{
  cyl=disk->sidesN==1?cyl:cyl<<1;
  uint mt=disk->tracksN*disk->sidesN;
  
  return cyl<mt;
}

uint8 *seekEDsk(rvmDskS *disk,uint8 side,uint8 track,uint8 sideId,uint8 trackId,uint8 sectorId,uint8 sizereq,rvmDskSectorInfoS **sector)
{
  uint cyl=(disk->sidesN==1)?track:((track<<1)+side);
  uint mt=disk->tracksN*disk->sidesN-1;
  
  if(cyl>mt) return NULL;
  
  rvmDskTrackS *tr=disk->tracks[cyl];
  if(!tr) return NULL;
  rvmDskSectorInfoS **si=tr->sectors;
  //uint8 *pt=(uint8*)tr+0x100;
  
  //uint ss=0x80<<tr->sectorSize;
  
  for(int i=0;i<tr->nsector;i++)
  {
    if(si[i]->track==trackId && si[i]->side==sideId && si[i]->sID==sectorId && sizereq<=si[i]->sSize)
    {
       *sector=si[i];
        uint ss=0x80<<si[i]->sSize;
        if(si[i]->rsize>ss && (si[i]->rsize % ss)==0)
        {
          uint d=si[i]->rsize/ss;
          d=(counter++ % d);
          //return pt+ss*d;
          return &si[i]->data[ss*d];
          
        }
        else if(si[i]->st1==si[i]->st2 && si[i]->st2==0x20 && ss==si[i]->rsize)
        {
          si[i]->data[ss-1]--;
        }
        return si[i]->data;
      //}
    }
    
    
  }
  
  return NULL;
}

rvmDskTrackS *formatTrack(rvmDskS *disk,uint8 track,uint8 side,uint8 n,uint sc,uint8 gap3,uint8 fill)
{
  uint cyl=(disk->sidesN==1)?track:((track<<1)+side);
  uint mt=disk->tracksN*disk->sidesN;
  
  if(cyl>=mt) return NULL; //From now not ampliate the disk.
  
  rvmDskTrackS *tr=disk->tracks[cyl];
  
  if(tr) //Free the track
  {
    for(int i=0;i<tr->nsector;i++)
    {
      free(tr->sectors[i]->data);
      free(tr->sectors[i]);
    }
    
    free(tr);
  }
  
  tr=disk->tracks[cyl]=calloc(1, sizeof(rvmDskTrackS));
  
  //Signatures empty.
  tr->trackN=track;
  tr->sideN=side;
  tr->sectorSize=n;
  tr->nsector=sc;
  tr->gap3=gap3;
  tr->filler=fill;
  
  tr->sectors=calloc(sc, sizeof(rvmDskSectorInfoS*));
  
  return tr;
}

void formatSector(rvmDskS *disk,rvmDskTrackS *track,uint i,uint8 c,uint8 h,uint8 r,uint8 n)
{
  rvmDskSectorInfoS *sec=track->sectors[i]=calloc(1, sizeof(rvmDskSectorInfoS));
  
  sec->sID=r;
  sec->side=h;
  sec->track=c;
  sec->rsize=0x80<<n;
  sec->sSize=n;
  
  sec->data=malloc(sec->rsize);
  
  memset(sec->data, track->filler, sec->rsize);
}


@implementation rvmDskDecoder

+(rvmDskDecoder*)loadDisk:(NSString*)path
{
  rvmDskDecoder *s=[rvmDskDecoder new];
  
  NSFileManager *fm=[NSFileManager defaultManager];
  
  s->path=path;
  NSData *dsk=[fm contentsAtPath:path];

  [s parseFile:dsk];
  //s->disk.seek=(rvmDskSeek)seekDsk;
  s->disk.first=(rvmDskFirstSector)firstSector;
  s->disk.fsector=(rvmDskFormatSector)formatSector;
  s->disk.ftrack=(rvmDskFormatTrack)formatTrack;
  s->disk.chtrack=(rvmDskCheckTrack)checkTrack;
  
  s->disk.writeProtect=YES;
  return s;
}

+(rvmDskDecoder*)new40Track:(NSString*)path
{
  rvmDskDecoder *d=[rvmDskDecoder new];
  
  d->path=path;
  
  d.handle->tracksN=44;
  d.handle->sidesN=1;
  d.handle->tracks=calloc(44, sizeof(rvmDskTrackS*));
  
  d->disk.first=(rvmDskFirstSector)firstSector;
  d->disk.fsector=(rvmDskFormatSector)formatSector;
  d->disk.ftrack=(rvmDskFormatTrack)formatTrack;
  d->disk.chtrack=(rvmDskCheckTrack)checkTrack;
  d->disk.type=kRvmEDSKFormat;
  d->disk.seek=(rvmDskSeek)seekEDsk;
  
  [d saveEDsk];
  
  return d;
}

+(rvmDskDecoder*)new80Track:(NSString*)path
{
  rvmDskDecoder *d=[rvmDskDecoder new];
  
  d->path=path;
  
  d.handle->tracksN=84;
  d.handle->sidesN=2;
  d.handle->tracks=calloc(168, sizeof(rvmDskTrackS*));
  
  d->disk.first=(rvmDskFirstSector)firstSector;
  d->disk.fsector=(rvmDskFormatSector)formatSector;
  d->disk.ftrack=(rvmDskFormatTrack)formatTrack;
  d->disk.chtrack=(rvmDskCheckTrack)checkTrack;
  d->disk.type=kRvmEDSKFormat;
  d->disk.seek=(rvmDskSeek)seekEDsk;
  
  [d saveEDsk];
  
  return d;
}

-(void)formatStandard
{
  uint inc=disk.sidesN==1?1:2;
  
  for(int i=0;i<40*inc;i+=inc)
  {
    disk.ftrack(&disk,i/inc,0,2,9,0x2a,0xe5);
    
    for(int j=0;j<9;j++)
    {
      disk.fsector(&disk,disk.tracks[i],j,i/inc,0,1+j,2);
    }
  }
  
  [self saveEDsk];
}

-(void)formatCpcSystem
{
  uint inc=disk.sidesN==1?1:2;
  
  for(int i=0;i<40*inc;i+=inc)
  {
    disk.ftrack(&disk,i/inc,0,2,9,0x2a,0xe5);
    
    for(int j=0;j<9;j++)
    {
      disk.fsector(&disk,disk.tracks[i],j,i/inc,0,0x41+j,2);
    }
  }
  
  [self saveEDsk];
}

-(void)formatCpcData
{
  uint inc=disk.sidesN==1?1:2;
  
  for(int i=0;i<40*inc;i+=inc)
  {
    disk.ftrack(&disk,i/inc,0,2,9,0x2a,0xe5);
    
    for(int j=0;j<9;j++)
    {
      disk.fsector(&disk,disk.tracks[i],j,i/inc,0,0xc1+j,2);
    }
  }
  
  [self saveEDsk];
}

-(void)formatIbm
{
  uint inc=disk.sidesN==1?1:2;
  
  for(int i=0;i<40*inc;i+=inc)
  {
    disk.ftrack(&disk,i/inc,0,2,8,0x2a,0xe5);
    
    for(int j=0;j<8;j++)
    {
      disk.fsector(&disk,disk.tracks[i],j,i/inc,0,1+j,2);
    }
  }
  
  const uint8 sig[]={0x3,0x80,0x28,0x08,0x02,0x01,0x03,0x02,0x2a,0x50};
  memcpy(disk.tracks[0]->sectors[0]->data, sig, 10);
  
  [self saveEDsk];
}

-(void)formatXCf2
{
  uint inc=disk.sidesN==1?1:2;
  
  for(int i=0;i<40*inc;i+=inc)
  {
    disk.ftrack(&disk,i/inc,0,2,10,0x2a,0xe5);
    
    for(int j=0;j<10;j++)
    {
      disk.fsector(&disk,disk.tracks[i],j,i/inc,0,1+j,2);
    }
  }
  
  const uint8 sig[]={0x3,0x80,0x28,0x0a,0x02,0x01,0x3,0x03,0x0c,0x17};
  memcpy(disk.tracks[0]->sectors[0]->data, sig, 10);
  
  [self saveEDsk];
}

-(void)formatStandard80
{
  for(int i=0;i<160;i++)
  {
    disk.ftrack(&disk,i>>1,i&0x1,2,9,0x2a,0xe5);
    
    for(int j=0;j<9;j++)
    {
      disk.fsector(&disk,disk.tracks[i],j,i>>1,i&0x1,1+j,2);
    }
  }
  
  const uint8 sig[]={0x3,0x81,0x50,0x09,0x02,0x01,0x4,0x04,0x2a,0x52};
  memcpy(disk.tracks[0]->sectors[0]->data, sig, 10);
  
  [self saveEDsk];
}

-(void)formatXCf2dd
{
  for(int i=0;i<160;i++)
  {
    disk.ftrack(&disk,i>>1,i&0x1,2,10,0x2a,0xe5);
    
    for(int j=0;j<10;j++)
    {
      disk.fsector(&disk,disk.tracks[i],j,i>>1,i&0x1,1+j,2);
    }
  }
  
  const uint8 sig[]={0x3,0x81,0x50,0x0a,0x02,0x01,0x5,0x02,0x0c,0x17};
  memcpy(disk.tracks[0]->sectors[0]->data, sig, 10);
  
  [self saveEDsk];
}

-(uint8)measureTrack:(rvmDskTrackS*)t
{
  if(!t) return 0;
  uint s=0x100;
  
  for(int i=0;i<t->nsector;i++)
  {
    s+=t->sectors[i]->rsize;
  }
  
  if(s & 0xff)
  {
    s+=0x100;
  }
  
  return (s & 0xff00)>>8;
}

static uint8 zeroReg[0x100];

-(void)saveTrack:(rvmDskTrackS*)track data:(NSMutableData*)data
{
  if(!track) return;
  
  uint8 header[0x100];
  
  memset(header, 0, 0x100);
  memcpy(header, "Track-Info\r\n", 12);
  
  uint8 *pt=&header[0x10];
  *pt++=track->trackN;
  *pt++=track->sideN;
  pt+=2;
  *pt++=track->sectorSize;
  *pt++=track->nsector;
  *pt++=track->gap3;
  *pt++=track->filler;
  
  for(int i=0;i<track->nsector;i++)
  {
    memcpy(pt, track->sectors[i], 0x8);
    pt+=8;
  }
  
  [data appendBytes:header length:0x100];
  
  uint ss=0;
  for(int i=0;i<track->nsector;i++)
  {
    ss+=track->sectors[i]->rsize;
    [data appendBytes:track->sectors[i]->data length:track->sectors[i]->rsize];
  }
  
  if(ss & 0xff) //fill bytes
  {
    uint fb=0x100 - (ss & 0xff);
    [data appendBytes:zeroReg length:fb];
  }
}

-(void)saveEDsk
{
  NSMutableData *data=[NSMutableData new];
  
  uint8 header[0x100];
  
  memcpy(header, "EXTENDED CPC DSK File\r\nDisk-Info\r\n", 34);
  
  uint8 *pt=&header[0x22];
  memcpy(pt, "RVM              ", 14);
  pt=&header[0x30];
  *pt++=self.handle->tracksN;
  *pt++=self.handle->sidesN;
  pt+=2;
  
  uint cyl=self.handle->sidesN==2?(self.handle->tracksN<<1):self.handle->tracksN;
  for(int i=0;i<cyl;i++)
  {
    *pt++=[self measureTrack:self.handle->tracks[i]];
  }
  
  [data appendBytes:header length:0x100];
  
  for(int i=0;i<cyl;i++)
  {
    [self saveTrack:self.handle->tracks[i] data:data];
  }
  
  [data writeToFile:path atomically:YES];
  
  [self parseDirectory];
}

-(uint)computeSize:(rvmDskDirectoryS*)dir add:(uint)add sizeblock:(uint8)sb increment:(uint*)inc
{
  if(sb==1)
  {
    uint i=0,j=0;
    do
    {
      uint8 *pt=dir->blocks;
      for(j=0;j<16 && *pt;j++,i++,pt++);
      if(j==16)
      {
        dir++;
        (*inc)++;
      }
    }while(j==16);
    
    return i;
  }
  else
  {
    uint i=0,j=0;
    do
    {
      uint16 *pt=(uint16*)dir->blocks;
      for(j=0;j<8 && *pt;j++,i++,pt++);
      if(j==8) {
        dir++;
        (*inc)++;
      }
    }while(j==8);
    
    return i;
  }
}

-(uint)extractDirectory:(uint)track head:(uint8)head sectors:(uint)sectors first:(uint8)first sizeBlock:(uint8)sb widthBlock:(uint8)wb
{
  rvmDskSectorInfoS *sec=NULL;
  
  rvmDskDirectoryS *dir=malloc(sizeof(rvmDskDirectoryS)*(0x10*sectors));
  
  for(int i=0;i<sectors;i++,first++)
  {
    sec=NULL;
    disk.seek(&disk,head,track,head,track,first,0,(void**)&sec);
    if(!sec)
    {
      free(dir);
      return 0;
    }
    memcpy(&dir[0x10*i], sec->data, 0x200);
  }

  uint tsize=0;
  
  for(int i=0;i<(0x10*sectors);i++)
  {
    if(dir[i].user<0x10)
    {
      NSString *name=[[[NSString alloc] initWithBytes:dir[i].name length:8 encoding:NSASCIIStringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      NSString *ext=[[[NSString alloc] initWithBytes:dir[i].ext length:3 encoding:NSASCIIStringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      
      NSString *filename=(ext.length)?[NSString stringWithFormat:@"%@.%@",name,ext]:name;
      
      if(dir[i].user)
        filename=[NSString stringWithFormat:@"%d:%@",dir[i].user,filename];
      
      uint inc=0;
      uint size=[self computeSize:&dir[i] add:0 sizeblock:wb increment:&inc]*sb;
      tsize+=size;
      
      i+=inc;
      [_dirEntries addObject:@{@"Filename":filename,@"User":[NSNumber numberWithUnsignedInt:dir[i].user],@"Size":[NSNumber numberWithUnsignedInt:size]}];
    }
//    else
//    {
//      if(dir[i].user!=0xe5)
//      {
//        uint old=[_dirEntries.lastObject[@"Size"] unsignedIntegerValue];
//        old=[self computeSize:&dir[i] add:old sizeblock:sb];
//        _dirEntries.lastObject[@"Size"]=[NSNumber numberWithInt:old];
//      }
//    }
  }
  
  free(dir);
  return tsize;
}

-(void)addTotalSize:(uint)size maxSize:(uint)msize;
{
  if(!msize) return;
  
  if(size>msize)
  {
    [_dirEntries removeAllObjects];
    return;
  }
  
  [_dirEntries addObject:@{@"User":@0,@"Filename":@"-----------"}];
  [_dirEntries addObject:@{@"User":@0,@"Filename":@"Total size:",@"Size":[NSNumber numberWithUnsignedInteger:size]}];
  [_dirEntries addObject:@{@"User":@0,@"Filename":@"Free:",@"Size":[NSNumber numberWithUnsignedInteger:msize-size]}];
}

-(void)parseDirectory
{
  if(!disk.tracks[0]) return;
  
  rvmDskSectorInfoS *sec=disk.tracks[0]->sectors[0];
  _dirEntries=[NSMutableArray array];
  
  uint size=0,msize=0;
  
  switch(sec->sID)
  {
    case 0x41: //CPC System
    {
      size=[self extractDirectory:2 head:0 sectors:4 first:0x41 sizeBlock:1 widthBlock:1];
      msize=169;
      break;
    }
      
    case 0xc1: //CPC Data
    {
      size=[self extractDirectory:0 head:0 sectors:4 first:0xc1 sizeBlock:1 widthBlock:1];
      msize=178;
      break;
    }
      
    case 0x1:
    {
      rvmDskSectorInfoS *sec=disk.tracks[0]->sectors[0];
      uint8 *pt=sec->data;
      
      bool same=true;
      for(int i=0;i<0x10;i++)
      {
        if(pt[i]!=pt[0]) same=false;
      }
      
      if(same)
      {
        size=[self extractDirectory:1 head:0 sectors:4 first:0x1 sizeBlock:1 widthBlock:1];
        msize=173;
      }
      else
      {
        rvmDskDiskID *did=(rvmDskDiskID*)pt;
        
        if(did->formatNumber!=0 && did->formatNumber!=3)
        {
          return;
        }
        
        //uint ssize=0x80<<did->psh;
        uint sectorsBlock=(0x1<<(did->bsh-did->psh));
        uint sectorsD=sectorsBlock*did->nDirBlocks;
        
        uint ns=(did->tracks*did->sectors)<<(did->sideness&0x1);
        uint nb=ns/sectorsBlock;
        
        uint t=(did->sideness&0x1)?did->reservedTracks>>1:did->reservedTracks;
        uint h=(did->sideness&0x1)?did->reservedTracks&0x1:0;
        
        uint nbf=(((did->tracks<<(did->sideness&0x1))-did->reservedTracks)*did->sectors)/sectorsBlock;
        nbf-=did->nDirBlocks;
        
        msize=nbf*(0x1<<(did->bsh-3));
        
        while(sectorsD)
        {
          uint d=(sectorsD>did->sectors)?did->sectors:sectorsD;
          size+=[self extractDirectory:t head:h sectors:d first:1 sizeBlock:(0x1<<(did->bsh-3)) widthBlock:(nb>0xff)?2:1];
          sectorsD-=d;
          if(sectorsD)
          {
            if(did->sideness&0x1)
            {
              h=(h)?0:1;
              if(!h)
              {
                t++;
              }
            }
            else
            {
              t++;
            }
          }
        }
      }
      break;
    }
  }
  
  [self addTotalSize:size maxSize:msize];
}

-(void)parseFile:(NSData*)data
{
  uint8 *pt=(uint8*)data.bytes;
  
  disk.type=kRvmDSKFormat;
  if(memcmp(pt, "MV - CPC", 8))
  {
    if(memcmp(pt, "EXTENDED CPC DSK File\r\nDisk-Info\r\n",34))
    {
      NSLog(@"Not a dsk file");
      return;
    }
    else
      disk.type=kRvmEDSKFormat;
  }
  
  disk.tracksN=pt[0x30];
  disk.sidesN=pt[0x31];
  disk.sizeOfTrack=*((uint16*)&pt[0x32]);
  
  
  uint tn=disk.tracksN*disk.sidesN;
  disk.tracks=(rvmDskTrackS**)calloc(sizeof(rvmDskTrackS*),tn);
  
  uint8 *ti=pt+0x34;
  pt+=0x100;
  
  switch(disk.type)
  {
    case kRvmDSKFormat:
    {
      for(int i=0;i<tn;i++)
      {
        disk.tracks[i]=malloc(disk.sizeOfTrack);
        memcpy(disk.tracks[i], pt, 0x18);

        uint n=disk.tracks[i]->nsector;
        disk.tracks[i]->sectors=malloc(sizeof(rvmDskSectorInfoS*)*n);
        uint8 *dpt=pt+0x100;
        uint8 *spt=pt+0x18; //Inicio de los sectores.
        
        for(int j=0;j<n;j++)
        {
          disk.tracks[i]->sectors[j]=malloc(sizeof(rvmDskSectorInfoS));
          rvmDskSectorInfoS *sec=disk.tracks[i]->sectors[j];
          memcpy(sec, spt, 0x8);
          uint size=0x80<<sec->sSize;
          sec->rsize=size;
          sec->data=malloc(size);
          memcpy(sec->data, dpt, size);
          dpt+=size;
          spt+=0x8;
        }
        
        pt+=disk.sizeOfTrack;
      }
      disk.seek=(rvmDskSeek)seekEDsk;
      break;
    }
      
    case kRvmEDSKFormat:
    {
      for(int i=0;i<tn;i++)
      {
        if(*ti)
        {
          //uint s=1<<(*ti+7);
          uint s=*ti<<8;
          disk.tracks[i]=malloc(s);
          memcpy(disk.tracks[i], pt, 0x18);
          uint8 *dpt=pt+0x100;
          uint8 *spt=pt+0x18;
          
          uint n=disk.tracks[i]->nsector;
          disk.tracks[i]->sectors=malloc(sizeof(rvmDskSectorInfoS*)*n);
          for(uint j=0;j<n;j++)
          {
            disk.tracks[i]->sectors[j]=malloc(sizeof(rvmDskSectorInfoS));
            rvmDskSectorInfoS *sec=disk.tracks[i]->sectors[j];
            memcpy(sec, spt, 0x8);
            //uint size=0x80<<sec->sSize;
            //size=size>=sec->rsize?size:sec->rsize;
            sec->data=calloc(1, sec->rsize);
            memcpy(sec->data, dpt, sec->rsize);
            dpt+=sec->rsize;
            spt+=0x8;
          }
          
          pt+=s;
          
        }
        else
          disk.tracks[i]=NULL;
        ti++;
      }
      disk.seek=(rvmDskSeek)seekEDsk;
      break;
    }
  }
  
  [self parseDirectory];
}

-(rvmDskS*)handle
{
  return &disk;
}

-(void)dealloc
{
  NSLog(@"Disc dealloc");
  uint t=disk.tracksN*disk.sidesN;
  
  for(int i=0;i<t;i++)
  {
    if(disk.tracks[i])
    {
      for(int j=0;j<disk.tracks[i]->nsector;j++)
      {
        free(disk.tracks[i]->sectors[j]->data);
        free(disk.tracks[i]->sectors[j]);
      }
      
      free(disk.tracks[i]);
    }
  }
  
  free(disk.tracks);
}

@end
