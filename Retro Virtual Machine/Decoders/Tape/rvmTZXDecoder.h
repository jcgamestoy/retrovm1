//
//  rvmTZXDecoder.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 31/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "rvmPZXDecoder.h"

//#import "rvmTapeBlockProtocol.h"
//#import "rvmTapeDecoderProtocol.h"

//typedef struct
//{
//  rvmTapeDecoderStep step;
//  uint32 blockIndex;
//  uint64 currentT;
//  uint64 totalTStates;
//  uint32 numberOfBlocks;
//  void **blocks;
//  uint32 state;
//  uint8 *pointer,*last;
//  rvmTapeBlockProtocolS *block;
//}rvmTZXDecoderS;

typedef struct
{
  char sig[8];
  uint8 major;
  uint8 minor;
}rvmTZXHeader;

typedef struct
{
  uint16 pause;
  uint16 length;
  uint8 data[];
}rvmTZX10Block;

typedef struct __attribute__ ((__packed__))
{
  uint16 length;
  uint16 n;
}rvmTZX12Block;

typedef struct __attribute__ ((__packed__))
{
  uint16 l0;
  uint16 l1;
  uint8 ub;
  uint16 pause;
  uint8 length[3];
  uint8 data[];
}rvmTZX14Block;

typedef struct __attribute__ ((__packed__))
{
  uint8 flags;
  uint16 data[];
}rvmTZXSymdef;

typedef struct __attribute__ ((__packed__))
{
  uint8 sym;
  uint16 count;
}rvmTZXPRle;

typedef struct __attribute__ ((__packed__))
{
  uint32 length;
  uint16 pause;
  uint32 totp;
  uint8 npp;
  uint8 asp;
  uint32 totd;
  uint8 npd;
  uint8 asd;
  uint8 data[];
}rvmTZX19Block;

typedef struct
{
  uint8 tid;
  uint8 length;
  char str;
}rvmTZXText;

typedef struct
{
  uint16 length;
  uint8 n;
  rvmTZXText str;
}rvmTZX32Block;

typedef struct __attribute__ ((__packed__))
{
  uint16 pilotL;
  uint16 sync1;
  uint16 sync2;
  uint16 l0;
  uint16 l1;
  uint16 pilotC;
  uint8 usedBits;
  uint16 pause;
  uint8 length[3];
  uint8 data[];
}rvmTZX11Block;

typedef struct __attribute__ ((__packed__))
{
  uint16 T;
  uint16 pause;
  uint8 used;
  uint8 length[3];
  uint8 data[];
}rvmTZX15Block;

typedef struct __attribute__ ((__packed__))
{
  uint32 length;
  uint16 pause;
  uint8 sampling[3];
  uint8 compression;
  uint32 pulses;
  uint8 data[];
}rvmTZX18Block;

@interface rvmTZXDecoder : rvmPZXDecoder

@property uint8 major;
@property uint8 minor;

@end

@interface rvmDirectEncoder:NSObject
{

}

@property (nonatomic) double rate;
@property NSMutableData *data;

-(void)addPulse:(uint)T level:(uint)level;
-(void)finish;

@end
