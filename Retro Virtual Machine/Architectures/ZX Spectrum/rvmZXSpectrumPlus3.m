//
//  rvmZXSpectrumPlus3.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 06/07/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmZXSpectrumPlus3.h"
#import "rvmRecorderViewController.h"
#import "rvmPlus3FddViewController.h"
#import "rvmZxSpectrum48kConfigViewController.h"
#import "rvmZxSpectrum48kKeyboardConfigViewController.h"

static bool initTables=NO;
extern NSData *motorSound,*seekSound;

@interface rvmZXSpectrumPlus3()
{
  rvmUpd765 *upd765;

  uint oldLedA,oldLedB;
}

@end

@implementation rvmZXSpectrumPlus3

-(NSViewController*)cassetteController
{
  if(!cassetteController)
    cassetteController=[[rvmRecorderViewController alloc] initWithNibName:@"rvmRecorderViewController" bundle:nil];
  return cassetteController;
}

-(NSViewController *)diskController
{
  if(!fddController)
    fddController=[[rvmPlus3FddViewController alloc] initWithNibName:@"rvmPlus3FddViewController" bundle:nil];
  
  return fddController;
}

-(void)initPtr
{
  speccy3=calloc(1,sizeof(spectrumPlus3));
  speccy2A=(spectrumPlus2A*)speccy3;
  speccy128=(spectrum128*)speccy3;
  speccy=(spectrum*)speccy3;
}

-(void)initModel
{
  [super initModel];
  if(!initTables)
  {
    initPlus3();
//    motorSound=[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Resources/Disk Sounds/Motor192" ofType:@"raw"]];
//    seekSound=[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Resources/Disk Sounds/Seek192" ofType:@"raw"]];
    initTables=YES;
  }
  

  speccy3->motorSound=speccy3->motor=(int16_t*)motorSound.bytes;
  speccy3->motorLast=(int16_t*)(motorSound.bytes+motorSound.length);
  
  speccy3->seekSound=speccy3->seek=(int16_t*)seekSound.bytes;
  speccy3->seekLast=(int16_t*)(seekSound.bytes+seekSound.length);
  
  speccy->cpu->in=sPlus3_in;
  speccy->cpu->out=sPlus3_out;
  speccy->step=(rvmSpeccyStep)stepPlus3;
  speccy->frameF=(rvmSpeccyStep)framePlus3;
  
  upd765=[rvmUpd765 new];
  speccy3->upd765=(rvmUpd765S*)upd765.handle;
  [self enableDrive:0];
  [self enableDrive:2];
}

-(void)doFrame:(bool)fast
{
  speccy3->ledA=speccy3->ledB=0;
  [super doFrame:fast];
  if(speccy3->ledA!=oldLedA)
  {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self->fddController.fdd led:self->speccy3->ledA];
    });
    oldLedA=speccy3->ledA;
  }
  
  if(speccy3->ledB!=oldLedB)
  {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self->fddController.fddB led:self->speccy3->ledB];
    });
    oldLedB=speccy3->ledB;
  }
  
  rvmDskDecoder *d=upd765->disks[0];
  if(d && d.handle->dirty)
  {
    d.handle->dirty--;
    if(!d.handle->dirty)
      [d saveEDsk];
  }
  
  d=upd765->disks[1];
  if(d && d.handle->dirty)
  {
    d.handle->dirty--;
    if(!d.handle->dirty)
      [d saveEDsk];
  }
}

-(void)resetMachine
{
  [super resetMachine];
  
  [upd765 reset];
}

-(void)insertDisk:(rvmDskDecoder *)disk inDrive:(uint32)drive
{
  [upd765 insertDisk:disk inDrive:drive];
}

-(void)enableDrive:(uint32)drive
{
  [upd765 enableDrive:drive];
}

-(void)disableDrive:(uint32)drive
{
  [upd765 disableDrive:drive];
}

-(rvmTransitionViewController *)configViewController
{
  rvmZxSpectrum48kConfigViewController* v=(rvmZxSpectrum48kConfigViewController*)[super configViewController];
  
  v.machineImage.image=[NSImage imageNamed:@"staticSpectrum+3"];
  
  return v;
}

-(rvmTransitionViewController *)configKeyboardViewController
{
  rvmZxSpectrum48kKeyboardConfigViewController *vc=[[rvmZxSpectrum48kKeyboardConfigViewController alloc] initWithNibName:@"rvmZxSpectrumPlus3KeyboardViewController" bundle:nil];
  
  return vc;
}

-(NSMutableDictionary *)snapshotModel
{
  NSMutableDictionary *d=[super snapshotModel];
  
  d[@"submodel"]=@"plus3";
  
  return d;
}

-(NSArray *)supportedTypes
{
  NSMutableArray *t=[[NSMutableArray alloc] initWithArray:[super supportedTypes]];
  [t addObject:@"dsk"];
  
  return t;
}

-(void)loadMedia:(NSURL *)filename
{
  NSString *ext=filename.pathExtension.lowercaseString;
  
  if([ext isEqualToString:@"dsk"])
    [fddController loadMediaFile:filename sound:YES drive:0];
  else
    [super loadMedia:filename];
}

-(NSMutableDictionary *)snapshotSpectrum
{
  NSMutableDictionary *s=[super snapshotSpectrum];
  s[@"upd765"]=[upd765 save];
  
  return s;
}

-(void)loadSpectrum:(NSDictionary *)s {
  [super loadSpectrum:s];
  
  if(s[@"upd765"])
    [upd765 load:s[@"upd765"]];
}

@end
