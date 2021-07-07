//
//  rvmZxSpectrum48kKeyboardView.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 24/08/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "rvmMachineProtocol.h"

IB_DESIGNABLE
@interface rvmZxSpectrum48kKeyboardView : NSView
{
  CALayer *chasis,*labels;
  NSMutableArray *keys;
}

-(void)makeChasis;
-(void)makeLabels;
-(void)makeKeys;

-(void)highlightKey:(rvmMachineKeyS*)key;
-(void)unHighlightKey:(rvmMachineKeyS*)key;
-(void)unHighlightAll;

-(uint)extraKey:(rvmMachineKeyS*)k index:(int*)i;
-(NSImage*)keyImage:(uint)ki highlight:(bool)h;
-(uint)keyCount;

@property (nonatomic) uint state;

@property (strong) void (^onKeyClick)(uint code);

@end
