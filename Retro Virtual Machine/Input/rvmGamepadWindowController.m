//
//  rvmGamepadWindowController.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 13/4/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmGamepadWindowController.h"
#import "rvmInputManager.h"

@interface rvmGamepadWindowController ()
{
  void (^ant)(rvmGamepad* gamepad,uint elementId,uint value);
  NSArray *phases;
  uint state;
  rvmGamepad *configuring;
}

@property (weak) IBOutlet NSTextField *label;

@end

@implementation rvmGamepadWindowController

-(void)awakeFromNib
{
  phases=@[@"Push one button to identify the gamepad.",
           @"Push Up",
           @"Push Down",
           @"Push Left",
           @"Push Right",
           @"Push Snapshot Button",
           @"Push Pause Button",
           @"Push Joystick Type Button",];
}

-(void)beginConfig
{
  if(!self.window) [self loadWindow];
  rvmInputManager *m=[rvmInputManager manager];
  
  ant=m.onJoy;
  state=0;
  _label.stringValue=phases[0];
  
  NSMutableData *a=[NSMutableData dataWithLength:7];
  uint8 *pt=(uint8*)a.bytes;
  
  __weak rvmInputManager *mw=m;
  
  m.onJoy=^(rvmGamepad *g,uint e,uint v)
  {
    if(v)
    {
      if(self->state==0)
      {
        self->configuring=g;
      }
      else
      {
        if(g!=self->configuring) return;
        
        for(int i=0;i<self->state-1;i++)
          if(pt[i]==e) return;
        
        pt[self->state-1]=e;
        
        if(self->state==7) //end
        {
          [mw addConfig:g data:a];
          [self onCancel:self];
          return;
        }
      }
      
      self->state++;
      self->_label.stringValue=self->phases[(self->state) & 0x7];
    }
  };
}

-(void)endConfig
{
  rvmInputManager *m=[rvmInputManager manager];
  
  m.onJoy=ant;
}

- (IBAction)onCancel:(id)sender {
  [self.window.sheetParent endSheet:self.window returnCode:0];
  [self.window orderOut:sender];
}

@end
