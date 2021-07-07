//
//  rvmMachinesCollectionViewController.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 24/03/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "rvmNavigationItemViewController.h"
#import "rvmSimpleCollectionView.h"
#import "rvmArchitecture.h"

@interface rvmMachinesCollectionViewController : rvmNavigationItemViewController<rvmSimpleCollectionViewDelegateProtocol>

@property NSMutableArray *recentMachines;
@property NSMutableArray *machinesDocuments;
@property (strong) IBOutlet rvmSimpleCollectionView *collection;

-(void)machineRunning:(rvmArchitecture*)doc;
-(void)machineStopped:(rvmArchitecture*)doc;

-(void)openDocument:(id)sender;
-(void)openFile:(NSURL*)filename;
-(IBAction)onClearRecent:(id)sender;

-(void)checkUpdate;
@end
