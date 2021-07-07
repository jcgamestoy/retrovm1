//
//  rvmVideoViewController.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 14/04/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "rvmTransitionViewController.h"
#import "rvmMainView.h"

@interface rvmVideoViewController : rvmTransitionViewController
//@property (strong) IBOutlet NSView *placeHolder;

@property (weak) IBOutlet NSSlider *saturation;
@property (weak) IBOutlet NSSlider *contrast;
@property (weak) IBOutlet NSSlider *brightness;
@property (weak) IBOutlet NSSlider *scanlines;
@property (weak) IBOutlet NSSlider *noise;
@property (weak) IBOutlet NSSlider *offset;
@property (weak) IBOutlet NSSlider *interlaced;
@property (weak) IBOutlet NSSlider *ghostOffset;
@property (weak) IBOutlet NSSlider *ghostIntensity;
@property (weak) IBOutlet NSSlider *ghostAngle;
@property (weak) IBOutlet NSSlider *blur;
@property (weak) IBOutlet NSSlider *curvature;

@property (weak,nonatomic) rvmMainView *emulationView;

-(NSMutableDictionary*)saveConfig;
-(void)loadConfig:(NSDictionary*)d major:(uint)M minor:(uint)m;

@end
