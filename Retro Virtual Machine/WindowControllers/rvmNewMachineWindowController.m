//
//  rvmNewZXSpectrumWindowController.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 29/01/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmNewMachineWindowController.h"
#import "rvmImageView.h"
#import "rvmArchitecture.h"
#import "rvmImageView.h"
//Block structures.



@interface rvmNewMachineWindowController ()
{
  NSDictionary *architectures;
  NSDictionary *model;
  NSDictionary *submodel;
}

@property (weak) IBOutlet NSBrowser *architecturesB;
@property (weak) IBOutlet NSButton *okButton;
@property (weak) IBOutlet rvmImageView *imageView;
@property (weak) IBOutlet NSView *descBox;
@property (weak) IBOutlet NSTextField *ddescription;


@end

@implementation rvmNewMachineWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}


-(void)awakeFromNib
{
  architectures=[rvmArchitecture architectures];
  
  _architecturesB.delegate=self;
  _architecturesB.backgroundColor=[NSColor clearColor];
  
  [_architecturesB setTitle:@"Architecture" ofColumn:0];
  [_architecturesB setTitle:@"Model" ofColumn:1];
  [_architecturesB setTitle:@"Sub-Model" ofColumn:2];
}

- (IBAction)onOk:(id)sender {
  [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
  [self.window orderOut:sender];
}

- (IBAction)onCancel:(id)sender {
  [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseCancel];
  [self.window orderOut:sender];
}

-(id)rootItemForBrowser:(NSBrowser *)browser
{
  return architectures;
}

-(NSInteger)browser:(NSBrowser *)browser numberOfChildrenOfItem:(id)item
{
  return [item[@"_childs"] count];
}

-(id)browser:(NSBrowser *)browser child:(NSInteger)index ofItem:(id)item
{
  return item[@"_childs"][index];
}

-(BOOL)browser:(NSBrowser *)browser isLeafItem:(id)item
{
  return item[@"_childs"]==nil;
}

-(id)browser:(NSBrowser *)browser objectValueForItem:(id)item
{
  return item[@"_name"];
}

- (IBAction)onBrowser:(NSBrowser *)sender {
  if(sender.selectionIndexPath.length!=3)
  {
    _okButton.enabled=NO;
    _imageView.image=nil;
    _descBox.hidden=YES;
  }
  else
  {
    NSDictionary *i=[sender itemAtIndexPath:sender.selectionIndexPath];
    
    NSString *desc=i[@"desc"];
    NSAttributedString *a=[[NSAttributedString alloc] initWithHTML:[desc dataUsingEncoding:NSUTF8StringEncoding] documentAttributes:nil];
    
    _okButton.enabled=YES;
    _imageView.image=i[@"machineImage"];
    _descBox.hidden=NO;
    
    _ddescription.attributedStringValue=a;
  }
}
@end
