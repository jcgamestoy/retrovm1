//
//  rvmUpd765.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 29/06/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmDevice.h"
#import "rvmDskDecoder.h"

typedef struct
{
  rvmDeviceT handle;
  rvmDskS *disks[4]; //Four drives.
  
  uint8 status;     //Status register
  uint8 data;       //Data register
  uint8 buffer[8]; //Command buffer
  uint8 pc[4];      //Cylinder position.
  uint8 dpc[4];     //Desired cylinder.
  
  uint headUnload[4];
  bool headBlock[4];
  
  uint8 dstatus[4]; //Drive Status
  uint8 rstatus[4]; //Status registers
  uint8 bIndex;
  uint8 lastPCN;
  
  uint8 *pt;        //Data pointer
  uint32 length;  //Data to read / write
  rvmDskTrackS *formatingTrack;
  uint32 flength;
  uint32 fdrive;
  uint32 findex;
  uint32 fside;
  uint32 rtrackI;
  
  uint32 idleTicks;
  uint32 delay;
  
  uint32 rstate,wstate,sstate;
  uint8 command;
  
  //Timing all in ticks
  uint hut; //Head unload time
  uint srt; //Step rate time
  uint hlt; //Head load time
  uint mode;
  
  //uint headState;
  uint next;
  
  uint8 motorStatus;
  
  uint8 led[4];
  uint8 irq; //Not used in Plus3 / CPC
  uint32 power;
}rvmUpd765S;

@interface rvmUpd765 : rvmDevice
{
  @public   rvmDskDecoder *disks[4];
}

-(void)insertDisk:(rvmDskDecoder*)dsk inDrive:(uint)slot;
-(void)enableDrive:(uint32)drive;
-(void)disableDrive:(uint32)drive;
-(NSDictionary*)save;
-(void)load:(NSDictionary*)snap;

@end
