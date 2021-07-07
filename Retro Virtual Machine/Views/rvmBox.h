//
//  rvmBox.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 14/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

IB_DESIGNABLE
@interface rvmBox : NSView

@property (strong,nonatomic) IBInspectable NSColor* backgroundColor;
@property (strong,nonatomic) IBInspectable NSColor* lineColor;
@property (nonatomic) IBInspectable double  cornerRadious;
@property (nonatomic) IBInspectable double  lineWidth;
@end
