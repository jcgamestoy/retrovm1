//
//  rvmMainVoew.m
//  rvmSpectrum
//
//  Created by Juan Carlos González Amestoy on 03/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "rvmMainView.h"
#import "rvmMatrix.h"
#import "rvmGLProgram.h"
#include "rvmShaders.h"
#import "rvmGLTexture.h"
#import "rvmGLFloatTexture.h"

#import "rvmMonitorWindowController.h"
#import "rvmAbsoluteTime.h"
#include <time.h>
#define kDEGRAD 0.0174532925

//const unsigned char key[128] = {
//  4, 22,  7,  9, 11, 10, 29, 27,  6, 25,255,  5, 20, 26,  8, 21,
//  28, 23, 30, 31, 32, 33, 35, 34, 46, 38, 36, 45, 37, 39, 48, 18,
//  24, 47, 12, 19, 40, 15, 13, 52, 14, 51, 49, 54, 56, 17, 16, 55,
//  43, 44, 53, 42,255, 41,231,227,225, 57,226,224,229,230,228,255,
//  108, 99,255, 85,255, 87,255, 83,255,255,255, 84, 88,255, 86,109,
//  110,103, 98, 89, 90, 91, 92, 93, 94, 95,111, 96, 97,255,255,255,
//  62, 63, 64, 60, 65, 66,255, 68,255,104,107,105,255, 67,255, 69,
//  255,106,117, 74, 75, 76, 61, 77, 59, 78, 58, 80, 79, 81, 82,255
//};

@interface rvmMainView ()
{
  bool _isInit;
  CVDisplayLinkRef displayLink;
  unsigned long lastFlags;
  bool paused;
  NSRect boundsSZ;
  float scale;
  
  int textureSelected;
  int fps;
  double lastTime;
  rvmGLTexture *textures[2];
  //rvmGLTexture *texture;
  rvmGLProgram *whiteNoise,*pausedS,*warpS;
  //rvmGLProgram *interlacedP;
  
  rvmGLFloatTexture *scanlinesMask;
  uint64 tt[2];
  struct timeval startT;
  double tcord[4];
}

@property (strong,nonatomic) rvmMatrix* projectionMatrix;
@property rvmGLProgram* mainProgram;

@end

CVReturn displayLinkCallback(CVDisplayLinkRef displayLink,
                             const CVTimeStamp *inNow,
                             const CVTimeStamp *inOutputTime,
                             CVOptionFlags flagsIn,
                             CVOptionFlags *flagsOut,
                             void *displayLinkContext)
{
  //@autoreleasepool {
    rvmMainView* view=(__bridge rvmMainView*) displayLinkContext;
    if(view) [view renderGPU];
    return kCVReturnSuccess;
  //}
}

@implementation rvmMainView

- initWithFrame:(NSRect)frameRect {
  NSOpenGLPixelFormatAttribute attrs[] = {
  
    NSOpenGLPFANoRecovery,
    
    NSOpenGLPFAColorSize, 24,
    NSOpenGLPFAAlphaSize, 8,
    NSOpenGLPFADepthSize, 16,
    NSOpenGLPFADoubleBuffer,
    NSOpenGLPFAAccelerated,
    0
  };
  
  NSOpenGLPixelFormat* pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
  NSOpenGLContext* ctx=[[NSOpenGLContext alloc] initWithFormat:pixelFormat shareContext:NULL];
  
  self=[super initWithFrame:frameRect];
  if (self) {
    [self setOpenGLContext:ctx];
    [ctx setView:self];

    //_buffer=[rvmTripleBuffer tripleBufferWithSizeX:320 sizeY:240];
    //CVReturn e=kCVReturnSuccess;
    CGDirectDisplayID display=CGMainDisplayID();
    
    CVDisplayLinkCreateWithCGDisplay(display, &displayLink);
    CVDisplayLinkSetOutputCallback(displayLink, displayLinkCallback, (__bridge void *)(self));
    //CGLContextObj cglContext = [ctx CGLContextObj];
    //CGLPixelFormatObj cglPixelFormat = [pixelFormat CGLPixelFormatObj];
    //CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, cglContext, cglPixelFormat);

    //CVDisplayLinkStart(displayLink);
  
  
    _interlaced=0;
    _brightness=0;
    _contrast=1;
    _saturation=1;
    _scanlines=0.2;
    _noise=0;
    _offset=0;
    _interlaced=0.6;
    _ghostIntensity=0;
    _ghostOffset=0;
    
    //self.wantsLayer=YES;
  }
  return self;
}

