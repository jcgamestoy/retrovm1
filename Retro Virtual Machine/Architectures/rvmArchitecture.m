//
//  rvmArchitecture.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 10/02/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmArchitecture.h"
//#import "rvmZXSpectrum.h"
#import "rvmZXSpectrum16k.h"
#import "rvmZXSpectrum48k.h"
#import "rvmZXSpectrum128k.h"
#import "rvmZXSpectrum128kSpa.h"
#import "rvmZxSpectrumPlus2.h"
#import "rvmZxSpectrumPlus2Spa.h"
#import "rvmZXSpectrumPlus2Fr.h"
#import "rvmZXSpectrumPlus2A.h"
#import "rvmZxSpectrumPlus2ASpa.h"
#import "rvmZXSpectrumPlus2E.h"
#import "rvmZXSpectrum48kIssue2.h"
#import "rvmZXSpectrum16kIssue2.h"
#import "rvmZXSpectrumPlus3.h"
#import "rvmZXSpectrumPlus2Av41.h"
#import "rvmZxSpectrumPlus2Av41Spa.h"
#import "rvmZxSpectrumPlus3Spa.h"
#import "rvmZxSpectrumPlus3v41.h"
#import "rvmZxSpectrumPlus3v41Spa.h"
#import "rvmZxSpectrumPlus3E.h"
#import "rvmZXSpectrumPlus.h"
#import "rvmZXSpectrumPlusSpa.h"
#import "rvmZXSpectrumInves.h"

/*
#import "rvmAmstradCPC464.h"
#import "rvmAmstradCPC664.h"
#import "rvmAmstradCPC6128.h"
*/
#import "NSData+Gzip.h"

#import "NSFileWrapper+Extension.h"
#import "NSData+Gzip.h"

#import "rvmAudioViewController.h"
#import "rvmVideoViewController.h"

#define kMajor 1
#define kMinor 1

static NSDictionary *architectures;
static NSMutableDictionary *directArch;

@implementation rvmArchitecture

