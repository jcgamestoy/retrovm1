//
//  rvmShaderLayer.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 22/4/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "rvmGLProgram.h"

@interface rvmShaderLayer : CAOpenGLLayer

@property rvmGLProgram *program;
+(rvmShaderLayer*)shaderLayer;

@end
