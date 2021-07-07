//
//  rvmZXSpectrum128k.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 11/04/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmZXSpectrum128k.h"
#import "rvmZxSpectrum48kConfigViewController.h"
#import "rvmZxSpectrum48kKeyboardConfigViewController.h"
#import "rvmAudioViewControllerZx128.h"

static bool initTables=NO;

@interface rvmZXSpectrum128k()
{
  rvmAY3819X *ay;
  rvmAudioViewControllerZx128 *_audioController;
}

@end

@implementation rvmZXSpectrum128k

-(void)initPtr
{
  speccy128=calloc(1,sizeof(spectrum128));
  speccy=(spectrum*)speccy128;
}

-(void)initModel
{
  if(!initTables) init128k();
  
  speccy->ram=(uint8**)malloc(sizeof(uint8*)*8);
  speccy->rom=(uint8**)malloc(sizeof(uint8*)*2);
  
  for(int i=0;i<8;i++)
  {
    speccy->ram[i]=(uint8*)calloc(1,0x4000);
  }
  
  for(int i=0;i<2;i++)
    speccy->rom[i]=(uint8*)calloc(1,0x4000);
  
  speccy->cpu->mem[0]=speccy->rom[0];
  speccy->cpu->mem[1]=speccy->cpu->memw[1]=speccy->ram[5];
  speccy->cpu->mem[2]=speccy->cpu->memw[2]=speccy->ram[2];
  speccy->cpu->mem[3]=speccy->cpu->memw[3]=speccy->ram[0];
  
  speccy->cpu->get=s48k_get;
  speccy->cpu->set=s48k_set;
  speccy->cpu->out=s128k_out;
  speccy->cpu->in=s128k_in;
  speccy->cpu->con1=speccy->cpu->con2=s128k_contention;
  speccy->cpu->conIO=s128k_contentionIO;
  speccy->step=(rvmSpeccyStep)step128k;
  speccy->frameF=(rvmSpeccyStep)frame128k;
  speccy->cpu->busInt=s48k_busInt;
  speccy->cpu->iAknowlegde=s48k_ack;
  //speccy->extension=&speccy128;
  
  ay=[rvmAY3819X new];
  speccy128->ay=(rvmAY3819XT*)ay.handle;
  speccy128->ay->deviceAIn=(rvmDeviceIOInF)s128k_AYin;
  speccy128->ay->deviceBIn=(rvmDeviceIOInF)s128k_AYin;
  speccy128->ay->tag=speccy;
  
  mixer=[rvmAudioMixer new];
  [mixer setChannels:4 maxVolume:4];
  speccy->mixer=&(mixer->mixerS);
  
  for(int i=0;i<4;i++)
  {
    mixer->mixerS.cVol[i]=(i)?1.0:1.33;
    mixer->mixerS.cPan[i]=0.5;
  }
  
  mixer->mixerS.cPan[1]=0;
  mixer->mixerS.cPan[3]=1;
}

-(void)loadDefaultRom
{
  NSFileManager *fm=[NSFileManager defaultManager];
  
  NSData *rom=[fm contentsAtPath:[[NSBundle mainBundle] pathForResource:@"Resources/Roms/ZXSpectrum128k.0" ofType:@"rom"]];
  memcpy(speccy->rom[0],rom.bytes,0x4000);
  rom=[fm contentsAtPath:[[NSBundle mainBundle] pathForResource:@"Resources/Roms/ZXSpectrum128k.1" ofType:@"rom"]];
  memcpy(speccy->rom[1],rom.bytes,0x4000);
}

-(void)resetRam
{
  for(int i=0;i<8;i++)
    for (int j=0;j<0x4000;j++)
      speccy->ram[i][j]=(j & 0x8)?0xff:0x00;
  
  }

-(void)resetRamBanks
{
  speccy->cpu->mem[0]=speccy->rom[0];
  speccy->cpu->mem[1]=speccy->cpu->memw[1]=speccy->ram[5];
  speccy->cpu->mem[2]=speccy->cpu->memw[2]=speccy->ram[2];
  speccy->cpu->mem[3]=speccy->cpu->memw[3]=speccy->ram[0];
  speccy128->memory7f=0;
}

-(void)resetMachine
{
  [super resetMachine];
  [self resetRamBanks];
  [ay reset];
}

