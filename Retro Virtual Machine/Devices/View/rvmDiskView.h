//
//  rvmDiskView.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 20/07/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

IB_DESIGNABLE
@interface rvmDiskView : NSView

-(void)setTracks:(uint)tracks type:(uint)type name:(NSString*)name;
-(void)clear;

@end
