//
//  rvmMachineItemViewController.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 25/03/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmMachineItemViewController.h"
#import "rvmSimpleCollectionView.h"
#import "NSColor+rvmNSColors.h"

@interface rvmMachineItemViewController ()
@property (weak) IBOutlet NSTextField *titleField;
@property (strong) IBOutlet rvmBackgroundView *background;

@end

@implementation rvmMachineItemViewController

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
  [_image setWantsLayer:YES];
  //_image.backColor=[NSColor clearColor];
  
  _image.layer.cornerRadius=20;
  _titleField.delegate=self;
  
  __weak rvmMachineItemViewController *v=self;
  
  _image.onDoubleClick=^(id sender) {
    //[[v.view rvmSimpleCollectionView] viewControllerSelected:v];
    [[v.view rvmSimpleCollectionView] viewControllerOpen:v];
  };
  
  _image.onClick=^(id sender) {
//    [v.titleField setEditable:YES];
//    [v.titleField setSelectable:YES];
//    [v.titleField selectText:v];
//    [v.titleField becomeFirstResponder];
    //v.titleField.backgroundColor=[NSColor redColor];
    //v.background.backColor=[NSColor redColor];
    [[v.view rvmSimpleCollectionView] viewControllerSelected:v];
  };
}

-(void)rename
{
  [_titleField setEditable:YES];
  [_titleField setSelectable:YES];
  [_titleField selectText:self];
  [_titleField becomeFirstResponder];
}

-(void)mark
{
  self.background.backColor=[NSColor cornflowerBlue];
  self.background.layer.cornerRadius=6.0;
}

-(void)unmark
{
  self.background.backColor=[NSColor transparent];
  self.background.layer.cornerRadius=0;
}

-(BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
  //[_titleField setPreferredMaxLayoutWidth:100];
  //[_titleField sizeToFit];
  //[self.view layoutSubtreeIfNeeded];
  //[[self.view rvmSimpleCollectionView] layoutCollection];
  _titleField.editable=_titleField.selectable=NO;
  dispatch_async(dispatch_get_main_queue(), ^{
    [self->_titleField.window makeFirstResponder:self.view.rvmSimpleCollectionView];
  });
  
  _machineDocument.properties[@"title"]=_titleField.stringValue;
  [_machineDocument saveMain];
    return YES;
}
@end
