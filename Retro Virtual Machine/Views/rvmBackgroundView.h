//
//  rvmBackgroundView.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 14/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol rvmBackgroundViewDelegate

-(void)rvmMouseDown:(id)sender;

@end

IB_DESIGNABLE
@interface rvmBackgroundView : NSView

@property id<rvmBackgroundViewDelegate> mouseDelegate;

//@property (strong,nonatomic) NSColor *backgroundColor;

@property (nonatomic) IBInspectable NSImage *backgroundImage;
@property (nonatomic) IBInspectable NSColor *backColor;
@property (nonatomic) IBInspectable NSColor *backColor2;
@property (nonatomic) IBInspectable double angle;
@property (nonatomic) IBInspectable BOOL vibrance;

@end
