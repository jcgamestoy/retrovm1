//
//  rvmSelectMediaWindowController.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 10/07/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "rvmMediaLoader.h"
#import "rvmAlphaButton.h"
@interface rvmSelectMediaWindowController : NSWindowController

@property (weak) id<rvmMediaLoader> tapeViewController;
@property (weak) id<rvmMediaLoader> diskViewController;

@end
