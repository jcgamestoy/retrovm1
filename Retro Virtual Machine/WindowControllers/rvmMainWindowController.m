//
//  rvmMainWindowController.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 24/03/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmMainWindowController.h"
#import "rvmAudioViewController.h"
#import "rvmNavigationViewController.h"
#import "rvmNavButtonCell.h"
#import "rvmMachinesCollectionViewController.h"
#import "NSColor+rvmNSColors.h"
#import "rvmImageView.h"
#import <QuartzCore/QuartzCore.h>

@interface rvmMainWindowController ()
{
  CALayer *logo;
  //NSWindow *overlayWindow;
}

@property (strong) IBOutlet rvmNavigationViewController *navigation;
@property (weak) IBOutlet rvmImageView *logoView;

//@property (strong) IBOutlet rvmMachinesCollectionViewController *machines;

@property (strong) IBOutlet rvmBackgroundView *backgroundView;
@property (weak) IBOutlet rvmImageView *titleImage;
@property (weak) IBOutlet rvmImageView *titleImage2;

@property (weak) IBOutlet NSLayoutConstraint *imageHeightCo;
@property (weak) IBOutlet NSLayoutConstraint *imageTopCo;
@property (weak) IBOutlet NSTextField *copyright;
@property (weak) IBOutlet NSToolbarItem *toolbarTitle;

@end

@implementation rvmMainWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
  self.window.delegate=self;
  //[self initAnimation];
}

-(void)awakeFromNib
{
  [_navigation pushViewController:_machines];
  //[self.window.contentView addSubview:_machines.view];
  [_machines.view setWantsLayer:YES];
  
  //_backgroundView.backgroundColor=[NSColor colorWithPatternImage:[NSImage imageNamed:@"mainPattern"]];
  //_titleImage2.image=_titleImage.image=[NSImage imageNamed:@"Logo1"];
  
  [_toolbarTitle setView:_titleImage];
  [_titleImage setNeedsDisplay:YES];

  CGFloat h=_backgroundView.bounds.size.width/10.0-10;
  _imageHeightCo.constant=h;
  _imageTopCo.constant=_backgroundView.frame.size.height/2.0-h/2.0;

  [_machines.view setAlphaValue:0];
  [_copyright setAlphaValue:1.0];
  //[self.window makeFirstResponder:self];
  [self performSelector:@selector(initAnimation) withObject:self afterDelay:.50];
  //[self initAnimation];
  [self.window registerForDraggedTypes:@[NSURLPboardType]];
}

//-(void)windowDidResize:(NSNotification *)notification
//{
//  [overlayWindow setFrame:[self.window convertRectToScreen:self.window.frame] display:YES];
//}

#define logoW 553
#define logoH 532

-(void)initAnimation
{
  logo=[CALayer layer];
  NSRect b=[self.window.contentView frame];
  
  NSRect l=NSMakeRect((b.size.width-logoW)/2.0, (b.size.height-logoH)/2.0, logoW, logoH);
  
  logo.frame=l;
  logo.contents=[NSImage imageNamed:@"mainLogo"];
  logo.opacity=0.0;

  NSView *v=self.window.contentView;
  
  [v.layer addSublayer:logo];
  
  [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
    context.duration=4.5;
    context.allowsImplicitAnimation=YES;
    _copyright.alphaValue=1.0;

    CAKeyframeAnimation *op=[CAKeyframeAnimation animationWithKeyPath:@"opacity"];

    op.duration=context.duration;
    op.keyTimes=@[@0,@(.35/context.duration),@1.0];
    op.values=@[@0,@1,@1];
    
    CAKeyframeAnimation *sc=[CAKeyframeAnimation animationWithKeyPath:@"transform"];
    sc.duration=context.duration;
    sc.keyTimes=@[@0,@(.5/context.duration),@1];
    sc.values=@[[NSValue valueWithCATransform3D:CATransform3DMakeScale(4.0, 4.0, 1.0)],
                [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)],
                [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)],
                ];
    
    CAAnimationGroup *ag=[CAAnimationGroup animation];
    ag.animations=@[op,sc];
    ag.duration=context.duration;
    ag.removedOnCompletion=YES;
    [logo addAnimation:ag forKey:nil];
  } completionHandler:^{
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
      context.duration=0.35;
      context.allowsImplicitAnimation=YES;
      self->_copyright.alphaValue=0.0;
      self->_machines.view.alphaValue=1.0;
      CAKeyframeAnimation *op=[CAKeyframeAnimation animationWithKeyPath:@"opacity"];
      op.duration=context.duration;
      op.keyTimes=@[@0,@1];
      op.values=@[@1,@0];
      
      self->logo.transform=CATransform3DIdentity;
      CAKeyframeAnimation *sc=[CAKeyframeAnimation animationWithKeyPath:@"transform"];
      sc.duration=context.duration;
      //sc.keyTimes=@[@0,@1];
      sc.keyTimes=@[@0,@1];
      sc.values=@[[NSValue valueWithCATransform3D:CATransform3DMakeScale(.90, .90, 1.0)],
                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(.0, .0, 1.0)],
                  ];

      
      CAAnimationGroup *ag=[CAAnimationGroup animation];
      ag.animations=@[op,sc];
      ag.duration=context.duration;
      ag.removedOnCompletion=YES;

      
      [self->logo addAnimation:ag forKey:nil];
    } completionHandler:^{
      [self->logo removeFromSuperlayer];
      [self->_machines checkUpdate];
      self->logo=nil;
    }];
  }];
}

-(IBAction)openDocument:(id)sender
{
  [_machines openDocument:sender];
}

-(IBAction)onClearRecent:(id)sender
{
  [_machines onClearRecent:sender];
}

-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
  NSURL *file=[NSURL URLFromPasteboard:[sender draggingPasteboard]];
  NSArray *type=@[@"rvmmachine"];
  
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
  [_machines openFile:file];
  return YES;
}

-(void)windowDidEnterFullScreen:(NSNotification *)notification {
  [_machines.collection layoutCollection];
}

-(void)windowDidExitFullScreen:(NSNotification *)notification {
  [_machines.collection layoutCollection];
}
@end
