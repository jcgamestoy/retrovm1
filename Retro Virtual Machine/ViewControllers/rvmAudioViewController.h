//
//  rvmAudioViewController.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 24/01/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "rvmAudioEngine.h"
#import "rvmTransitionViewController.h"
#import "rvmAudioLeds.h"
#import "rvmAudioMixer.h"
//@class rvmNavigationItemViewController;
//#import "rvmZXSpectrum48k.h"

@interface rvmAudioViewController : rvmTransitionViewController

//@property (weak) IBOutlet NSView *placeHolder;
@property (weak,nonatomic) rvmAudioEngine *engine;
//@property (weak,nonatomic) rvmZXSpectrum48k *machine;
@property (weak) IBOutlet rvmAudioLeds *rMaster;
@property (weak) IBOutlet rvmAudioLeds *lMaster;

@property (weak) rvmAudioMixer *mixer;

-(void)setLevels;
-(NSMutableDictionary*)saveConfig;
-(void)loadConfig:(NSDictionary*)d;
-(void)performConfig:(NSDictionary*)d;

@end
