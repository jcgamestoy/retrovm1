//
//  rvmTapeView.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 28/12/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

IB_DESIGNABLE
@interface rvmTapeView : NSView

@property (nonatomic) NSImage *chassisImage;
@property (nonatomic) double length;

-(void)setCassetteImage:(NSImage*)i length:(double)l name:(NSString*)name;

@end
