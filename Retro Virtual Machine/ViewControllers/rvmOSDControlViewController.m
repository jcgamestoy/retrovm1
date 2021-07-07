//
//  rvmOSDControlViewController.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 04/03/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmOSDControlViewController.h"
#import "rvmTexturedButton.h"
#import "rvmMonitorWindowController.h"
#import "rvmJumpingButton.h"
#import "rvmAlphaButton.h"

@interface rvmOSDControlViewController ()
{
  bool inside;
}

@property (weak) IBOutlet NSButton *diskButton;
@property (weak) IBOutlet rvmJumpingButton *powerB;
@property (weak) IBOutlet rvmJumpingButton *pauseB;
@property (weak) IBOutlet rvmJumpingButton *resetB;
@property (weak) IBOutlet rvmJumpingButton *videoB;
@property (weak) IBOutlet rvmJumpingButton *audioB;
@property (weak) IBOutlet rvmJumpingButton *photoB;
@property (weak) IBOutlet rvmJumpingButton *diskB;
@property (weak) IBOutlet rvmJumpingButton *tapeB;
@property (weak) IBOutlet rvmJumpingButton *warpB;
@property (weak) IBOutlet rvmJumpingButton *gearB;
@property (weak) IBOutlet rvmJumpingButton *joyEmuB;

@property (weak) IBOutlet rvmJumpingButton *reSpeccy;

@property (strong) IBOutlet NSMenu *joyEmuMenu;
@property (strong) IBOutlet NSPopover *keyboardPop;
@property (weak) IBOutlet rvmImageView *standardKeyboard;
@property (weak) IBOutlet rvmImageView *recreatedKeyboard;

@end

@implementation rvmOSDControlViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)awakeFromNib
{
  [self.view setAlphaValue:0];
  
  NSTrackingArea *ta=[[NSTrackingArea alloc] initWithRect:self.view.bounds options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways owner:self userInfo:nil];
  
  [self.view addTrackingArea:ta];
  _visible=YES;
  
  _powerB.onClick=^(id sender) {
    [self->_monitor onStartStop:self];
    self->_powerB.image=(!(self->_monitor.machine.control & kRvmStatePlaying))?[NSImage imageNamed:@"osdPowerOn"]:[NSImage imageNamed:@"osdPowerOff"];
    self->_pauseB.image=[NSImage imageNamed:@"osdPause"];
  };
  
  _pauseB.onClick=^(id sender) {
    if(self->_monitor.machine.control & kRvmStatePlaying)
    {
      self->_pauseB.image=(!(self->_monitor.machine.control & kRvmStatePaused))?[NSImage imageNamed:@"osdPlay"]:[NSImage imageNamed:@"osdPause"];
      [self->_monitor onPauseRun:sender];
    }
    //_powerB.image=(!_monitor.machine.running)?[NSImage imageNamed:@"osdPowerOn"]:[NSImage imageNamed:@"osdPowerOff"];
  };
  
  _resetB.onClick=^(id sender) {
    [self->_monitor hardReset];
  };
  
  _videoB.onClick=^(id sender) {
    [self->_monitor onVideoPanel:self];
  };
  
  _audioB.onClick=^(id sender) {
    [self->_monitor onAudioPanel:self];
  };
  
  _tapeB.onClick=^(id sender) {
    [self->_monitor onCassettePanel:self];
  };
  
  _diskB.onClick=^(id sender) {
    [self->_monitor onDiskPanel:self];
  };
  
  _photoB.onClick=^(id sender) {
    [self->_monitor onSnapshotPanel:self];
  };
  
  _warpB.onClick=^(id sender) {
    [self->_monitor toggleWarp];
  };
  
  _gearB.onClick=^(id sender) {
    [self->_monitor onConfigPanel:self];
  };
  
  _joyEmuB.onClick=^(id sender) {
    NSView *v=sender;
    [self->_joyEmuMenu popUpMenuPositioningItem:nil atLocation:v.frame.origin inView:self.view];
  };
  
  _reSpeccy.onClick=^(id sender)
  {
    NSView *v=sender;
    [self->_keyboardPop showRelativeToRect:v.bounds ofView:v preferredEdge:NSMaxYEdge];
    //[_keyboardPop.contentViewController.view becomeFirstResponder];
    [self->_keyboardPop.contentViewController.view.window makeKeyWindow];
  };
  
  _standardKeyboard.onClick=^(id sender)
  {
    [self->_monitor.machine setKeyboardType:0];
    [self->_keyboardPop close];
    self->_reSpeccy.image=[NSImage imageNamed:@"osdRecreOff"];
  };
  
  _recreatedKeyboard.onClick=^(id sender)
  {
    [self->_monitor.machine setKeyboardType:1];
    [self->_keyboardPop close];
    self->_reSpeccy.image=[NSImage imageNamed:@"osdRecreOn"];
  };
}

-(void)setupOSD
{
  _powerB.image=(!(_monitor.machine.control & kRvmStatePlaying))?[NSImage imageNamed:@"osdPowerOff"]:[NSImage imageNamed:@"osdPowerOn"];
  _pauseB.image=(_monitor.machine.control & kRvmStatePaused)?[NSImage imageNamed:@"osdPlay"]:[NSImage imageNamed:@"osdPause"];
  _reSpeccy.image=(_monitor.machine.keyboardType)?[NSImage imageNamed:@"osdRecreOn"]:[NSImage imageNamed:@"osdRecreOff"];
}

-(void)mouseEntered:(NSEvent *)theEvent
{
  if(!_visible) return;
  inside=YES;
  [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
    [context setDuration:0.5];
    [self.view.animator setAlphaValue:1.0];
  } completionHandler:^{
    
  }];
}

-(void)mouseExited:(NSEvent *)theEvent
{
  inside=FALSE;
//  if(!_visible) return;
//  
//  [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
//    [context setDuration:0.0];
//    [self.view.animator setAlphaValue:0.5];
//  } completionHandler:^{
//  
//  }];
}

-(void)showShadowed
{
  //[NSCursor unhide];
  [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
    [context setDuration:1];
    [self.view.animator setAlphaValue:1.0];
  } completionHandler:^{
    
  }];
}

-(void)hideShadowed
{
  if(inside) return;
  
  //[NSCursor hide];
  [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
    [context setDuration:1];
    [self.view.animator setAlphaValue:0];
  } completionHandler:^{
    
  }];
}

-(void)hideDisk
{
  //[_diskButton setHidden:YES];
  [_diskB setHidden:YES];
}

- (IBAction)onJoyEmu:(id)sender {
  for(NSMenuItem *it in _joyEmuMenu.itemArray)
  {
    it.state=NSOffState;
  }
  
  NSMenuItem *i=sender;
  i.state=NSOnState;
  
  if(i.tag>0xff)
  {
    _joyEmuB.image=[NSImage imageNamed:@"osdJoyEmu"];
  }
  else
  {
    _joyEmuB.image=[NSImage imageNamed:@"osdJoyEmu On"];
  }
  
  [_monitor.machine joyEmuType:(uint)i.tag];
}

@end
