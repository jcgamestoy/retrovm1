//
//  rvmZXSpectrum48kIssue2.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 12/05/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmZXSpectrum48kIssue2.h"


@implementation rvmZXSpectrum48kIssue2

-(void)initModel
{
  [super initModel];
  
  speccy->cpu->in=s48kIssue2_in;
}

@end
