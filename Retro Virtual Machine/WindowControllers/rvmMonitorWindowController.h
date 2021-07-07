//
//  rvmMonitorWindowController.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 11/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "rvmMachineProtocol.h"
#import "rvmMainView.h"
#import "rvmOSDControlViewController.h"
#import "rvmTransitionViewController.h"
#import "rvmBackgroundView.h"

@interface rvmMonitorWindowController : NSWindowController <NSWindowDelegate,rvmBackgroundViewDelegate>

@property (nonatomic) id<rvmMachineProtocol> machine;
@property rvmMainView *monitor;
@property rvmTransitionViewController *currentPanel;

-(void)hardReset;
//-(void)debug;
-(void)frameDone;
//-(void)loadTape;
-(void)warp;
-(void)toggleWarp;
-(void)onLowFilter:(double)d;
-(void)resume;


-(IBAction)onCassettePlay:(id)sender;
-(IBAction)onCassetteStop:(id)sender;

-(IBAction)onAudioPanel:(id)sender;
-(IBAction)onVideoPanel:(id)sender;
-(IBAction)onCassettePanel:(id)sender;
-(IBAction)onDiskPanel:(id)sender;
-(IBAction)onConfigPanel:(id)sender;
-(IBAction)onSnapshotPanel:(id)sender;
-(IBAction)onSnapshotListPanel:(id)sender;

-(IBAction)onStartStop:(id)sender;
-(IBAction)onPauseRun:(id)sender;

-(void)transitionTo:(rvmTransitionViewController*)panel;
-(void)showKeyboardPanel:(bool)show;
//-(void)showDevicePanel:(bool)show;
//-(IBAction)onCassetteReset:(id)sender;
//-(void)tapePlay;
//-(void)tapeStop;
//-(void)tapeReset;

-(void)joyStateChanged:(uint8)state;
-(void)joyPlugged:(rvmGamepad*)g;
-(void)joyUnplugged:(rvmGamepad*)g;

@end
