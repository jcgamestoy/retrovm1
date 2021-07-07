//
//  NSView+AutolayoutExtension.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 13/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import "NSView+AutolayoutExtension.h"

@implementation NSView (AutolayoutExtension)

-(void)addStringConstraints:(NSArray *)constraints names:(NSDictionary *)names
{
  for(NSString *s in constraints)
  {
    NSArray *a=[NSLayoutConstraint constraintsWithVisualFormat:s options:0 metrics:nil views:names];
    
    [self addConstraints:a];
  }
}

-(NSLayoutConstraint *)getConstraintForView:(NSView *)left toView:(NSView *)right attribute:(NSLayoutAttribute)attr
{
  for(NSLayoutConstraint* c in self.constraints)
  {
    if(c.firstItem==left && c.secondItem==right && c.firstAttribute==attr) return c;
  }
  
  return nil;
}

-(void)removeContraintForView:(NSView *)left toView:(NSView *)right attribute:(NSLayoutAttribute)attr
{
  for(NSLayoutConstraint* c in self.constraints)
  {
    if(c.firstItem==left && c.secondItem==right && c.firstAttribute==attr)
    {
      [self removeConstraint:c];
      return;
    }
  }
}

@end
