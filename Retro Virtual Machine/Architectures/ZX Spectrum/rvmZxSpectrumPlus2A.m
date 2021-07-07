//
//  rvmZxSpectrumPlus2A.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 09/05/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmZxSpectrumPlus2A.h"
#import "rvmPlus2ADatacorderViewController.h"
#import "rvmZxSpectrum48kConfigViewController.h"
#import "rvmZxSpectrum48kKeyboardConfigViewController.h"

static bool initTables=NO;

@interface rvmZxSpectrumPlus2A()
@end

@implementation rvmZxSpectrumPlus2A

-(void)initPtr
{
  speccy2A=calloc(1,sizeof(spectrumPlus2A));
  speccy128=(spectrum128*)speccy2A;
  speccy=(spectrum*)speccy2A;
}

-(void)initModel
{
  [super initModel];
  if(!initTables) initPlus2A();
  
  uint8 **roms=malloc(sizeof(uint8*)*4);
  roms[0]=speccy->rom[0];
  roms[1]=speccy->rom[1];
  roms[2]=calloc(1, 0x4000);
  roms[3]=calloc(1, 0x4000);
  free(speccy->rom);
  speccy->rom=roms;
  
  speccy->cpu->in=sPlus2A_in;
  speccy->cpu->out=sPlus2A_out;
  speccy->cpu->con2=speccy->cpu->conIO=sPlus2A_contentionIO;
  speccy->cpu->con1=sPlus2A_contention;
  speccy->step=(rvmSpeccyStep)stepPlus2A;
  speccy->frameF=(rvmSpeccyStep)framePlus2A;
  //speccy128.extension=&speccy2A;
}

-(void)loadDefaultRom
{
  NSFileManager *fm=[NSFileManager defaultManager];
  
  NSData *rom=[fm contentsAtPath:[[NSBundle mainBundle] pathForResource:@"Resources/Roms/ZXSpectrumPlus3.4.0-0" ofType:@"rom"]];
  memcpy(speccy->rom[0],rom.bytes,0x4000);
  rom=[fm contentsAtPath:[[NSBundle mainBundle] pathForResource:@"Resources/Roms/ZXSpectrumPlus3.4.0-1" ofType:@"rom"]];
  memcpy(speccy->rom[1],rom.bytes,0x4000);
  rom=[fm contentsAtPath:[[NSBundle mainBundle] pathForResource:@"Resources/Roms/ZXSpectrumPlus3.4.0-2" ofType:@"rom"]];
  memcpy(speccy->rom[2],rom.bytes,0x4000);
  rom=[fm contentsAtPath:[[NSBundle mainBundle] pathForResource:@"Resources/Roms/ZXSpectrumPlus3.4.0-3" ofType:@"rom"]];
  memcpy(speccy->rom[3],rom.bytes,0x4000);
}

-(void)resetRam
{
  [super resetRam];
}

-(void)resetRamBanks
{
  speccy2A->memory1f=0;
  [super resetRamBanks];
}

-(NSViewController *)cassetteController
{
  if(!cassetteController)
    cassetteController=[[rvmPlus2ADatacorderViewController alloc] initWithNibName:@"rvmPlus2ADatacorderViewController" bundle:nil];
  
  return cassetteController;
}

//-(void)luaInit:(lua_State *)L
//{
//  callLua(L,[NSString stringWithFormat:@"local zx=require('rvm.architectures.zxspectrum.spectrumPlus2A'); machine=zx.new(%pULL)",speccy]);
//  [self registerCommands:L];
//}

-(rvmTransitionViewController *)configViewController
{
  rvmZxSpectrum48kConfigViewController* v=(rvmZxSpectrum48kConfigViewController*)[super configViewController];
  
  v.machineImage.image=[NSImage imageNamed:@"staticSpectrum+2A"];
  
  return v;
}

-(rvmTransitionViewController *)configKeyboardViewController
{
  rvmZxSpectrum48kKeyboardConfigViewController *vc=[[rvmZxSpectrum48kKeyboardConfigViewController alloc] initWithNibName:@"rvmZxSpectrumPlus2AKeyboardViewController" bundle:nil];
  
  return vc;
}

-(NSMutableDictionary *)snapshotSpectrum
{
  NSMutableDictionary *s=[super snapshotSpectrum];
  
  s[@"memory1f"]=[NSNumber numberWithUnsignedChar:speccy2A->memory1f];
  
  return s;
}

-(void)loadSpectrum:(NSDictionary *)s
{
  [super loadSpectrum:s];
  
  speccy2A->memory1f=[s[@"memory1f"] unsignedCharValue];
  
  sPlus2A_memoryConfig(speccy, speccy2A->memory7f, speccy2A->memory1f);
}

-(NSMutableDictionary *)snapshotModel
{
  NSMutableDictionary *d=[super snapshotModel];
  
  d[@"model"]=@"Plus3";
  d[@"submodel"]=@"Plus2A";
  
  return d;
}

-(void)deallocMemory {
  for(int i=0;i<8;i++) free(speccy->ram[i]);
  for(int i=0;i<3;i++) free(speccy->rom[i]);
}

@end
