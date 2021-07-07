//
//  rvmZXSpectrum128k.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 11/04/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "rvmZXSpectrum48k.h"

#import "spectrum128k.h"
//typedef struct {
//  uint8 f128; //last 0x7ffd
//  uint8 aySelect;
//  rvmAY3819XT *ay;
//  void* extension;
//}spectrum128;
//
//uint32* step128k(spectrum *speccy,bool fast,uint32* buffer);
//void init128k();
//void s128k_out(z80* z,uint16 a,uint8 v);
//uint8 s128k_in(z80* z,uint16 a);
//uint8 s128k_AYin(rvmAY3819XT *h,uint16 a);
//uint32 s128k_cont4T(uint32 l,uint32_t t);
//uint32 s128k_contention(z80 *z,uint16 a);
//uint32 s128k_contentionIO(z80 *z,uint16 a);
//uint32 floatingBus128k(z80 * z);

@interface rvmZXSpectrum128k : rvmZXSpectrum48k
{
  spectrum128 *speccy128;
}

-(void)resetRamBanks;
@end