//-(void)luaInit:(lua_State *)L
//{
//  callLua(L,[NSString stringWithFormat:@"local zx=require('rvm.architectures.zxspectrum.spectrum128k'); machine=zx.new(%pULL)",speccy]);
//  [self registerCommands:L];
//}

-(rvmTransitionViewController *)configViewController
{
  rvmZxSpectrum48kConfigViewController* v=(rvmZxSpectrum48kConfigViewController*)[super configViewController];
  
  v.machineImage.image=[NSImage imageNamed:@"staticSpectrum128k"];
  
  return v;
}

-(rvmTransitionViewController *)configKeyboardViewController
{
  rvmZxSpectrum48kKeyboardConfigViewController *c=[[rvmZxSpectrum48kKeyboardConfigViewController alloc] initWithNibName:@"rvmZxSpectrum128kKeyboardViewController" bundle:nil];
  
  return c;
}

-(rvmAudioViewController *)audioController
{
  if(!_audioController)
  {
    _audioController=[[rvmAudioViewControllerZx128 alloc] initWithNibName:@"rvmAudioViewControllerZx128" bundle:nil];
    _audioController.mixer=mixer;
  }
  return _audioController;
}

//Snapshots

-(NSMutableDictionary *)snapshotMemory
{
  NSMutableDictionary *d=[NSMutableDictionary new];
  
  for(int i=0;i<8;i++)
  {
    NSString *key=[NSString stringWithFormat:@"ram%d",i];
    d[key]=[[NSData dataWithBytes:speccy->ram[i] length:0x4000] base64EncodedStringWithOptions:0];
  }
  
  return d;
}

-(NSMutableDictionary *)snapshotSpectrum
{
  NSMutableDictionary *s=[super snapshotSpectrum];
  
  s[@"memory7f"]=[NSNumber numberWithUnsignedChar:speccy128->memory7f];
  s[@"aySelect"]=[NSNumber numberWithUnsignedChar:speccy128->aySelect];
  s[@"ay"]=[ay snapshotAy];
  
  return s;
}

-(NSMutableArray *)snapshotSoundChannels
{
  NSMutableArray *soundChannels=[NSMutableArray new];
  
  for(int i=0;i<4;i++)
  {
    soundChannels[i]=[NSNumber numberWithDouble:speccy->soundChannels[i]];
  }
  
  return soundChannels;
}

//Load
-(void)loadMemory:(NSDictionary *)m
{
  for(int i=0;i<8;i++)
  {
    NSString *key=[NSString stringWithFormat:@"ram%d",i];
    
    NSData *r=[[NSData alloc] initWithBase64EncodedString:m[key] options:0];
    memcpy(speccy->ram[i],r.bytes,0x4000);
  }
}

-(void)loadSpectrum:(NSDictionary *)s
{
  [super loadSpectrum:s];
  speccy128->memory7f=[s[@"memory7f"] unsignedCharValue];
  speccy128->aySelect=[s[@"aySelect"] unsignedCharValue];
  
  speccy->cpu->mem[3]=speccy->cpu->memw[3]=speccy->ram[speccy128->memory7f & 0x7];
  speccy->cpu->mem[0]=speccy->rom[(speccy128->memory7f & 0x10)>>4];
  
  [ay reset];
  [ay loadAy:s[@"ay"]];
}

-(void)loadSoundChannels:(NSArray *)sound
{
  for(int i=0;i<4;i++)
    speccy->soundChannels[i]=[sound[i] doubleValue];
}

-(NSMutableDictionary *)snapshotModel
{
  NSMutableDictionary *d=[super snapshotModel];
  
  d[@"model"]=@"128k";
  d[@"submodel"]=@"128k";
  
  return d;
}

-(NSData*)frameSnapshot:(NSData*)memory border:(uint8)border
{
  NSMutableData *s=[NSMutableData dataWithLength:384*288*4];
  
  
  if(memory)
    snap48k(speccy, (uint32*)s.bytes, (uint8*)memory.bytes,border);
  else
    snap48k(speccy, (uint32*)s.bytes, (speccy128->memory7f & 0x8)?speccy->ram[7]:speccy->ram[5],border);
  
  return s;
}

-(void)deallocMemory {
  for(int i=0;i<8;i++) free(speccy->ram[i]);
  for(int i=0;i<2;i++) free(speccy->rom[i]);
}
@end
