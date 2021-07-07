//
//  rvmSnapshotListViewController.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 16/1/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmSnapshotListViewController.h"
#import "rvmImageView.h"
#import "rvmRemovableTableCellView.h"
#import "NSColor+rvmNSColors.h"
#import "NSData+Gzip.h"
#import "rvmAppDelegate.h"
#import "rvmSNADecoder.h"
#import "rvmZ80Decoder.h"
#import "rvmNSImage+Extensions.h"

//View Controler
@interface rvmSnapshotListViewController ()
{
  //rvmFileNode *fn;
  NSDictionary *selected;
  NSFileWrapper *snaps;
  NSArray *snapsA;
  rvmRemovableTableCellView *lastSelected;
}

@property (weak) IBOutlet rvmImageView *imageView;
@property (weak) IBOutlet NSOutlineView *listView;
@property (weak) IBOutlet NSButton *runButton;
@property (weak) IBOutlet NSButton *exportButton;

@end

@implementation rvmSnapshotListViewController

-(void)awakeFromNib
{
  _exportSna.onClick=^(rvmAlphaButton* b)
  {
    [self onExportSna];
  };
  
  _exportZ80.onClick=^(rvmAlphaButton* b)
  {
    [self onExportZ80];
  };
}

-(void)setDoc:(rvmArchitecture *)doc
{
  _doc=doc;
  snaps=[_doc getSnapshots];
  snapsA=[snaps.fileWrappers.allValues sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    return [[obj1 filename] compare:[obj2 filename]];
  }];
//  NSString *path=[NSString stringWithFormat:@"%@/snap/",doc.fileURL.path];
//  fn=[rvmFileNode newForPath:path];
}

#pragma mark NSOutlineViewDatasource

-(NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
  return (item)?[item[@"childs"] count]:snapsA.count;
}

-(id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
  NSFileWrapper *it=(item)?item[@"fw"]:snaps;
  
  NSArray *a=(item)?item[@"childs"]:snapsA;
  
  return @{@"parent":it,
           @"value":a[index],
           @"childs":[[[it fileWrappers] allValues] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
             return [[obj1 filename] compare:[obj2 filename]];
           }]};
}

-(BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
  return [item[@"chidls"] count];
}

-(id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
  return item;
}

-(NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
  NSFileWrapper *it=item[@"value"];
  rvmRemovableTableCellView *tv=[outlineView makeViewWithIdentifier:@"cell" owner:self];
  tv.textField.stringValue=it.filename?it.filename:it.preferredFilename;
  tv.textField.delegate=self;
  tv.object=item;
  return tv;
}


-(void)controlTextDidEndEditing:(NSNotification *)obj
{
  NSTextField *tf=obj.object;

  NSDictionary *i=[_listView itemAtRow:[_listView rowForView:tf]];
  NSFileWrapper *fw=i[@"value"];
  NSFileWrapper *parent=i[@"parent"];
  NSFileWrapper *other=parent.fileWrappers[tf.stringValue];
  
  if(other && other!=fw)
  {
    NSAlert *a=[NSAlert alertWithMessageText:@"Error" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Already exist a snapshot called '%@'.",tf.stringValue];
    [a beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
      
    }];
    tf.stringValue=fw.filename;
    return;
  }
  
  [parent removeFileWrapper:fw];
  
  fw.filename=fw.preferredFilename=tf.stringValue;
  [parent addFileWrapper:fw];
  self.doc=_doc;
}

- (IBAction)onRemoveSnapshot:(id)sender {
  NSButton *b=sender;
  rvmRemovableTableCellView *s=(rvmRemovableTableCellView*)[b superview];
  NSAlert *a=[NSAlert alertWithMessageText:@"Sure?" defaultButton:@"Ok" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"The '%@' snapshot will be deleted. Are you sure?",[s.object[@"value"] filename]];
  [a beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
    if(returnCode==NSOKButton)
    {
      [s.object[@"parent"] removeFileWrapper:s.object[@"value"]];
      [self->_doc updateChangeCount:NSChangeDone];
      [self->_doc savePresentedItemChangesWithCompletionHandler:^(NSError *errorOrNil) {
        self.doc=self->_doc;
        [self->_listView reloadData];
      }];
      self->_imageView.image=nil;
      self->_runButton.enabled=NO;
      self->_exportButton.enabled=NO;
      self->selected=nil;
    }
  }];
}





