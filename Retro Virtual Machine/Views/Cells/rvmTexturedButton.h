//
//  rvmTexturedButton.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 04/03/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

IB_DESIGNABLE
@interface rvmTexturedButton : NSButtonCell

@property IBInspectable NSString* imageName;

@property NSRect normalRect;
@property NSRect overRect;
@property NSRect onRect;

@property bool useHover;

@end
