//
//  rvmZxSpectrum48kConfigViewController.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 13/08/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmZxSpectrum48kConfigViewController.h"
#import "rvmMonitorWindowController.h"
#import "rvmButton.h"
#import "rvmGamepadWindowController.h"

@interface rvmZxSpectrum48kConfigViewController ()
{
  rvmGamepadWindowController *wcontroller;
}
@property (weak) IBOutlet rvmImageView *keyboardB;
@property (weak) IBOutlet rvmImageView *controllerB;

@end

@implementation rvmZxSpectrum48kConfigViewController

-(void)awakeFromNib
{
  wcontroller=[[rvmGamepadWindowController alloc] initWithWindowNibName:@"rvmGamepadWindowController"];
  
  _keyboardB.onClick=^(id sender)
  {
    [self->_monitor showKeyboardPanel:YES];
  };
  
  _controllerB.onClick=^(id sender)
  {
    [self->wcontroller beginConfig];
    [self.view.window beginSheet:self->wcontroller.window completionHandler:^(NSModalResponse returnCode) {
      [self->wcontroller endConfig];
    }];
  };
}
//- (IBAction)onDevices:(id)sender {
//  [_monitor showDevicePanel:YES];
//}
//
//- (IBAction)onStart:(id)sender {
//  [_monitor transitionTo:nil];
//}

@end
