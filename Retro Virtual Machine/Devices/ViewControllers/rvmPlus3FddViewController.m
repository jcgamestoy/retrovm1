//
//  rvmPlus2DatacorderViewController.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 14/05/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmPlus3FddViewController.h"
#import "rvmDskDecoder.h"
#import "rvmDiskView.h"
#import "NSColor+rvmNSColors.h"
#import "rvmNewDiskWindowsController.h"
#import "rvmAppDelegate.h"

@interface rvmPlus3FddViewController ()
{
  NSOpenPanel *op;
  rvmDskDecoder *disk[2];
  uint32 selectedTag;
  rvmNewDiskWindowsController *newDisk;
}

@property (weak) IBOutlet rvmDiskView *diskView;
@property (strong) IBOutlet NSPopover *ejectPanel;

@property (weak) IBOutlet NSButton *writeProtected;
@property (weak) IBOutlet NSButton *bSwitch;
@property (weak) IBOutlet NSOutlineView *dirList;

@end

@implementation rvmPlus3FddViewController

-(void)awakeFromNib
{
  //_background.backgroundColor=[NSColor colorWithPatternImage:[NSImage imageNamed:@"mainPattern"]];
  op=[(rvmAppDelegate*)[[NSApplication sharedApplication] delegate] openPanel];;
  
  
  [self animateOut];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)animateIn
{
  [_fdd animateIn];
  [_fddB animateIn];
 
}

-(void)animateOut
{
  [_fdd animateOut];
  [_fddB animateOut];
}


-(void)loadMedia:(int)tag
{
  rvmPlus3FddView *fddView=tag?_fddB:_fdd;
  
  [fddView hideDisk];
  [_dirList reloadData];
  [_machine insertDisk:nil inDrive:tag];
  disk[tag]=nil;
  [_diskView clear];
  
  [op setAllowedFileTypes:@[@"dsk"]];
  [op setCanChooseFiles:YES];
  [op setCanChooseDirectories:NO];
  [op setAllowsMultipleSelection:NO];
  [op beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
    if(result==NSOKButton)
    {
      @synchronized (self->_machine)
      {
        [self loadMediaFile:self->op.URL sound:NO drive:tag];
      }
    }
  }];
}

-(void)configureDiskView:(rvmDskDecoder*)d
{
  if(d)
  {
    _writeProtected.enabled=YES;
    _writeProtected.state=d.handle->writeProtect?NSOnState:NSOffState;
    [_diskView setTracks:d.handle->tracksN type:d.handle->type name:d->path.lastPathComponent.stringByDeletingPathExtension];
  }
  else
  {
    [_diskView clear];
    _writeProtected.enabled=NO;
  }
}

- (IBAction)onEject:(id)sender {
  NSButton *b=sender;
  selectedTag=(uint32)b.tag;
  [_dirList reloadData];
  [self configureDiskView:disk[selectedTag]];
  [_ejectPanel showRelativeToRect:b.bounds ofView:b preferredEdge:NSMaxYEdge];
}

- (IBAction)onEjectMedia:(id)sender {
  rvmPlus3FddView *fddView=selectedTag?_fddB:_fdd;
  [fddView hideDisk];
  disk[selectedTag]=nil;
  [_dirList reloadData];
  //_writeProtected.enabled=NO;
  //[_diskView clear];
  [self configureDiskView:disk[selectedTag]];
  [_machine insertDisk:nil inDrive:selectedTag];
}

- (IBAction)onInsertMedia:(id)sender {
  [self loadMedia:selectedTag];
}

- (IBAction)onWriteProtected:(NSButton *)sender {
  disk[selectedTag].handle->writeProtect=sender.state==NSOnState;
}

- (IBAction)onDriveBSwitch:(id)sender {
  NSButton *b=sender;
  
  [_fddB.switchSound stop];
  [_fddB.switchSound play];
  if(b.state)
  {
    _fddB.powerLed.backgroundColor=[NSColor orange].CGColor;
    [_machine enableDrive:1];
    [_machine enableDrive:3];
    [_machine insertDisk:disk[1] inDrive:1];
    [_machine insertDisk:disk[1] inDrive:3];
  }
  else
  {
    _fddB.powerLed.backgroundColor=[NSColor sienna].CGColor;
    [_machine disableDrive:1];
    [_machine disableDrive:3];
    [_machine insertDisk:nil inDrive:1];
    [_machine insertDisk:nil inDrive:3];
  }
  

}

- (IBAction)onNewDisk:(id)sender {
  rvmPlus3FddView *fddView=selectedTag?_fddB:_fdd;
  
  [fddView hideDisk];
  [_machine insertDisk:nil inDrive:selectedTag];
  disk[selectedTag]=nil;
  [_diskView clear];
  
  if(!newDisk)
  {
    newDisk=[[rvmNewDiskWindowsController alloc] initWithWindowNibName:@"rvmNewDiskWindowController"];
    newDisk.delegate=self;
  }
  
  [self.view.window beginSheet:newDisk.window completionHandler:^(NSModalResponse returnCode) {
    //
  }];
}

-(void)newDisk:(rvmDskDecoder *)dsk
{
  rvmPlus3FddView *fddView=selectedTag?_fddB:_fdd;
  
  NSString *t=dsk->path.lastPathComponent.stringByDeletingPathExtension;
  
  disk[selectedTag]=dsk;
  fddView.diskTitle=t;
  [fddView showDisk];
  [_machine insertDisk:dsk inDrive:selectedTag];
  [_machine insertDisk:dsk inDrive:selectedTag+2];
}

#pragma mark - NSOutlineViewDatasource

-(id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
  return disk[selectedTag].dirEntries[index];
}

-(BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
  return item==nil;
}

-(NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
  return (item)?0:disk[selectedTag].dirEntries.count;
}

-(id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
  if([tableColumn.identifier isEqualToString:@"Size"])
  {
    if(item[@"Size"])
      return [NSString stringWithFormat:@"%@K",item[@"Size"]];
    else
      return nil;
  }
  else
    return item[tableColumn.identifier];
}

-(void)loadMediaFile:(NSURL *)filename sound:(BOOL)b drive:(uint)d
{
  rvmPlus3FddView *fddView=d?_fddB:_fdd;
  disk[d]=[rvmDskDecoder loadDisk:filename.path];
  NSString *t=filename.path.lastPathComponent.stringByDeletingPathExtension;
  
  //        _writeProtected.enabled=YES;
  //        _writeProtected.state=disk.handle->writeProtect?NSOnState:NSOffState;
  
  fddView.diskTitle=t;
  //[_diskView setTracks:disk.handle->tracksN type:disk.handle->type name:t];
  [fddView showDisk];
  [_machine insertDisk:disk[d] inDrive:d];
  [_machine insertDisk:disk[d] inDrive:d+2];
  [_dirList reloadData];
}

@end
