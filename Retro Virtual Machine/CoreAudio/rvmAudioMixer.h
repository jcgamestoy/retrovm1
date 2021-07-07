//
//  rvmAudioMixer.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 2/1/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (*rvmAudioMixerStep)(void *mixer,double *data,double *r,double *l);
typedef void (*rvmAudioMixerReset)(void *mixer);

typedef struct
{
  uint32 nchannel;
  double *cPan;
  double *cVol;
  double max;
  
  double lm,rm,lM,rM,l,r;
  //double c;
  
  double volume;
  
  double *cOutM,*cOutm,*cOut;
  
  rvmAudioMixerStep step;
  rvmAudioMixerReset reset;
}rvmAudioMixerS;

@interface rvmAudioMixer : NSObject
{
  @public
  rvmAudioMixerS mixerS;
}

-(void)setChannels:(uint32)numberOfChannels maxVolume:(double)max;

//-(void)reset;
//-(NSData*)outputL:(double*)l R:(double*)r;

@end
