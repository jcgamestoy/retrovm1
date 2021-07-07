//
//  NSView+AutolayoutExtension.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 13/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (AutolayoutExtension)

-(void)addStringConstraints:(NSArray*)constraints names:(NSDictionary*)names;
-(NSLayoutConstraint*)getConstraintForView:(NSView*)left toView:(NSView*)right attribute:(NSLayoutAttribute)attr;
-(void)removeContraintForView:(NSView *)left toView:(NSView *)right attribute:(NSLayoutAttribute)attr;

@end
