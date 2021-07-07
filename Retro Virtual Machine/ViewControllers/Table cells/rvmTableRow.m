//
//  rvmTableRow.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 2/2/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmTableRow.h"
#import "NSColor+rvmNSColors.h"

@implementation rvmTableRow

-(void)drawSelectionInRect:(NSRect)dirtyRect
{
  if(self.selectionHighlightStyle==NSTableViewSelectionHighlightStyleRegular)
  {
    if(self.selected)
    {
      [[NSColor goldWithAlpha:0.5] setFill];
      NSRectFill(dirtyRect);
    }
  }
  else
    [super drawSelectionInRect:dirtyRect];
}

@end
