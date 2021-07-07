//
//  rvmMacKeyboardView.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 11/08/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

IB_DESIGNABLE
@interface rvmMacKeyboardView : NSView

@property (strong) void (^onKeyDown)(uint code);
@property (strong) void (^onKeyUp)(uint code);

@property (strong) void (^onKeyClick)(uint code,NSRect r);

@end
