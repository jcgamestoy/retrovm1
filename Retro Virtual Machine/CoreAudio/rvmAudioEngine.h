//
//  rvmAudioEngine.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 26/01/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "rvmMainView.h"

typedef void (^rvmAudioEngineDestroy)(void);

@interface rvmAudioEngine : NSObject

@property BOOL playing;
@property (weak) rvmMainView *mainView;
@property dispatch_queue_t renderQueue;
@property (nonatomic) double lowPassFilter;
@property (nonatomic) double highPassFilter;

-(void)setup:(dispatch_queue_t)q;
-(void)play;
-(void)stop;
-(void)destroy:(rvmAudioEngineDestroy)destroy;

@end
