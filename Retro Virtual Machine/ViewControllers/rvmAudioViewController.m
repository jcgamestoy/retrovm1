//
//  rvmAudioViewController.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 24/01/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmAudioViewController.h"
#import "rvmBackgroundView.h"
#import "rvmImageView.h"

@interface rvmAudioViewController ()
{
  double ll,rl;
  NSDictionary *configL;
}

@property (strong) IBOutlet rvmBackgroundView *backgroundView;

@property (weak) IBOutlet NSSlider *lowPassSlider;
@property (weak) IBOutlet NSSlider *highPassSlider;
@property (weak) IBOutlet NSTextField *lowPassLabel;
@property (weak) IBOutlet NSTextField *highPassLabel;
@property (weak) IBOutlet NSSlider *volumeSlider;
@property (weak) IBOutlet rvmImageView *soundImage;
@property (weak) IBOutlet NSScrollView *scrollView;

@end

@implementation rvmAudioViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)awakeFromNib
{
  [self onLowPass:self];
  [self onHighPass:self];
  
  if(configL) [self performConfig:configL];
}

- (IBAction)onLowPass:(id)sender {
  //_machine.lowPass=_lowPassSlider.doubleValue;
  _engine.lowPassFilter=_lowPassSlider.doubleValue;
  _lowPassLabel.stringValue=[NSString stringWithFormat:@"Low Pass Filter: %.f Hz",_lowPassSlider.doubleValue];
  
}

- (IBAction)onHighPass:(id)sender {
  _engine.highPassFilter=_highPassSlider.doubleValue;
  _highPassLabel.stringValue=[NSString stringWithFormat:@"High Pass Filter: %.f Hz",_highPassSlider.doubleValue];
}

-(void)setEngine:(rvmAudioEngine *)engine
{
  _engine=engine;
  //engine.lowPassFilter=_lowPassSlider.doubleValue;
  //engine.highPassFilter=_highPassSlider.doubleValue;
  [self onLowPass:self];
  [self onHighPass:self];
}

-(void)setLevels
{
  if(!self.mixer) return;

  
  ll=self.mixer->mixerS.l*0.5;
  rl=self.mixer->mixerS.r*0.5;

  ll=isnan(ll)?0:ll;
  rl=isnan(rl)?0:rl;
  
  double v=self.mixer->mixerS.volume;
  
  self.lMaster.value=ll*v;
  self.rMaster.value=rl*v;
}

-(NSMutableDictionary*)saveConfig
{
  if(!self.view) [self loadView];
  
  NSMutableDictionary *config=[NSMutableDictionary dictionary];
  
  config[@"highPass"]=_highPassSlider.objectValue;
  config[@"lowPass"]=_lowPassSlider.objectValue;
  config[@"volume"]=_volumeSlider.objectValue;
  
  return config;
}

-(void)loadConfig:(NSDictionary*)d
{
  configL=d;
  [self performConfig:configL];
}

-(void)performConfig:(NSDictionary*)d
{
  _highPassSlider.objectValue=d[@"highPass"];
  _lowPassSlider.objectValue=d[@"lowPass"];
  _volumeSlider.objectValue=d[@"volume"];
  
  _mixer->mixerS.volume=_volumeSlider.doubleValue;
  _engine.highPassFilter=_highPassSlider.doubleValue;
  _engine.lowPassFilter=_lowPassSlider.doubleValue;
  //[_lowPassSlider setNeedsDisplay:YES];
}

- (IBAction)onVolumen:(id)sender {
  NSSlider *sl=(NSSlider*)sender;
  _mixer->mixerS.volume=sl.doubleValue;
}

-(void)animateOut
{
  _soundImage.alphaValue=0.0;
  _scrollView.alphaValue=0.0;
}

-(void)animateIn
{
  _soundImage.alphaValue=1.0;
  _scrollView.alphaValue=1.0;
}

@end
