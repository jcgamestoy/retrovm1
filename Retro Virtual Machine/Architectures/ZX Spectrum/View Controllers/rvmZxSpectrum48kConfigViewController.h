//
//  rvmZxSpectrum48kConfigViewController.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 13/08/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "rvmTransitionViewController.h"
#import "rvmImageView.h"

@class rvmMonitorWindowController;

@interface rvmZxSpectrum48kConfigViewController : rvmTransitionViewController

@property (weak) rvmMonitorWindowController *monitor;
@property (weak) IBOutlet rvmImageView *machineImage;
@end
