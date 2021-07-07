//
//  rvmNewZXSpectrumWindowController.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 29/01/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface rvmNewMachineWindowController : NSWindowController<NSBrowserDelegate>

@property (weak) IBOutlet NSBrowser *browser;

@end
