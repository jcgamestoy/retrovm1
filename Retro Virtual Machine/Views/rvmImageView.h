//
//  rvmImageView.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 30/01/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

IB_DESIGNABLE
@interface  rvmImageView : NSView

@property IBInspectable NSImage *image;

@property (strong) void (^onClick)(id sender);
@property (strong) void (^onDoubleClick)(id sender);

@end
