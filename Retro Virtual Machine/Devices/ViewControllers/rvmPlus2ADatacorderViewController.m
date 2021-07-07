//
//  rvmPlus2ADatacorderViewController.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 25/05/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmPlus2ADatacorderViewController.h"

@interface rvmPlus2ADatacorderViewController ()

@end

@implementation rvmPlus2ADatacorderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)awakeFromNib
{
  [super awakeFromNib];
  //self.background.backgroundColor=[NSColor colorWithPatternImage:[NSImage imageNamed:@"mainPattern"]];
  self.recB.imageName=@"button2A.2";
  self.playB.imageName=@"button2A.2";
  self.rewB.imageName=@"button2A.2";
  self.fwdB.imageName=@"button2A.2";
  self.ejB.imageName=@"button2A.2";
  self.psB.imageName=@"button2A.2";
  
  [self animateOut];
  
  [self.browserList setTarget:self];
  [self.browserList setDoubleAction:NSSelectorFromString(@"onBrowserDoubleClick:")];
}

@end
