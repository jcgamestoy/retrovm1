//
//  rvmPlus2DatacorderViewController.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 14/05/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "rvmPlus2DatacorderView.h"
#import "rvmMachineProtocol.h"
#import "rvmBackgroundView.h"
#import "rvmTexturedButton.h"
#import "rvmMediaLoader.h"
#import "rvmTapeView.h"
#import "rvmAlphaButton.h"

#import "rvmTransitionViewController.h"

@interface rvmPlus2DatacorderViewController : rvmTransitionViewController<rvmMediaLoader>

//@property (strong) IBOutlet NSView *placeHolder;

@property (weak) IBOutlet rvmPlus2DatacorderView *datacorder;

@property (strong) IBOutlet rvmBackgroundView *background;
@property (strong) IBOutlet rvmTexturedButton *recB;
@property (strong) IBOutlet rvmTexturedButton *playB;
@property (strong) IBOutlet rvmTexturedButton *rewB;
@property (strong) IBOutlet rvmTexturedButton *fwdB;
@property (strong) IBOutlet rvmTexturedButton *ejB;
@property (strong) IBOutlet rvmTexturedButton *psB;
@property (strong) IBOutlet NSPopover *browser;
@property (strong) IBOutlet NSOutlineView *browserList;

@property (strong) IBOutlet rvmTapeView* tapeView;
@property (strong) IBOutlet NSPopover *tapeNewPop;

@property id<rvmMachineProtocol> machine;
@property (weak) IBOutlet rvmAlphaButton *tzxNew;
@property (weak) IBOutlet rvmAlphaButton *pzxNew;
@property (weak) IBOutlet rvmAlphaButton *tapNew;
@property (weak) IBOutlet rvmAlphaButton *cswNew;

-(IBAction)onInsertMedia:(id)sender;
-(IBAction)onEject:(id)sender;
-(NSArray*)tapeDecoders;

-(void)loadMediaFile:(NSURL*)filename sound:(BOOL)b;

@end
