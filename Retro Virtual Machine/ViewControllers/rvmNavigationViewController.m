//
//  rvmNavigationViewController.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 24/03/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmNavigationViewController.h"
#import "rvmNavigationItemViewController.h"

@interface rvmNavigationViewController ()
{
  NSMutableArray *stack;
  NSView *currentView;
}

@property (weak) IBOutlet NSToolbarItem *nav;

@end

@implementation rvmNavigationViewController

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
  stack=[NSMutableArray array];
  _nav.label=@"";
  _nav.image=nil;
  //[_navButton setHidden:YES];
}

-(void)pushViewController:(rvmNavigationItemViewController *)viewController
{
  rvmNavigationItemViewController *curr=[stack lastObject];
  [stack addObject:viewController];
  viewController.navigationController=self;
  
  if(stack.count>1)
  {
    rvmNavigationItemViewController *prev=stack[stack.count-2];
    //_navButton.title=prev.navTitle;
    _nav.label=prev.navTitle;
    _nav.image=prev.navImage;
    
    if(stack.count==2)
    {
      //[_navButton setHidden:NO];
      //[_navButton setAlphaValue:0];
    }
    
    NSRect r=self.view.bounds;
    r.origin.x=r.size.width;
    viewController.view.frame=r;
    [viewController.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self.view addSubview:viewController.view positioned:NSWindowBelow relativeTo:nil];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
      [context setDuration:0.5];
      NSRect r2=self.view.bounds;
      viewController.view.animator.frame=r2;
      r2.origin.x=-r2.size.width;
      curr.view.animator.frame=r2;
      
      if(stack.count==2)
      {
        //[_navButton.animator setAlphaValue:1];
      }
    } completionHandler:^{
      [curr.view removeFromSuperview];
    }];
  }
  else
  {
    _nav.label=@"";
    _nav.image=nil;
    //[_navButton setHidden:YES];
    
    viewController.view.frame=self.view.bounds;
    [viewController.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    //[self.view addSubview:viewController.view positioned:NSWindowBelow relativeTo:nil];
    [self.view addSubview:viewController.view];
  }
}

-(IBAction)popViewController:(id)sender
{
  if(stack.count>1)
  {
    rvmNavigationItemViewController *curr=[stack lastObject];
    rvmNavigationItemViewController *prev=stack[stack.count-2];
    [stack removeLastObject];
    
    NSRect r=self.view.bounds;
    r.origin.x=-r.size.width;
    prev.view.frame=r;
    [prev.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self.view addSubview:prev.view positioned:NSWindowBelow relativeTo:nil];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
      [context setDuration:0.5];
      NSRect r2=self.view.bounds;
      prev.view.animator.frame=r2;
      r2.origin.x=r2.size.width;
      curr.view.animator.frame=r2;
      
      if(stack.count==1)
      {
        //[_navButton.animator setAlphaValue:0];
      }
    } completionHandler:^{
      [curr.view removeFromSuperview];
      //[stack removeLastObject];
      
      if(self->stack.count>1)
      {
        rvmNavigationItemViewController *pprev=self->stack[self->stack.count-2];
        //_navButton.title=pprev.navTitle;
        self->_nav.label=pprev.navTitle;
        self->_nav.image=pprev.navImage;
      }
      else
      {
        self->_nav.label=@"";
        self->_nav.image=nil;
        //[_navButton setHidden:YES];
      }
    }];
  }
}

@end
