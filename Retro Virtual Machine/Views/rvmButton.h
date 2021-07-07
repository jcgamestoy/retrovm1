//
//  rvmButton.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 23/08/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

IB_DESIGNABLE
@interface rvmButton : NSView

@property (strong) IBInspectable NSImage* image;
@property (strong) IBInspectable NSImage* imageOver;
//@property (strong) IBInspectable NSImage* imageOn;

@property (strong) void (^onClick)(void);

@end
