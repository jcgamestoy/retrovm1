//
//  rvmSimpleCollectionView.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 25/03/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "rvmBackgroundView.h"

@protocol rvmSimpleCollectionViewDelegateProtocol <NSObject>

-(void)itemSelected:(NSUInteger)index inSection:(NSString*)section tag:(id)tag;
-(void)itemRemoved:(NSUInteger)index inSection:(NSString*)section tag:(id)tag;
@end

@protocol rvmSimpleCollectionViewItemProtocol<NSObject>

-(void)mark;
-(void)unmark;
-(void)rename;

@end

@class rvmSimpleCollectionView;

@interface NSView(rvmSimpleCollectionView)

-(rvmSimpleCollectionView*)rvmSimpleCollectionView;

@end

@interface rvmSimpleCollectionView : rvmBackgroundView

//@property NSMutableArray *viewControllers;
@property NSMutableDictionary * items;

@property double hSpace;
@property double vSpace;
@property double topMargin;

@property id<rvmSimpleCollectionViewDelegateProtocol> delegate;
-(void)layoutCollection;

-(void)addItem:(NSViewController *)viewController toSection:(NSString *)key tag:(id)tag index:(NSNumber*)index;
-(void)removeTag:(id)tag inSection:(NSString*)section;
-(void)removeAllInSection:(NSString*)section;

-(void)viewControllerOpen:(NSViewController*)viewController;

-(void)viewControllerSelected:(id<rvmSimpleCollectionViewItemProtocol>)viewController;

-(void)addSection:(NSString*)key viewController:(NSViewController*)controller;
@end
