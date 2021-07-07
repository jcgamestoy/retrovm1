//
//  rvmMacKeyboardView.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 11/08/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmMacKeyboardView.h"
#import "NSColor+rvmNSColors.h"

const static uint32 key2def[128]=
{
  //0-9
   43, //0 A
   44, //1 S
   45, //2 D
   46, //3 F
   48, //4 H
   47, //5 G
   57, //6 Z
   58, //7 X
   59, //8 C
   60, //9 V
  
  //10-19
   14, //0 §
   61, //1 B
   29, //2 Q
   30, //3 W
   31, //4 E
   32, //5 R
   34, //6 Y
   33, //7 T
   15, //8 1
   16, //9 2
  
  //20-29
   17, //0 3
   18, //1 4
   20, //2 6
   19, //3 5
   26, //4 =
   23, //5 9
   21, //6 7
   25, //7 -
   22, //8 8
   24, //9 0
  
  //30-39
   40, //0 ]
   37, //1 O
   35, //2 U
   39, //3 [
   36, //4 I
   38, //5 P
  255, //6
   51, //7 L
   49, //8 J
   53, //9 '
  
  //40-49
   50, //0 K
   52, //1 ;
   54, //2 |
   64, //3 ,
   66, //4 /
   62, //5 N
   63, //6 M
   65, //7 .
   28, //8 TAB
   72, //9 Space
  
  //50-59
   56, //0 `
   27, //1 Delete
  255, //2
    0, //3 ESC
  255, //4
  255, //5
   55, //6 L Shift
   42, //7 CAPS LOCK
  255, //8
  255, //9
  
  //60-69
  255, //0
  255, //1
  255, //2
  255, //3
  255, //4
  255, //5
  255, //6
  255, //7
  255, //8
  255, //9
  
  //70-79
  255, //0
  255, //1
  255, //2
  255, //3
  255, //4
  255, //5
  255, //6
  255, //7
  255, //8
  255, //9
  
  //80-89
  255, //0
  255, //1
  255, //2
  255, //3
  255, //4
  255, //5
  255, //6
  255, //7
  255, //8
  255, //9
  
  //90-99
  255, //0
  255, //1
  255, //2
  255, //3
  255, //4
  255, //5
    5, //6 F5
    6, //7 F6
    7, //8 F7
    3, //9 F3
  
  //100-109
    8, //0 F8
    9, //1 F9
  255, //2
   11, //3 F11
  255, //4
  255, //5
  255, //6
  255, //7
  255, //8
   10, //9 F9
  
  //110-119
  255, //0
   12, //1 F12
  255, //2
  255, //3
  255, //4
  255, //5
  255, //6
  255, //7
    4, //8 F4
  255, //9
  
  //120-127
    2, //0 F2
  255, //1
    1, //2 F1
   75, //3 Cursor left
   77, //4 Cursor Right
   76, //5 Cursor Down
   78, //6 Cursor Up
  255, //7
};

static uint32 def2key[128];
static bool init=false;

typedef struct
{
  NSRect rect;
  uint32 type;
}key;

#define defKey(x,y,w,h,t) {{{x,350-(y+h)},{w,h}},t},

#define fKey(x) defKey(x,55.5,48.1,28.8,0)
#define rKey(x,y) defKey(x,y,45.9,45.9,1)

