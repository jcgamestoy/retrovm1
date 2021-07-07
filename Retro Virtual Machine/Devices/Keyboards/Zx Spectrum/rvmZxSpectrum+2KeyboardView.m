//
//  rvmZxSpectrum+2KeyboardView.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 28/08/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmZxSpectrum+2KeyboardView.h"

typedef struct
{
  NSRect rect;
  uint32 type;
}key;

#define defKey(x,y,w,h,t) {{{x,712-(y+h)},{w,h}},t},
#define rkey(x,y) defKey(x,y,75.1,75.1,0)

#define line(a,b,c,d,e) {0,a,b,0,c,0,0,0,d,0,0,0,0,0,0,0,e},

static key keyDefs[58]={
  rkey(232.8,251.2)  //1
  rkey(312.5,251.2)  //2
  rkey(392.1,251.2) //3
  rkey(471.8,251.2) //4
  rkey(551.4,251.2) //5
  rkey(631.1,251.2) //6
  rkey(710.7,251.2) //7
  rkey(790.4,251.2) //8
  rkey(870.1,251.2) //9
  rkey(949.7,251.2) //0
  
  rkey(268.1,330.9)  //Q
  rkey(347.7,330.9) //W
  rkey(427.4,330.9) //E
  rkey(507,330.9) //R
  rkey(586.7,330.9)   //T
  rkey(666.3,330.9) //Y
  rkey(746,330.9) //U
  rkey(825.6,330.9) //I
  rkey(905.3,330.9) //O
  rkey(984.9,330.9)   //P
  
  rkey(295.6,412)  //A
  rkey(375.3,412) //S
  rkey(454.9,412) //D
  rkey(534.6,412) //F
  rkey(614.2,412) //G
  rkey(693.9,412) //H
  rkey(773.6,412) //J
  rkey(853.2,412) //K
  rkey(932.9,412)   //L
  //rkey(675.2,377.8) //Enter
  defKey(1012.5,330.9,127.1,156.2, 3) //ENTER
  
  defKey(73.5,491.7,177.7,75.1,4) //LSHIFT
  
  rkey(335.5,491.7) //Z
  rkey(415.1,491.7)   //X
  rkey(494.8,491.7) //C
  rkey(574.4,491.7) //V
  rkey(654.1,491.7) //B
  rkey(733.7,491.7) //N
  rkey(813.4,491.7) //M
  rkey(73.5,571.3) // L Symb
  
  defKey(471.8,571.3,349.2,75.1,6) //Space
  
  //Extra keys
  rkey(73.5,251.2)  //True video
  rkey(153.2,251.2) //Inv video
  defKey(1029.4,251.2,110.3,75.1,1) //BREAK
  defKey(73.5,330.9,110.3,75.1,1) //Delete
  rkey(188.4,330.9) //GRAPH
  defKey(73.5,412,137.9,75.1,2) //Extend
  rkey(216, 412) //Edit
  rkey(255.8,491.7) //CAPS LOCK
  rkey(893,491.7) //.
  defKey(972.7, 491.7, 167, 75.1, 5) //R Shift
  
  rkey(153.2,571.3) //;
  rkey(232.8,571.3) //"
  rkey(312.5,571.3) //Cursor Left
  rkey(392.1,571.3) //Cursor right
  rkey(825.6,571.3) //Cursor Up
  rkey(905.3,571.3) //Cursor Down
  rkey(984.9,571.3) //,
  rkey(1064.6,571.3) //R Symb
};

@interface rvmZxSpectrumPlus2KeyboardView()
{
}

@end

@implementation rvmZxSpectrumPlus2KeyboardView

static NSString* imageNames[7]={@"zx+2KRegular",@"zx+2KType2",@"zx+2KType3",@"zx+2KEnter",@"zx+2KLShift",@"zx+2KRShift",@"zx+2KSpace"};

-(void)makeChasis
{
  chasis=[CALayer layer];
  chasis.contents=[NSImage imageNamed:@"zx+2KChasis"];
  chasis.frame=NSMakeRect(0, 0, 1795, 712);
}

-(void)makeLabels
{
  labels=[CALayer layer];
  labels.contents=[NSImage imageNamed:@"zx+2KLabels"];
  labels.frame=NSMakeRect(0, 12, 1783, 700);
}

-(void)makeKeys
{
  keys=[NSMutableArray arrayWithCapacity:58];
  
  for(int i=0;i<58;i++)
  {
    CALayer *la=[CALayer layer];
    la.frame=keyDefs[i].rect;
    la.contents=[self keyImage:i highlight:NO];
    keys[i]=la;
    [chasis addSublayer:keys[i]];
  }
}

-(uint)keyType:(uint)ki
{
  return keyDefs[ki].type;
}

-(NSImage *)keyImage:(uint)ki highlight:(bool)h
{
  NSString *iname=imageNames[[self keyType:ki]];
  iname=h?[NSString stringWithFormat:@"%@Over",iname]:iname;
  
  return [NSImage imageNamed:iname];
}


@end