-(void)adjustProjection
{
  _projectionMatrix=[rvmMatrix orthoFromRect:boundsSZ];
}

-(void)initGL
{
  gettimeofday(&startT, NULL);
  //self.window.title=@"modified";
  glClearColor(0, 0, 0, 1);
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
  
  _mainProgram=[rvmGLProgram newWithVertexShader:rvmShader_normalVS fragmentShader:rvmShader_crtFS attributes:@[@"pos",@"tc"]];
  whiteNoise=[rvmGLProgram newWithVertexShader:rvmShader_normalVS fragmentShader:rvmShader_whiteNoise attributes:@[@"pos",@"tc"]];
  pausedS=[rvmGLProgram newWithVertexShader:rvmShader_normalVS fragmentShader:rvmShader_paused attributes:@[@"pos",@"tc"]];
  warpS=[rvmGLProgram newWithVertexShader:rvmShader_normalVS fragmentShader:rvmShader_warp attributes:@[@"pos",@"tc"]];
  
  textures[0]=[rvmGLTexture initWithWidth:_machine.tripleBuffer.width height:_machine.tripleBuffer.height];
  textures[1]=[rvmGLTexture initWithWidth:_machine.tripleBuffer.width height:_machine.tripleBuffer.height];
  
  [textures[0] linear];
  [textures[1] linear];
  
  scanlinesMask=[rvmGLFloatTexture initWithWidth:1 height:5];
  float f[]={2.0,2.0,1.1,1.0,1.0};
  [scanlinesMask update:f];
  [scanlinesMask linear];
  [scanlinesMask repeat];
  
  textureSelected=0;
  
  [self adjustProjection];
  
  _isInit=YES;
  
  int p=1;
  [[self openGLContext] setValues:&p forParameter:NSOpenGLCPSwapInterval];

  paused=NO;
  
  [self setTc];
}

-(void)reshape
{
  [super reshape];
  [self adjustProjection];
  if(!paused) return;
  @synchronized(NSApplication.sharedApplication) {
    
  CGLLockContext([[self openGLContext] CGLContextObj]);
  [self renderFast];
  CGLUnlockContext([[self openGLContext] CGLContextObj]);
  }
}

-(void)drawRect:(NSRect)dirtyRect
{
  boundsSZ=self.bounds;
  scale=self.layer.contentsScale;
    @synchronized(NSApplication.sharedApplication) {
  CGLLockContext([[self openGLContext] CGLContextObj]);
  [self renderFast];
  CGLUnlockContext([[self openGLContext] CGLContextObj]);
    }
}

-(void)swapTextures
{
  //if(!_machine.running || _machine.paused) return;
  if((_machine.control & 0x3)!=0x1) return;
  
  //OSSpinLockLock(&(_machine.tripleBuffer->lock));
  //[textures[0] update:_machine.tripleBuffer->f0];
  //[textures[1] update:_machine.tripleBuffer->f1];
  //OSSpinLockUnlock(&(_machine.tripleBuffer->lock));
  uint b;
  uint c=0;
  do
  {
    if(paused) return;

    b=[_machine.tripleBuffer select];
    
    if(!b) {
      usleep(1000);
      c++;
    }
  }while(c<32 && !b && (_machine.control & 0x3)==0x1);

  if(b==1)
  {
    textureSelected++;
  //[textures[0] update:b];
    if(b) [textures[textureSelected & 0x1] update:_machine.tripleBuffer->g0->buf];
  }
  else if(b==2)
  {
    [textures[(textureSelected & 0x1)] update:_machine.tripleBuffer->g0->buf];
    [textures[(textureSelected+1) & 0x1] update:_machine.tripleBuffer->g1->buf];
  }
}


-(void)addFPS
{
  fps++;
}

-(void)render
{
  //if(!_machine.running || _machine.paused) return; //GRAY the image.
  if((_machine.control & 0x3)!=0x1) return;
  //[_machine.tripleBuffer swap];

//  if(_machine.debugging)
//    [_machine doFrameDebug];
//  else
    [_machine doFrame:NO];
  
}

-(void)renderGPU
{
  if(paused || !_machine) return;
  NSOpenGLContext *ctx=[self openGLContext];
  if(!ctx) return;
    @synchronized(NSApplication.sharedApplication) {
  CGLLockContext([ctx CGLContextObj]);
  [ctx makeCurrentContext];


  if(!_isInit)
    [self initGL];
  
  [self swapTextures];
  
  [self renderFast];
  //[self swapTextures];
  CGLUnlockContext([ctx CGLContextObj]);
    }
}

