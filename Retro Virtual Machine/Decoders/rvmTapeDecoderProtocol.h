//
//  rvmTapeDecoder.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 19/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "rvmCassetteViewProtocol.h"

#define kRvmTapeDecoderBufferLength 4096*1024 //16Mb.

typedef uint (*rvmTapeDecoderStep)(void *data,uint *level);
typedef uint (*rvmTapeDecoderGo)(void *data,uint block);

typedef void (*rvmTapeDecoderStepRec)(void *data,uint level);

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
  uint32* recBuffer;
}rvmTapeDecoderProtocolS;

@protocol rvmTapeDecoderProtocol <NSObject>

//@property uint8_t level;
//@property uint32 count;

@property id<rvmCassetteViewProtocol> cassetteView;

-(void)load:(NSString*)path;
-(void)reset;
-(double)progress;
-(double)length;
-(void)go:(uint)index;

-(void)startRec;
-(void)endRec;
-(void)parseRec;

-(void)removeFromBlock:(uint)min to:(uint)max;
-(void)saveFile;

-(rvmTapeDecoderProtocolS*)decoder;

@property bool writeProtected;
@property NSString *path;
@property NSImage *image;

-(NSArray*)tapeBlocksDescription;
//-(void)step;

//-(uint)level;
//-(bool)isStoped;

@end
