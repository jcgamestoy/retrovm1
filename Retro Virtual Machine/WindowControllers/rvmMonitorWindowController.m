//
//  rvmMonitorWindowController.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 11/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmMonitorWindowController.h"
//#import "rvmDebugViewController.h"

#import "rvmMainView.h"
#import "rvmAppDelegate.h"
//#import "rvmAudioQueue.h"
#import "rvmAudioEngine.h"
//#import "rvmZXSpectrum.h"
#import "rvmBackgroundView.h"
#import "rvmOSDViewController.h"
#import "rvmAudioViewController.h"
#import "rvmVideoViewController.h"
//#import "rvmDeviceConfigViewController.h"

#import "rvmTapeDecoderProtocol.h"
#import "rvmAbsoluteTime.h"
#import "NSView+AutolayoutExtension.h"

#import "rvmOverlayWindow.h"

#import "rvmPlus2DatacorderViewController.h"
#import "rvmPlus3FddViewController.h"

#import "rvmSelectMediaWindowController.h"
#import "rvmZxSpectrum48kConfigViewController.h"
#import "rvmZxSpectrum48kKeyboardConfigViewController.h"

#import "rvmBackgroundViewDraw.h"

#import "rvmSnapshotViewController.h"
#import "rvmSnapshotListViewController.h"

#import "rvmGamepad.h"
#import "rvmOSDLastSnapshot.h"

//Debugger
//#import "rvmDebuggerHost.h"

#define kEStateDefault 0
#define kEStateWarp 1

@interface rvmMonitorWindowController ()
{
  bool debuging,audio,video,cassette;
  uint64 lastTime;
  uint64 lastSecond;
  uint fps;
  NSWindow *overlayWindow;
  NSWindow *screenWindow;
  uint32 eState;
  dispatch_queue_t warpQueue;
  bool transitioning;
  bool osdShadow;
  NSTimer *timer;
  
  double ll,rl;
}

//@property rvmMainView *monitor;
@property (strong) IBOutlet NSView *mainView;

//@property (strong) rvmAudioQueue *audioQueue;
@property (strong) rvmAudioEngine *audioEngine;
//@property rvmDebugViewController *debugController;
@property rvmOSDViewController *osdController;
@property rvmAudioViewController *audioController;
@property rvmOSDControlViewController *osdControl;
@property rvmVideoViewController *videoController;
@property rvmPlus2DatacorderViewController *tapeController;
@property rvmPlus3FddViewController *diskController;
@property rvmZxSpectrum48kConfigViewController *configView;
@property rvmZxSpectrum48kKeyboardConfigViewController *keyboardController;
//@property rvmDeviceConfigViewController *deviceController;

//@property rvmBackgroundView *contentView;
@property rvmBackgroundViewDraw *contentView;
@property rvmSelectMediaWindowController *selectMedia;

@property rvmSnapshotViewController *snapController;
@property rvmSnapshotListViewController *snapListController;
@property rvmOSDLastSnapshot *osdLast;

//@property rvmDebuggerHost *debugController;

@end

@implementation rvmMonitorWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
      debuging=false;
      lastTime=0;
      transitioning=false;
      rl=ll=0;
    }
    return self;
}

- (void)windowDidLoad
{
  [super windowDidLoad];
  
  _selectMedia=[[rvmSelectMediaWindowController alloc] initWithWindowNibName:@"rvmSelectMediaWindowController"];

  warpQueue=dispatch_queue_create("WarpQueue", NULL);
  _machine.queue=warpQueue;
  dispatch_set_target_queue(warpQueue,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0));
  //Init the overlay NSWindow.
  CGRect wr=self.window.frame;
  CGRect vr=self.mainView.frame;
  CGRect r=CGRectMake(wr.origin.x, wr.origin.y, vr.size.width, vr.size.height);
  
