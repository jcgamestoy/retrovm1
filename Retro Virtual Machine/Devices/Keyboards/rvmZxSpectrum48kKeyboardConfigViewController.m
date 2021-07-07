//
//  rvmZxSpectrum48kKeyboardConfigViewController.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 11/08/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmZxSpectrum48kKeyboardConfigViewController.h"
#import "rvmMacKeyboardView.h"
#import "rvmZxSpectrum48kKeyboardView.h"

@interface rvmZxSpectrum48kKeyboardConfigViewController ()
{
  rvmMachineKeyS keyConfig;
  uint keyClicked;
}

@property (weak) IBOutlet rvmMacKeyboardView *macKeyboard;
@property (weak) IBOutlet rvmZxSpectrum48kKeyboardView *machineKeyboard;
@property (strong) IBOutlet NSPopover *keyClickedPopover;
@property (weak) IBOutlet NSTextField *popoverLabel;

@end

@implementation rvmZxSpectrum48kKeyboardConfigViewController

-(void)awakeFromNib
{
  _macKeyboard.onKeyDown=^(uint key)
  {
    rvmMachineKeyS keys=[self->_machine keysForkey:key];
    
    //if(keys==(id)[NSNull null]) return;
    
    for(int i=0;i<keys.number;i++)
    {
      [self->_machineKeyboard highlightKey:&keys];
    }
  };
  
  _macKeyboard.onKeyUp=^(uint key)
  {
    rvmMachineKeyS keys=[self->_machine keysForkey:key];
  
    for(int i=0;i<keys.number;i++)
    {
      [self->_machineKeyboard unHighlightKey:&keys];
    }
  };
  
  _popoverLabel.stringValue=@"";
  
  _macKeyboard.onKeyClick=^(uint key,NSRect r)
  {
    self->_machineKeyboard.state=1;
    self->keyClicked=key;
    self->keyConfig=((rvmMachineKeyS) {0,{},{}});
    self->_popoverLabel.stringValue=[NSString stringWithFormat:@"Click on machine keys..."];
    [self->_keyClickedPopover showRelativeToRect:r ofView:self->_macKeyboard preferredEdge:NSMinYEdge];
  };
  
  _machineKeyboard.onKeyClick=^(uint keyCode)
  {
    rvmMachineKeyS key=[self->_machine keysForMachinekey:keyCode];
    
    if((self->keyConfig.number+key.number)==8)
    {
      self->_popoverLabel.stringValue=[NSString stringWithFormat:@"Too many keys."];
      return;
    }
    
    //const char* kname=[_machine keyName:key];
    if(key.name)
    {
      NSString *n=[NSString stringWithFormat:@"%s",key.name];
      if(self->keyConfig.number)
      {
        self->_popoverLabel.stringValue=[NSString stringWithFormat:@"%@ + %@",self->_popoverLabel.stringValue,n];
      }
      else self->_popoverLabel.stringValue=n;
    }
    
    for(int i=0;i<key.number;i++)
    {
      uint ind=self->keyConfig.number++;
      self->keyConfig.lines[ind]=key.lines[i];
      self->keyConfig.codes[ind]=key.codes[i];
    }
  };
}

- (IBAction)onOk:(id)sender {
  _machineKeyboard.state=0;
  [_machine changeKey:keyClicked keys:&keyConfig];
  [_keyClickedPopover close];
}

- (IBAction)onCancel:(id)sender {
  _machineKeyboard.state=0;
  [_keyClickedPopover close];
}

- (IBAction)onClose:(id)sender {
  if(_onClose) _onClose();
  _machineKeyboard.state=0;
  [_keyClickedPopover close];
}

@end
