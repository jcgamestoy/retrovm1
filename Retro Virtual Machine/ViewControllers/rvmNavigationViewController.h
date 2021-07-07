//
//  rvmNavigationViewController.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 24/03/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class rvmNavigationItemViewController;

@interface rvmNavigationViewController : NSViewController

-(void)pushViewController:(rvmNavigationItemViewController*)viewController;
-(IBAction)popViewController:(id)sender;

@end
