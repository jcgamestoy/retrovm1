//
//  rvmSNADecoder.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 9/2/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "rvmMachineProtocol.h"
#import "rvmSnapshotDecoderProtocol.h"

//SNA Encoding
typedef struct __attribute__ ((__packed__))
{
  uint8 i;
  uint16 hlp,dep,bcp,afp;
  uint16 hl,de,bc,iy,ix;
  uint8 inte;
  uint8 r;
  uint16 af,sp;
  uint8 iMode;
  uint8 bColor;
}snaHeader;

typedef struct __attribute__ ((__packed__))
{
  uint16 pc;
  uint8 m7;
  uint8 trdos;
}snaHeader128k;

@interface rvmSNADecoder : NSObject<rvmSnapshotDecoderProtocol>

@end
