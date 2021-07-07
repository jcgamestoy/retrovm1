//
//  rvmSnapshotViewController.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 14/1/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmTransitionViewController.h"
#import "rvmMachineProtocol.h"

@class rvmMonitorWindowController;

@interface rvmSnapshotViewController : rvmTransitionViewController

//@property rvmTripleBuffer *tbuffer;
@property id<rvmMachineProtocol> machine;
@property (weak) rvmMonitorWindowController* monitor;

@end
