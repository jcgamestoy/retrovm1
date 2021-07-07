//
//  rvmSelectMediaWindowController.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 10/07/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmSelectMediaWindowController.h"

@interface rvmSelectMediaWindowController ()
@property (strong) IBOutlet rvmAlphaButton *diskButton;
@property (strong) IBOutlet rvmAlphaButton *tapeButton;

@end

@implementation rvmSelectMediaWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)awakeFromNib
{
  _diskButton.image=[NSImage imageNamed:@"DiskIcon"];
  _tapeButton.image=[NSImage imageNamed:@"TapeIcon"];
  
  //_diskButton.delegate=self;
  __weak rvmSelectMediaWindowController *v=self;
  
  _diskButton.onClick=^(rvmAlphaButton *sender) {
    [v onDisk:v];
  };
  
  _tapeButton.onClick=^(rvmAlphaButton *sender) {
    [v onTape:v];
  };
  
//  _tapeButton.delegate=self;
}



- (IBAction)onTape:(id)sender {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [self->_tapeViewController loadMedia:0];
  });
  
  [self.window.sheetParent endSheet:self.window returnCode:0];
  [self.window orderOut:sender];
}

- (IBAction)onDisk:(id)sender {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [self->_diskViewController loadMedia:0];
  });
  [self.window.sheetParent endSheet:self.window returnCode:0];
  [self.window orderOut:sender];
}

@end
