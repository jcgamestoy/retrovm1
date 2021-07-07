//
//  rvmNavigationItemViewController.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 24/03/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "rvmNavigationViewController.h"
//@class rvmNavigationViewController;

@interface rvmNavigationItemViewController : NSViewController

@property rvmNavigationViewController *navigationController;
@property NSString *navTitle;
@property NSImage *navImage;

@end