-(void)renderFast
{
  if(!_isInit) return;
  NSOpenGLContext *ctx=[self openGLContext];

  glViewport(0, 0, boundsSZ.size.width*scale, boundsSZ.size.height*scale);
  glClear(GL_COLOR_BUFFER_BIT);
  
  rvmGLProgram *prog;
  
  //if(_machine.running)
  if(_machine.control & kRvmStatePlaying)
  {
    if(_machine.control & kRvmStatePaused)
      prog=pausedS;
    else
    {
      if(_machine.control & kRvmStateWarp)
        prog=warpS;
      else
        prog=_mainProgram;
    }
  }
  else
  {
    prog=whiteNoise;
  }

  [prog use];
  [prog uniformMatrix:_projectionMatrix named:@"pm"];
  int p=[prog.attributes[@"pos"] intValue];
  int t=[prog.attributes[@"tc"] intValue];

  //[textures[textureSelected] use:0];
  [textures[textureSelected & 0x1] use:0];
  //[textures[0] use:0];
  [prog uniformTextureUnit:0 named:@"sam"];
  
  [textures[(textureSelected+1) & 0x1] use:1];
  //[textures[1] use:1];
  [prog uniformTextureUnit:1 named:@"previous"];
    
  [scanlinesMask use:2];
  
  [prog uniformTextureUnit:2 named:@"scanMask"];
  
  float seed=(rand()/(float)RAND_MAX);
  [prog uniformFloat:seed named:@"seed"];
  
  //Screen cordinates
  //[prog uniformFloat:800 named:@"x"];
  //[prog uniformFloat:600 named:@"y"];
  
  [prog uniformVec2X:boundsSZ.size.width y:boundsSZ.size.height named:@"screen"];
  
  [prog uniformFloat:_saturation named:@"saturation"];
  [prog uniformFloat:_contrast named:@"contrast"];
  [prog uniformFloat:_brightness named:@"brightness"];
  [prog uniformFloat:_scanlines named:@"scanlines"];
  [prog uniformFloat:_noise named:@"noise"];
  [prog uniformFloat:_offset named:@"offset"];
  [prog uniformFloat:_interlaced named:@"interlaced"];
  [prog uniformFloat:_blur named:@"blur"];
  [prog uniformFloat:_curvature named:@"curvature"];
  [prog uniformFloat:_vignette named:@"vigAmp"];
  [prog uniformFloat:_vignetteRnd named:@"vigRnd"];
  [prog uniformFloat:_beamI named:@"beamI"];
  [prog uniformFloat:_beamSpeed named:@"beamSpeed"];
  
  double a=(_ghostAngle+90.0)*kDEGRAD;
  [prog uniformVec2X:_ghostOffset*cos(a) y:_ghostOffset*sin(a) named:@"ghostOffset"];
  
  //[prog uniformFloat:_ghostOffset named:@"ghostOffset"];
  [prog uniformFloat:_ghostIntensity named:@"ghostIntensity"];
  
  //[prog uniformFloat:(clock()/(double)CLOCKS_PER_SEC) named:@"time"];
  struct timeval timeS;
  gettimeofday(&timeS, NULL);
  double time=timeS.tv_sec-startT.tv_sec+(timeS.tv_usec/1000000.0);
  [prog uniformFloat:time named:@"time"];
  
  double w=boundsSZ.size.width;
  double h=boundsSZ.size.height;
  
  //[prog uniformFloat:720 named:@"w"];
  //[prog uniformFloat:h/round(h/288.0) named:@"h"];
  double hs=(h*scale)/ceil((h*scale)/288.0);

  if(_machine.control & kRvmStatePlaying)
    [prog uniformVec2X:384 y:hs named:@"size"];
  else
    [prog uniformVec2X:533 y:400 named:@"size"];
  
  //@synchronized([NSApplication sharedApplication]) {
    
  glBegin(GL_QUADS);
  glColor4d(0, 1, 1, 1);
  glVertexAttrib2d(t, tcord[0], tcord[3]);
  glVertexAttrib2d(p, 0, 0);
  glVertexAttrib2d(t, tcord[1], tcord[3]);
  glVertexAttrib2d(p, w, 0);
  glVertexAttrib2d(t, tcord[1], tcord[2]);
  glVertexAttrib2d(p, w, h);
  glVertexAttrib2d(t, tcord[0], tcord[2]);
  glVertexAttrib2d(p, 0, h);
  glEnd();
  //}
  [ctx flushBuffer];
}

#pragma mark - Keyboard Handling

