//
//  rvmMachinesRunningViewController.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 03/05/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "rvmAlphaButton.h"
#import "rvmSimpleCollectionView.h"

@interface rvmMachinesRunningViewController : NSViewController<rvmSimpleCollectionViewItemProtocol>

@property (weak) IBOutlet rvmAlphaButton *viewPlaceholder;
@property (weak) IBOutlet NSTextField *label;

-(void)setMachine:(id)machine;

@end
