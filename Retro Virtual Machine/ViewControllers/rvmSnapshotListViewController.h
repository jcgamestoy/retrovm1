//
//  rvmSnapshotListViewController.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 16/1/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmTransitionViewController.h"
#import "rvmArchitecture.h"
#import "rvmAlphaButton.h"

//@interface rvmFileNode:NSObject
//{
//  @public
//  NSString *path;
//  NSMutableArray *childs;
//}

//+(rvmFileNode*)newForPath:(NSString*)path;
//@end

@interface rvmSnapshotListViewController : rvmTransitionViewController<NSOutlineViewDataSource,NSOutlineViewDelegate,NSTextFieldDelegate>

@property (nonatomic) rvmArchitecture *doc;

@property (weak) IBOutlet rvmAlphaButton *exportSna;
@property (weak) IBOutlet rvmAlphaButton *exportZ80;
@property (weak) IBOutlet rvmAlphaButton *exportPng;

@property (strong) IBOutlet NSPopover *popExport;
@end
