//
//  rvmInvesSpectrumPlusKeyboardView.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 7/3/16.
//  Copyright © 2016 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmInvesSpectrumPlusKeyboardView.h"

@implementation rvmInvesSpectrumPlusKeyboardView

-(void)makeChasis
{
  chasis=[CALayer layer];
  chasis.contents=[NSImage imageNamed:@"invesChasis"];
  chasis.frame=NSMakeRect(0, 0, 1529, 700);
}

@end
