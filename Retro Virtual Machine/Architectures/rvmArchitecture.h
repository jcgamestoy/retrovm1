//
//  rvmArchitecture.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 10/02/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "rvmMachineProtocol.h"

#define kRvmZXSpectrumArchitecture @"Zx Spectrum"

#define kRvmZxSpectrumModel @"Zx Spectrum"
#define kRvmZxSpectrumModelInves @"Inves Spectrum"
#define kRvmZxSpectrumModel128 @"Zx Spectrum 128k"
#define kRvmZxSpectrumModelPlus2 @"Zx Spectrum +2"
#define kRvmZxSpectrumModelPlus2A @"Zx Spectrum +2A"
#define kRvmZxSpectrumModelPlus3 @"Zx Spectrum +3"

#define kRvmZXSpectrum16 @"Zx Spectrum 16k"
#define kRvmZXSpectrum48 @"Zx Spectrum 48k"
#define kRvmZXSpectrumPlus @"Zx Spectrum +"
#define kRvmZXSpectrum128 @"Zx Spectrum 128k"
#define kRvmZXSpectrum128spa @"Zx Spectrum 128k Spanish"
#define kRvmZXSpectrumPlus2 @"Zx Spectrum +2"
#define kRvmZXSpectrumPlus2Spa @"Zx Spectrum +2 Spanish"
#define kRvmZXSpectrumPlus2Fr @"Zx Spectrum +2 French"
#define kRvmZXSpectrumPlus2A @"Zx Spectrum +2A v4.0"
#define kRvmZXSpectrumPlus2ASpa @"Zx Spectrum +2A v4.0 Spanish"
#define kRvmZXSpectrumPlus2Av41 @"Zx Spectrum +2A v4.1"
#define kRvmZXSpectrumPlus2Av41Spa @"Zx Spectrum +2A v4.1 Spanish"
#define kRvmZXSpectrumPlus2E @"Zx Spectrum +2E"
#define kRvmZXSpectrumPlus3v40 @"Zx Spectrum +3 v4.0"
#define kRvmZXSpectrumPlus3v40Spa @"Zx Spectrum +3 v4.0 Spanish"
#define kRvmZXSpectrumPlus3v41 @"Zx Spectrum +3 v4.1"
#define kRvmZXSpectrumPlus3v41Spa @"Zx Spectrum +3 v4.1 Spanish"
#define kRvmZXSpectrumPlus3E @"Zx Spectrum +3E"

#define kRvmZXSpectrumPlusSpa @"Zx Spectrum + Spanish"

#define kRvmZXSpectrum16Issue2 @"Zx Spectrum 16k issue 2"
#define kRvmZXSpectrum48Issue2 @"Zx Spectrum 48k issue 2"

#define kRvmZXSpectrumInves @"Inves Spectrum +"

//AMSTRAD CPC
#define kRvmAmstradCpcArchitecture @"Amstrad CPC"

#define kRvmAmstradCpcModel @"Amstrad CPC"

#define kRvmAmstradCpc464 @"Amstrad CPC 464"
#define kRvmAmstradCpc664 @"Amstrad CPC 664"
#define kRvmAmstradCpc6128 @"Amstrad CPC 6128"

@interface rvmArchitecture : NSDocument

@property NSMutableDictionary *properties;
@property id<rvmMachineProtocol> machine;
@property NSFileWrapper *fileWrapper;

+(NSDictionary*)architectures;

+(rvmArchitecture*)newArchitecture:(NSIndexPath*)ip;

-(NSString*)title;
-(NSImage*)image;

-(NSString*)snapshotPath:(NSString*)path;
-(void)saveSnapshot:(NSDictionary*)s filename:(NSString*)filename;
-(void)removeSnapshot:(NSString*)path completion:(void (^)(void))com;
-(NSFileWrapper*)getSnapshots;

-(void)saveMain;
-(void)saveFile;
@end
