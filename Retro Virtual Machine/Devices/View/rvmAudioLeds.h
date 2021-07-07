//
//  rvmAudioLeds.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 2/1/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

IB_DESIGNABLE
@interface rvmAudioLeds : NSView

@property IBInspectable double width;
@property IBInspectable double value;
@property IBInspectable BOOL horizontal;
@property IBInspectable double factor;

@end
