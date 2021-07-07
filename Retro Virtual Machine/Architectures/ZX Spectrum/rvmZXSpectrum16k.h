//
//  rvmZXSpectrum16k.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 11/04/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "rvmZXSpectrum48k.h"

uint8 s16k_get(z80* z,uint16 a);
void s16k_set(z80 *z,uint16_t a,uint8_t v);

@interface rvmZXSpectrum16k : rvmZXSpectrum48k

@end
