//
//  rvmMachinesCollectionViewController.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 24/03/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmMachinesCollectionViewController.h"
#import "rvmBackgroundView.h"
//#import "rvmCollectionView.h"

#import "NSColor+rvmNSColors.h"

//#import "rvmMachineCollectionItemViewController.h"
#import "rvmMachineItemViewController.h"
#import "rvmNewMachineWindowController.h"
#import "rvmImageView.h"
#import "rvmRecentMachinesHeaderViewController.h"
#import "rvmRunningMachinesHeaderViewController.h"

#import "rvmMachinesRunningViewController.h"
#import "rvmAppDelegate.h"
#import "rvmArchitecture.h"

@interface rvmMachinesCollectionViewController ()
{
  //NSMutableArray *viewControllerList;
  rvmNewMachineWindowController *newMachine;
  NSSavePanel *savePanel;
  //NSOpenPanel *openPanel;
  NSMutableArray *runningMachines;
}

@property (strong) IBOutlet rvmBackgroundView *backgroundView;

@property (strong) IBOutlet rvmImageView *adso;
@property (unsafe_unretained) IBOutlet rvmRecentMachinesHeaderViewController *recentHeader;
@property (strong) IBOutlet rvmRunningMachinesHeaderViewController *runnigHeader;
@property (weak) IBOutlet rvmBackgroundView *updateBox;
@property (weak) IBOutlet NSButton *updateButton;

@end

@implementation rvmMachinesCollectionViewController

static NSArray *zxSpectrumNames;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)awakeFromNib
{
  self.navImage=[NSImage imageNamed:@"machines"];
  self.navTitle=@"Machines";
  //_backgroundView.backgroundColor=[NSColor colorWithPatternImage:[NSImage imageNamed:@"mainPattern"]];
  //_collection.backgroundColor=[NSColor transparent];
  
  runningMachines=[NSMutableArray array];
  
  [_collection addSection:@"recent" viewController:_recentHeader];
  [_collection addSection:@"running" viewController:_runnigHeader];
  
  if(!self.machinesDocuments)
  {
    self.recentMachines=[NSMutableArray array];
    //self.machinesDocuments=[NSMutableArray array];
    //viewControllerList=[NSMutableArray array];
    //_collection.delegate=self;
    [self loadRecentMachines];
  }
  _collection.hSpace=11.0;
  _collection.vSpace=11.0;
  _collection.topMargin=0;
  
  _collection.delegate=self;
  
  savePanel=[(rvmAppDelegate*)[NSApp delegate] savePanel];
  //savePanel.allowedFileTypes=@[@"rvmmachine"];
  
  _adso.image=[NSImage imageNamed:@"adso"];
  
  newMachine=[[rvmNewMachineWindowController alloc] initWithWindowNibName:@"rvmNewMachineWindowController"];
  _updateBox.alphaValue=0.;
}

-(void)loadRecentMachines
{
  NSArray *p=NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
  NSString *dPath=[NSString stringWithFormat:@"%@/Retro Virtual Machine",p[0]];
  
  NSFileManager *f=[NSFileManager defaultManager];
  
  NSError *e;
  BOOL r=[f createDirectoryAtPath:dPath withIntermediateDirectories:YES attributes:nil error:&e];
  if(!r)
  {
    NSException *e=[NSException exceptionWithName:@"Error" reason:@"Error creating application support directory." userInfo:nil];
    @throw e;
  }
  
  //self.recentMachines=[NSMutableArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/machines.plist",dPath]];
  NSData *rm=[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/machines.json",dPath]];
  if(rm)
    self.recentMachines=[NSMutableArray arrayWithArray:[NSJSONSerialization JSONObjectWithData:rm options:0 error:nil]];
  
  if(!self.recentMachines)
  {
    self.recentMachines=[NSMutableArray array];
    _machinesDocuments=[NSMutableArray new];
  }
  else
  {
    NSDocumentController *dc=[NSDocumentController sharedDocumentController];
    [dc clearRecentDocuments:self];
    
    _machinesDocuments=[NSMutableArray arrayWithCapacity:_recentMachines.count];
    
    NSMutableArray *t=[NSMutableArray new];
    for(NSString *p in self.recentMachines)
    {
      if([f fileExistsAtPath:p ])
      {
        [t addObject:p];
      }
    }
    self.recentMachines=t;
    
    uint32 i=0;
    
    //NSMutableIndexSet *toremove=[NSMutableIndexSet new];
    //for(int j=0;j<self.recentMachines.count;j++)
    for(NSString *p in self.recentMachines)
    {
      //NSString *p=self.recentMachines[j];
//      if([f fileExistsAtPath:p])
//      {
        __block uint32 index=i++;
        NSLog(@"%d %@",index,p);
        [_machinesDocuments addObject:@0];
      
        [dc openDocumentWithContentsOfURL:[NSURL fileURLWithPath:p] display:NO completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error) {
          if(!document) return;
          NSLog(@"inside %d %@",index,document.fileURL.path);
          rvmArchitecture *a=(rvmArchitecture*)document;
          self->_machinesDocuments[index]=a;
          
          rvmMachineItemViewController *bv=[[rvmMachineItemViewController alloc] initWithNibName:@"rvmMachineItemViewController" bundle:nil];
          
          
          bv.machineDocument=a;
          [self->_collection addItem:bv toSection:@"recent" tag:a index:[NSNumber numberWithUnsignedInt:index]];
          //bv.imageView.image=[a image];
          bv.image.image=[a image];
          bv.label.stringValue=[a title];
          [bv.label setPreferredMaxLayoutWidth:bv.view.frame.size.width];
        }];
//      }
//      else
//        [toremove addIndex:i];
    }
    
    //[self.recentMachines removeObjectsAtIndexes:toremove];
    [self saveRecentMachines];
  }
}

