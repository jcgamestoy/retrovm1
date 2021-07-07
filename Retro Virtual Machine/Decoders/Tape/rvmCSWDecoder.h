//
//  rvmCSWDecoder.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 4/11/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmPZXDecoder.h"

typedef struct __attribute__ ((__packed__))
{
  char sig[22];
  uint8 terminator;
  uint8 major;
  uint8 minor;
  uint32 sampleRate;
  uint32 total;
  uint8 compression;
  uint8 flags;
  uint8 hdr;
  char tool[16];
  uint8 data[];
}rvmCSWBlock2S;

typedef struct __attribute__ ((__packed__))
{
  char sig[22];
  uint8 terminator;
  uint8 major;
  uint8 minor;
  uint16 sampleRate;
  uint8 compression;
  uint8 flags;
  uint8 reserved[3];
  uint8 data[];
}rvmCSWBlock1S;

@interface rvmCSWDecoder : rvmPZXDecoder

+(NSData*)compressRLE:(rvmPulse*)pulses count:(uint32)c sample:(uint32)s total:(uint32*)tot;

@end
