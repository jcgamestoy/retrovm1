//
//  rvmNewDiskWindowsController.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 29/07/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmNewDiskWindowsController.h"
#import "rvmDskDecoder.h"
#import "rvmAppDelegate.h"

@interface rvmNewDiskWindowsController ()
{
  NSSavePanel *s;
}

@property (weak) IBOutlet NSButton *selector80;
@property (weak) IBOutlet NSButton *selector40;
@property (weak) IBOutlet NSMatrix *formatGroup;

@end

@implementation rvmNewDiskWindowsController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void)awakeFromNib
{
  s=[(rvmAppDelegate*)[NSApp delegate] savePanel];
  //s=[NSSavePanel savePanel];
  
}

- (IBAction)onTypeSelected:(NSButton *)sender {
  if(sender==_selector40)
  {
    _selector80.state=!_selector40.state;
    ((NSButtonCell*)[_formatGroup cellWithTag:6]).enabled=NO;
    ((NSButtonCell*)[_formatGroup cellWithTag:7]).enabled=NO;
  }
  else
  {
    _selector40.state=!_selector80.state;
    ((NSButtonCell*)[_formatGroup cellWithTag:6]).enabled=YES;
    ((NSButtonCell*)[_formatGroup cellWithTag:7]).enabled=YES;
  }
}

- (IBAction)onOk:(id)sender {
  NSWindow *w=self.window.sheetParent;
  [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
  [self.window orderOut:sender];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [self->s setAllowedFileTypes:@[@"dsk"]];
    [self->s beginSheetModalForWindow:w completionHandler:^(NSInteger result) {
      if(result==NSOKButton)
      {
        rvmDskDecoder *d;
        if(self->_selector40.state)
        {
          d=[rvmDskDecoder new40Track:self->s.URL.path];
        }
        else
        {
          d=[rvmDskDecoder new80Track:self->s.URL.path];
        }
        
        switch(self->_formatGroup.selectedTag)
        {
          case 1: //Standard
          {
            [d formatStandard];
            break;
          }
          case 2: //Cpc System
          {
            [d formatCpcSystem];
            break;
          }
          case 3: //Cpc Data
          {
            [d formatCpcData];
            break;
          }
          case 4: //Ibm
          {
            [d formatIbm];
            break;
          }
          case 5: //XCf2
          {
            [d formatXCf2];
            break;
          }
          case 6: //Standard80
          {
            [d formatStandard80];
            break;
          }
          case 7:
          {
            [d formatXCf2dd];
            break;
          }
        }
        
        [self->_delegate newDisk:d];
      }
    }];
  });
}

- (IBAction)onCancel:(id)sender {
  [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseCancel];
  [self.window orderOut:sender];
  
}

@end
