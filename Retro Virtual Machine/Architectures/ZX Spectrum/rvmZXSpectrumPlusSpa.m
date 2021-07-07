//
//  rvmZXSpectrumPlusSpa.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 21/2/16.
//  Copyright © 2016 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmZXSpectrumPlusSpa.h"
#import "rvmZxSpectrum48kConfigViewController.h"
#import "rvmZxSpectrum48kKeyboardConfigViewController.h"

@implementation rvmZXSpectrumPlusSpa

-(rvmTransitionViewController *)configKeyboardViewController
{
  rvmZxSpectrum48kKeyboardConfigViewController *c=[[rvmZxSpectrum48kKeyboardConfigViewController alloc] initWithNibName:@"rvmZxSpectrumPlusSpaKeyboardViewController" bundle:nil];
  
  return c;
}

-(rvmTransitionViewController *)configViewController
{
  rvmZxSpectrum48kConfigViewController* v=(rvmZxSpectrum48kConfigViewController*)[super configViewController];
  
  v.machineImage.image=[NSImage imageNamed:@"staticSpectrum+Spa"];
  
  return v;
}

-(void)loadDefaultRom
{
  NSFileManager *fm=[NSFileManager defaultManager];
  
  NSData *rom=[fm contentsAtPath:[[NSBundle mainBundle] pathForResource:@"Resources/Roms/ZXSpectrum48kSpa" ofType:@"rom"]];
  memcpy(speccy->rom[0],rom.bytes,0x4000);
  //defaultRom=YES;
}

@end
