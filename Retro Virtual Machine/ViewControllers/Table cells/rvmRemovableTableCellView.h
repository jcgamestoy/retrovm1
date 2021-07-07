//
//  rvmRemovableTableCellView.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 18/1/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

IB_DESIGNABLE

@protocol rvmRemovableTableCellViewProtocol <NSObject>

-(void)onDelete:(id)object;

@end


@interface rvmRemovableTableCellView : NSTableCellView

@property id object;

@property (weak) id<rvmRemovableTableCellViewProtocol> delegate;

-(IBAction)onDelete:(id)sender;

@end