static key keyDefs[80]={
  fKey(10.7) //0
  fKey(63)
  fKey(116.4)
  fKey(168.8)
  fKey(221.1)
  fKey(273.4)
  fKey(326.8)
  fKey(379.2)
  fKey(431.5)
  fKey(483.8)
  fKey(537.2)
  fKey(589.6)
  fKey(643)
  fKey(695.3)
  
  //Second row
  rKey(10.7,89.6)
  rKey(61.9,89.6)
  rKey(113.2,89.6)
  rKey(163.4,89.6)
  rKey(214.7,89.6)
  rKey(264.9,89.6)
  rKey(316.2,89.6)
  rKey(367.4,89.6)
  rKey(417.6,89.6)
  rKey(468.9,89.6)
  rKey(519.1,89.6)
  rKey(570.4,89.6)
  rKey(621.6,89.6)
  
  defKey(671.6, 89.5, 71, 46, 2)
  
  //Third row
  defKey(10.6, 138.5, 70, 46, 3)
  rKey(86.5,138.7)
  rKey(137.8,138.7)
  rKey(189.1,138.7)
  rKey(239.3,138.7)
  rKey(290.5,138.7)
  rKey(340.7,138.7)
  rKey(392,138.7)
  rKey(443.3,138.7)
  rKey(493.5,138.7)
  rKey(544.7,138.7)
  rKey(594.9,138.7)
  rKey(646.4,138.7)
  defKey(695, 137, 49, 97, 4)
  
  //Fourth row
  defKey(10.6, 187.5, 85, 46, 5)
  rKey(100.4,187.8)
  rKey(150.6,187.8)
  rKey(201.9,187.8)
  rKey(252.1,187.8)
  rKey(303.3,187.8)
  rKey(354.6,187.8)
  rKey(404.8,187.8)
  rKey(456.1,187.8)
  rKey(507.3,187.8)
  rKey(557.5,187.8)
  rKey(607.7,187.8)
  rKey(659,187.8)

  //Fifth row
  defKey(10.6, 237.5, 60, 46, 6)
  rKey(73.7,238)
  rKey(125,238)
  rKey(176.2,238)
  rKey(227.5,238)
  rKey(277.7,238)
  rKey(329,238)
  rKey(379.2,238)
  rKey(430.4,238)
  rKey(481.7,238)
  rKey(531.9,238)
  rKey(583.2,238)
  defKey(634.6, 237.5, 109, 46, 7)
  
  //Last row
  defKey(10.6, 287, 46, 51, 8)
  defKey(61.9, 287, 46, 51, 8)
  defKey(112.1, 287, 46, 51, 8)
  defKey(163.6, 287, 60, 51, 9)
  defKey(227.6, 287, 249, 51, 10)
  defKey(479.6, 287, 60, 51, 9)
  defKey(544.7, 287, 46, 51, 8)
  
  defKey(595, 312.7, 46, 25.5, 11)
  defKey(646, 312.7, 46, 25.5, 11)
  defKey(697.5, 312.7, 46, 25.5, 11)
  defKey(646.6, 287.5, 46, 25.5, 11)
};

@interface rvmMacKeyboardView()
{
  CALayer *chasis,*labels;
  CALayer *keys[80];
  
  CALayer *keyOverlay;
  
  NSColor *col,*over,*line,*enterColor;
}

@end

@implementation rvmMacKeyboardView

//-(NSImage*)keyImage:(uint32)type
//{
//  switch(type)
//  {
//    case 0:
//      return [NSImage imageNamed:@"macFunctionKey"];
//    
//    case 1:
//      return [NSImage imageNamed:@"macRegularKey"];
//    
//    case 2:
//      return [NSImage imageNamed:@"macDeleteKey"];
//      
//    case 3:
//      return [NSImage imageNamed:@"macTabKey"];
//      
//    case 4:
//      return [NSImage imageNamed:@"macEnterKey"];
//    
//    case 5:
//      return [NSImage imageNamed:@"macCapsLockKey"];
//
//    case 6:
//      return [NSImage imageNamed:@"macShiftLeftKey"];
//
//    case 7:
//      return [NSImage imageNamed:@"macShiftRightKey"];
//      
//    case 8:
//      return [NSImage imageNamed:@"macOptionKey"];
//      
//    case 9:
//      return [NSImage imageNamed:@"macCmdKey"];
//      
//    case 10:
//      return [NSImage imageNamed:@"macSpaceKey"];
//    
//    case 11:
//      return [NSImage imageNamed:@"macCursorKey"];
//  }
//  
//  return nil;
//}

void classInit(void)
{
  for(int i=0;i<128;i++)
  {
    def2key[key2def[i]]=i;
  }
}