//  screenWindow=[[NSWindow alloc] initWithContentRect:r styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
//  screenWindow.backgroundColor=[NSColor clearColor];
//  [screenWindow setOpaque:NO];
//  screenWindow.nextResponder=self.window;
//  [self.window addChildWindow:screenWindow ordered:NSWindowAbove];
//  [screenWindow orderWindow:NSWindowAbove relativeTo:[self.window windowNumber]];
  
  overlayWindow=[[rvmOverlayWindow alloc] initWithContentRect:r styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
  overlayWindow.backgroundColor=[NSColor clearColor];
  [overlayWindow setOpaque:NO];
  [overlayWindow setAcceptsMouseMovedEvents:YES];
  [overlayWindow setNextResponder:self.window];
  
  [self.window addChildWindow:overlayWindow ordered:NSWindowAbove];
  
  [overlayWindow orderWindow:NSWindowAbove relativeTo:[self.window windowNumber]];
  self.window.delegate=self;

  //_contentView=[[rvmBackgroundView alloc] initWithFrame:self.mainView.bounds];
  NSView *o=screenWindow.contentView;
  [o setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
  _contentView=[[rvmBackgroundViewDraw alloc] initWithFrame:self.mainView.bounds];
  [_contentView setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
  //_contentView.hidden=YES;
  _contentView.backgroundColor=[NSColor blackColor];
  //_contentView.backColor=[NSColor blackColor];
  //_contentView.mouseDelegate=self;
  
  _monitor=[[rvmMainView alloc] initWithFrame:self.mainView.bounds];
  [_monitor setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
  
  //[screenWindow.contentView addSubview:_contentView];
  [_contentView addSubview:_monitor];
  [self.window makeFirstResponder:screenWindow];
  //[screenWindow makeFirstResponder:_monitor];
  
  _audioEngine=[rvmAudioEngine new];

  _audioEngine.mainView=_monitor;
  
  [_audioEngine setup:warpQueue];
  [_audioEngine play];
  
  //_debugController=[[rvmDebuggerHost alloc] initWithNibName:@"rvmDebuggerHost" bundle:NULL];
  //[_debugController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
  //_debugController.machine=_machine;
  _monitor.machine=_machine;

//  [_mainView addSubview:_debugController.view positioned:NSWindowBelow relativeTo:_contentView];
//  [_mainView addStringConstraints:@[@"|-0-[d]-0-|",@"V:|-0-[d]-0-|"]  names:@{@"d":_debugController.view}];
//  [_mainView layoutSubtreeIfNeeded];
//  [_debugController.view setHidden:YES];
//  
  
  //Audio View Controller
  //_audioController=[[rvmAudioViewController alloc] initWithNibName:@"rvmAudioViewController" bundle:NULL];
  _audioController=[_machine audioController];
  if(_audioController)
  {
    [_audioController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_mainView addSubview:_audioController.view positioned:NSWindowBelow relativeTo:_contentView];
    [_mainView addStringConstraints:@[@"|-0-[d]-0-|",@"V:|-0-[d]-0-|"]  names:@{@"d":_audioController.view}];
    [_mainView layoutSubtreeIfNeeded];
    [_audioController.view setHidden:YES];
    //_audioController.machine=_machine;
    _audioController.engine=_audioEngine;
  }
  
  //Config View Controller
  _configView=(rvmZxSpectrum48kConfigViewController*)[_machine configViewController];
  if(_configView)
  {
    [_configView.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_mainView addSubview:_configView.view positioned:NSWindowBelow relativeTo:_contentView];
    [_mainView addStringConstraints:@[@"|-0-[d]-0-|",@"V:|-0-[d]-0-|"]  names:@{@"d":_configView.view}];
    [_mainView layoutSubtreeIfNeeded];
    [_configView.view setHidden:YES];
    _configView.monitor=self;
  }
  //Video View Controller
  //_videoController=[[rvmVideoViewController alloc] initWithNibName:@"rvmVideoViewController" bundle:NULL];
  _videoController=[_machine videoController];
  if(_videoController)
  {
  [_videoController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
  [_mainView addSubview:_videoController.view positioned:NSWindowBelow relativeTo:_contentView];
  [_mainView addStringConstraints:@[@"|-0-[d]-0-|",@"V:|-0-[d]-0-|"]  names:@{@"d":_videoController.view}];
  [_mainView layoutSubtreeIfNeeded];
  [_videoController.view setHidden:YES];
  //[_videoController.view setWantsLayer:YES];
  _videoController.emulationView=_monitor;
  }
  _snapController=[[rvmSnapshotViewController alloc] initWithNibName:@"rvmSnapshotViewController" bundle:NULL];
  [_snapController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
  [_mainView addSubview:_snapController.view positioned:NSWindowBelow relativeTo:_contentView];
  [_mainView addStringConstraints:@[@"|-0-[d]-0-|",@"V:|-0-[d]-0-|"]  names:@{@"d":_snapController.view}];
  [_mainView layoutSubtreeIfNeeded];
  _snapController.machine=_machine;
  _snapController.monitor=self;
  [_snapController.view setHidden:YES];
  
  
  _snapListController=[[rvmSnapshotListViewController alloc] initWithNibName:@"rvmSnapshotListViewController" bundle:NULL];
  _snapListController.doc=_machine.doc;
  [_snapListController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
  [_mainView addSubview:_snapListController.view positioned:NSWindowBelow relativeTo:_contentView];
  [_mainView addStringConstraints:@[@"|-0-[d]-0-|",@"V:|-0-[d]-0-|"]  names:@{@"d":_snapListController.view}];
  [_mainView layoutSubtreeIfNeeded];

  [_snapListController.view setHidden:YES];
  
  
  
  
  //Tape View Controller
  //_tapeController=[[rvmPlus2DatacorderViewController alloc] initWithNibName:@"rvmPlus2DatacorderViewController" bundle:NULL];
  _tapeController=(rvmPlus2DatacorderViewController*)[_machine cassetteController];
  if(_tapeController)
  {
    [_tapeController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_mainView addSubview:_tapeController.view positioned:NSWindowBelow relativeTo:_contentView];
    [_mainView addStringConstraints:@[@"|-0-[d]-0-|",@"V:|-0-[d]-0-|"]  names:@{@"d":_tapeController.view}];
    [_mainView layoutSubtreeIfNeeded];
    [_tapeController.view setHidden:YES];
    //[_videoController.view setWantsLayer:YES];
    _tapeController.machine=_machine;
    _selectMedia.tapeViewController=_tapeController;
  }
  //Disk
  _diskController=(rvmPlus3FddViewController*)[_machine diskController];
  if(_diskController)
  {
    [_diskController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_mainView addSubview:_diskController.view positioned:NSWindowBelow relativeTo:_contentView];
    [_mainView addStringConstraints:@[@"|-0-[d]-0-|",@"V:|-0-[d]-0-|"]  names:@{@"d":_diskController.view}];
    [_mainView layoutSubtreeIfNeeded];
    [_diskController.view setHidden:YES];
    _selectMedia.diskViewController=_diskController;
    _diskController.machine=_machine;
  }
  
  __weak rvmMonitorWindowController* vv=self;
  
  //Keyboard
  _keyboardController=(rvmZxSpectrum48kKeyboardConfigViewController*)[_machine configKeyboardViewController];
  if(_keyboardController)
  {
    [_keyboardController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_mainView addSubview:_keyboardController.view positioned:NSWindowBelow relativeTo:_contentView];
    [_mainView addStringConstraints:@[@"|-0-[d]-0-|",@"V:|-0-[d]-0-|"]  names:@{@"d":_keyboardController.view}];
    [_mainView layoutSubtreeIfNeeded];
    [_keyboardController.view setHidden:YES];
    _keyboardController.machine=_machine;
    
    
    _keyboardController.onClose=^()
    {
      [vv transitionTo:vv.configView];
    };
  }
  
//  _deviceController=[rvmDeviceConfigViewController new];//(rvmZxSpectrum48kKeyboardConfigViewController*)[_machine configKeyboardViewController];
//  if(_deviceController)
//  {
//    [_deviceController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [_mainView addSubview:_deviceController.view positioned:NSWindowBelow relativeTo:_contentView];
//    [_mainView addStringConstraints:@[@"|-0-[d]-0-|",@"V:|-0-[d]-0-|"]  names:@{@"d":_deviceController.view}];
//    [_mainView layoutSubtreeIfNeeded];
//    [_deviceController.view setHidden:YES];
//    _deviceController.machine=_machine;
//  }
//  
  _osdController=[[rvmOSDViewController alloc] initWithNibName:@"rvmOSDViewController" bundle:NULL];
  [_osdController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
  
  o=overlayWindow.contentView;
  [o setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
  [overlayWindow.contentView addSubview:_osdController.view];
  [overlayWindow.contentView addStringConstraints:@[@"V:|-32-[osd(64)]",@"[osd(700)]"] names:@{@"osd":_osdController.view}];
  [overlayWindow.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_osdController.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_osdController.view.superview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:1.0]];

  _osdControl=[[rvmOSDControlViewController alloc] initWithNibName:@"rvmOSDControlViewController" bundle:nil];
  [_osdControl.view setTranslatesAutoresizingMaskIntoConstraints:NO];
  _osdControl.monitor=self;
  if(!_diskController) [_osdControl hideDisk];
  [_osdControl setupOSD];
  
  
  
  [overlayWindow.contentView addSubview:_osdControl.view];
  [overlayWindow.contentView addStringConstraints:@[@"V:[osd(70)]-6-|",@"[osd(706)]"] names:@{@"osd":_osdControl.view}];
  
  [overlayWindow.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_osdControl.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_osdControl.view.superview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:1.0]];
  
  _osdLast=[[rvmOSDLastSnapshot alloc] initWithNibName:@"rvmOSDLastSnapshot" bundle:nil];
  _osdLast.view.translatesAutoresizingMaskIntoConstraints=NO;
  
  [overlayWindow.contentView addSubview:_osdLast.view];
  //[overlayWindow.contentView addStringConstraints:@[@"V:[osd(424)]",@"[osd(652)]"] names:@{@"osd":_osdLast.view}];
  
  [overlayWindow.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_osdLast.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_osdLast.view.superview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
  
  [overlayWindow.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_osdLast.view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_osdLast.view.superview attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:1.0]];
  _osdLast.view.hidden=YES;
  
  NSTrackingArea *ta=[[NSTrackingArea alloc] initWithRect:((NSView*)overlayWindow.contentView).bounds options:NSTrackingMouseMoved | NSTrackingActiveAlways | NSTrackingInVisibleRect owner:self userInfo:nil];
  
  [overlayWindow.contentView addTrackingArea:ta];
  
  _osdLast.imageView.onClick=^(id sender)
  {
    [self->_machine loadSnapshot:self->_machine.lastSnapshot];
    self->_machine.control&=~(kRvmStatePaused);
    self->_osdLast.view.hidden=YES;
    [self->_osdControl setupOSD];
    [self->_osdController showMessage:@"Last snapshot loaded" image:[NSImage imageNamed:@"photo"]];
  };
  
  [_mainView addSubview:_contentView positioned:NSWindowAbove relativeTo:nil];
  _contentView.hidden=NO;
  
  _contentView.onClick=^(void)
  {
    if(vv.currentPanel)
      [vv transitionTo:nil];
  };
  
  if(!(_machine.control & kRvmStatePlaying))
  {
    [_osdController fixedText:@"Power Off. Press CMD+Enter to power on." image:[NSImage imageNamed:@"osdPowerOff"]];
  }
  //[self transitionTo:nil speed:0];
  
  [self.window registerForDraggedTypes:@[NSURLPboardType]];
}



-(void)mouseMoved:(NSEvent *)theEvent
{
  if(_osdControl.view.alphaValue>0 && NSPointInRect(theEvent.locationInWindow, [overlayWindow.contentView bounds]))
  {
  if(timer)
    osdShadow=YES;
  else
  {
  osdShadow=NO;
  timer=[NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerOsd:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
  [_osdControl showShadowed];
  }
  }
}

//-(void)rvmMouseDown:(id)sender
//{
//  if(_currentPanel)
//    [self transitionTo:nil];
//}

-(void)timerOsd:(NSTimer*)t
{
  if(osdShadow)
    osdShadow=NO;
  else
  {
    [timer invalidate];
    timer=nil;
    osdShadow=NO;
    [_osdControl hideShadowed];
  }
}

-(BOOL)windowShouldClose:(id)sender
{
  eState=kEStateDefault;

  [_monitor stop];
  [_audioEngine stop];

  [[NSApplication sharedApplication] sendAction:NSSelectorFromString(@"onMachineStopped:") to:nil from:_machine.doc];
  
  dispatch_sync(warpQueue, ^{
    //_machine.paused=YES;
    _machine.control|=kRvmStatePaused;
  });
  
  //[_machine.doc saveFile];
  [_machine.doc saveDocument:self];
  return YES;
}

-(void)resume
{
  [_monitor run:YES];
  _machine.control&=~(kRvmStatePaused);
  if(_machine.control&kRvmStateWarp)
  {
    [_osdController fixedText:nil image:nil];
  }
  _machine.control&=~kRvmStateWarp;
  [_audioEngine play];
  [_osdControl setupOSD];
  //[_osdController showMessage:nil image:nil];
  _osdLast.view.hidden=YES;
}

-(void)windowDidResize:(NSNotification *)notification
{
  [overlayWindow setFrame:[self.window convertRectToScreen:self.mainView.frame] display:YES];
  //[screenWindow setFrame:[self.window convertRectToScreen:self.mainView.frame] display:YES];
  
  if(_currentPanel && _currentPanel.placeHolder) _contentView.frame=[_currentPanel.placeHolder convertRect:_currentPanel.placeHolder.bounds toView:nil];
}

-(IBAction)onHardReset:(id)sender
{
  [self hardReset];
}

-(void)hardReset
{
  eState=kEStateDefault;
  _machine.control&=~kRvmStateWarp;

  dispatch_sync(warpQueue, ^{
    [_machine resetMachine];
    [_audioEngine play];
    [_monitor reset];
  });
  [_osdController fixedText:nil image:nil];
}

-(IBAction)onAudioPanel:(id)sender
{
  [self transitionTo:(_currentPanel==_audioController)?nil:_audioController];
 }

-(IBAction)onVideoPanel:(id)sender
{
  [self transitionTo:(_currentPanel==_videoController)?nil:_videoController];
}

-(IBAction)onCassettePanel:(id)sender
{
  [self transitionTo:(_currentPanel==_tapeController)?nil:_tapeController];
}

-(IBAction)onDiskPanel:(id)sender
{
  if(_diskController)
    [self transitionTo:(_currentPanel==_diskController)?nil:_diskController];
}

-(IBAction)onConfigPanel:(id)sender
{
  if(_configView)
    [self transitionTo:(_currentPanel==_configView)?nil:_configView];
}

-(IBAction)onSnapshotPanel:(id)sender
{
  if(_snapController)
    [self transitionTo:(_currentPanel==_snapController)?nil:_snapController];
}

-(IBAction)onSnapshotListPanel:(id)sender
{
  if(_snapController)
    [self transitionTo:(_currentPanel==_snapListController)?nil:_snapListController];
}

//-(IBAction)onDebug:(id)sender
//{
//  if(_debugController)
//    [self transitionTo:(_currentPanel==_debugController)?nil:_debugController];
//}


-(void)showKeyboardPanel:(bool)show
{
  if(show)
    [self transitionTo:_keyboardController];
  else
    [self transitionTo:_configView];
}

//-(void)showDevicePanel:(bool)show
//{
//  if(show)
//    [self transitionTo:_deviceController];
//  else
//    [self transitionTo:_configView];
//}




//-(void)debug
//{
////  if(eState) return;
////  
////  //[_debugController update];
////  
////  [self transitionTo:(_currentPanel==_debugController)?nil:_debugController];
//}

-(void)frameDone
{

//  if(debuging)
//  {
//    [_debugController update];
//  }

  
  if(_currentPanel==_audioController)
  {
    [_audioController setLevels];
//    double l,r;
//    
//    [_machine SoundLevelL:&l R:&r];
//    //_audioController.lMaster.value=(l-0.06)*8;
//    //_audioController.rMaster.value=(r-0.06)*8;
//    //ll=(ll+(log10(l*10000)*0.25-0.7)*5.0)*0.5;
//    //rl=(rl+(log10(r*10000)*0.25-0.7)*5.0)*0.5;
//    ll=ll*0.75+((l-0.06)*4.0)*0.25;
//    rl=rl*0.75+((r-0.06)*4.0)*0.25;
//    ll=isnan(ll)?0:ll;
//    rl=isnan(rl)?0:rl;
//    _audioController.lMaster.value=ll;
//    _audioController.rMaster.value=rl;
  }
  //double t=getTimeUs();
  uint64 t=rvmGetTime();
  
  //if(t>(lastSecond+1000000))
  if(rvmGetTimeDiffNs(lastSecond, t)>=1e9)
  {
    uint f=fps;
    dispatch_async(dispatch_get_main_queue(), ^{
      self.window.title=[NSString stringWithFormat:@"Retro Virtual Machine fps:%d (%.0f%%)",f,(double)f*100.0/50.0];
    });
    fps=0;
    lastSecond=t;
  } else fps++;
}

-(void)openDocument:(id)sender
{
  rvmAppDelegate *app=[NSApp delegate];
  NSOpenPanel *p=app.openPanel;
  
  p.allowedFileTypes=[_machine supportedTypes];
  [p setCanChooseFiles:YES];
  [p setCanChooseDirectories:NO];
  [p setAllowsMultipleSelection:NO];
  [p beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
    if(result==NSOKButton)
    {
      [self->_machine loadMedia:p.URL];
    }
  }];
//  if(_diskController)
//  {
//    [self.window beginSheet:_selectMedia.window completionHandler:^(NSModalResponse returnCode) {
//      
//    }];
//  }
//  else
//    [_tapeController loadMedia:0];
}

-(IBAction)onCassettePlay:(id)sender
{
  [_osdController showMessage:@"Tape playing" image:[NSImage imageNamed:@"tape"]];
  [_tapeController.datacorder onPlay:self];
  //[_machine cassettePlay];
}


-(IBAction)onCassetteStop:(id)sender
{
  [_osdController showMessage:@"Tape stopped" image:[NSImage imageNamed:@"tape"]];
  [_tapeController.datacorder onStop:self];
}

-(void)warp
{
  while(eState)
  {
    //double t=getTimeUs();
    uint64 t =rvmGetTime();
    //if(t>(lastTime+60000))
    if(rvmGetTimeDiffNs(lastTime, t)>(1e9/20))
    {
      lastTime=t;
      [_monitor render];
    }
    else
    {
      [_machine doFrame:YES];
      [self frameDone];
    }
  }
}

-(IBAction)onWarp:(id)sender
{
  [self toggleWarp];
}

-(void)toggleWarp
{
  if(debuging) return;
  //_audioQueue.warp=!_audioQueue.warp;
  if(eState)
  {
    eState=kEStateDefault;
    _machine.control&=~kRvmStateWarp;
    [_audioEngine play];
  }
  else
  {
    eState=kEStateWarp;
    _machine.control|=kRvmStateWarp;
    [_audioEngine stop];
    
    dispatch_async(warpQueue, ^{
      [self warp];
    });
  }
  
  if(eState)
    [_osdController fixedText:@"Warping..." image:[NSImage imageNamed:@"osdWarp"]];
  else
    [_osdController fixedText:nil image:nil];
}

-(void)joyDown:(rvmGamepad*)gamepad axis:(uint)axis
{
  
}

-(void)joyStateChanged:(uint8)state
{
  [_machine joyState:state];
}

-(void)joyPlugged:(rvmGamepad*)g
{
  [_osdController showMessage:@"Joystick Plugged" image:g.gamepadImage];
}

-(void)joyUnplugged:(rvmGamepad*)g
{
  [_osdController showMessage:@"Joystick Unplugged" image:g.gamepadImage];
}

-(void)onLowFilter:(double)d
{
  _audioEngine.lowPassFilter=d;
}

-(void)setMachine:(id<rvmMachineProtocol>)machine
{
  _machine=machine;
  
  rvmMonitorWindowController *mc=self;
  
  _machine.onOsdEvent=^(NSString *msg,uint size,NSImage* img) {
    [mc.osdController showMessage:msg size:size image:img];
    
    if(mc.osdLast.imageView.image)
    {
      mc.osdLast.view.hidden=!(mc.machine.control & kRvmStatePaused);
    }
    
    [mc.osdControl setupOSD];
  };
  
  _machine.onFastSnap=^(NSImage *i)
  {
    mc.osdLast.imageView.image=i;
    //mc.osdLast.view.hidden=NO;
  };
  
  //_debugController.machine=machine;
  _monitor.machine=machine;
  _machine.queue=warpQueue;
  
  [[NSApplication sharedApplication] sendAction:NSSelectorFromString(@"onMachineRunning:") to:nil from:_machine.doc];
}

-(IBAction)onStartStop:(id)sender
{
  //[_osdController showMessage:(!_machine.running)?@"Power On":@"Power off" image:(!_machine.running)?[NSImage imageNamed:@"osdPowerOn"]:[NSImage imageNamed:@"osdPowerOff"]];
  if(!(_machine.control & kRvmStatePlaying))
  {
    [_osdController fixedText:nil image:nil];
    [_osdController showMessage:@"Power On" image:[NSImage imageNamed:@"osdPowerOn"]];
  }
  else
  {
    [_osdController fixedText:@"Power Off. Press CMD+Enter to power on." image:[NSImage imageNamed:@"osdPowerOff"]];
  }
  dispatch_async(warpQueue, ^{
    if(!(self->_machine.control & kRvmStatePlaying))
    {
      [self->_machine resetMachine];
      [self->_machine resetRam];
    }
    self->_machine.control^=kRvmStatePlaying;
    if(self->_machine.control & kRvmStatePlaying) self->_machine.control&=~kRvmStatePaused;
  });
}

-(IBAction)onPauseRun:(id)sender
{
  [_osdController showMessage:(!(_machine.control & kRvmStatePaused))?@"Paused":@"Running" image:(!(_machine.control & kRvmStatePaused))?[NSImage imageNamed:@"osdPause"]:[NSImage imageNamed:@"osdPlay"]];
  
  if(_osdLast.imageView.image)
  {
    _osdLast.view.hidden=_machine.control & kRvmStatePaused;
  }
  
  dispatch_async(warpQueue, ^{
    self->_machine.control^=kRvmStatePaused;
  });
}

-(IBAction)onWarpOff:(id)sender
{
  if(eState)
  {
    eState=kEStateDefault;
    _machine.control&=~kRvmStateWarp;
    [_audioEngine play];
  }
  
  if(eState)
    [_osdController fixedText:@"Warping..." image:[NSImage imageNamed:@"osdWarp"]];
  else
    [_osdController fixedText:nil image:nil];
}

-(IBAction)onFullscreen:(id)sender
{
  [self.window toggleFullScreen:sender];
}

//-(IBAction)onInterlacedToggle:(id)sender
//{
//  NSButton *check=sender;
//  _monitor.interlaced=check.state;
//}
//
//-(IBAction)onChangeSaturation:(id)sender
//{
//  NSSlider *s=sender;
//  _monitor.saturation=[s doubleValue];
//}
//
//-(IBAction)onChangeContrast:(id)sender
//{
//  NSSlider *s=sender;
//  _monitor.contrast=[s doubleValue];
//}
//
//-(IBAction)onChangeBrightness:(id)sender
//{
//  NSSlider *s=sender;
//  _monitor.brightness=[s doubleValue];
//}
//
//-(IBAction)onChangeScanlines:(id)sender
//{
//  NSSlider *s=sender;
//  _monitor.scanlines=[s doubleValue];
//}
//
//-(IBAction)onChangeNoise:(id)sender
//{
//  NSSlider *s=sender;
//  _monitor.noise=[s doubleValue];
//}
//
//-(IBAction)onChangeOffset:(id)sender
//{
//  NSSlider *s=sender;
//  _monitor.offset=[s doubleValue];
//}
//
//-(IBAction)onChangeInterlaced:(id)sender
//{
//  NSSlider *s=sender;
//  _monitor.interlaced=[s doubleValue];
//}
//
//-(IBAction)onChangeGhostOffset:(id)sender
//{
//  NSSlider *s=sender;
//  _monitor.ghostOffset=[s doubleValue];
//}
//
//-(IBAction)onChangeGhostIntensity:(id)sender
//{
//  NSSlider *s=sender;
//  _monitor.ghostIntensity=[s doubleValue];
//}
//
//-(IBAction)onChangeGhostAngle:(id)sender
//{
//  NSSlider *s=sender;
//  _monitor.ghostAngle=[s doubleValue];
//}
//
//-(IBAction)onBlurChange:(id)sender
//{
//  NSSlider *s=sender;
//  _monitor.blur=[s doubleValue];
//}

//Transitions
-(void)animateTransition:(NSView*)view from:(NSRect)r toView:(NSView*)cview speed:(double)speed animation:(void (^)(void))animation completion:(void (^)(void))completion
{
  if(!cview)
  {
    _contentView.hidden=YES;
  }
  else
  {

    _contentView.hidden=NO;
  }
  
  NSDisableScreenUpdates();
  [_mainView addSubview:view positioned:NSWindowAbove relativeTo:nil];
  //view.frame=r;
  NSEnableScreenUpdates();
  
  [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
    [context setDuration:speed];
    [context setAllowsImplicitAnimation:YES];
    
    if(cview) _contentView.frame=[cview convertRect:cview.bounds toView:nil];
    animation();
  } completionHandler:^{
    NSDisableScreenUpdates();
    if(cview)
    {
//      [cview addSubview:view positioned:NSWindowAbove relativeTo:nil];
//      view.frame=cview.bounds;
//      [self.window makeFirstResponder:_monitor];

    }
    completion();
    
    NSEnableScreenUpdates();
    //[_monitor run:YES];
    self->transitioning=NO;
    [self->_osdControl setupOSD];
  }];
  
}

-(void)transitionTo:(rvmTransitionViewController *)panel speed:(double)speed
{
  //[_monitor run:NO];

//  _machine.debugging=panel==_debugController;
  
  if(transitioning) return;
  transitioning=YES;
  
  if(!panel && _currentPanel) //No panel
  {
    NSRect fr=[_contentView convertRect:_contentView.bounds toView:nil];
    [self animateTransition:_contentView from:fr toView:_mainView speed:speed animation:^{
      //[_osdControl.view setAlphaValue:1.0];
      //[_osdController.view setAlphaValue:1.0];
      [self->_currentPanel animateOut];
    } completion:^{
      [self->_currentPanel.view setHidden:YES];
      self->_currentPanel=nil;

      [self->_osdControl.view setHidden:NO];
      //[_osdController.view setHidden:NO];
      self->_osdControl.visible=YES;
    }];
  }
  else if(_currentPanel) //From panel to panel
  {
    

    NSRect fr=[_contentView convertRect:_contentView.bounds toView:nil];
    [panel.view setHidden:NO];
    
    [self animateTransition:_contentView from:fr toView:panel.placeHolder speed:speed animation:^{
      [self->_currentPanel animateOut];
      [panel animateIn];
    } completion:^{
      [self->_currentPanel.view setHidden:YES];
      self->_currentPanel=panel;
    }];
  }
  else //To panel
  {
    _osdLast.view.hidden=YES;
    NSRect fr=[_contentView convertRect:_contentView.bounds toView:nil];
    [panel.view setHidden:NO];
    
    [self animateTransition:_contentView from:fr toView:panel.placeHolder speed:speed animation:^{
      [self->_osdControl.view setAlphaValue:0.0];
      //[_osdController.view setAlphaValue:0.0];
      [panel animateIn];
    } completion:^{
      [self->_osdControl.view setHidden:YES];
      //[_osdController.view setHidden:YES];
      self->_currentPanel=panel;
    }];
  }
}

-(void)transitionTo:(rvmTransitionViewController*)panel
{
  [self transitionTo:panel speed:0.5];
}

-(void)rvmMouseDown:(id)sender
{
  
}


-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
  NSURL *file=[NSURL URLFromPasteboard:[sender draggingPasteboard]];
  NSArray *type=[_machine supportedTypes];
  
  if([type containsObject:[[file pathExtension] lowercaseString]])
  {
    return NSDragOperationCopy;
  }
  else
    return NSDragOperationNone;
}

-(BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender
{
  return YES;
}

-(BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
  
  NSURL *file=[NSURL URLFromPasteboard:[sender draggingPasteboard]];
  [_machine loadMedia:file];
  return YES;
}
@end
