//
//  rvmMainWindowController.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 24/03/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "rvmMachinesCollectionViewController.h"

@interface rvmMainWindowController : NSWindowController<NSWindowDelegate,NSDraggingDestination>

@property (strong) IBOutlet rvmMachinesCollectionViewController *machines;

@end
