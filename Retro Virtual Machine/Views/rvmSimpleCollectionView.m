//
//  rvmSimpleCollectionView.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 25/03/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmSimpleCollectionView.h"

@implementation NSView(rvmSimpleCollectionView)

-(rvmSimpleCollectionView *)rvmSimpleCollectionView
{
  id e=self;
  
  do
  {
    e=[e superview];
    if([e isKindOfClass:[rvmSimpleCollectionView class]])
    {
      return e;
    }
  }while(e);
  
  return nil;
}

@end

@interface rvmSimpleCollectionView()
{
  id<rvmSimpleCollectionViewItemProtocol> selected;
  NSString *selectedKey;
  NSDictionary *selectedItem;
  NSUInteger selectedIndex;
}

@end

@implementation rvmSimpleCollectionView

- (id)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    //_viewControllers=[NSMutableArray array];
    _items=[NSMutableDictionary dictionary];
  }
  return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
  //if(self.inLiveResize) [self layoutCollection];
  [super drawRect:dirtyRect];
}

-(void)addItem:(NSViewController *)viewController toSection:(NSString *)key tag:(id)tag index:(NSNumber*)index
{
  NSMutableArray *a=_items[key][@"items"];
  [a addObject:@{@"viewController":viewController,@"tag":tag,@"index":index}];
  [a sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    NSNumber *n1=obj1[@"index"];
    NSNumber *n2=obj2[@"index"];
    
    return [n1 compare:n2];
  }];
  
  [self addSubview:viewController.view];
  [self layoutSubtreeIfNeeded];
  //[self layoutCollection];
}

-(void)addSection:(NSString *)key viewController:(NSViewController *)controller
{
  _items[key]=@{@"viewController":controller,@"items":[NSMutableArray array]};
  controller.view.translatesAutoresizingMaskIntoConstraints=YES;
  [self addSubview:controller.view];
  [self layoutSubtreeIfNeeded];
  //[self layoutCollection];
}

-(void)removeTag:(id)tag inSection:(NSString*)section
{
  NSMutableArray *items=_items[section][@"items"];
  for(NSDictionary *d in items)
  {
    if(d[@"tag"]==tag)
    {
      NSViewController *vc=d[@"viewController"];
      [vc.view removeFromSuperview];
      [items removeObject:d];
      [self layoutSubtreeIfNeeded];
      //[self layoutCollection];
      return;
    }
  }
}

-(void)removeAllInSection:(NSString*)section
{
  NSMutableArray *items=_items[section][@"items"];
  for(NSDictionary *d in items)
  {
    NSViewController *v=d[@"viewController"];
    [v.view removeFromSuperview];
  }
  
  [items removeAllObjects];
  [self layoutSubtreeIfNeeded];
  //[self layoutCollection];
}

-(BOOL)isFlipped
{
  return YES;
}

