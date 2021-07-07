//
//  rvmZxSpectrumPlusSpaKeyboardView.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 21/2/16.
//  Copyright © 2016 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmZxSpectrumPlusSpaKeyboardView.h"

@implementation rvmZxSpectrumPlusSpaKeyboardView

-(void)makeLabels
{
  labels=[CALayer layer];
  labels.contents=[NSImage imageNamed:@"zx128kKLabelsSpa"];
  //labels.backgroundColor=[NSColor red].CGColor;
  labels.frame=NSMakeRect(62,70,1202,431);
}

@end
