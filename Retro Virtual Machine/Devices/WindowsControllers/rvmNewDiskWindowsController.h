//
//  rvmNewDiskWindowsController.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 29/07/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "rvmMachineProtocol.h"
#import "rvmDskDecoder.h"

@protocol rvmNewDiskProtocol <NSObject>

-(void)newDisk:(rvmDskDecoder*)dsk;

@end

@interface rvmNewDiskWindowsController : NSWindowController

@property id<rvmNewDiskProtocol> delegate;

@end
