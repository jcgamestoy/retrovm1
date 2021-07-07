//
//  rvmVideoViewController.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 14/04/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmVideoViewController.h"
#import "rvmBackgroundView.h"
#import "NSColor+rvmNSColors.h"
#import "rvmImageView.h"

@interface rvmVideoViewController ()
@property (strong) IBOutlet rvmBackgroundView *backgroundView;


@property (weak) IBOutlet rvmImageView *colorIcon;
@property (weak) IBOutlet rvmImageView *contrastIcon;
@property (weak) IBOutlet rvmImageView *brightnessIcon;

@property (weak) IBOutlet rvmImageView *videoIcon;

@property (weak) IBOutlet NSPopUpButton *presetButton;
@property (strong) IBOutlet NSPopover *overscanPop;
@property (weak) IBOutlet NSSlider *ovSize;
@property (weak) IBOutlet NSSlider *ovV;
@property (weak) IBOutlet NSSlider *ovH;
@property (weak) IBOutlet NSPopUpButton *overscanPreset;
@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSSlider *vignette;
@property (weak) IBOutlet NSSlider *vignetteRnd;
@property (weak) IBOutlet NSSlider *beamI;
@property (weak) IBOutlet NSSlider *beamSpeed;

@end

@implementation rvmVideoViewController

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

}

-(void)enabled:(BOOL)e
{
  [_saturation setEnabled:e];
  [_contrast setEnabled:e];
  [_brightness setEnabled:e];
  [_scanlines setEnabled:e];
  [_noise setEnabled:e];
  [_offset setEnabled:e];
  [_ghostAngle setEnabled:e];
  [_ghostIntensity setEnabled:e];
  [_ghostOffset setEnabled:e];
  [_interlaced setEnabled:e];
  [_blur setEnabled:e];
  [_curvature setEnabled:e];
  [_vignette setEnabled:e];
  [_vignetteRnd setEnabled:e];
  [_beamI setEnabled:e];
  [_beamSpeed setEnabled:e];
}

static double configs[][16]={
  {1.0,1.0,1.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0,0,0},
  {1.0,0.8,1.0,0.0,0.0,0.06,0.00045,0.0005,0.1,135.0,0.002,0.0,0.0,0,0,0},
  {1.0,0.8,1.0,0.0,0.0,0.15,0.0008,0.0007,0.15,135.0,0.002,0.0,0.0,0,0,0},
  {0.6,0.8,1.0,0.0,0.15,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0,0,0},
  {0.6,0.8,1.0,0.0,0.15,0.06,0.00075,0.0005,0.1,135.0,0.002,0.0,0.0,0,0,0},
  {0.6,0.8,1.0,0.0,0.15,0.15,0.001,0.007,0.15,135.0,0.002,0.0,0.0,0,0,0},
  {0.6,0.0,1.0,0.0,0.15,0.15,0.001,0.007,0.15,135.0,0.002,0.0,0.0,0,0,0},
  
  //Curved
  {0.6,0.8,1.0,0.0,0.15,0.0,0.0,0.0,0.0,0.0,0.0,1.5,1.,0,0,0},
  {0.6,0.8,1.0,0.0,0.15,0.06,0.00075,0.0005,0.1,135.0,0.002,1.5,1.,0,0,0},
  {0.6,0.8,1.0,0.0,0.15,0.15,0.001,0.007,0.15,135.0,0.002,1.5,1.,0,0,0},
  {0.6,0.0,1.0,0.0,0.15,0.15,0.001,0.007,0.15,135.0,0.002,1.5,1.,0,0,0},
  
  //Curved Flicker
  {0.6,0.8,1.0,0.0,0.15,0.0,0.0,0.0,0.0,0.0,0.0,1.5,1.,0.1,0.07,0.2},
  {0.6,0.8,1.0,0.0,0.15,0.06,0.00075,0.0005,0.1,135.0,0.002,1.5,1.,0.1,0.07,0.2},
  {0.6,0.8,1.0,0.0,0.15,0.15,0.001,0.007,0.15,135.0,0.002,1.5,1.,0.1,0.07,0.2},
  {0.6,0.0,1.0,0.0,0.15,0.15,0.001,0.007,0.15,135.0,0.002,1.5,1.,0.1,0.07,0.2},
};

