//
//  rvmDebugViewController.h
//  rvmSpectrum
//
//  Created by Juan Carlos González Amestoy on 03/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "rvmZXSpectrum48k.h"
#import "rvmConsoleView.h"
#import "rvmMachineProtocol.h"
#import "rvmTransitionViewController.h"

@interface rvmDebugViewController : rvmTransitionViewController<rvmConsoleViewDelegate>

//@property (weak) IBOutlet NSView *monitorPlaceHolder;
@property (weak,nonatomic) rvmZXSpectrum48k *machine;
@property (strong) IBOutlet rvmConsoleView *consoleView;

-(void)update;

@end
