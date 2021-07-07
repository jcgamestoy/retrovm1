//
//  rvmPlus2ADatacorderView.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 25/05/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmPlus2ADatacorderView.h"

@implementation rvmPlus2ADatacorderView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(NSImage*)chasisImage
{
  return [NSImage imageNamed:@"chasis+2A.2"];
}

-(NSImage*)chasisDoorImage
{
  return [NSImage imageNamed:@"chasisDoor+2A.2"];;
}

@end
