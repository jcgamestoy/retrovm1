//
//  rvmCollectionViewDelegateProtocol.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 18/02/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol rvmCollectionViewDelegateProtocol <NSObject>

-(NSViewController*)selectedViewController:(NSUInteger)index;

@end
