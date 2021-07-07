//
//  rvmMachinesRunningViewController.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 03/05/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmMachinesRunningViewController.h"
#import "rvmSnowLayer.h"
#import "rvmSimpleCollectionView.h"

@interface rvmMachinesRunningViewController ()
{
  rvmSnowLayer *snow;
}
@end

@implementation rvmMachinesRunningViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      snow=[rvmSnowLayer snowLayer];
      snow.cornerRadius=8.0;
      //[_viewPlaceholder setWantsLayer:YES];
      //_viewPlaceholder.layer=snow;
    }
    return self;
}

-(void)setMachine:(id)machine
{
  snow.machine=machine;

}

-(void)awakeFromNib
{
  _viewPlaceholder.layer=snow;
  //_viewPlaceholder.delegate=self;
  __weak rvmMachinesRunningViewController *v=self;
  
  _viewPlaceholder.onClick=^(rvmAlphaButton* sender) {
    [[v.view rvmSimpleCollectionView] viewControllerOpen:v];
  };
}

-(void)mark
{
  
}

-(void)unmark
{
  
}

-(void)rename
{
  
}
@end