- (IBAction)onAddItem:(id)sender {
  [self.view.window beginSheet:newMachine.window completionHandler:^(NSModalResponse returnCode) {
    if(returnCode==NSModalResponseOK)
    {
      rvmArchitecture *a=[rvmArchitecture newArchitecture:self->newMachine.browser.selectionIndexPath];
      
      self->savePanel.allowedFileTypes=@[@"rvmmachine"];
      [self->savePanel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        if(result==NSOKButton)
        {
          [a saveToURL:self->savePanel.URL ofType:@"com.madeInAlacant.rvmMachine" forSaveOperation:NSSaveOperation completionHandler:^(NSError *errorOrNil) {
            
            [self.machinesDocuments addObject:a];
            [self.recentMachines addObject:self->savePanel.URL.path];
            
            rvmMachineItemViewController *bv=[[rvmMachineItemViewController alloc] initWithNibName:@"rvmMachineItemViewController" bundle:nil];
            bv.machineDocument=a;
            [self->_collection addItem:bv toSection:@"recent" tag:a index:[NSNumber numberWithInteger:self->_machinesDocuments.count]];

            bv.image.image=a.image;
            bv.label.stringValue=a.title;
            [bv.label setPreferredMaxLayoutWidth:bv.view.frame.size.width ];
            [self saveRecentMachines];
          }];
        }
      }];
    }
  }];
}

-(void)openDocument:(id)sender
{
  //if(!openPanel) {
  NSOpenPanel *openPanel=[(rvmAppDelegate*)[[NSApplication sharedApplication] delegate] openPanel];;
    
  //}
  openPanel.allowedFileTypes=@[@"rvmmachine"];
  [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
    if(result==NSOKButton)
    {
      [self openFile:openPanel.URL];
    }
  }];
}

-(void)openFile:(NSURL*)filename {

    NSDocumentController *dc=[NSDocumentController sharedDocumentController];
    [dc openDocumentWithContentsOfURL:filename display:NO completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error) {
      if(documentWasAlreadyOpen) {
        NSAlert *a=[NSAlert alertWithMessageText:@"Document already open." defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"The machine '%@' is already open.",document.fileURL.lastPathComponent];
        [a beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        }];
        return;
      }
      rvmArchitecture *a=(rvmArchitecture*)document;
      [self.machinesDocuments addObject:a];
      [self.recentMachines addObject:filename.path];
      
      [self saveRecentMachines];
      
      rvmMachineItemViewController *bv=[[rvmMachineItemViewController alloc] initWithNibName:@"rvmMachineItemViewController" bundle:nil];
      bv.machineDocument=a;
      [self->_collection addItem:bv toSection:@"recent" tag:a index:[NSNumber numberWithInteger:self->_recentMachines.count]];
      bv.image.image=a.image;
      bv.label.stringValue=a.title;
      [bv.label setPreferredMaxLayoutWidth:bv.view.frame.size.width ];
    }];
}