-(void)awakeFromNib
{
  if(!init)
  {
    classInit();
  }
  
  [self setWantsLayer:YES];
  
  chasis=[CALayer layer];
  chasis.frame=NSMakeRect(0, 0, 753, 350);
  chasis.contents=[NSImage imageNamed:@"macKeyboardChasis"];
  
  labels=[CALayer layer];
  labels.frame=NSMakeRect(14, 350-(61+270), 724, 270);
  labels.contents=[NSImage imageNamed:@"macKeyboardLabelsEN"];
  
  [self.layer addSublayer:chasis];

  col=[NSColor colorWithSRGBRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
  over=[NSColor gold];
  line=[NSColor colorWithSRGBRed:151/255.0 green:151/255.0 blue:151/255.0 alpha:1];
  
  for(int i=0;i<80;i++)
  {
    keys[i]=[CALayer layer];
    keys[i].frame=keyDefs[i].rect;
    
    if(keyDefs[i].type!=4)
    {
      keys[i].cornerRadius=4.0;
      keys[i].backgroundColor=col.CGColor;
      keys[i].borderColor=line.CGColor;
      keys[i].borderWidth=1.5;
    }
    else
    {
      keys[i].delegate=(id)self;
      enterColor=col;
    }
      //keys[i].contents=[NSImage imageNamed:@"macEnterKey"];
    //keys[i].backgroundColor=[NSColor red].CGColor;
    
    //[self.layer addSublayer:keys[i]];
    [chasis addSublayer:keys[i]];
    
    if(keyDefs[i].type==4)
    {
      //keys[i].delegate=self;
      [keys[i] setNeedsDisplay];
    }

  }
  
  [self.layer addSublayer:labels];
  
  NSLog(@"size: %f,%f",self.frame.size.width,self.frame.size.height);
  NSLog(@"size super: %f,%f",self.superview.frame.size.width,self.superview.frame.size.height);
  [self setNeedsLayout:YES];
}



-(BOOL)acceptsFirstResponder
{
  return true;
}

-(void)keyDown:(NSEvent *)theEvent
{
  //NSLog(@"Key Code: %d",theEvent.keyCode);
  if(_onKeyDown) _onKeyDown(theEvent.keyCode);
  
  if(theEvent.keyCode==36)
  {
    enterColor=over;
    [keys[41] setNeedsDisplay];
    return;
  }
  uint32 k=key2def[theEvent.keyCode];
  if(k!=255)
  {
    keys[k].backgroundColor=over.CGColor;
  }
}

-(void)keyUp:(NSEvent *)theEvent
{
  //NSLog(@"Up Key Code: %d",theEvent.keyCode);
  if(_onKeyUp) _onKeyUp(theEvent.keyCode);
  if(theEvent.keyCode==36)
  {
    enterColor=col;
    [keys[41] setNeedsDisplay];
    return;
  }
  uint32 k=key2def[theEvent.keyCode];
  if(k!=255)
  {
    keys[k].backgroundColor=col.CGColor;
  }
}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
  NSGraphicsContext *nctx=[NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:NO];
  
  [NSGraphicsContext saveGraphicsState];
  [NSGraphicsContext setCurrentContext:nctx];
  
  NSBezierPath *up=[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(1, 51, 46, 43) xRadius:4 yRadius:4];
  NSBezierPath *down=[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(15, 1, 32, 57) xRadius:4 yRadius:4];
  
  [line setStroke];
  [up setLineWidth:3];
  [down setLineWidth:3];
  
  [up stroke];
  [down stroke];
  
  [enterColor setFill];
  [up fill];
  [down fill];
  
  [NSGraphicsContext restoreGraphicsState];
}

static uint32 lastFlags;

-(void)viewWillDraw {
  [self resizeWithOldSuperviewSize:self.frame.size];
}

