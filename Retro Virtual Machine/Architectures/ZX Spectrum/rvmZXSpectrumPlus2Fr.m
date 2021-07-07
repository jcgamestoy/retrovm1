//
//  rvmZXSpectrumPlus2Fr.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 13/04/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmZXSpectrumPlus2Fr.h"

@implementation rvmZXSpectrumPlus2Fr

-(void)loadDefaultRom
{
  NSFileManager *fm=[NSFileManager defaultManager];
  
  NSData *rom=[fm contentsAtPath:[[NSBundle mainBundle] pathForResource:@"Resources/Roms/ZXSpectrumPlus2Fr.0" ofType:@"rom"]];
  memcpy(speccy->rom[0],rom.bytes,0x4000);
  rom=[fm contentsAtPath:[[NSBundle mainBundle] pathForResource:@"Resources/Roms/ZXSpectrumPlus2Fr.1" ofType:@"rom"]];
  memcpy(speccy->rom[1],rom.bytes,0x4000);
}

@end