+(void)initArchitectures
{
  if(!architectures)
  {
    architectures=@{@"_childs":@[
                                  @{
                        @"_name":kRvmZXSpectrumArchitecture,
                        @"_childs":@[
                        @{
                            @"_name":kRvmZxSpectrumModel,
                            @"_childs":@[
                            @{
                                @"_name":kRvmZXSpectrum16,
                                @"image":[NSImage imageNamed:@"speccy 16k"],@"model":@1,@"class":[rvmZXSpectrum16k class],
                                @"machineImage":[NSImage imageNamed:@"staticSpectrum48k"],
                                @"desc":@"<b>Cpu:</b> Z80A @3.5Mhz</br><b>Ram:</b> 16Kb</br><b>Rom:</b> 16Kb</br><b>Standard ULA</b></br><b>Issue 3 Motherboard</b>"},
                            @{
                                @"_name":kRvmZXSpectrum48,
                                @"image":[NSImage imageNamed:@"speccy 48k"],@"model":@2,@"class":[rvmZXSpectrum48k class],
                                @"machineImage":[NSImage imageNamed:@"staticSpectrum48k"],
                                @"desc":@"<b>Cpu:</b> Z80A @3.5Mhz</br><b>Ram:</b> 48Kb</br><b>Rom:</b> 16Kb</br><b>Standard ULA</b></br><b>Issue 3 Motherboard</b>"},
                            @{
                                @"_name":kRvmZXSpectrumPlus,@"image":[NSImage imageNamed:@"speccy +"],@"model":@2,@"class":[rvmZXSpectrumPlus class],
                                @"machineImage":[NSImage imageNamed:@"staticSpectrum+"],
                                @"desc":@"<b>Cpu:</b> Z80A @3.5Mhz</br><b>Ram:</b> 48Kb</br><b>Rom:</b> 16Kb</br><b>Standard ULA</b></br>"},
                            @{
                              @"_name":kRvmZXSpectrumPlusSpa,@"image":[NSImage imageNamed:@"speccy + spa"],@"model":@2,@"class":[rvmZXSpectrumPlusSpa class],
                              @"machineImage":[NSImage imageNamed:@"staticSpectrum+Spa"],
                              @"desc":@"<b>Cpu:</b> Z80A @3.5Mhz</br><b>Ram:</b> 48Kb</br><b>Rom:</b> 16Kb</br><b>Standard ULA</b></br>"},
                            @{@"_name":kRvmZXSpectrum16Issue2,@"image":[NSImage imageNamed:@"speccy 16k i2"],@"model":@12,@"class":[rvmZXSpectrum16kIssue2 class],
                              @"machineImage":[NSImage imageNamed:@"staticSpectrum48k"],
                              @"desc":@"<b>Cpu:</b> Z80A @3.5Mhz</br><b>Ram:</b> 16Kb</br><b>Rom:</b> 16Kb</br><b>Standard ULA</b></br><b>Issue 2 Motherboard</b>"},
                            @{@"_name":kRvmZXSpectrum48Issue2,@"image":[NSImage imageNamed:@"speccy 48k i2"],@"model":@11,@"class":[rvmZXSpectrum48kIssue2 class],
                              @"machineImage":[NSImage imageNamed:@"staticSpectrum48k"],
                              @"desc":@"<b>Cpu:</b> Z80A @3.5Mhz</br><b>Ram:</b> 48Kb</br><b>Rom:</b> 16Kb</br><b>Standard ULA</b></br><b>Issue 2 Motherboard</b>"}
                            ]
                            },
                        @{
                          @"_name":kRvmZxSpectrumModelInves,
                          @"_childs":@[
                              @{
                                @"_name":kRvmZXSpectrumInves,
                                @"image":[NSImage imageNamed:@"inves +"],@"model":@1,@"class":[rvmZXSpectrumInves class],
                                @"machineImage":[NSImage imageNamed:@"staticInves"],
                                @"desc":@"<b>Cpu:</b> Z80A @3.54690Mhz</br><b>Ram:</b> 48Kb (+16kb hidden)</br><b>Rom:</b> 16Kb</br><b>Texas Istruments ULA</b></br><b>No memory contention</b>"},
                                                            ]
                          },
                        @{
                            @"_name":kRvmZxSpectrumModel128,
                            @"_childs":@[
                            @{@"_name":kRvmZXSpectrum128,@"image":[NSImage imageNamed:@"speccy 128k"],@"model":@3,@"class":[rvmZXSpectrum128k class],
                              @"machineImage":[NSImage imageNamed:@"staticSpectrum128k"],
                              @"desc":@"<b>Cpu:</b> Z80A @3.54690Mhz</br><b>Ram:</b> 128Kb</br><b>Rom:</b> 32Kb</br><b>Standard ULA</b></br>"},
                            @{@"_name":kRvmZXSpectrum128spa,@"image":[NSImage imageNamed:@"speccy 128k spa"],@"model":@4,@"class":[rvmZXSpectrum128kSpa class],
                              @"machineImage":[NSImage imageNamed:@"staticSpectrum128kSpa"],
                              @"desc":@"<b>Cpu:</b> Z80A @3.54690Mhz</br><b>Ram:</b> 128Kb</br><b>Rom:</b> 32Kb</br><b>Standard ULA</b></br><b>Spanish version</b></br>"},
                            ]},
                        @{
                            @"_name":kRvmZxSpectrumModelPlus2,
                            @"_childs":@[
                            @{@"_name":kRvmZXSpectrumPlus2,@"image":[NSImage imageNamed:@"speccy +2"],@"model":@5,@"class":[rvmZxSpectrumPlus2 class],
                              @"machineImage":[NSImage imageNamed:@"staticSpectrum+2"],
                              @"desc":@"<b>Cpu:</b> Z80A @3.54690Mhz</br><b>Ram:</b> 128Kb</br><b>Rom:</b> 32Kb</br><b>Standard ULA</b></br><b>Integrated datacorder</b></br><b>English version</b></br>"},
                            @{@"_name":kRvmZXSpectrumPlus2Spa,@"image":[NSImage imageNamed:@"speccy +2 spa"],@"model":@6,@"class":[rvmZxSpectrumPlus2Spa class],
                              @"machineImage":[NSImage imageNamed:@"staticSpectrum+2"],
                              @"desc":@"<b>Cpu:</b> Z80A @3.54690Mhz</br><b>Ram:</b> 128Kb</br><b>Rom:</b> 32Kb</br><b>Standard ULA</b></br><b>Integrated datacorder</b></br><b>Spanish version</b></br>"},
                            @{@"_name":kRvmZXSpectrumPlus2Fr,@"image":[NSImage imageNamed:@"speccy +2 fr"],@"model":@7,@"class":[rvmZXSpectrumPlus2Fr class],
                              @"machineImage":[NSImage imageNamed:@"staticSpectrum+2"],
                              @"desc":@"<b>Cpu:</b> Z80A @3.54690Mhz</br><b>Ram:</b> 128Kb</br><b>Rom:</b> 32Kb</br><b>Standard ULA</b></br><b>Integrated datacorder</b></br><b>French version</b></br>"},
                            ]},
                        @{
                            @"_name":kRvmZxSpectrumModelPlus2A,
                            @"_childs":@[
                            @{@"_name":kRvmZXSpectrumPlus2A,@"image":[NSImage imageNamed:@"speccy +2A v4.0"],@"model":@8,@"class":[rvmZxSpectrumPlus2A class],
                              @"machineImage":[NSImage imageNamed:@"staticSpectrum+2A"],
                              @"desc":@"<b>Cpu:</b> Z80A @3.54690Mhz</br><b>Ram:</b> 128Kb</br><b>Rom:</b> 64Kb</br><b>Standard ULA</b></br><b>Integrated datacorder</b></br><b>Rom Version:<b> 4.0 English</br>"},
                            @{@"_name":kRvmZXSpectrumPlus2ASpa,@"image":[NSImage imageNamed:@"speccy +2A v4.0 spa"],@"model":@9,@"class":[rvmZxSpectrumPlus2ASpa class],
                              @"machineImage":[NSImage imageNamed:@"staticSpectrum+2A"],
                              @"desc":@"<b>Cpu:</b> Z80A @3.54690Mhz</br><b>Ram:</b> 128Kb</br><b>Rom:</b> 64Kb</br><b>Standard ULA</b></br><b>Integrated datacorder</b></br><b>Rom Version:<b> 4.0 Spanish</br>"},
                            @{@"_name":kRvmZXSpectrumPlus2E,@"image":[NSImage imageNamed:@"speccy +2E"],@"model":@10,@"class":[rvmZXSpectrumPlus2E class],
                              @"machineImage":[NSImage imageNamed:@"staticSpectrum+2A"],
                              @"desc":@"<b>Cpu:</b> Z80A @3.54690Mhz</br><b>Ram:</b> 128Kb</br><b>Rom:</b> 64Kb</br><b>Standard ULA</b></br><b>Integrated datacorder</b></br><b>Rom Version:<b> +3E</br>"},
                            @{@"_name":kRvmZXSpectrumPlus2Av41,@"image":[NSImage imageNamed:@"speccy +2A v4.1"],@"model":@8,@"class":[rvmZXSpectrumPlus2Av41 class],
                              @"machineImage":[NSImage imageNamed:@"staticSpectrum+2A"],
                              @"desc":@"<b>Cpu:</b> Z80A @3.54690Mhz</br><b>Ram:</b> 128Kb</br><b>Rom:</b> 64Kb</br><b>Standard ULA</b></br><b>Integrated datacorder</b></br><b>Rom Version:<b> 4.1 English</br>"},
                            @{@"_name":kRvmZXSpectrumPlus2Av41Spa,@"image":[NSImage imageNamed:@"speccy +2A v4.1 spa"],@"model":@8,@"class":[rvmZXSpectrumPlus2Av41 class],
                              @"machineImage":[NSImage imageNamed:@"staticSpectrum+2A"],
                              @"desc":@"<b>Cpu:</b> Z80A @3.54690Mhz</br><b>Ram:</b> 128Kb</br><b>Rom:</b> 64Kb</br><b>Standard ULA</b></br><b>Integrated datacorder</b></br><b>Rom Version:<b> 4.1 Spanish</br>"},
                            ]},
                        @{
                            @"_name":kRvmZxSpectrumModelPlus3,
                            @"_childs":@[
                            @{@"_name":kRvmZXSpectrumPlus3v40,@"image":[NSImage imageNamed:@"speccy +3 v4.0"],@"model":@8,@"class":[rvmZXSpectrumPlus3 class],
                              @"machineImage":[NSImage imageNamed:@"staticSpectrum+3"],
                              @"desc":@"<b>Cpu:</b> Z80A @3.54690Mhz</br><b>Ram:</b> 128Kb</br><b>Rom:</b> 64Kb</br><b>Standard ULA</b></br><b>Integrated Fdd drive</b></br><b>Rom Version:<b> 4.0 English</br>"},
                            @{@"_name":kRvmZXSpectrumPlus3v40Spa,@"image":[NSImage imageNamed:@"speccy +3 v4.0 spa"],@"model":@8,@"class":[rvmZxSpectrumPlus3Spa class],
                              @"machineImage":[NSImage imageNamed:@"staticSpectrum+3"],
                              @"desc":@"<b>Cpu:</b> Z80A @3.54690Mhz</br><b>Ram:</b> 128Kb</br><b>Rom:</b> 64Kb</br><b>Standard ULA</b></br><b>Integrated Fdd drive</b></br><b>Rom Version:<b> 4.0 Spanish</br>"},
                            @{@"_name":kRvmZXSpectrumPlus3v41,@"image":[NSImage imageNamed:@"speccy +3 v4.1"],@"model":@8,@"class":[rvmZxSpectrumPlus3v41 class],
                              @"machineImage":[NSImage imageNamed:@"staticSpectrum+3"],
                              @"desc":@"<b>Cpu:</b> Z80A @3.54690Mhz</br><b>Ram:</b> 128Kb</br><b>Rom:</b> 64Kb</br><b>Standard ULA</b></br><b>Integrated Fdd drive</b></br><b>Rom Version:<b> 4.1 English</br>"},
                            @{@"_name":kRvmZXSpectrumPlus3v41Spa,@"image":[NSImage imageNamed:@"speccy +3 v4.1 spa"],@"model":@8,@"class":[rvmZxSpectrumPlus3v41Spa class],
                              @"machineImage":[NSImage imageNamed:@"staticSpectrum+3"],
                              @"desc":@"<b>Cpu:</b> Z80A @3.54690Mhz</br><b>Ram:</b> 128Kb</br><b>Rom:</b> 64Kb</br><b>Standard ULA</b></br><b>Integrated Fdd drive</b></br><b>Rom Version:<b> 4.1 Spanish</br>"},
                            @{@"_name":kRvmZXSpectrumPlus3E,@"image":[NSImage imageNamed:@"speccy +3E"],@"class":[rvmZxSpectrumPlus3E class],
                              @"machineImage":[NSImage imageNamed:@"staticSpectrum+3"],
                              @"desc":@"<b>Cpu:</b> Z80A @3.54690Mhz</br><b>Ram:</b> 128Kb</br><b>Rom:</b> 64Kb</br><b>Standard ULA</b></br><b>Integrated Fdd drive</b></br><b>Rom Version:<b> +3E</br>"}
                            ]},
                        //Amstrad
                        /*
                        ]},
                                  @{@"_name":kRvmAmstradCpcArchitecture,
                                    @"_childs":@[
                                        @{
                                          @"_name":kRvmAmstradCpcModel,
                                          @"_childs":@[
                                              @{
                                                
                                                @"_name":kRvmAmstradCpc464,
                                                @"image":[NSImage imageNamed:@"speccy 16k"],@"model":@1,@"class":[rvmAmstradCPC464 class],
                                                @"machineImage":[NSImage imageNamed:@"staticSpectrum48k"],
                                                @"desc":@"<b>Cpu:</b> Z80A @3.5Mhz</br><b>Ram:</b> 16Kb</br><b>Rom:</b> 16Kb</br><b>Standard ULA</b></br><b>Issue 3 Motherboard</b>"},
                                              @{
                                                
                                                @"_name":kRvmAmstradCpc664,
                                                @"image":[NSImage imageNamed:@"speccy 16k"],@"model":@1,@"class":[rvmAmstradCPC664 class],
                                                @"machineImage":[NSImage imageNamed:@"staticSpectrum48k"],
                                                @"desc":@"<b>Cpu:</b> Z80A @3.5Mhz</br><b>Ram:</b> 16Kb</br><b>Rom:</b> 16Kb</br><b>Standard ULA</b></br><b>Issue 3 Motherboard</b>"},
                                              @{
                                                
                                                @"_name":kRvmAmstradCpc6128,
                                                @"image":[NSImage imageNamed:@"speccy 16k"],@"model":@1,@"class":[rvmAmstradCPC6128 class],
                                                @"machineImage":[NSImage imageNamed:@"staticSpectrum48k"],
                                                @"desc":@"<b>Cpu:</b> Z80A @3.5Mhz</br><b>Ram:</b> 16Kb</br><b>Rom:</b> 16Kb</br><b>Standard ULA</b></br><b>Issue 3 Motherboard</b>"}
                                              
                                              ]
                                          },*/
                                        
                                        ]
                                    
                                    }
                                  ]};
    
    directArch=[NSMutableDictionary new];
    for(NSDictionary *a in architectures[@"_childs"])
    {
      for(NSDictionary *m in a[@"_childs"])
      {
        for(NSDictionary *s in m[@"_childs"])
        {
          directArch[s[@"_name"]]=s;
        }
      }
    }
  }
}

