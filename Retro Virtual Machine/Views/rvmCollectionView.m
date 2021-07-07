//
//  rvmCollectionView.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 28/01/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "rvmCollectionView.h"
#import "rvmBackgroundView.h"
#import "NSColor+rvmNSColors.h"

@interface rvmCollectionView()
{
  NSMutableArray *viewCollection;
  NSView *selectedPanel;
  NSUInteger selectedIndex;
  bool itemSelected;
  CGFloat selectedHeight;
  
  NSViewController *selectedController;
}

@end

@implementation NSView(rvmCollectionView)

-(rvmCollectionView *)rvmCollectionView
{
  id e=self;
  
  do
  {
    e=[e superview];
    if([e isKindOfClass:[rvmCollectionView class]])
    {
      return e;
    }
  }while(e);
  
  return nil;
}

@end

@implementation rvmCollectionView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)awakeFromNib
{
  [self setAutoresizesSubviews:NO];
  self.backColor=[NSColor white];

  viewCollection=[NSMutableArray array];
  selectedPanel=[rvmBackgroundView new];
  
  CGRect f=selectedPanel.frame;
  f.size.width=self.frame.size.width;
  f.size.height=0;
  selectedPanel.frame=f;
  selectedHeight=200;
  [self addSubview:selectedPanel];
}

-(void)addItem:(NSView*)view
{
  [viewCollection addObject:view];
  [self addSubview:view];
  [self layoutSubtreeIfNeeded];
  [self layoutCollection:YES];
}

-(BOOL)isFlipped
{
  return YES;
}

-(void)layoutCollection:(BOOL)begin
{
  CGRect frame=self.frame;
  CGFloat w,x,y,my;
  bool addPanel=NO;
  bool panelAdded=NO;
  
  w=frame.size.width;
  my=0;
  x=_hSpace;
  y=_topMargin;
  
  for(int i=0;i<viewCollection.count;i++)
  {
    if(itemSelected && i==selectedIndex)
    {
      addPanel=YES;
    }
    
    NSView *v=viewCollection[i];
    CGRect vFrame=v.frame;
    vFrame.origin.x=x;
    x+=v.frame.size.width+_hSpace;
    
    if(x>w) //new Line
    {
      if(addPanel && selectedIndex!=i)
      {
        panelAdded=YES;
        [self addPanel:my begin:begin];
        
        if(!begin) my+=selectedHeight+_vSpace;
      }
      
      vFrame.origin.x=_hSpace;
      x=vFrame.size.width+2*_hSpace;
      
      y=my;
      my=0;
      if(selectedIndex!=i) addPanel=NO;
    }
    
    vFrame.origin.y=y;
    CGFloat myp=y+vFrame.size.height+_vSpace;
    my=(myp>my)?myp:my;
    
    if(!begin) v.animator.frame=vFrame;
    else v.frame=vFrame;
  }
  
  if(addPanel)
  {
    panelAdded=YES;
    [self addPanel:my begin:begin];
    
    my+=selectedHeight+_vSpace;
  }
  
  if(!panelAdded && !begin)
  {
    CGRect pf=selectedPanel.frame;
    pf.size.height=0;
    selectedPanel.animator.frame=pf;
  }
  
  frame.size.height=my;
  if(begin) self.frame=frame;
  else self.animator.frame=frame;
}

-(void)addPanel:(CGFloat)y begin:(BOOL)begin
{
  NSScrollView *sv=[self enclosingScrollView];
  
  CGRect pf=selectedPanel.frame;
  pf.origin.x=0;
  pf.origin.y=y;
  pf.size.width=self.frame.size.width;
  pf.size.height=selectedHeight;
  
  if(begin)
  {
    if(itemSelected) pf.size.height=0;
  }
  else
  {
    if(!itemSelected) pf.size.height=0;
  }
  
  if(sv)
  {
    CGRect clipBounds=sv.contentView.bounds;
    CGFloat d=(pf.origin.y+pf.size.height)-(clipBounds.origin.y+clipBounds.size.height);
    if(d>0)
    {
      clipBounds.origin.y+=d;
      if(begin) [sv.contentView setBoundsOrigin:clipBounds.origin];
      else [sv.contentView.animator setBoundsOrigin:clipBounds.origin];
      [sv reflectScrolledClipView:sv.contentView];
    }
  }
  
  if(begin) selectedPanel.frame=pf;
  else selectedPanel.animator.frame=pf;
}

-(void)mouseDown:(NSEvent *)theEvent
{
  itemSelected=NO;
  [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
    [context setDuration:0.5];
    [self layoutCollection:NO];
  } completionHandler:^{

  }];
}

-(void)viewControllerSelected:(NSViewController*)viewController
{
  if(itemSelected)
  {
    itemSelected=NO;
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
      [context setDuration:0.5];
      //[context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];

      [self layoutCollection:NO];
    } completionHandler:^{
    }];
  }
  else
  {
    itemSelected=YES;
    selectedIndex=[viewCollection indexOfObject:viewController.view];
    selectedController=[_delegate selectedViewController:selectedIndex];
    //selectedController=viewController;
    selectedHeight=selectedController.view.bounds.size.height;
    [selectedPanel removeFromSuperview];
    selectedPanel=selectedController.view;
    [self addSubview:selectedPanel];
    
    [self layoutCollection:YES];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
      [context setDuration:0.5];
      //[context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
      [self layoutCollection:NO];
      
    } completionHandler:^{

    }];
  }
}
@end
