//
//  rvmZXSpectrumPlusKeyboardView.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 29/3/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmZXSpectrumPlusKeyboardView.h"

@implementation rvmZXSpectrumPlusKeyboardView

-(void)makeChasis
{
  chasis=[CALayer layer];
  chasis.contents=[NSImage imageNamed:@"zx+chasis"];
  chasis.frame=NSMakeRect(0, 0, 1529, 700);
}

@end