-(IBAction)onChange:(id)sender
{
  NSPopUpButton *b=sender;
  uint t=(uint)b.selectedTag;
  
  if(t<255)
  {
    _interlaced.doubleValue=1.0-configs[t][0];
    _saturation.doubleValue=configs[t][1];
    _contrast.doubleValue=configs[t][2];
    _brightness.doubleValue=configs[t][3];
    
    _scanlines.doubleValue=configs[t][4];
    _noise.doubleValue=configs[t][5];
    _offset.doubleValue=configs[t][6];
    _ghostOffset.doubleValue=configs[t][7];

    _ghostIntensity.doubleValue=configs[t][8];
    _ghostAngle.doubleValue=configs[t][9];
    _blur.doubleValue=configs[t][10];

    _curvature.doubleValue=configs[t][11];
    _vignette.doubleValue=configs[t][12];
    _vignetteRnd.doubleValue=configs[t][13];
    _beamI.doubleValue=configs[t][14];
    _beamSpeed.doubleValue=configs[t][15];
    
    [self assignValues:_presetButton];
    //[self enabled:NO];
  }
  else
  {
    //[self enabled:YES];
  }
}

-(IBAction)assignValues:(id)sender
{
  if(_emulationView)
  {
    _emulationView.saturation=_saturation.doubleValue;
    _emulationView.contrast=_contrast.doubleValue;
    _emulationView.brightness=_brightness.doubleValue;
    _emulationView.scanlines=_scanlines.doubleValue;
    
    _emulationView.noise=_noise.doubleValue;
    _emulationView.offset=_offset.doubleValue;
    _emulationView.interlaced=1-_interlaced.doubleValue;
    _emulationView.ghostOffset=_ghostOffset.doubleValue;
    
    _emulationView.ghostIntensity=_ghostIntensity.doubleValue;
    _emulationView.ghostAngle=_ghostAngle.doubleValue;
    _emulationView.blur=_blur.doubleValue;
    
    _emulationView.overscan=_ovSize.doubleValue;
    _emulationView.overscanH=_ovH.doubleValue;
    _emulationView.overscanV=_ovV.doubleValue;
    
    _emulationView.curvature=_curvature.doubleValue;
    _emulationView.vignette=_vignette.doubleValue;
    _emulationView.vignetteRnd=_vignetteRnd.doubleValue;
    
    _emulationView.beamI=_beamI.doubleValue;
    _emulationView.beamSpeed=_beamSpeed.doubleValue;
  }
  
  if(sender!=_presetButton)
    [_presetButton selectItemWithTag:255];
}

-(NSMutableDictionary*)saveConfig
{
  NSMutableDictionary *config=[NSMutableDictionary dictionary];
  
  uint pr=(uint)[_presetButton selectedTag];
  
  config[@"preset"]=[NSNumber numberWithUnsignedInt:pr];
  
  if(pr==255)
  {
    config[@"interlaced"]=[NSNumber numberWithDouble:1.0-_interlaced.doubleValue];
    config[@"saturation"]=_saturation.objectValue;
    config[@"contrast"]=_contrast.objectValue;
    config[@"brightness"]=_brightness.objectValue;

    config[@"scanlines"]=_scanlines.objectValue;
    config[@"noise"]=_noise.objectValue;
    config[@"offset"]=_offset.objectValue;
    config[@"ghostOffset"]=_ghostOffset.objectValue;
    
    config[@"ghostIntensity"]=_noise.objectValue;
    config[@"ghostAngle"]=_ghostAngle.objectValue;
    config[@"blur"]=_blur.objectValue;
    config[@"curvature"]=_curvature.objectValue;
    config[@"vignette"]=_vignette.objectValue;
    config[@"vignetteRnd"]=_vignetteRnd.objectValue;
    config[@"beamI"]=_beamI.objectValue;
    config[@"beamSpeed2"]=_beamSpeed.objectValue;
  }
  else
  {
    
  }
  
  pr=(uint)[_overscanPreset selectedTag];
  
  config[@"overscanPreset"]=[NSNumber numberWithUnsignedInt:pr];
  
  if(pr>4)
  {
    config[@"overscan"]=_ovSize.objectValue;
    config[@"overscanH"]=_ovH.objectValue;
    config[@"overscanV"]=_ovV.objectValue;
  }
  
  return config;
}

