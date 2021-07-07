//
//  rvmOSDViewController.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 30/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "rvmBox.h"

@interface rvmOSDViewController : NSViewController

@property (weak) IBOutlet NSTextField *label;
@property (strong) IBOutlet rvmBox *background;
@property (strong) NSString* fixedText;
@property (strong) NSImage* fixedImage;
@property (nonatomic) bool visible;

-(void)showMessage:(NSString*)message image:(NSImage*)image;
-(void)showMessage:(NSString *)message size:(uint)size image:(NSImage*)image;
-(void)fixedText:(NSString *)fixedText image:(NSImage*)image;

@end
