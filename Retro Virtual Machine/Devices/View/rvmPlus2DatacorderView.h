//
//  rvmPlus2DatacorderView.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 14/05/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

#import "rvmCassetteViewProtocol.h"
#import "rvmTapeDecoderProtocol.h"
#import "rvmRemovableTableCellView.h"


@interface rvmPlus2DatacorderView : NSView<rvmCassetteViewProtocol,NSOutlineViewDataSource,NSOutlineViewDelegate,rvmRemovableTableCellViewProtocol>

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx;
-(void)animateIn;
-(void)animateOut;

-(void)hideCassette;
-(void)showCassette;

-(NSImage*)chasisImage;
-(NSImage*)chasisDoorImage;
-(CGRect)chasisFrame;
-(CGRect)chasisDoorFrame;
-(CGRect)cassetteFrame;
-(CGPoint)wheel1Point;
-(CGPoint)wheel2Point;
-(CGRect)cassetteNameFrame;
-(CGRect)blockNameFrame;

@property (nonatomic) id<rvmTapeDecoderProtocol> decoder;
@property (nonatomic,assign) IBOutlet NSOutlineView *list;
@property (weak) IBOutlet NSButton *playButton;
@property (weak) IBOutlet NSButton *recButton;

-(void)go:(uint)index;
-(IBAction)onStop:(id)sender;

@end
