//
//  rvmZXSpectrum48k.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 11/04/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "rvmMachineProtocol.h"

#import "spectrum48k.h"
#import "rvmAudioMixer.h"
#import "rvmMachine.h"
#import "rvmPlus2DatacorderViewController.h"

@interface rvmZXSpectrum48k : rvmMachine
{
  spectrum *speccy;
  rvmAudioMixer *mixer;
  rvmPlus2DatacorderViewController *cassetteController;
}

-(spectrum*)spectrum;
-(void)initModel;
-(void)loadDefaultRom;
-(void)resetRam;
-(void)initPtr;

//-(void)loadSnapshot:(NSDictionary*)snap;
-(void)loadSpectrum:(NSDictionary*)s;
-(void)loadCpu:(NSDictionary*)cpu;
-(void)loadMemory:(NSDictionary*)m;
-(void)loadSoundChannels:(NSArray*)sound;

-(NSMutableDictionary*)snapshotMemory;
-(NSMutableDictionary*)snapshotCpu;
-(NSMutableDictionary*)snapshotSpectrum;
-(NSMutableArray*)snapshotSoundChannels;
-(NSMutableDictionary*)snapshotModel;

-(NSData*)frameSnapshot:(NSData*)memory border:(uint8)border;

-(void)deallocMemory;
@end
