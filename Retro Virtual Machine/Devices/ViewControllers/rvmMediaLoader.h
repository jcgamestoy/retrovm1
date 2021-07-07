//
//  rvmMediaLoader.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 10/07/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol rvmMediaLoader <NSObject>

-(void)loadMedia:(int)tag;

@end
