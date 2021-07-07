//
//  rvmZXSpectrumPlus2E.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 12/05/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmZXSpectrumPlus2E.h"

@implementation rvmZXSpectrumPlus2E

-(void)loadDefaultRom
{
  NSFileManager *fm=[NSFileManager defaultManager];
  
  NSData *rom=[fm contentsAtPath:[[NSBundle mainBundle] pathForResource:@"Resources/Roms/+3e/ZXSpectrumPlus3e.0" ofType:@"rom"]];
  memcpy(speccy->rom[0],rom.bytes,0x4000);
  rom=[fm contentsAtPath:[[NSBundle mainBundle] pathForResource:@"Resources/Roms/+3e/ZXSpectrumPlus3e.1" ofType:@"rom"]];
  memcpy(speccy->rom[1],rom.bytes,0x4000);
  rom=[fm contentsAtPath:[[NSBundle mainBundle] pathForResource:@"Resources/Roms/+3e/ZXSpectrumPlus3e.2" ofType:@"rom"]];
  memcpy(speccy->rom[2],rom.bytes,0x4000);
  rom=[fm contentsAtPath:[[NSBundle mainBundle] pathForResource:@"Resources/Roms/+3e/ZXSpectrumPlus3e.3" ofType:@"rom"]];
  memcpy(speccy->rom[3],rom.bytes,0x4000);
}

@end
