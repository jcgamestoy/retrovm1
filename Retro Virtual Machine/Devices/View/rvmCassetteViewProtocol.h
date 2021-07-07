//
//  rvmCassetteViewProtocol.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 16/05/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol rvmCassetteViewProtocol <NSObject>

@property (nonatomic) double length;
@property (nonatomic) double delta;
@property (nonatomic) NSString *cassetteTitle;
@property (nonatomic) NSString *blockTitle;

-(IBAction)onPlay:(id)sender;
-(IBAction)onStop:(id)sender;

-(void)makeEjectSound;
-(void)setBlock:(uint32)i;
@end
