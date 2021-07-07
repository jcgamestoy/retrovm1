//
//  rvmAmstradCPC464RecorderViewController.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 28/9/15.
//  Copyright © 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmAmstradCPC464RecorderViewController.h"
#import "rvmTZXDecoder.h"
#import "rvmCSWDecoder.h"

@interface rvmAmstradCPC464RecorderViewController ()

@end

@implementation rvmAmstradCPC464RecorderViewController

-(NSArray *)tapeDecoders
{
  return @[@[@"cdt",@"csw"],@[[rvmTZXDecoder class],[rvmCSWDecoder class]]];
}

@end
