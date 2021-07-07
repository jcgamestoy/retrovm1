//
//  rvmBackgroundViewDraw.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 10/10/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

IB_DESIGNABLE
@interface rvmBackgroundViewDraw : NSView

@property IBInspectable NSColor *backgroundColor;
@property (strong) void (^onClick)(void);
@end
