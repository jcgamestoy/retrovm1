//
//  rvmRoundedButtonCell.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 24/02/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface rvmRoundedButtonCell : NSButtonCell

@property NSGradient *backgroundGradient;
@property NSGradient *overGradient;
@property NSGradient *highlightedGradient;

@property CGFloat angle;
@property CGFloat angleOver;
@property CGFloat angleHighlighted;

@property NSColor *color;
@property NSColor *colorOver;
@property NSColor *colorHighlighted;

@property CGFloat roundCorner;

@property bool over;

@property NSColor *lineColor;
@property NSColor *lineOverColor;
@property NSColor *lineHighlightedColor;

@property CGFloat lineWidth;
@property CGFloat lineOverWidth;
@property CGFloat lineHighlightedWidth;

@end
