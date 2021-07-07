//
//  rvmAlphaButton.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 21/02/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "rvmBackgroundView.h"

//@protocol rvmAlphaButtonProtocol <NSObject>
//
//@optional
//-(void)click:(id)sender;
//-(void)dClick:(id)sender;
//
//@end

IB_DESIGNABLE
@interface rvmAlphaButton : NSView

@property IBInspectable NSImage *image;
//@property id<rvmAlphaButtonProtocol> delegate;

@property (strong) void (^onClick)(rvmAlphaButton* button);
@property (strong) void (^onDoubleClick)(rvmAlphaButton* button);

@end
