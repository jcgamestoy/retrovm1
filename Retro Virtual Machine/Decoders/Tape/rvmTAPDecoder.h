//
//  rvmTAPDecoder.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 19/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "rvmTapeDecoderProtocol.h"
#import "rvmTapeBlocks.h"

typedef struct
{
  rvmTapeDecoderStep step;
  rvmTapeDecoderGo go;
  rvmTapeDecoderStepRec stepRec;
  uint32 blockIndex;
  uint64 currentT;
  uint64 totalTStates;
  uint32 numberOfBlocks;
  void **blocks;
  //char *blockName;
  bool running,recording;
  uint32 recLevel,recCount,recIndex;
  uint32 *recBuffer;
  //uint8 *pointer,*last;
  rvmDataBlockS block;
}rvmTAPDecoderS;

@interface rvmTAPDecoder : NSObject<rvmTapeDecoderProtocol>
{
  NSData *tap;
  rvmTAPDecoderS decoder;
}

extern uint16 s0[],s1[];
extern rvmPulse pilot[],pilotShort[];

-(void)parseFile;
-(void)saveFile;
-(NSArray*)tapeBlocksDescription;
-(NSMutableArray *)groupBlocks:(NSMutableArray *)r;
-(NSString*)standardBlockName:(uint8*)pt index:(uint32)ii;

-(void)addPulsesBlock:(rvmPulse*)pulses count:(uint32)c;
-(void)addStandardBlock:(NSData*)data pilotCount:(uint32)c bits:(uint32)bits;
-(void)insertBlock:(void*)block index:(uint)i;

-(void)extractBlocks:(rvmPulse*)pulses count:(uint32)c;

@end