- (id)init
{
    self = [super init];
    if (self) {
      if(!architectures) [self.class initArchitectures];
      
        // Add your subclass-specific initialization here.
      self.properties=[NSMutableDictionary dictionary];
    }
  return self;
}

+(NSDictionary*)architectures
{
  if(!architectures) [rvmArchitecture initArchitectures];
  return architectures;
}

-(BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
  NSError *e=nil;
  NSDictionary *root=[NSJSONSerialization JSONObjectWithData:[[fileWrapper.fileWrappers[@"machine"] regularFileContents] gunzip] options:0 error:&e];
  
  NSUInteger M=[root[@"version"][@"major"] unsignedIntegerValue];
  NSUInteger m=[root[@"version"][@"minor"] unsignedIntegerValue];
  
  if(M>kMajor || (M==kMajor && m>kMinor)) return NO;
  
  _properties=[NSMutableDictionary dictionaryWithDictionary:root[@"properties"]];
  
  [self createMachine];
  
  if(!self.machine) return NO;
  
  if(root[@"snap"])
  {
    [_machine loadSnapshot:root[@"snap"]];
    //_machine.running=YES;
    //_machine.paused=YES;
    _machine.control=0x3;
  }
  
  if(_properties[@"keyboard"])
    [self.machine loadMachineKeys:[[NSData alloc] initWithBase64EncodedString:_properties[@"keyboard"] options:0]];
  
  [_machine.audioController loadConfig:_properties[@"audio"]];
  [_machine.videoController loadConfig:_properties[@"video"] major:[_properties[@"version"][@"major"] unsignedIntValue] minor:[_properties[@"version"][@"major"] unsignedIntValue]];
  
  _fileWrapper=fileWrapper;
  return YES;
}