-(void)loadConfig:(NSDictionary*)d major:(uint)M minor:(uint)m
{
  if(!self.view) [self loadView];
  
  uint pr=[d[@"preset"] unsignedIntValue];

  pr=(M==1 && m==0 & pr==7)?255:pr;
  
  [_presetButton selectItemWithTag:pr];
  [self onChange:_presetButton];
  if(pr<255)
  {

  }
  else
  {
    _interlaced.doubleValue=1-[d[@"interlaced"] doubleValue];
    _saturation.objectValue=d[@"saturation"];
    _contrast.objectValue=d[@"contrast"];
    _brightness.objectValue=d[@"brightness"];
    
    _scanlines.objectValue=d[@"scanlines"];
    _noise.objectValue=d[@"noise"];
    _offset.objectValue=d[@"offset"];
    _ghostOffset.objectValue=d[@"ghostOffset"];
    
    _ghostIntensity.objectValue=d[@"ghostIntensity"];
    _ghostAngle.objectValue=d[@"ghostAngle"];
    _blur.objectValue=d[@"blur"];
    _curvature.objectValue=d[@"curvature"];
    _vignette.objectValue=d[@"vignette"];
    _vignetteRnd.objectValue=d[@"vignetteRnd"];
    _beamI.objectValue=d[@"beamI"];
    _beamSpeed.objectValue=d[@"beamSpeed"];
  }
  
  pr=[d[@"overscanPreset"] unsignedIntValue];
  [_overscanPreset selectItemWithTag:pr];
  [self onOverscanPreset:_overscanPreset];
  
  if(pr>4)
  {
    _ovSize.objectValue=d[@"overscan"];
    _ovH.objectValue=d[@"overscanH"];
    _ovV.objectValue=d[@"overscanV"];
  }
  
  [self assignValues:_presetButton];
}

-(void)setEmulationView:(rvmMainView *)emulationView
{
  _emulationView=emulationView;
  [self assignValues:_presetButton];
}

- (IBAction)onOverscan:(id)sender {
  NSView *v=sender;
  [_overscanPop showRelativeToRect:v.bounds ofView:v preferredEdge:NSMaxXEdge];
}

- (IBAction)onOverscanChange:(id)sender {
  _emulationView.overscan=_ovSize.doubleValue;
  _emulationView.overscanH=_ovH.doubleValue;
  _emulationView.overscanV=_ovV.doubleValue;
}

-(void)overscanEnable:(BOOL)e
{
  _ovSize.enabled=_ovH.enabled=_ovV.enabled=e;
}

- (IBAction)onOverscanPreset:(id)sender {
  NSPopUpButton *po=sender;
  
  switch(po.selectedTag)
  {
    case 0: //Full PAL
    {
      _ovSize.doubleValue=_ovH.doubleValue=_ovV.doubleValue=0.0;
      [self onOverscanChange:sender];
      [self overscanEnable:NO];
      break;
    }
    case 1: //320x240
    {
      _ovH.doubleValue=_ovV.doubleValue=0.0;
      _ovSize.doubleValue=0.5;
      [self onOverscanChange:sender];
      [self overscanEnable:NO];
      break;
    }
    case 2: //tiny borders
    {
      _ovH.doubleValue=_ovV.doubleValue=0.0;
      _ovSize.doubleValue=0.85;
      [self onOverscanChange:sender];
      [self overscanEnable:NO];
      break;
    }
    case 4: //PAL
    {
      _ovH.doubleValue=_ovV.doubleValue=0.0;
      _ovSize.doubleValue=0.35;
      [self onOverscanChange:sender];
      [self overscanEnable:NO];
      break;
    }
    case 3: //borderless
    {
      _ovH.doubleValue=_ovV.doubleValue=0.0;
      _ovSize.doubleValue=1.0;
      [self onOverscanChange:sender];
      [self overscanEnable:NO];
      break;
    }
    default: 
    {
      [self overscanEnable:YES];
      break;
    }
  }
}

-(void)animateIn
{
  _videoIcon.alphaValue=1.0;
  _scrollView.alphaValue=1.0;
}

-(void)animateOut
{
  _scrollView.alphaValue=0.0;
  _videoIcon.alphaValue=0.0;
}
@end
