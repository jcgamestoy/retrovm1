//
//  rvmOSDControlViewController.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 04/03/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class rvmMonitorWindowController;

@interface rvmOSDControlViewController : NSViewController

@property bool visible;

@property (weak) rvmMonitorWindowController* monitor;

-(void)showShadowed;
-(void)hideShadowed;
-(void)hideDisk;

-(void)setupOSD;

@end
