//
//  rvmAudioViewControllerZx128.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 8/1/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmAudioViewControllerZx128.h"

@interface rvmAudioViewControllerZx128 ()
{
  double ll,rl;
//  double mbe,ma,mb,mc;
//  uint32 cc;
  NSArray *vols;
}

@property (strong) IBOutlet NSPopover *mixerPop;
@property (weak) IBOutlet rvmAudioLeds *beeperLed;
@property (weak) IBOutlet rvmAudioLeds *ayALed;
@property (weak) IBOutlet rvmAudioLeds *ayBLed;
@property (weak) IBOutlet rvmAudioLeds *ayCLed;

@property (weak) IBOutlet NSSlider *beeperVol;
@property (weak) IBOutlet NSSlider *ayAVol;
@property (weak) IBOutlet NSSlider *ayBVol;
@property (weak) IBOutlet NSSlider *ayCVol;
@property (weak) IBOutlet NSSlider *beeperPan;
@property (weak) IBOutlet NSSlider *ayAPan;
@property (weak) IBOutlet NSSlider *ayBPan;
@property (weak) IBOutlet NSSlider *ayCPan;
@property (weak) IBOutlet NSPopUpButton *presetCombo;


@end

@implementation rvmAudioViewControllerZx128

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    // Do view setup here.
//}

-(void)awakeFromNib
{
  [super awakeFromNib];
  vols=@[_beeperVol,_ayAVol,_ayBVol,_ayCVol];
  ll=rl=0;
//  mbe=mb=mc=ma=0;
//  cc=0;
//
  //[_presetCombo selectItemWithTag:1];
  _beeperLed.value=0;
  _ayALed.value=0;
  _ayBLed.value=0;
  _ayCLed.value=0;
}

-(void)setLevels
{
  if(!self.mixer) return;
  
  [super setLevels];
  
  double *pt=self.mixer->mixerS.cOut;
  
  _beeperLed.value=pt[0];
  _ayALed.value=pt[1];
  _ayBLed.value=pt[2];
  _ayCLed.value=pt[3];
}


- (IBAction)onMixer:(NSButton*)sender {
  [_mixerPop showRelativeToRect:sender.bounds ofView:sender preferredEdge:NSMaxXEdge];
}

- (IBAction)onPanChannel:(NSSlider*)sender {
  self.mixer->mixerS.cPan[sender.tag]=sender.doubleValue;
}

- (IBAction)onVolChannel:(NSSlider*)sender {
  self.mixer->mixerS.cVol[sender.tag]=sender.doubleValue;
}

static double pans[7][4]={
  {.5,.5,.5,.5}, //Mono
  {.5,0,.5,1}, //ABC
  {.5,0,1,.5}, //ACB
  {.5,.5,0,1}, //BAC
  {.5,1,0,.5}, //BCA
  {.5,.5,1,0}, //CAB
  {.5,1,.5,0} //CBA
};

- (IBAction)onPreset:(NSMenuItem*)sender {
  [self applyPreset:(uint)sender.tag];
}

-(void)applyPreset:(uint)preset
{
  if(preset<7)
  {
    _ayAVol.doubleValue=_ayBVol.doubleValue=_ayCVol.doubleValue=1.0;
    self.mixer->mixerS.cVol[0]=1.33;
    self.mixer->mixerS.cVol[1]=1;
    self.mixer->mixerS.cVol[2]=1;
    self.mixer->mixerS.cVol[3]=1;
    
    _beeperVol.doubleValue=1.33;
    
    _ayAPan.doubleValue=self.mixer->mixerS.cPan[1]=pans[preset][1];
    _ayBPan.doubleValue=self.mixer->mixerS.cPan[2]=pans[preset][2];
    _ayCPan.doubleValue=self.mixer->mixerS.cPan[3]=pans[preset][3];
    _beeperPan.doubleValue=self.mixer->mixerS.cPan[0]=pans[preset][0];
    
    _ayAVol.enabled=_ayBVol.enabled=_ayCVol.enabled=_beeperVol.enabled=NO;
    _ayAPan.enabled=_ayBPan.enabled=_ayCPan.enabled=_beeperPan.enabled=NO;
  }
  else
  {
    self.mixer->mixerS.cVol[0]=_beeperVol.doubleValue;
    self.mixer->mixerS.cVol[1]=_ayAVol.doubleValue;
    self.mixer->mixerS.cVol[2]=_ayBVol.doubleValue;
    self.mixer->mixerS.cVol[3]=_ayCVol.doubleValue;
    
    self.mixer->mixerS.cPan[0]=_beeperPan.doubleValue;
    self.mixer->mixerS.cPan[1]=_ayAPan.doubleValue;
    self.mixer->mixerS.cPan[2]=_ayBPan.doubleValue;
    self.mixer->mixerS.cPan[3]=_ayCPan.doubleValue;
    
    _ayAVol.enabled=_ayBVol.enabled=_ayCVol.enabled=_beeperVol.enabled=YES;
    _ayAPan.enabled=_ayBPan.enabled=_ayCPan.enabled=_beeperPan.enabled=YES;
  }
}

- (IBAction)onMute:(NSButton *)sender {
  NSSlider *sl=vols[sender.tag];
  
  if(!sender.state)
  {
    self.mixer->mixerS.cVol[sender.tag]=sl.doubleValue;
  }
  else
  {
    self.mixer->mixerS.cVol[sender.tag]=0.0;
  }
}

-(NSMutableDictionary *)saveConfig
{
  NSMutableDictionary *config=[super saveConfig];
  
  uint preset=(uint)_presetCombo.selectedTag;
  
  config[@"preset"]=[NSNumber numberWithUnsignedInt:preset];
  
  if(preset>=7)
  {
    config[@"mixer"]=[NSMutableDictionary dictionary];
    
    NSMutableDictionary *m=config[@"mixer"];
    
    m[@"bVol"]=_beeperVol.objectValue;
    m[@"bPan"]=_beeperPan.objectValue;
    
    m[@"ayAV"]=_ayAVol.objectValue;
    m[@"ayAP"]=_ayAPan.objectValue;
    
    m[@"ayBV"]=_ayBVol.objectValue;
    m[@"ayBP"]=_ayBPan.objectValue;
    
    m[@"ayCV"]=_ayCVol.objectValue;
    m[@"ayCP"]=_ayCPan.objectValue;
  }
  
  return config;
}

-(void)performConfig:(NSDictionary *)d
{
  [super performConfig:d];
  
  uint pr=[d[@"preset"] unsignedIntValue];
  
  [_presetCombo selectItemWithTag:pr];

  
  if(pr>=7)
  {
    NSDictionary *m=d[@"mixer"];
    _beeperVol.objectValue=m[@"bVol"];
    _beeperPan.objectValue=m[@"bPan"];
    
    _ayAVol.objectValue=m[@"ayAV"];
    _ayAPan.objectValue=m[@"ayAP"];
    _ayBVol.objectValue=m[@"ayBV"];
    _ayBPan.objectValue=m[@"ayBP"];
    _ayCVol.objectValue=m[@"ayCV"];
    _ayCPan.objectValue=m[@"ayCP"];
  }
  
  [self applyPreset:pr];
}

@end
