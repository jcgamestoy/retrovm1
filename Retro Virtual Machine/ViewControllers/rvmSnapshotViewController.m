//
//  rvmSnapshotViewController.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 14/1/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmSnapshotViewController.h"
#import "QuartzCore/QuartzCore.h"
#import "rvmArchitecture.h"
#import "rvmImageView.h"

#import "NSData+Gzip.h"
#import "rvmMonitorWindowController.h"

@interface rvmSnapshotViewController ()
{
  NSSound *click;
}

@property (weak) IBOutlet rvmImageView *mini;
@property NSWindow *overlayWindow;
//@property NSImage *snap;
@property (weak) IBOutlet NSView *snaps;
@property (weak) IBOutlet NSButton *snapButton;
@end

@implementation rvmSnapshotViewController

-(void)awakeFromNib
{
  click=[[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Resources/Camera sounds/snapshot" ofType:@"aif"] byReference:YES];
  
  _mini.onClick=^(id sender)
  {
    [self->_monitor onSnapshotListPanel:self];
  };
}

-(NSString*)snapshotPath
{
  //rvmArchitecture *doc=_machine.doc;
  NSDateComponents *c=[[NSCalendar currentCalendar] components:NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitSecond|NSCalendarUnitNanosecond fromDate:[NSDate date]];
  
  NSString *name=[NSString stringWithFormat:@"snap.%ld.%ld.%ld.%ld.%ld.%ld.%ld.rvmSnap",(long)c.year,(long)c.month,(long)c.day,(long)c.hour,(long)c.minute,(long)c.second,(long)c.nanosecond];
  
  return name;
}

- (IBAction)onSnapshot:(id)sender {
  if(!(_machine.control & kRvmStatePlaying)) {
    _snapButton.state=NO;
    return;
  }
  
  [click play];
  _overlayWindow=[[NSWindow alloc] initWithContentRect:self.placeHolder.bounds styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
  _overlayWindow.backgroundColor=[NSColor clearColor];
  [_overlayWindow setOpaque:NO];

  NSView *v=_overlayWindow.contentView;
  [v setWantsLayer:YES];
  NSImage *snap=[_machine.tripleBuffer snapshot];
  v.layer.contents=snap;
  v.layer.minificationFilter=kCAFilterTrilinear;
  v.layer.magnificationFilter=kCAFilterTrilinear;
  NSRect r=[self.view.window convertRectToScreen:self.placeHolder.frame];
  [_overlayWindow setFrame:r display:NO];
  //v.layer.contents=[_tbuffer snapshot];
  //v.layer.backgroundColor=[NSColor redColor].CGColor;

  [_overlayWindow orderFront:NSApp];
  
  dispatch_async(_machine.queue, ^{
    @synchronized(self->_machine)
    {
      NSDictionary *snapF=[self->_machine createFastSnapshot];
      dispatch_async(dispatch_get_main_queue(), ^{
        NSString *p=[self->_machine.doc snapshotPath:@"snapshot"];
        [self->_machine.doc saveSnapshot:snapF filename:p];
      });
      
    }
  });
  
  [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
    context.duration=.50;
    context.allowsImplicitAnimation=YES;
    
    context.timingFunction=[CAMediaTimingFunction functionWithControlPoints:0.84 :0.17 :0.85 :0.18];
    
    [v setAlphaValue:0.0];
    [_overlayWindow setFrame:[self.view.window convertRectToScreen:_snaps.frame] display:NO];
  } completionHandler:^{
    self->_snapButton.state=NO;
    self->_overlayWindow=nil;
    
    self->_mini.image=snap;
  }];
}

-(void)animateIn
{
  _snapButton.alphaValue=1.0;
  _snaps.alphaValue=1.0;
}

-(void)animateOut
{
  _snapButton.alphaValue=0.0;
  _snaps.alphaValue=0.0;
}
@end
