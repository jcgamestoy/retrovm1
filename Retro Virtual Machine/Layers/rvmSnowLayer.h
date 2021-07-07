//
//  rvmSnowLayer.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 18/02/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "rvmMachineProtocol.h"

@interface rvmSnowLayer : CAOpenGLLayer

@property id<rvmMachineProtocol> machine;

+(rvmSnowLayer*)snowLayer;

@end