-(void)flagsChanged:(NSEvent *)event
{
    unsigned long mask=[event modifierFlags] ^ lastFlags; //1 bit significa tecla modificada
    
    if(mask & 0x2) //left shift
    {
      if(lastFlags & 0x2) //up
      {
        keys[55].backgroundColor=col.CGColor;
        _onKeyUp(56);
      }
      else
      {
        keys[55].backgroundColor=over.CGColor;
        _onKeyDown(56);
      }
    }
    
    if(mask & 0x4) //right shift
    {
      if(lastFlags & 0x4) //upv
      {
        keys[67].backgroundColor=col.CGColor;
        _onKeyUp(56);
      }
      else
      {
        keys[67].backgroundColor=over.CGColor;
        _onKeyDown(56);
      }
    }
    
    if(mask & 0x1) //left ctrl
    {
      if(lastFlags & 0x1) //up
      {
        keys[69].backgroundColor=col.CGColor;
        _onKeyUp(59);
      }
      else
      {
        keys[69].backgroundColor=over.CGColor;
        _onKeyDown(59);
      }
    }

  
    if(mask & 0x20) //left alt
    {
      if(lastFlags & 0x20) //up
      {
        keys[70].backgroundColor=col.CGColor;
        _onKeyUp(58);
      }
      else
      {
        keys[70].backgroundColor=over.CGColor;
        _onKeyDown(58);
      }
    }
    
    if(mask & 0x40) //right alt
    {
      if(lastFlags & 0x40) //up
      {
        keys[74].backgroundColor=col.CGColor;
        _onKeyUp(58);
      }
      else
      {
        keys[74].backgroundColor=over.CGColor;
        _onKeyDown(58);
      }
    }
    
    if(mask & 0x08) //left command
    {
      if(lastFlags & 0x08) //up
        keys[71].backgroundColor=col.CGColor;
      else
        keys[71].backgroundColor=over.CGColor;
    }
    
    if(mask & 0x10) //right command
    {
      if(lastFlags & 0x10) //up
        keys[73].backgroundColor=col.CGColor;
      else
        keys[73].backgroundColor=over.CGColor;
    }
    
    if(mask & 0x10000) //caps-look
    {
      if(lastFlags & 0x10000) //caps-look
        keys[42].backgroundColor=col.CGColor;
      else
        keys[42].backgroundColor=over.CGColor;
    }
  
  if(mask & (1<<23)) //fn
  {
    if(lastFlags & (1<<23)) //fn
      keys[68].backgroundColor=col.CGColor;
    else
      keys[68].backgroundColor=over.CGColor;
  }
  
    lastFlags=(uint)[event modifierFlags];
}

-(void)resizeWithOldSuperviewSize:(NSSize)oldSize
{
  [super resizeWithOldSuperviewSize:oldSize];
  CATransform3D t=CATransform3DIdentity;
  //t=CATransform3DTranslate(t, self.frame.origin.x, self.frame.origin.y, 0);
  t=CATransform3DScale(t, self.frame.size.width/753.0, self.frame.size.height/350.0, 1.0);
  
  NSLog(@"%f %f",self.frame.size.width,self.frame.size.height);
  
  self.layer.sublayerTransform=t;
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
  NSPoint el=[theEvent locationInWindow];
  //el=[self.layer convertPoint:el fromLayer:self.layer.superlayer];
  CGPoint p=[self.layer convertPoint:NSPointToCGPoint(el) fromLayer:nil];
  CALayer *k=[chasis hitTest:p];
  
  for(int i=0;i<80;i++)
  {
    if(keys[i]==k)
    {
      NSRect r=keys[i].frame;
      [self fixRectangle:&r];
      if(_onKeyClick) _onKeyClick(def2key[i],r);
      //NSLog(@"Click Found i:%d",i);
      return;
    }
  }
  
  //NSLog(@"Not found");
}

#if TARGET_INTERFACE_BUILDER
-(void)drawRect:(NSRect)dirtyRect
{
  [[NSColor darkRed] setFill];
  NSRectFill(dirtyRect);
}
#endif

@end
