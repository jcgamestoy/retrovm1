//
//  rvmZxSpectrumPlus2Spa.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 13/04/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmZxSpectrumPlus2Spa.h"

@implementation rvmZxSpectrumPlus2Spa

-(void)loadDefaultRom
{
  NSFileManager *fm=[NSFileManager defaultManager];
  
  NSData *rom=[fm contentsAtPath:[[NSBundle mainBundle] pathForResource:@"Resources/Roms/ZXSpectrumPlus2Spa.0" ofType:@"rom"]];
  memcpy(speccy->rom[0],rom.bytes,0x4000);
  rom=[fm contentsAtPath:[[NSBundle mainBundle] pathForResource:@"Resources/Roms/ZXSpectrumPlus2Spa.1" ofType:@"rom"]];
  memcpy(speccy->rom[1],rom.bytes,0x4000);
}

@end