-(void)saveRecentMachines
{
  NSArray *p=NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
  NSString *dPath=[NSString stringWithFormat:@"%@/Retro Virtual Machine/machines.json",p[0]];
  
  //[self.recentMachines writeToFile:dPath atomically:YES];
  [[NSJSONSerialization dataWithJSONObject:_recentMachines options:0 error:nil] writeToFile:dPath atomically:YES];
}

-(void)itemSelected:(NSUInteger)index inSection:(NSString *)section tag:(id)tag
{
  rvmArchitecture *a=tag;
  
  rvmAppDelegate *ad=(rvmAppDelegate*)[NSApplication sharedApplication].delegate;
  
  [ad newWindow:self machine:a.machine];
  //[self.navigationController pushViewController:(rvmNavigationItemViewController*)[a.machine configViewController]];
  [self machineRunning:a];
}

-(void)itemRemoved:(NSUInteger)index inSection:(NSString *)section tag:(id)tag
{
  rvmArchitecture *a=tag;
  
  for(int i=0;i<_recentMachines.count;i++)
  {
    if([a.fileURL.path isEqualToString:_recentMachines[i]])
    {
      [_recentMachines removeObjectAtIndex:i];
      break;
    }
  }
  
  [_machinesDocuments removeObject:a];
  [a close];
  [self saveRecentMachines];
}

-(void)machineRunning:(rvmArchitecture*)doc
{
  NSInteger index=[runningMachines indexOfObject:doc];
  
  if(index==NSNotFound)
  {
    rvmMachinesRunningViewController *r=[[rvmMachinesRunningViewController alloc] initWithNibName:@"rvmMachinesRunningViewController" bundle:nil];
    r.view=r.view;
    [r setMachine:doc.machine];
    r.label.stringValue=doc.title;
    [_collection addItem:r toSection:@"running" tag:doc index:@0];
    [runningMachines addObject:doc];
  }
}

-(void)machineStopped:(rvmArchitecture*)doc
{
  NSInteger index=[runningMachines indexOfObject:doc];
  
  if(index!=NSNotFound)
  {
    [_collection removeTag:doc inSection:@"running"];
    [runningMachines removeObject:doc];
  }
}

-(IBAction)onClearRecent:(id)sender
{
  [_collection removeAllInSection:@"recent"];
  [_recentMachines removeAllObjects];
  
  for(NSDocument *d in _machinesDocuments)
  {
    if(d.class==[rvmArchitecture class])
      [d close];
  }
  [self saveRecentMachines];
}

-(void)animateUpdateIn
{
  [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
    context.allowsImplicitAnimation=YES;
    context.duration=1.0;
    _updateBox.alphaValue=1.0;
  } completionHandler:^{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [self animateUpdateOut];
    });
  }];
}

-(void)animateUpdateOut
{
  [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
    context.allowsImplicitAnimation=YES;
    context.duration=1.0;
    _updateBox.alphaValue=0.0;
  } completionHandler:^{
    self->_updateBox.hidden=YES;
  }];
}

- (IBAction)onUpdate:(id)sender {
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: @"http://www.retrovirtualmachine.org"]];
}

- (IBAction)onDonation:(id)sender {
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: @"http://www.retrovirtualmachine.org/en/donate"]];
}

-(void)checkUpdate
{
  NSURLSessionDataTask *t=[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"http://www.retrovirtualmachine.org/meta/update.json"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    NSHTTPURLResponse *res=(NSHTTPURLResponse*)response;
    
    if(res.statusCode==200)
    {
      NSDictionary *d=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
      
      int v=[[[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"] intValue];
      int wv=[d[@"version"] intValue];
      
      if(wv>v) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
          self->_updateBox.backColor=[NSColor fireBrickWithAlpha:0.75];
          self->_updateButton.title=[NSString stringWithFormat:@"⚠️ Update to rvm v%@ ⚠️",d[@"versionString"]];
          [self animateUpdateIn];
        });
        return;
      }
    }
      dispatch_async(dispatch_get_main_queue(), ^{
        self->_updateBox.backColor=[NSColor forestGreenWithAlpha:0.75];
        self->_updateButton.title=@"RVM is up to date 🍺";
        [self animateUpdateIn];
      });
    
  }];
  
  [t resume];
}


@end
