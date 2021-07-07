//
//  rvmZxSpectrumPlus2A.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 09/05/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmZXSpectrum128k.h"

#import "spectrum48k.h"
#import "spectrumPlus2A.h"
//typedef struct {
//  uint8 memory;
//  void *extension;
//}spectrum2A;

@interface rvmZxSpectrumPlus2A : rvmZXSpectrum128k
{
  spectrumPlus2A *speccy2A;
}

@end
