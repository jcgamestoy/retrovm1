//
//  rvmZxSpectrum48kKeyboardView.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 24/08/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmZxSpectrum128kKeyboardView.h"
#import "NSColor+rvmNSColors.h"

typedef struct
{
  NSRect rect;
  uint32 type;
}key;

#define defKey(x,y,w,h,t) {{{x,700-(y+h)},{w,h}},t},
#define rkey(x,y) defKey(x,y,91.2,90.2,0)

#define line(a,b,c,d,e) {0,a,b,0,c,0,0,0,d,0,0,0,0,0,0,0,e},

static key keyDefs[58]={
  rkey(231,195.3)  //1
  rkey(323.2,195.3)  //2
  rkey(415.4,195.3) //3
  rkey(507.7,195.3) //4
  rkey(599.9,195.3) //5
  rkey(692.1,195.3) //6
  rkey(784.3,195.3) //7
  rkey(876.5,195.3) //8
  rkey(968.7,195.3) //9
  rkey(1060.9,195.3) //0
  

  rkey(267.7,286.5)  //Q
  rkey(360.9,286.5) //W
  rkey(453.1,286.5) //E
  rkey(545.3,286.5) //R
  rkey(637.5,286.5)   //T
  rkey(729.7,286.5) //Y
  rkey(822,286.5) //U
  rkey(914.2,286.5) //I
  rkey(1006.4,286.5) //O
  rkey(1098.6,286.5)   //P
  
  rkey(287.5,377.8)  //A
  rkey(379.7,377.8) //S
  rkey(472,377.8) //D
  rkey(564.2,377.8) //F
  rkey(656.4,377.8) //G
  rkey(748.6,377.8) //H
  rkey(840.8,377.8) //J
  rkey(933,377.8) //K
  rkey(1025.2,377.8)   //L
  //rkey(675.2,377.8) //Enter
  defKey(1118.4, 286.5, 163.6, 181.4, 3) //ENTER
  
  defKey(46.6,470,198.3,90.2,4) //LSHIFT
  
  rkey(338.1,470) //Z
  rkey(430.3,470)   //X
  rkey(522.5,470) //C
  rkey(614.7,470) //V
  rkey(706.9,470) //B
  rkey(799.2,470) //N
  rkey(891.4,470) //M
  rkey(46.6,561.2) // L Symb

  defKey(507.7,561.2,405.5,90.2,6) //Space

  //Extra keys
  rkey(46.6,195.3)  //True video
  rkey(138.8,195.3) //Inv video
  defKey(1153.1,195.3,128.9,90.2,1) //BREAK
  defKey(46.6,286.5,128.9,90.2,1) //Delete
  rkey(176.5,286.5) //GRAPH
  defKey(46.6,377.8,128.9,90.2,1) //Extend
  defKey(176.5,377.8,109.1,90.2,2) //Edit
  rkey(245.9,470) //CAPS LOCK
  rkey(983.6,470) //.
  defKey(1075.8, 470, 206.2, 90.2, 5) //R Shift
  
  rkey(138.8,561.2) //;
  rkey(231,561.2) //"
  rkey(323.2,561.2) //Cursor Left
  rkey(415.4,561.2) //Cursor right
  rkey(914.2,561.2) //Cursor Up
  rkey(1006.4,561.2) //Cursor Down
  rkey(1098.6,561.2) //,
  rkey(1190.8,561.2) //R Symb
};

@interface rvmZxSpectrum128kKeyboardView()
{
  //CALayer *chasis,*labels;
}

@end

@implementation rvmZxSpectrum128kKeyboardView

static NSString* imageNames[7]={@"zx128kKRegular",@"zx128kKType2",@"zx128kKType3",@"zx128kKEnter",@"zx128kKLShift",@"zx128kKRShift",@"zx128kKSpace"};


-(void)makeChasis
{
  chasis=[CALayer layer];
  chasis.contents=[NSImage imageNamed:@"zx128kKChasis"];
  chasis.frame=NSMakeRect(0, 0, 1634, 700);
}

-(void)makeLabels
{
  labels=[CALayer layer];
  labels.contents=[NSImage imageNamed:@"zx128kKLabels"];
  //labels.backgroundColor=[NSColor red].CGColor;
  labels.frame=NSMakeRect(0,0,1528,700);
}

-(void)makeKeys
{
  keys=[NSMutableArray arrayWithCapacity:58];
  
  for(int i=0;i<58;i++)
  {
    CALayer *la=[CALayer layer];
    la.frame=keyDefs[i].rect;
    la.contents=[NSImage imageNamed:imageNames[keyDefs[i].type]];
    keys[i]=la;
    [chasis addSublayer:keys[i]];
  }
}

-(NSImage *)keyImage:(uint)ki highlight:(bool)h
{
  NSString *iname=imageNames[keyDefs[ki].type];
  iname=h?[NSString stringWithFormat:@"%@Over",iname]:iname;
  
  return [NSImage imageNamed:iname];
}

-(uint)extraKey:(rvmMachineKeyS *)k index:(int *)i
{
  uint ki=[super extraKey:k index:i];
  
  if(ki==38) //Symb
  {
    (*i)++;
    ki=[super extraKey:k index:i];
    switch(ki)
    {
      case 36: //,
        return 56;
      case 37: //.
        return 48;
      case 18: //;
        return 50;
      case 19: //"
        return 51;

      default:
        (*i)--;
        return [super extraKey:k index:i];
    }
  }
  else if(ki==30) //Caps
  {
    (*i)++;
    if(*i>=k->number) return ki;
    ki=[super extraKey:k index:i];
    switch(ki)
    {
      case 0: //Edit
        return 46;
      case 2: //True Video
        return 40;
      case 3:
        return 41;
      case 4: //Cursor left
        return 52;
      case 7: //Cursor Right
        return 53;
      case 6: //Cursor Up
        return 54;
      case 5: //Cursor Down
        return 55;
      case 9: //Delete
        return 43;
      case 8: //GRAPH
        return 44;
      case 39:
        return 42;
      case 38: //Extend
        return 45;
      default:
        (*i)--;
        return [super extraKey:k index:i];
    }
  }
  
  return ki;
}

-(uint)keyCount
{
  return 58;
}

@end
