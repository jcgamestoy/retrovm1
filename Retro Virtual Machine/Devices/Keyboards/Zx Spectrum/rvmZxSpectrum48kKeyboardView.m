//
//  rvmZxSpectrum48kKeyboardView.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 24/08/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmZxSpectrum48kKeyboardView.h"
#import "NSColor+rvmNSColors.h"
#import "rvmMachineProtocol.h"

typedef struct
{
  NSRect rect;
  uint32 type;
}key;

#define defKey(x,y,w,h,t) {{{x,468-(y+h)},{w,h}},t},
#define rkey(x,y) defKey(x,y,45.8,34.4,0)

#define line(a,b,c,d,e) {0,a,b,0,c,0,0,0,d,0,0,0,0,0,0,0,e},

static uint8 lineTranslator[8][17]={
  line(30,31,32,33,34)
  line(20,21,22,23,24)
  line(10,11,12,13,14)
  line(0,1,2,3,4)
  line(9,8,7,6,5)
  line(19,18,17,16,15)
  line(29,28,27,26,25)
  line(39,38,37,36,35)
};
//
//rkey(46.6,195.3)  //True video
//rkey(138.8,195.3) //Inv video
//defKey(1153.1,195.3,128.9,90.2,1) //BREAK
//defKey(46.6,286.5,128.9,90.2,1) //Delete
//rkey(176.5,286.5) //GRAPH
//defKey(46.6,377.8,128.9,90.2,1) //Extend
//defKey(176.5,377.8,109.1,90.2,2) //Edit
//rkey(245.9,470) //CAPS LOCK
//rkey(983.6,470) //.
//defKey(1075.8, 470, 206.2, 90.2, 5) //R Shift
//
//rkey(138.8,561.2) //;
//rkey(231,561.2) //"
//rkey(323.2,561.2) //Cursor Left
//rkey(415.4,561.2) //Cursor right
//rkey(914.2,561.2) //Cursor Up
//rkey(1006.4,561.2) //Cursor Down
//rkey(1098.6,561.2) //,
//rkey(1190.8,561.2) //R Symb
static uint toMachineKey[58]={
  15,16,17,18,19,
  24,23,22,21,20,
  10,11,12,13,14,
  29,28,27,26,25,
  5,6,7,8,9,
  34,33,32,31,30,
  0,1,2,3,4,
  39,38,37,36,35,
  
  //Extra
  51,52,53,40,56,
  54,47,55,46,0,
  49,50,41,42,44,
  43,45,36
};

static bool init=NO;

static rvmMachineKeyS invLineTranslator[40];

void makeInvLineTranslator(void)
{
  for(int i=0;i<8;i++)
    for(int j=0;j<17;j++)
    {
      uint8 t=lineTranslator[i][j];
      
      if(t)
      {
        invLineTranslator[t]=((rvmMachineKeyS) {1,{i},{j}});
      }
    }
}

static key keyDefs[40]={
  rkey(29.4,180.3)  //1
  rkey(95.6,180.3)  //2
  rkey(161.9,180.3) //3
  rkey(228.1,180.3) //4
  rkey(294.3,180.3) //5
  rkey(360.5,180.3) //6
  rkey(426.7,180.3) //7
  rkey(492.9,180.3) //8
  rkey(559.1,180.3) //9
  rkey(625.4,180.3) //0
  

  rkey(62.1,246.7)  //Q
  rkey(128.3,246.7) //W
  rkey(194.6,246.7) //E
  rkey(260.8,246.7) //R
  rkey(327,246.7)   //T
  rkey(393.2,246.7) //Y
  rkey(459.4,246.7) //U
  rkey(525.6,246.7) //I
  rkey(594.3,246.7) //O
  rkey(658,246.7)   //P
  
  rkey(79.3,313.1)  //A
  rkey(145.5,313.1) //S
  rkey(211.7,313.1) //D
  rkey(277.9,313.1) //F
  rkey(344.1,313.1) //G
  rkey(410.4,313.1) //H
  rkey(476.4,313.1) //J
  rkey(542.8,313.1) //K
  rkey(609,313.1)   //L
  rkey(675.2,313.1) //Enter
  
  defKey(28.6,380.3,63.8,34.4,1)
  
  rkey(111.2,380.3) //Z
  rkey(179,380.3)   //X
  rkey(245.2,380.3) //C
  rkey(311.4,380.3) //V
  rkey(377.7,380.3) //B
  rkey(443.9,380.3) //N
  rkey(512.5,380.3) //M
  rkey(576.3,380.3) //Symb

  defKey(642.5,380.3,77.7,34.4,2) //Space
};

#define kIdle 0
#define kAssign 1

@interface rvmZxSpectrum48kKeyboardView()
{
}

@end

@implementation rvmZxSpectrum48kKeyboardView

