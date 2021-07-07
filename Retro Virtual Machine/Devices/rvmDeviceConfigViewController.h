//
//  rvmDeviceConfigViewController.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 20/9/15.
//  Copyright © 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "rvmTransitionViewController.h"
#import "rvmMachineProtocol.h"

@interface rvmDeviceConfigViewController : rvmTransitionViewController

@property id<rvmMachineProtocol> machine;

@end
