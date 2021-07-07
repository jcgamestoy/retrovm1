//
//  rvmPlus3FddView.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 06/07/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface rvmPlus3FddView : NSView
{
  @public
  CALayer *chasis,*led,*diskLome;
  CATextLayer *diskName;
}

@property (nonatomic) NSString *diskTitle;

-(void)animateIn;
-(void)animateOut;

-(void)showDisk;
-(void)hideDisk;

-(void)led:(uint32)b;

@end
