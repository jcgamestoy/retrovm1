//
//  rvmMachineItemViewController.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 25/03/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "rvmImageView.h"
#import "rvmSimpleCollectionView.h"
#import "rvmArchitecture.h"

@interface rvmMachineItemViewController : NSViewController<NSTextFieldDelegate,rvmSimpleCollectionViewItemProtocol>

@property (strong) IBOutlet NSTextField *label;
@property (strong) IBOutlet rvmImageView *image;
@property (weak) rvmArchitecture* machineDocument;

-(void)mark;
-(void)unmark;

@end