-(NSFileWrapper *)fileWrapperOfType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
  if(!_fileWrapper)
  {
    _fileWrapper=[[NSFileWrapper alloc] initDirectoryWithFileWrappers:@{}];
    
    //NSError *e;
    //[_fileWrapper addRegularFileWithContents:[NSPropertyListSerialization dataWithPropertyList:self.properties format:NSPropertyListXMLFormat_v1_0 options:NSPropertyListMutableContainersAndLeaves error:&e] preferredFilename:@"machine.plist"];
    
    //[_fileWrapper addRegularFileWithContents:[NSJSONSerialization dataWithJSONObject:_properties options:0 error:nil] preferredFilename:@"machine.json"];
    
    //[self saveFile];
    
    NSFileWrapper *snapshots=[[NSFileWrapper alloc] initDirectoryWithFileWrappers:@{}];
    [snapshots setPreferredFilename:@"snap"];
    
    [_fileWrapper addFileWrapper:snapshots];
  }
  [self saveFile];
  return _fileWrapper;
}



-(void)saveFile
{
  NSMutableDictionary *root=[NSMutableDictionary new];
  
  root[@"version"]=[self version];
  root[@"properties"]=_properties;
  
  _properties[@"keyboard"]=[_machine.machineKeysSnap base64EncodedStringWithOptions:0];
  _properties[@"audio"]=[[_machine audioController] saveConfig];
  _properties[@"video"]=[[_machine videoController] saveConfig];
  
  if(_machine.control & kRvmStatePlaying)
  {
    @synchronized(_machine)
    {
      root[@"snap"]=[_machine createSnapshot];
    }
  }
  
  
  NSData *json=[NSJSONSerialization dataWithJSONObject:root options:NSJSONWritingPrettyPrinted error:nil];
  
  [_fileWrapper updateContents:[json gzip] filename:@"machine"];
  
}