-(void)layoutCollection
{
  NSRect frame=self.frame;
  double x,w,y,my;
  
  w=frame.size.width;
  my=0;
  //x=_hSpace;
  //y=_topMargin+_vSpace;
  
  for(NSString *key in _items)
  {
    NSDictionary *section=_items[key];
    NSArray *a=section[@"items"];
    
    NSView *sv=((NSViewController*)section[@"viewController"]).view;
    
    [sv setHidden:a.count==0];
    if(a.count==0) continue;
    NSRect svf=sv.frame;
    
    svf.origin.x=0;
    svf.origin.y=my;
    svf.size.width=w;
    
    //[NSAnimationContext currentContext].allowsImplicitAnimation=NO;
    sv.animator.frame=svf;
    //[self layoutSubtreeIfNeeded];
    //[NSAnimationContext currentContext].allowsImplicitAnimation=YES;
    //NSLog(@"x: %f y: %f w:%f h:%f",svf.origin.x,svf.origin.y,svf.size.width,svf.size.width);
    y=my+svf.size.height+_vSpace;
    my=0;
    x=_hSpace;
    
    for(int i=0;i<a.count;i++)
    {
      NSDictionary *it=a[i];
      NSView *v=((NSViewController*)it[@"viewController"]).view;
      
      NSRect vFrame=v.frame;
      vFrame.origin.x=x;
      x+=vFrame.size.width+_hSpace;
      
      if(x>w)
      {
        vFrame.origin.x=_hSpace;
        x=vFrame.size.width+2*_hSpace;
        y=my;
        my=0;
      }
      
      vFrame.origin.y=y;
      double myp=y+vFrame.size.height+_vSpace;
      my=(myp>my)?myp:my;
      
      //NSLog(@"v: %@, frame:(%f,%f,%f,%f) nframe:(%f,%f,%f,%f)",v,v.frame.origin.x,v.frame.origin.y,v.frame.size.width,v.frame.size.height,vFrame.origin.x,vFrame.origin.y,v.frame.size.width,vFrame.size.height);
      v.animator.frame=vFrame;
    }
  }
  
//  NSLayoutConstraint *heightConstraint;
//  for (NSLayoutConstraint *constraint in self.constraints) {
//    if (constraint.firstAttribute == NSLayoutAttributeHeight) {
//      heightConstraint = constraint;
//      break;
//    }
//  }
//  
//  heightConstraint.constant = my;
  
  frame.size.height=my;
  self.frame=frame;
  
  //[self layoutSubtreeIfNeeded];
}

-(void)resizeWithOldSuperviewSize:(NSSize)oldSize
{
  //[self layoutCollection];
  [super resizeWithOldSuperviewSize:oldSize];
  [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
    //context.allowsImplicitAnimation=YES;
    context.duration=0.5;
    [self layoutCollection];
    [self layoutCollection];
  } completionHandler:^{
    //Res
  }];
}

-(void)layoutSubtreeIfNeeded
{
  [self layoutCollection];
  [super layoutSubtreeIfNeeded];
  [self layoutCollection];
}

-(void)viewControllerOpen:(NSViewController *)viewController
{
  for(NSString* key in _items)
  {
    int i=0;
    for(NSDictionary *it in _items[key][@"items"])
    {
      if(viewController==it[@"viewController"])
      {
        [self.delegate itemSelected:i inSection:key tag:it[@"tag"]];
        return;
      }
      i++;
    }
  }
}

-(void)viewControllerSelected:(id<rvmSimpleCollectionViewItemProtocol>)viewController
{
  for(NSString* key in _items)
  {
    uint i=0;
    for(NSDictionary *it in _items[key][@"items"])
    {
      id<rvmSimpleCollectionViewItemProtocol> v=it[@"viewController"];
      [v unmark];
      if(v==viewController)
      {
        selectedKey=key;
        selectedItem=it;
        selectedIndex=i;
      }
      i++;
    }
  }
  
  [self.window makeFirstResponder:self];
  selected=viewController;
  [viewController mark];
}

-(BOOL)acceptsFirstResponder
{
  return YES;
}

-(BOOL)canBecomeKeyView
{
  return YES;
}

-(void)keyDown:(NSEvent *)event
{
  if(event.keyCode==36 && selected)
  {
    [selected rename];
  }
  else if(event.keyCode==51 && selected && selectedKey)
  {
    NSViewController *vc=(NSViewController*)selected;
    [vc.view removeFromSuperview];
    NSMutableArray *a=_items[selectedKey][@"items"];
    [a removeObject:selectedItem];
    [_delegate itemRemoved:selectedIndex inSection:selectedKey tag:selectedItem[@"tag"]];
    NSLog(@"removed");
    [self layoutSubtreeIfNeeded];
    
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
      context.allowsImplicitAnimation=YES;
      context.duration=0.5;
      [self layoutCollection];
      //[self layoutCollection];
    } completionHandler:^{
      //[self layoutCollection];
    }];
  }
}
@end
