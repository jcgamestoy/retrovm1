//
//  rvmPZXDecoder.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 14/10/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmTAPDecoder.h"

//#define FOURCC(n,k) const uint32 n=k;

//FOURCC(kPZXHeader, 'PZXT')
//FOURCC(kPZXPulses, 'PULS')
//FOURCC(kPZXData, 'DATA')
//FOURCC(kPZXPause, 'PAUS')
//FOURCC(kPZXBrowse, 'BRWS')
//FOURCC(kPZXStop, 'STOP')

#define kPZXHeader 'TXZP' //'PZXT'
#define kPZXPulses 'SLUP' //'PULS'
#define kPZXData   'ATAD' //'DATA'
#define kPZXPause  'SUAP' //'PAUS'
#define kPZXBrowse 'SWRB' //'BRWS'
#define kPZXStop   'POTS' //'STOP'

typedef struct __attribute__ ((__packed__))
{
  uint32 tag;
  uint32 size;
  uint8 data[];
}rvmPZXBlockS;

typedef struct __attribute__ ((__packed__))
{
  uint8 major;
  uint8 minor;
  uint8 info[];
}rvmPZXHeaderS;

//typedef struct __attribute__ ((__packed__))
//{
//  uint16 count;
//  uint16 pulses[];
//}rvmPZXPulsesS;

typedef struct __attribute__ ((__packed__))
{
  uint32 count;
  uint16 tail;
  uint8 p0;
  uint8 p1;
  uint8 data[];
}rvmPZXDataS;

typedef struct __attribute__ ((__packed__))
{
  uint32 duration;
}rvmPZXPausS;

//typedef struct __attribute__ ((__packed__))
//{
//  uint8 text[];
//}rvmPZXBrwsS;

typedef struct __attribute__ ((__packed__))
{
  uint16 flags;
}rvmPZXStopS;


@interface rvmPZXDecoder : rvmTAPDecoder

@end
