//
//  rvmCollectionView.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 28/01/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "rvmBackgroundView.h"
#import "rvmCollectionViewDelegateProtocol.h"

@class rvmCollectionView;

@interface NSView(rvmCollectionView)

-(rvmCollectionView*)rvmCollectionView;

@end

@interface rvmCollectionView : rvmBackgroundView

//@property (nonatomic) Class itemClass;
//@property NSString *nibName;

@property double hSpace;
@property double vSpace;

@property double topMargin;

@property id<rvmCollectionViewDelegateProtocol> delegate;

-(void)addItem:(NSView*)view;

//-(void)mouseDown:(NSEvent *)theEvent subView:(NSView*)sv;
-(void)viewControllerSelected:(NSViewController*)viewController;
@end
