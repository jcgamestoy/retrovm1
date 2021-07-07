//
//  rvmZxSpectrumPlus3Spa.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 27/07/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmZxSpectrumPlus3Spa.h"

@implementation rvmZxSpectrumPlus3Spa

-(void)loadDefaultRom
{
  NSFileManager *fm=[NSFileManager defaultManager];
  
  NSData *rom=[fm contentsAtPath:[[NSBundle mainBundle] pathForResource:@"Resources/Roms/ZXSpectrumPlus3.4.0-0Spa" ofType:@"rom"]];
  memcpy(speccy->rom[0],rom.bytes,0x4000);
  rom=[fm contentsAtPath:[[NSBundle mainBundle] pathForResource:@"Resources/Roms/ZXSpectrumPlus3.4.0-1Spa" ofType:@"rom"]];
  memcpy(speccy->rom[1],rom.bytes,0x4000);
  rom=[fm contentsAtPath:[[NSBundle mainBundle] pathForResource:@"Resources/Roms/ZXSpectrumPlus3.4.0-2Spa" ofType:@"rom"]];
  memcpy(speccy->rom[2],rom.bytes,0x4000);
  rom=[fm contentsAtPath:[[NSBundle mainBundle] pathForResource:@"Resources/Roms/ZXSpectrumPlus3.4.0-3Spa" ofType:@"rom"]];
  memcpy(speccy->rom[3],rom.bytes,0x4000);
}

@end