-(void)makeChasis
{
  chasis=[CALayer layer];
  chasis.contents=[NSImage imageNamed:@"zx48kKChasis"];
  chasis.frame=NSMakeRect(0, 0, 753, 468);
}

-(void)makeLabels
{
  labels=[CALayer layer];
  labels.contents=[NSImage imageNamed:@"zx48kKLabels"];
  //labels.backgroundColor=[NSColor red].CGColor;
  labels.frame=NSMakeRect(32.3,468-152.4-274,672,274);
}

-(void)makeKeys
{
  keys=[NSMutableArray arrayWithCapacity:40];
  
  for(int i=0;i<40;i++)
  {
    CALayer *la;
    la=[CALayer layer];
    la.frame=keyDefs[i].rect;
    keys[i]=la;
    la.contents=[self keyImage:i highlight:NO];
    
    [chasis addSublayer:la];
  }
}

-(void)awakeFromNib
{
  [self setWantsLayer:YES];
  if(!init) makeInvLineTranslator();
  
  [self makeChasis];
  [self makeLabels];
  
  [self.layer addSublayer:chasis];

  [self makeKeys];
  
  [self.layer addSublayer:labels];
}

-(uint)keyCount
{
  return 40;
}

-(void)viewWillDraw {
  [self resizeWithOldSuperviewSize:self.frame.size];
}

-(void)unHighlightAll
{
  uint kc=[self keyCount];
  for(uint i=0;i<kc;i++)
  {
    CALayer *k=keys[i];
    k.contents=[self keyImage:i highlight:NO];
  }
}

-(uint)extraKey:(rvmMachineKeyS*)k index:(int*)i
{
  return lineTranslator[k->lines[*i]][k->codes[*i]];
}

-(NSImage*)keyImage:(uint)ki highlight:(bool)h
{
  NSString *imageName;
  
  if(!keyDefs[ki].type)
  {
    if(ki==38 && h)
      imageName=@"zx48kKSymb";
    else
      imageName=@"zx48kKRegular";
  }
  else if(keyDefs[ki].type==1)
  {
    imageName=@"zx48kKCaps";
  }
  else
  {
    imageName=@"zx48kKSpace";
  }
  
  imageName=h?[NSString stringWithFormat:@"%@Over",imageName]:imageName;
  return [NSImage imageNamed:imageName];
}

-(void)highlightKey:(rvmMachineKeyS*)key
{
  for(int i=0;i<key->number;i++)
  {
    uint ki=[self extraKey:key index:&i];
    CALayer *k=keys[ki];
    
    k.contents=[self keyImage:ki highlight:YES];
  }
}

-(void)unHighlightKey:(rvmMachineKeyS*)key
{
  for(int i=0;i<key->number;i++)
  {
    uint ki=[self extraKey:key index:&i];
    CALayer *k=keys[ki];
    
    k.contents=[self keyImage:ki highlight:NO];
  }
}

-(void)fixRectangle:(NSRect*)r
{
  double dx=self.frame.size.width/753.0;
  double dy=self.frame.size.height/350.0;
  
  r->origin.x=r->origin.x*dx;
  r->origin.y=r->origin.y*dy;
  r->size.width=r->size.width*dx;
  r->size.height=r->size.height*dy;
}

-(void)mouseDown:(NSEvent *)theEvent
{
  if(!_state) return;
  
  //[self unHighlightAll];
  NSPoint el=[theEvent locationInWindow];
  //el=[self.layer convertPoint:el fromLayer:self.layer.superlayer];
  CGPoint p=[self.layer convertPoint:NSPointToCGPoint(el) fromLayer:nil];
  CALayer *k=[chasis hitTest:p];
  
  uint kc=[self keyCount];
  for(int i=0;i<kc;i++)
  {
    if(keys[i]==k)
    {
      NSRect r=((CALayer*)keys[i]).frame;
      [self fixRectangle:&r];
      //if(_onKeyClick) _onKeyClick(i,r);
      //NSLog(@"Click Found i:%d",i);
      //return;
      
      if(_onKeyClick) _onKeyClick(toMachineKey[i]);
      k.contents=[self keyImage:i highlight:YES];
    }
  }
}

-(void)resizeWithOldSuperviewSize:(NSSize)oldSize
{
  [super resizeWithOldSuperviewSize:oldSize];
  CATransform3D t=CATransform3DIdentity;

  t=CATransform3DScale(t, self.frame.size.width/chasis.frame.size.width, self.frame.size.height/chasis.frame.size.height, 1.0);
  self.layer.sublayerTransform=t;
}

-(void)setState:(uint)state
{
  _state=state;
  [self unHighlightAll];
}

#if TARGET_INTERFACE_BUILDER
-(void)drawRect:(NSRect)dirtyRect
{
  [[NSColor darkGreen] setFill];
  NSRectFill(dirtyRect);
}
#endif

@end
