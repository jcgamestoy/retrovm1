//
//  rvmOutlineView.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 2/2/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmOutlineView.h"
#import "NSColor+rvmNSColors.h"

@implementation rvmOutlineView

-(void)highlightSelectionInClipRect:(NSRect)clipRect
{
  [[NSColor gold] setFill];
  NSRectFill(clipRect);
}

@end