-(void)saveMain
{
  [self saveFile];
  [self updateChangeCount:NSChangeDone];
  [self saveDocument:self];
}

-(NSString*)title
{
  return (_properties[@"title"])?_properties[@"title"]:_properties[@"submodel"];
}

-(NSImage*)image
{
  //return architectures[self.properties[@"architecture"]][self.properties[@"model"]][self.properties[@"submodel"]][@"image"];
  return directArch[_properties[@"submodel"]][@"image"];
}

-(void)saveSnapshot:(NSDictionary*)s filename:(NSString*)filename
{
  NSFileWrapper *f=_fileWrapper.fileWrappers[@"snap"];
  @synchronized(_machine)
  {
    [f updateContents:[[NSJSONSerialization dataWithJSONObject:s options:NSJSONWritingPrettyPrinted error:nil] gzip] filename:filename];
  }
  [self saveMain];
}

-(NSString*)snapshotPath:(NSString*)path
{
  NSFileWrapper *f=_fileWrapper.fileWrappers[@"snap"];
  
  int count=1;
  NSString *p=path;
  while([f.fileWrappers objectForKey:p])
  {
    p=[NSString stringWithFormat:@"%@ (%d)",path,count++];
  }
  
  return p;
}

-(void)removeSnapshot:(NSString*)path completion:(void (^)(void))com
{
  NSFileWrapper *f=_fileWrapper.fileWrappers[@"snap"];
  [f removeFileWrapper:f.fileWrappers[path]];
  //[self saveDocument:self];
  
  [self savePresentedItemChangesWithCompletionHandler:^(NSError *errorOrNil) {
    if(!errorOrNil)
      com();
  }];
}

