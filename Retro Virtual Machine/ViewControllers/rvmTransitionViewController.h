//
//  rvmTransitionViewController.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 01/06/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface rvmTransitionViewController : NSViewController

@property (strong) IBOutlet NSView *placeHolder;

-(void)animateIn;
-(void)animateOut;

@end