-(void)keyDown:(NSEvent *)event
{
  if(![event isARepeat] && !(event.modifierFlags&0x18))
  {
    //NSLog(@"Key %d, flags: %lu",event.keyCode,(unsigned long)event.modifierFlags);
    //ANSLog(@"Key: %d",key[[event keyCode]]);
    //[_machine keyDown:key[[event keyCode]]];
    [_machine keyDown:(event.keyCode & 0x7f) | ((event.modifierFlags>>10) & 0x80)];
  }
}

-(void)keyUp:(NSEvent *)event
{
  //[_machine keyUp:key[[event keyCode]]];
  [_machine keyUp:event.keyCode];
}

-(void)flagsChanged:(NSEvent *)event
{
  unsigned long mask=[event modifierFlags] ^ lastFlags; //1 bit significa tecla modificada
  
  if(mask & 0x2) //left shift
  {
    if(lastFlags & 0x2) //up
      [_machine keyUp:56];
    else
      [_machine keyDown:56];
  }
  
  if(mask & 0x4) //right shift
  {
    if(lastFlags & 0x4) //up
      [_machine keyUp:56];
    else
      [_machine keyDown:56];
  }
  
  if(mask & 0x1) //left ctrl
  {
    if(lastFlags & 0x1) //up
      [_machine keyUp:59];
    else
      [_machine keyDown:59];
  }
  
  if(mask & 0x2000) //right ctrl
  {
    if(lastFlags & 0x2000) //up
      [_machine keyUp:59];
    else
      [_machine keyDown:59];
  }
  
  if(mask & 0x20) //left alt
  {
    if(lastFlags & 0x20) //up
      [_machine keyUp:58];
    else
      [_machine keyDown:58];
  }
  
  if(mask & 0x40) //right alt
  {
    if(lastFlags & 0x40) //up
      [_machine keyUp:58];
    else
      [_machine keyDown:58];
  }
//  
//  if(mask & 0x08) //left command
//  {
//    if(lastFlags & 0x08) //up
//      [_machine keyUp:key[0x37]];
//    else
//      [_machine keyUp:key[0x37]];
//  }
//  
//  if(mask & 0x10) //right command
//  {
//    if(lastFlags & 0x10) //up
//      [_machine keyUp:key[0x37]];
//    else
//      [_machine keyDown:key[0x37]];
//  }
  
  if(mask & 0x10000) //caps-look
  {
    if(lastFlags & 0x10000) //caps-look
    {
      [_machine keyDown:57];
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->_machine keyUp:57];
      });
    }
    else
    {
      [_machine keyDown:57];
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->_machine keyUp:57];
      });
    }
  }
  
  lastFlags=[event modifierFlags];
}

-(BOOL)acceptsFirstResponder
{
  return YES;
}

#pragma mark - Emulator control
-(void)run:(bool)r
{
  CVDisplayLinkStart(displayLink);
  paused=!r;
}

-(void)dealloc
{
  CVDisplayLinkStop(displayLink);
  [[self openGLContext] makeCurrentContext];
  
  [textures[0] destroy];
  [textures[1] destroy];
  //[_texture destroy];
  
  [_mainProgram destroy];
}

-(void)resizeWithOldSuperviewSize:(NSSize)oldSize
{
  CGFloat w=self.superview.bounds.size.width;
  CGFloat h=self.superview.bounds.size.height;

  if(3*w>4*h)
  {
    CGFloat w2=(int)((4*h)/3);
    self.frame=CGRectMake((int)((w-w2)/2.0), 0, w2, h);
  }
  else
  {
    CGFloat h2=(int)((3*w)/4);
    self.frame=CGRectMake(0,(int)((h-h2)/2.0), w, h2);
  }
}

-(void)reset
{
  lastFlags=0;
}

-(void)stop
{
  CVDisplayLinkStop(displayLink);
  usleep(40000); //Wait for stop;
}

-(void)setTc
{
  
  
  double factH=1.0/384.0;
  double factV=1.0/288.0;
  tcord[0]=(64.0+32.0*-_overscanH)*factH*_overscan; //L
  tcord[1]=(384.0-(64.0-32.0*-_overscanH)*_overscan)*factH; //R
  tcord[2]=(48.0+24.0*_overscanV)*factV*_overscan;
  tcord[3]=(288.0-(48.0-24.0*_overscanV)*_overscan)*factV;
  
  //H
}

-(void)setOverscan:(double)overscan
{
  _overscan=overscan;
  [self setTc];
}

-(void)setOverscanH:(double)overscanH
{
  _overscanH=overscanH;
  [self setTc];
}

-(void)setOverscanV:(double)overscanV
{
  _overscanV=overscanV;
  [self setTc];
}



@end
