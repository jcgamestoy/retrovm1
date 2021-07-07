//
//  rvmMainVoew.h
//  rvmSpectrum
//
//  Created by Juan Carlos González Amestoy on 03/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <OpenGL/gl.h>
#include <sys/time.h>
#import "rvmMachineProtocol.h"
//#import "rvmMonitorWindowController.h"
#import "rvmTripleBuffer.h"
#import "rvmGLTexture.h"

//double getTimeUs();

@interface rvmMainView : NSOpenGLView

//@property rvmGLTexture *texture;
@property (weak,nonatomic) id<rvmMachineProtocol> machine;

@property double saturation;
@property double contrast;
@property double brightness;
@property double scanlines;
@property double noise;
@property double offset;
@property double interlaced;
@property double ghostOffset;
@property double ghostIntensity;
@property double ghostAngle;
@property double blur;
@property double curvature;
@property double vignette;
@property double vignetteRnd;
@property double beamI;
@property double beamSpeed;

@property (nonatomic) double overscan;
@property (nonatomic) double overscanV;
@property (nonatomic) double overscanH;

-(void)render;
-(void)initGL;
-(void)renderGPU;
-(void)addFPS;

-(void)run:(bool)r;
-(void)reset;
-(void)stop;

@end
