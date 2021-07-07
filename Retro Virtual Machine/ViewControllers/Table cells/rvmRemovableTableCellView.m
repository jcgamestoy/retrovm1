//
//  rvmRemovableTableCellView.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 18/1/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmRemovableTableCellView.h"
#import "NSColor+rvmNSColors.h"

@implementation rvmRemovableTableCellView

-(IBAction)onDelete:(id)sender
{
  if(_delegate) [_delegate onDelete:_object];
}

@end
