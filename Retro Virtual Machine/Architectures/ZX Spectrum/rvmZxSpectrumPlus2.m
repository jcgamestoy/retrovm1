//
//  rvmZxSpectrumPlus2.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 13/04/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmZxSpectrumPlus2.h"
#import "rvmPlus2ADatacorderViewController.h"
#import "rvmZxSpectrum48kConfigViewController.h"
#import "rvmZxSpectrum48kKeyboardConfigViewController.h"

@implementation rvmZxSpectrumPlus2

-(void)loadDefaultRom
{
  NSFileManager *fm=[NSFileManager defaultManager];
  
  NSData *rom=[fm contentsAtPath:[[NSBundle mainBundle] pathForResource:@"Resources/Roms/ZXSpectrumPlus2.0" ofType:@"rom"]];
  memcpy(speccy->rom[0],rom.bytes,0x4000);
  
  rom=[fm contentsAtPath:[[NSBundle mainBundle] pathForResource:@"Resources/Roms/ZXSpectrumPlus2.1" ofType:@"rom"]];
  memcpy(speccy->rom[1],rom.bytes,0x4000);
}

-(NSViewController *)cassetteController
{
  if(!cassetteController)
  cassetteController=[[rvmPlus2DatacorderViewController alloc] initWithNibName:@"rvmPlus2DatacorderViewController" bundle:nil];
  
  return cassetteController;
}

-(rvmTransitionViewController *)configViewController
{
  rvmZxSpectrum48kConfigViewController* v=(rvmZxSpectrum48kConfigViewController*)[super configViewController];
  
  v.machineImage.image=[NSImage imageNamed:@"staticSpectrum+2"];
  
  return v;
}

-(rvmTransitionViewController *)configKeyboardViewController
{
  rvmZxSpectrum48kKeyboardConfigViewController *vc=[[rvmZxSpectrum48kKeyboardConfigViewController alloc] initWithNibName:@"rvmZxSpectrum+2KeyboardViewController" bundle:nil];
  
  return vc;
}

-(NSMutableDictionary *)snapshotModel
{
  NSMutableDictionary *d=[super snapshotModel];
  
  d[@"Submodel"]=@"plus2";
  
  return d;
}
@end
