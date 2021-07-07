//
//  rvmZxSpectrum48kKeyboardConfigViewController.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 11/08/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "rvmTransitionViewController.h"
#import "rvmMachineProtocol.h"

@interface rvmZxSpectrum48kKeyboardConfigViewController : rvmTransitionViewController

@property (weak) id<rvmMachineProtocol> machine;

@property (strong) void (^onClose)(void);

@end