-(void)outlineViewSelectionDidChange:(NSNotification *)notification
{

//-(IBAction)onSelection:(id)sender
//{
  NSOutlineView *ov=_listView;//sender;
  NSFileWrapper *it=[ov itemAtRow:[ov selectedRow]][@"value"];
//  rvmRemovableTableCellView *r=[ov viewAtColumn:0 row:[ov selectedRow] makeIfNecessary:NO];
//  lastSelected.selected=NO;
//  r.selected=YES;
//  lastSelected=r;
  
  if(it)
  {
    //Check
    NSURL *u=[_doc.fileURL URLByAppendingPathComponent:[NSString stringWithFormat:@"snap/%@",it.filename]];
    //if(![it matchesContentsOfURL:u])
    //{
      [it readFromURL:u options:NSFileWrapperReadingImmediate error:nil];
    //}
    
    selected=[NSJSONSerialization JSONObjectWithData:[[it regularFileContents] gunzip] options:0 error:nil];
    
    NSDictionary *t=selected[@"thumb"];
    uint32 w=[t[@"w"] unsignedIntValue];
    uint32 h=[t[@"h"] unsignedIntValue];
    
    NSBitmapImageRep *br=[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:w pixelsHigh:h bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bitmapFormat:0 bytesPerRow:w<<2 bitsPerPixel:32];
    
    //NSData *d=[[NSData alloc] initWithBase64Encoding:t[@"payload"]];
    NSData *d=[[NSData alloc] initWithBase64EncodedString:t[@"payload"] options:0];
    memcpy(br.bitmapData, d.bytes, w*h*4);
    
    NSImage *r=[[NSImage alloc] initWithSize:NSMakeSize(w, h)];
    [r addRepresentations:@[br]];
    
    _imageView.image=[r subImageFromOffsetX:22 Y:16];
    
    _runButton.enabled=YES;
    _exportButton.enabled=YES;
  }
  else {
    _imageView.image=nil;
    _runButton.enabled=NO;
    _exportButton.enabled=NO;
  }
}

- (IBAction)onPlay:(id)sender {
  if(!selected) return;
  
  @synchronized(_doc.machine)
  {
    [_doc.machine loadSnapshot:selected];
  }
}

-(NSString*)snapshotPath
{
  //rvmArchitecture *doc=_machine.doc;
  NSDateComponents *c=[[NSCalendar currentCalendar] components:NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitSecond|NSCalendarUnitNanosecond fromDate:[NSDate date]];
  
  NSString *name=[NSString stringWithFormat:@"snap.%ld.%ld.%ld.%ld.%ld.%ld.%ld.rvmSnap",(long)c.year,(long)c.month,(long)c.day,(long)c.hour,(long)c.minute,(long)c.second,(long)c.nanosecond];
  
  return name;
}

-(IBAction)onImport:(id)sender {
  NSOpenPanel *op=[(rvmAppDelegate*)[NSApp delegate] openPanel];
  
  [op setAllowedFileTypes:@[@"sna",@"z80"]];
  
  [op beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
    if(result==NSOKButton)
    {
      NSString *ext=op.URL.pathExtension.lowercaseString;
      
      NSData *file=[NSData dataWithContentsOfFile:op.URL.path];;
      
      
      if(file)
      {
        NSDictionary *s;
        @synchronized(self->_doc.machine)
        {
          s=[self->_doc.machine createSnapshot];
        }
        
        if([ext isEqualToString:@"sna"])
          s=[rvmSNADecoder import:s[@"model"] data:file machine:self->_doc.machine onError:^(NSString *err) {
            
          }];
        else
          s=[rvmZ80Decoder import:s[@"model"] data:file machine:self->_doc.machine onError:^(NSString *err) {
            
          }];
        
        if(s)
        {
          NSString *p=[self->_doc snapshotPath:op.URL.lastPathComponent];
          [self->_doc saveSnapshot:s filename:p];
          self.doc=self->_doc;
          [self->_listView reloadData];
        }
      }
      
    }
  }];
}

-(void)animateIn
{
//  NSString *path=[NSString stringWithFormat:@"%@/snap/",_doc.fileURL.path];
//  fn=[rvmFileNode newForPath:path];
  self.doc=_doc;
  [_listView reloadData];
}

- (IBAction)onExport:(id)sender {
  NSButton *b=sender;
  [_popExport showRelativeToRect:b.bounds ofView:b preferredEdge:NSMinYEdge];
}

-(void)exportData:(NSData*)data type:(NSString*)type
{
  NSSavePanel *sp=[(rvmAppDelegate*)[NSApp delegate] savePanel];
  [sp setAllowedFileTypes:@[type]];
  
  [sp beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
    if(result==NSOKButton)
    {
      [data writeToFile:sp.URL.path atomically:YES];
    }
    [self->_popExport close];
  }];
}

-(void)onExportSna
{
  if(selected)
  {
    NSData *sna=[rvmSNADecoder export:selected];
    [self exportData:sna type:@"sna"];
  }
}

-(void)onExportZ80
{
  if(selected)
  {
    NSData *z80=[rvmZ80Decoder export:selected];
    [self exportData:z80 type:@"z80"];
  }
}

-(void)onExportPng
{
  
}
@end
