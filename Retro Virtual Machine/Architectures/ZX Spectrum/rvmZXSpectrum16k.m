//
//  rvmZXSpectrum16k.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 11/04/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmZXSpectrum16k.h"

@implementation rvmZXSpectrum16k

-(void)initModel
{
  speccy->ram=(uint8**)malloc(sizeof(uint8*)*1);
  speccy->rom=(uint8**)malloc(sizeof(uint8*)*1);
  
  speccy->ram[0]=(uint8*)calloc(1,0x4000);
  
  speccy->rom[0]=(uint8*)calloc(1,0x4000);
  
  speccy->cpu->mem[0]=speccy->rom[0];
  speccy->cpu->mem[1]=speccy->cpu->memw[1]=speccy->ram[0];
  
  speccy->cpu->get=s16k_get;
  speccy->cpu->set=s16k_set;
  speccy->cpu->out=s48k_out;
  speccy->cpu->in=s48k_in;
  speccy->cpu->con1=speccy->cpu->con2=s48k_contention;
  speccy->cpu->conIO=s48k_contentionIO;
  speccy->step=(rvmSpeccyStep)step48k;
  speccy->frameF=(rvmSpeccyStep)frame48k;
  speccy->cpu->busInt=s48k_busInt;
  
  mixer=[rvmAudioMixer new];
  [mixer setChannels:1 maxVolume:4.0];
  speccy->mixer=&(mixer->mixerS);
  
  for(int i=0;i<1;i++)
  {
    mixer->mixerS.cVol[i]=1.0;
    mixer->mixerS.cPan[i]=0.5;
  }
}

-(void)resetRam
{
  memset(speccy->ram[0],0,0x4000);
}

//-(void)luaInit:(lua_State *)L
//{
//  callLua(L,[NSString stringWithFormat:@"local zx=require('rvm.architectures.zxspectrum.spectrum16k'); machine=zx.new(%pULL)",speccy]);
//  [self registerCommands:L];
//}

-(NSMutableDictionary *)snapshotMemory
{
  NSMutableDictionary *m=[NSMutableDictionary new];
  
  m[@"ram0"]=[[NSData dataWithBytes:speccy->ram[0] length:0x4000] base64EncodedStringWithOptions:0];
  
  return m;
}

-(void)loadMemory:(NSDictionary *)m
{
  NSData *r;
  
  r=[[NSData alloc] initWithBase64EncodedString:m[@"ram0"] options:0];
  memcpy(speccy->ram[0],r.bytes,0x4000);

}

-(NSMutableDictionary *)snapshotModel
{
  NSMutableDictionary *d=[super snapshotModel];
  
  d[@"submodel"]=@"16k";
  
  return d;
}

-(void)deallocMemory {
  free(speccy->ram[0]);
  free(speccy->rom[0]);
}

@end
