//
//  rvmAudioMixer.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 2/1/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmAudioMixer.h"

//#define kFac 0.0124386529059309
#define kFac 0.05494505494505

void rvmAudioMixerStepF(rvmAudioMixerS *mixer,double *values,double *ro,double *lo)
{
  *ro=0; *lo=0;
  
  for(uint i=0;i<mixer->nchannel;i++)
  {
    double rf=mixer->cPan[i]>0.5?1.0:mixer->cPan[i]*2.0;
    double lf=mixer->cPan[i]<0.5?1.0:1.0-((mixer->cPan[i]-0.5)*2.0);
    
    double d=values[i]*mixer->cVol[i]*kFac;
    mixer->cOutm[i]=(mixer->cOutm[i]<d)?mixer->cOutm[i]:d;
    mixer->cOutM[i]=(mixer->cOutM[i]>d)?mixer->cOutM[i]:d;
    *ro+=d*rf;
    *lo+=d*lf;
  }
  
  double k=mixer->max*mixer->volume;
  
  mixer->lm=mixer->lm<*lo?mixer->lm:*lo;
  mixer->lM=mixer->lM>*lo?mixer->lM:*lo;
  mixer->rm=mixer->rm<*ro?mixer->rm:*ro;
  mixer->rM=mixer->rM>*ro?mixer->rM:*ro;
  
  *ro=*ro*k-1.0;
  *lo=*lo*k-1.0;
  
//  if(mixer->lm>0xffff)
//  {
//    NSLog(@"pum");
//  }
  
  
}

@interface rvmAudioMixer()
{
  NSMutableData *pan;
  NSMutableData *vol;
  NSMutableData *coutm,*coutM,*cout;
}

@end

@implementation rvmAudioMixer

-(void)setChannels:(uint32)numberOfChannels maxVolume:(double)max
{
  pan=[NSMutableData dataWithLength:sizeof(double)*numberOfChannels];
  vol=[NSMutableData dataWithLength:sizeof(double)*numberOfChannels];
  coutm=[NSMutableData dataWithLength:sizeof(double)*numberOfChannels];
  coutM=[NSMutableData dataWithLength:sizeof(double)*numberOfChannels];
  cout=[NSMutableData dataWithLength:sizeof(double)*numberOfChannels];
  
  mixerS.cPan=(double*)pan.bytes;
  mixerS.cVol=(double*)vol.bytes;
  mixerS.cOutm=(double*)coutm.bytes;
  mixerS.cOutM=(double*)coutM.bytes;
  mixerS.cOut=(double*)cout.bytes;
  
  mixerS.nchannel=numberOfChannels;
  
  mixerS.max=1/max;
  mixerS.volume=1.0;
  mixerS.step=(rvmAudioMixerStep)rvmAudioMixerStepF;
  mixerS.reset=(rvmAudioMixerReset)rvmAudioMixerResetF;
}

void rvmAudioMixerResetF(rvmAudioMixerS *mixer)
{
  //mixerS.l=mixerS.r=mixerS.c=0;
  mixer->l=mixer->lM-mixer->lm;
  mixer->r=mixer->rM-mixer->rm;
  mixer->lm=mixer->rm=100000;
  mixer->lM=mixer->rM=-100000.0;
  
  for(int i=0;i<mixer->nchannel;i++)
  {
    mixer->cOut[i]=mixer->cOutM[i]-mixer->cOutm[i];
    mixer->cOutm[i]=100000;
    mixer->cOutM[i]=-100000;
  }
}

@end
