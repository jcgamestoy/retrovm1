//
//  rvmAudioEngine.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 26/01/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmAudioEngine.h"
#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>

#import "rvmSoundQueue.h"
#import "rvmMonitorWindowController.h"

//#define kChunk 882
//#define kSAMPLE_RATE 44100
#define kSAMPLE_RATE 192000
#define kChunk 3840

static OSStatus render(void *inRefCon,AudioUnitRenderActionFlags *ioActionFlags,const AudioTimeStamp *inTimeStamp,UInt32 inBusNumber,UInt32 inNumberFrames,AudioBufferList *ioData);

@interface rvmAudioEngine()
{
  AUGraph graph;
  AUNode outNode,converterNode,lowPass,highPass;
  rvmSoundQueue *queue;
  rvmAudioEngineDestroy destroyBlock;
}

@end

@implementation rvmAudioEngine

-(id)init
{
  self=[super init];
  
  if(self)
  {
   
  }
  
  return self;
}

-(void)setup:(dispatch_queue_t)q
{
  _renderQueue=q;
  queue=[rvmSoundQueue queue];
  
  NewAUGraph(&graph);
  
  //OUTPUT NODE
  AudioComponentDescription d;
  d.componentType=kAudioUnitType_Output;
  d.componentSubType=kAudioUnitSubType_DefaultOutput;
  d.componentManufacturer=kAudioUnitManufacturer_Apple;
  
  AUGraphAddNode(graph, &d, &outNode);
  
  //AudioComponentDescription d;
  d.componentType=kAudioUnitType_Effect;
  d.componentSubType=kAudioUnitSubType_LowPassFilter;
  d.componentManufacturer=kAudioUnitManufacturer_Apple;
  
  AUGraphAddNode(graph, &d, &lowPass);
  
  AUGraphConnectNodeInput(graph, lowPass, 0, outNode, 0);
  
  d.componentType=kAudioUnitType_Effect;
  d.componentSubType=kAudioUnitSubType_HighPassFilter;
  d.componentManufacturer=kAudioUnitManufacturer_Apple;
  
  AUGraphAddNode(graph, &d, &highPass);
  
  AUGraphConnectNodeInput(graph, highPass, 0, lowPass, 0);
  
  d.componentType=kAudioUnitType_FormatConverter;
  d.componentSubType=kAudioUnitSubType_AUConverter;
  d.componentManufacturer=kAudioUnitManufacturer_Apple;
  
  AUGraphAddNode(graph, &d, &converterNode);
  
  AUGraphConnectNodeInput(graph, converterNode, 0, highPass, 0);
  //AUGraphConnectNodeInput(graph, converterNode, 0, outNode, 0);
  
  AUGraphOpen(graph);
  
  AudioStreamBasicDescription format;
  format.mFormatID=kAudioFormatLinearPCM;
  format.mFormatFlags=kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian;
  //format.mFormatFlags=kAudioFormatFlagIsPacked | kAudioFormatFlagsNativeEndian;
  format.mSampleRate=kSAMPLE_RATE;
  format.mBitsPerChannel=16;
  format.mChannelsPerFrame=2;
  format.mBytesPerFrame=4;
  format.mFramesPerPacket=1;
  format.mBytesPerPacket=4;
  
  AudioUnit convert;
  AUGraphNodeInfo(graph, converterNode, NULL, &convert);
  AudioUnitSetProperty(convert, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &format, sizeof(format));
  uint32 r=882;
  AudioUnitSetProperty(convert, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Input, 0, &r, sizeof(r));
  AURenderCallbackStruct rcs;
  rcs.inputProc=render;
  rcs.inputProcRefCon=(__bridge void *)(self);
  
  AUGraphSetNodeInputCallback(graph, converterNode, 0, &rcs);
  //AUGraphInitialize(graph);
  //AUGraphStart(graph);
  self.lowPassFilter=5000;
  self.highPassFilter=50;
  //AUGraphClose(graph);
  //Graph completed
}

-(void)play
{
  if(!_playing)
  {
    AUGraphOpen(graph);
    AUGraphInitialize(graph);
    AUGraphStart(graph);
    _playing=YES;
  }
}

-(void)stop
{
  if(_playing)
  {
    AUGraphStop(graph);
    //AUGraphUninitialize(graph);
    //AUGraphClose(graph);
    _playing=NO;
  }
}

-(void)dealloc
{
  DisposeAUGraph(graph);
}

static OSStatus render(void *inRefCon,AudioUnitRenderActionFlags *ioActionFlags,const AudioTimeStamp *inTimeStamp,UInt32 inBusNumber,UInt32 inNumberFrames,AudioBufferList *ioData)
{
  rvmAudioEngine *a=(__bridge rvmAudioEngine*)inRefCon;
  //@synchronized(a)
  //{
  int16_t *buffer=ioData->mBuffers[0].mData;
  
  memset(buffer, 0, inNumberFrames<<2);
  

  //if(a.playing && a.mainView.machine.running && !a.mainView.machine.paused)
  if(a.playing && (a.mainView.machine.control & 0x3)==0x1)
  {
    /*uint32 l=*/[a->queue read:buffer count:(inNumberFrames<<1)];
    
//    int r=(inNumberFrames<<2)-(l<<1);
//    
//    if(r) //Sino hay audio rellenar con 0's
//    {      
//      memset(buffer+(l<<1), 0, r);
//    }

    
    
    if([a->queue used]<(kChunk<<1))
    {
      dispatch_async(a.renderQueue, ^{
        [a.mainView render];
        [a->queue write:[a.mainView.machine audioBuffer] count:([a.mainView.machine audioLength]<<1)];
        
        dispatch_async(dispatch_get_main_queue(), ^{
          rvmMonitorWindowController *mw=a.mainView.window.windowController;
          [mw frameDone];
        });
      });
    }
  }
//  else
//  {
//    memset(buffer, 0, inNumberFrames<<2);
//  }
  
  ioData->mBuffers[0].mDataByteSize=inNumberFrames<<2;
  //}
  return noErr;
}

-(void)setLowPassFilter:(double)lowPassFilter
{
  _lowPassFilter=lowPassFilter;
  
  AudioUnit filterUnit;
  
  AUGraphNodeInfo (graph, lowPass, NULL, &filterUnit);
  
  AudioUnitSetParameter (filterUnit, 0, kAudioUnitScope_Global, 0, lowPassFilter, 0);
}

-(void)setHighPassFilter:(double)highPassFilter
{
  _highPassFilter=highPassFilter;
  
  AudioUnit filterUnit;
  
  AUGraphNodeInfo (graph, highPass, NULL, &filterUnit);
  
  AudioUnitSetParameter (filterUnit, 0, kAudioUnitScope_Global, 0, highPassFilter, 0);
}

-(void)destroy:(rvmAudioEngineDestroy)destroy
{
  @synchronized(self)
  {
  AUGraphStop(graph);
  AUGraphClose(graph);
  AUGraphUninitialize(graph);
  
  if(destroy)
  {
    destroy();
  }
  }
}

@end
