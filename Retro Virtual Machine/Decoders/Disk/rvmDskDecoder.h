//
//  rvmDskDecoder.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 29/06/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kRvmDSKFormat  0
#define kRvmEDSKFormat 1

typedef uint8* (*rvmDskSeek)(void *disk,uint8 side,uint8 track,uint8 sideId,uint8 trackId,uint8 sectorId,uint8 sizereq,void **sector);
typedef void* (*rvmDskFirstSector)(void *disk,uint8 track,uint8 side);

typedef void* (*rvmDskFormatTrack)(void *disk,uint8 track,uint8 side,uint8 n,uint sc,uint8 gap3,uint8 fill);

typedef void (*rvmDskFormatSector)(void *disk,void *track,uint i,uint8 c,uint8 h,uint8 r,uint8 n);
typedef bool (*rvmDskCheckTrack)(void *disk,uint cyl);


typedef struct
{
  uint8 track;
  uint8 side;
  uint8 sID;
  uint8 sSize;
  uint8 st1;
  uint8 st2;
  uint16 rsize;
  uint8 *data;
}rvmDskSectorInfoS;

typedef struct
{
  char sig[0x10];
  uint8 trackN;
  uint8 sideN;
  uint16 unused1;
  uint8 sectorSize;
  uint8 nsector;
  uint8 gap3;
  uint8 filler;
  //rvmDskSectorInfoS sectorList[1];
  rvmDskSectorInfoS **sectors;
}rvmDskTrackS;

typedef struct
{
  uint8 tracksN;
  uint8 sidesN;
  uint16 sizeOfTrack;
  
  rvmDskTrackS **tracks;
  
  rvmDskSeek seek;
  rvmDskFirstSector first;
  rvmDskFormatTrack ftrack;
  rvmDskFormatSector fsector;
  rvmDskCheckTrack chtrack;
  
  uint type;
  bool writeProtect;
  uint8 dirty;
}rvmDskS;

typedef struct __attribute__ ((__packed__)) {
  uint8 user; //1
  char name[8]; //9
  char ext[3]; //12
  uint8 extend; //13
  uint16 reserved1; //15
  uint8 recordCount; //16
  uint8 blocks[0x10]; //32
}rvmDskDirectoryS;

typedef struct __attribute__ ((__packed__)) {
  uint8 formatNumber;
  uint8 sideness;
  uint8 tracks;
  uint8 sectors;
  uint8 psh;
  uint8 reservedTracks;
  uint8 bsh;
  uint8 nDirBlocks;
  uint8 rgap;
  uint8 fgap;
}rvmDskDiskID;

@interface rvmDskDecoder : NSObject
{
  @public
  rvmDskS disk;
  NSString *path;
}

+(rvmDskDecoder*)loadDisk:(NSString*)path;
+(rvmDskDecoder*)new40Track:(NSString*)path;
+(rvmDskDecoder*)new80Track:(NSString*)path;

@property NSMutableArray *dirEntries;

-(void)saveEDsk;

-(void)formatStandard;
-(void)formatCpcSystem;
-(void)formatCpcData;
-(void)formatIbm;
-(void)formatXCf2;
-(void)formatStandard80;
-(void)formatXCf2dd;

-(rvmDskS*)handle;

@end
