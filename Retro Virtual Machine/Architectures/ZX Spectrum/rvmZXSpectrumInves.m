//
//  rvmZXSpectrumInves.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 25/2/16.
//  Copyright © 2016 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmZXSpectrumInves.h"
#import "spectrumInves.h"
#import "rvmZxSpectrum48kKeyboardConfigViewController.h"
#import "rvmZxSpectrum48kConfigViewController.h"

@implementation rvmZXSpectrumInves

static bool initTables=NO;

-(void)initPtr
{
  speccyInves=calloc(1,sizeof(spectrumInves));
  speccy=(spectrum*)speccyInves;
}

-(void)initModel
{
  if(!initTables)
    initInves();
  
  speccy->ram=(uint8**)malloc(sizeof(uint8*)*4);
  speccy->rom=(uint8**)malloc(sizeof(uint8*)*1);
  
  for(int i=0;i<4;i++)
  {
    speccy->ram[i]=(uint8*)calloc(1,0x4000);
  }
  
  speccy->rom[0]=(uint8*)calloc(1,0x4000);
  
  speccy->cpu->mem[0]=speccy->rom[0];
  speccy->cpu->memw[0]=speccy->ram[0];
  speccy->cpu->mem[1]=speccy->cpu->memw[1]=speccy->ram[1];
  speccy->cpu->mem[2]=speccy->cpu->memw[2]=speccy->ram[2];
  speccy->cpu->mem[3]=speccy->cpu->memw[3]=speccy->ram[3];
  
  speccy->cpu->get=s48k_get;
  speccy->cpu->set=sInves_set;
  speccy->cpu->out=sInves_out;
  speccy->cpu->in=sInves_in;
  speccy->cpu->con1=speccy->cpu->con2=sInves_contention;
  speccy->cpu->conIO=sInves_contention;
  speccy->step=(rvmSpeccyStep)stepInves;
  speccy->frameF=(rvmSpeccyStep)frameInves;
  speccy->cpu->busInt=s48k_busInt;
  speccy->cpu->iAknowlegde=sInves_ack;
  
  mixer=[rvmAudioMixer new];
  [mixer setChannels:1 maxVolume:4];
  
  speccy->mixer=&(mixer->mixerS);
  
  for(int i=0;i<1;i++)
  {
    mixer->mixerS.cVol[i]=1.0;
    mixer->mixerS.cPan[i]=0.5;
  }
}

-(void)loadDefaultRom
{
  NSFileManager *fm=[NSFileManager defaultManager];
  
  NSData *rom=[fm contentsAtPath:[[NSBundle mainBundle] pathForResource:@"Resources/Roms/ZXSpectrumInves" ofType:@"rom"]];
  memcpy(speccy->rom[0],rom.bytes,0x4000);
  //defaultRom=YES;
}

-(void)resetRam
{
  for(uint i=0;i<4;i++)
    for(uint j=0;j<0x4000;j++)
      speccy->ram[i][j]=(j & 0x1)?0x00:0xff;
}

//Snapshot support
-(NSMutableDictionary *)snapshotSpectrum
{
  NSMutableDictionary *s=[super snapshotSpectrum];
  
  s[@"portFELatch"]=[NSNumber numberWithUnsignedChar:speccyInves->portFELatch];
  
  return s;
}

-(NSMutableDictionary *)snapshotMemory
{
  NSMutableDictionary *m=[NSMutableDictionary new];
  
  m[@"ram0"]=[[NSData dataWithBytes:speccy->ram[0] length:0x4000] base64EncodedStringWithOptions:0];
  m[@"ram1"]=[[NSData dataWithBytes:speccy->ram[1] length:0x4000] base64EncodedStringWithOptions:0];
  m[@"ram2"]=[[NSData dataWithBytes:speccy->ram[2] length:0x4000] base64EncodedStringWithOptions:0];
  m[@"ram3"]=[[NSData dataWithBytes:speccy->ram[3] length:0x4000] base64EncodedStringWithOptions:0];
  
  return m;
}

//Load
-(void)loadMemory:(NSDictionary *)m
{
  for(int i=0;i<4;i++)
  {
    NSString *key=[NSString stringWithFormat:@"ram%d",i];
    
    NSData *r=[[NSData alloc] initWithBase64EncodedString:m[key] options:0];
    memcpy(speccy->ram[i],r.bytes,0x4000);
  }
}

-(void)loadSpectrum:(NSDictionary *)s
{
  [super loadSpectrum:s];
  speccyInves->portFELatch=[s[@"portFELatch"] unsignedCharValue];
}

-(rvmTransitionViewController *)configKeyboardViewController
{
  rvmZxSpectrum48kKeyboardConfigViewController *c=[[rvmZxSpectrum48kKeyboardConfigViewController alloc] initWithNibName:@"rvmInvesSpectrumPlusKeyboardViewController" bundle:nil];
  
  return c;
}

-(rvmTransitionViewController *)configViewController
{
  rvmZxSpectrum48kConfigViewController* v=(rvmZxSpectrum48kConfigViewController*)[super configViewController];
  
  v.machineImage.image=[NSImage imageNamed:@"staticInves"];
  
  return v;
}

-(NSMutableDictionary*)snapshotModel
{
  NSMutableDictionary *d=[NSMutableDictionary new];
  
  d[@"arch"]=@"ZX Spectrum";
  d[@"model"]=@"Inves";
  d[@"submodel"]=@"Inves";
  
  return d;
}

-(void)deallocMemory {
  for(int i=0;i<4;i++) free(speccy->ram[i]);
  for(int i=0;i<1;i++) free(speccy->rom[i]);
}
@end
