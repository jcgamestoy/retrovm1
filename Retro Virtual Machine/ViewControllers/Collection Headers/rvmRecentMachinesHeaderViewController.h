//
//  rvmRecentMachinesHeaderViewController.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 03/05/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "rvmBackgroundView.h"

@interface rvmRecentMachinesHeaderViewController : NSViewController
@property (strong) IBOutlet rvmBackgroundView *background;
@property (weak) IBOutlet NSTextField *label;

@end
