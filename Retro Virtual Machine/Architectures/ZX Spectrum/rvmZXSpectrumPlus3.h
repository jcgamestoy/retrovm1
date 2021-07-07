//
//  rvmZXSpectrumPlus3.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 06/07/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmZxSpectrumPlus2A.h"

#import "spectrumPlus3.h"
#import "rvmPlus3FddViewController.h"

@interface rvmZXSpectrumPlus3 : rvmZxSpectrumPlus2A
{
  spectrumPlus3 *speccy3;
  rvmPlus3FddViewController *fddController;
}
@end