-(NSFileWrapper*)getSnapshots
{
  NSFileWrapper *f=_fileWrapper.fileWrappers[@"snap"];
  
  return f;
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

+(rvmArchitecture*)newArchitecture:(NSIndexPath*)ip
{
  NSDocumentController *dc=[NSDocumentController sharedDocumentController];
  
  NSError *e;
  rvmArchitecture *a=[dc makeUntitledDocumentOfType:@"com.madeInAlacant.rvmMachine" error:&e];
  
  NSUInteger ind[3];
  
  [ip getIndexes:ind];
  
  NSDictionary *ar=architectures[@"_childs"][ind[0]];
  NSDictionary *md=ar[@"_childs"][ind[1]];
  NSDictionary *sm=md[@"_childs"][ind[2]];
  
  a.properties[@"architecture"]=ar[@"_name"];
  a.properties[@"model"]=md[@"_name"];
  a.properties[@"submodel"]=sm[@"_name"];
  
  [a createMachine];
  a.properties[@"keyboard"]=[[a.machine machineKeysSnap] base64EncodedStringWithOptions:0];
  a.properties[@"audio"]=@{
                           @"volume":@1,
                           @"highPass":@20,
                           @"lowPass":@6000,
                           @"preset":@1
                           };
  a.properties[@"video"]=@{
                           @"preset":@3,
                           @"overscanPreset":@4,
                           };
  
  [[a.machine audioController] loadConfig:a.properties[@"audio"]];
  //[[a.machine videoController] loadConfig:a.properties[@"video"]];
  [[a.machine videoController] loadConfig:a.properties[@"video"] major:[a.properties[@"version"][@"major"] unsignedIntValue] minor:[a.properties[@"version"][@"major"] unsignedIntValue]];
  return a;
}

//Constructors
//-(void)newArchitecture:(NSString*)arch model:(NSString*)model
//{
//  self.properties[@"architecture"]=arch;
//  
//  self.properties[@"model"]=model;
//  
//  [self createMachine];
//}

-(void)createMachine
{
//  if([_properties[@"architecture"] isEqualToString:kRvmZXSpectrumArchitecture] )
//  {
    //_machine=[architectures[self.properties[@"architecture"]][self.properties[@"model"]][self.properties[@"submodel"]][@"class"] new];
  NSDictionary *sm=directArch[_properties[@"submodel"]];
  Class c=sm[@"class"];
  if(c)
  {
    _machine=[c new];
    
    _machine.doc=self;
              }
//  }
}

-(NSDictionary*)version
{
  NSMutableDictionary *version=[NSMutableDictionary new];
  
  version[@"major"]=@kMajor;
  version[@"minor"]=@kMinor;
  
  return version;
}

@end
