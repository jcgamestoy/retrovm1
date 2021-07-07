//
//  rvmPlus2DatacorderViewController.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 14/05/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "rvmPlus3FDDView.h"
#import "rvmFddDriveView.h"
#import "rvmMachineProtocol.h"
#import "rvmBackgroundView.h"
#import "rvmTexturedButton.h"
#import "rvmMediaLoader.h"

#import "rvmTransitionViewController.h"
#import "rvmNewDiskWindowsController.h"

@interface rvmPlus3FddViewController : rvmTransitionViewController<rvmMediaLoader,rvmNewDiskProtocol,NSOutlineViewDataSource>


//@property (strong) IBOutlet NSView *placeHolder;

@property (weak) IBOutlet rvmPlus3FddView *fdd;
@property (weak) IBOutlet rvmFddDriveView *fddB;

@property (strong) IBOutlet rvmBackgroundView *background;

@property id<rvmMachineProtocol> machine;

-(void)loadMediaFile:(NSURL*)filename sound:(BOOL)b drive:(uint)d;

@end
