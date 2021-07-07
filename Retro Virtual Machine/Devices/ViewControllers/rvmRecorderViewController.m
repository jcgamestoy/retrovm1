//
//  rvmRecorderViewController.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 27/05/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmRecorderViewController.h"

@interface rvmRecorderViewController ()

@end

@implementation rvmRecorderViewController

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
  self.recB.imageName=@"recorder";
  self.playB.imageName=@"recorder";
  self.rewB.imageName=@"recorder";
  self.fwdB.imageName=@"recorder";
  self.ejB.imageName=@"recorder";
  self.psB.imageName=@"recorder";
  
  [self animateOut];
  
  [self.browserList setTarget:self];
  [self.browserList setDoubleAction:NSSelectorFromString(@"onBrowserDoubleClick:")];
}

@end
