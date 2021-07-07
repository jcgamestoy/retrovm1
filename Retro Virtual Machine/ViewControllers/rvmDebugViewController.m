//
//  rvmDebugViewController.m
//  rvmSpectrum
//
//  Created by Juan Carlos González Amestoy on 03/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmDebugViewController.h"
#import "rvmBackgroundView.h"
#import "NSColor+rvmNSColors.h"
#import "rvmLuajit.h"
#import "rvmBox.h"
#import "rvmZxSpectrum48k.h"
#import "rvmCommandDispatcher.h"

typedef struct _mem
{
  z80get get;
  //z80gets getS;
  void* cpu;
}mem;

@interface rvmDebugViewController ()
{
  lua_State *L;
  NSArray *disColors;
  mem memory;
}

@property (strong) IBOutlet rvmBackgroundView *backgroundView;

@property (weak) IBOutlet NSTextField *aRegister;
@property (weak) IBOutlet NSTextField *bRegister;
@property (weak) IBOutlet NSTextField *cRegister;
@property (weak) IBOutlet NSTextField *dRegister;
@property (weak) IBOutlet NSTextField *eRegister;
@property (weak) IBOutlet NSTextField *hRegister;
@property (weak) IBOutlet NSTextField *lRegister;
@property (weak) IBOutlet NSTextField *rRegister;

@property (weak) IBOutlet NSTextField *apRegister;
@property (weak) IBOutlet NSTextField *bpRegister;
@property (weak) IBOutlet NSTextField *cpRegister;
@property (weak) IBOutlet NSTextField *dpRegister;
@property (weak) IBOutlet NSTextField *epRegister;
@property (weak) IBOutlet NSTextField *hpRegister;
@property (weak) IBOutlet NSTextField *lpRegister;
@property (weak) IBOutlet NSTextField *iRegister;

@property (weak) IBOutlet NSTextField *afRegister;
@property (weak) IBOutlet NSTextField *bcRegister;
@property (weak) IBOutlet NSTextField *deRegister;
@property (weak) IBOutlet NSTextField *hlRegister;
@property (weak) IBOutlet NSTextField *ixRegister;
@property (weak) IBOutlet NSTextField *pcRegister;

@property (weak) IBOutlet NSTextField *afpRegister;
@property (weak) IBOutlet NSTextField *bcpRegister;
@property (weak) IBOutlet NSTextField *depRegister;
@property (weak) IBOutlet NSTextField *hlpRegister;
@property (weak) IBOutlet NSTextField *iyRegister;
@property (weak) IBOutlet NSTextField *spRegister;

@property (weak) IBOutlet NSTextField *flags;

@property (weak) IBOutlet NSTextField *stackView;
@property (weak) IBOutlet rvmBackgroundView *borderView;
@property (weak) IBOutlet rvmBackgroundView *earView;
@property (weak) IBOutlet rvmBackgroundView *micView;
@property (weak) IBOutlet NSTextField *TstatesView;
@property (strong) IBOutlet NSTextField *disassemblyView;
@property (weak) IBOutlet rvmBox *consoleBox;
@property (strong) IBOutlet rvmBackgroundView *micIn;


@end

@implementation rvmDebugViewController

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
  //_backgroundView.backgroundColor=[NSColor colorWithPatternImage:[NSImage imageNamed:@"mainPattern"]];
  
  disColors=@[
                       [NSColor lightSeaGreen], //memory address
                       [NSColor pink], //bytes
                       [NSColor springGreen] //mnemonic
                       ];
  
  L=newLua();
  callLua(L, @"dis=require('code.disassembler')");
  callLua(L, @"dispatcher=require('rvm.dispatcher')");

  //callLua(L, @"dis=require('h.version')");
  
  _consoleBox.backgroundColor=[NSColor colorWithRed:0 green:0 blue:0 alpha:0.8];
  _consoleView.commandDelegate=self;
}

-(void)updateStack:(spectrum*)speccy
{
  NSMutableAttributedString *ms=[NSMutableAttributedString new];
  
  for(int i=0;i<10;i++)
  {
    uint16 d=speccy->cpu->r.sp+(i<<1);
    [ms appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"0x%.4X\t",d]]];
    uint16 l=speccy->cpu->get(speccy->cpu,d)|(speccy->cpu->get(speccy->cpu,d+1)<<8);
    [ms appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"0x%.4X\n",l]]];
  }
  
  NSMutableParagraphStyle *p=[NSMutableParagraphStyle new];
  [p setAlignment:NSCenterTextAlignment];
  [ms addAttributes:@{NSParagraphStyleAttributeName:p} range:NSMakeRange(0, [ms length])];
  
  _stackView.attributedStringValue=ms;
}

//Disassembly


-(void)updateDisassembly:(spectrum*)speccy
{
  _disassemblyView.stringValue=@"";
  [self.view layout];
  CGFloat h=_disassemblyView.bounds.size.height;
  int li=h/17;
  
  NSMutableAttributedString *ms=[NSMutableAttributedString new];
  
  callLua(L,[NSString stringWithFormat:@"return dis.disassemble(%pULL,%d,%d)"
         ,&memory,speccy->cpu->r.pc,li
         ]);
  
  int j=0;
  
  lua_pushnil(L);
  while(lua_next(L, -2)!=0)
  {
    NSDictionary *attr;
    
    
    

    //Tabla en -1
    for(int i=1;i<4;i++)
    {
      if(j)
        attr=@{NSForegroundColorAttributeName:disColors[i-1]};
      else
        attr=@{NSBackgroundColorAttributeName:[NSColor goldWithAlpha:0.25],NSForegroundColorAttributeName:disColors[i-1]};
      
      lua_pushnumber(L, i);
      lua_gettable(L, -2);
      [ms appendAttributedString:[[NSAttributedString alloc] initWithString:luaString(L, -1) attributes:attr]];
      lua_pop(L, 1);
    }
    j++;
    lua_pop(L,1);
  }
  
  lua_pop(L,1);
  //NSLog(@"%d:%d",li,j);
  //NSLog(@"%@",luaString(L, -1));
  _disassemblyView.textColor=[NSColor white];
  _disassemblyView.attributedStringValue=ms;
}

-(void)update
{
  spectrum *speccy=[_machine spectrum];
  
  [self updateRegField:_aRegister reg:speccy->cpu->r.a format:@"A:0x%.2X"];
  [self updateRegField:_bRegister reg:speccy->cpu->r.b format:@"B:0x%.2X"];
  [self updateRegField:_cRegister reg:speccy->cpu->r.c format:@"C:0x%.2X"];
  [self updateRegField:_dRegister reg:speccy->cpu->r.d format:@"D:0x%.2X"];
  [self updateRegField:_eRegister reg:speccy->cpu->r.e format:@"E:0x%.2X"];
  [self updateRegField:_hRegister reg:speccy->cpu->r.h format:@"H:0x%.2X"];
  [self updateRegField:_lRegister reg:speccy->cpu->r.l format:@"L:0x%.2X"];
  [self updateRegField:_rRegister reg:speccy->cpu->r.r format:@"R:0x%.2X"];
  
  [self updateRegField:_apRegister reg:speccy->cpu->r.ap format:@"A':0x%.2X"];
  [self updateRegField:_bpRegister reg:speccy->cpu->r.bp format:@"B':0x%.2X"];
  [self updateRegField:_cpRegister reg:speccy->cpu->r.cp format:@"C':0x%.2X"];
  [self updateRegField:_dpRegister reg:speccy->cpu->r.dp format:@"D':0x%.2X"];
  [self updateRegField:_epRegister reg:speccy->cpu->r.ep format:@"E':0x%.2X"];
  [self updateRegField:_hpRegister reg:speccy->cpu->r.hp format:@"H':0x%.2X"];
  [self updateRegField:_lpRegister reg:speccy->cpu->r.lp format:@"L':0x%.2X"];
  [self updateRegField:_iRegister reg:speccy->cpu->r.i format:@"I :0x%.2X"];
  
  [self updateRegField:_afRegister reg:speccy->cpu->r.af format:@"AF:0x%.4X"];
  [self updateRegField:_bcRegister reg:speccy->cpu->r.bc format:@"BC:0x%.4X"];
  [self updateRegField:_deRegister reg:speccy->cpu->r.de format:@"DE:0x%.4X"];
  [self updateRegField:_hlRegister reg:speccy->cpu->r.hl format:@"HL:0x%.4X"];
  [self updateRegField:_ixRegister reg:speccy->cpu->r.ix format:@"IX:0x%.4X"];
  [self updateRegField:_pcRegister reg:speccy->cpu->r.pc format:@"PC:0x%.4X"];
  
  [self updateRegField:_afpRegister reg:speccy->cpu->r.afp format:@"AF':0x%.4X"];
  [self updateRegField:_bcpRegister reg:speccy->cpu->r.bcp format:@"BC':0x%.4X"];
  [self updateRegField:_depRegister reg:speccy->cpu->r.dep format:@"DE':0x%.4X"];
  [self updateRegField:_hlpRegister reg:speccy->cpu->r.hlp format:@"HL':0x%.4X"];
  [self updateRegField:_iyRegister reg:speccy->cpu->r.iy format:@"IY :0x%.4X"];
  if([self updateRegField:_spRegister reg:speccy->cpu->r.sp format:@"SP :0x%.4X"])
  {
    [self updateStack:speccy];
  }
  
  //Flags
  NSDictionary *aOn=@{NSForegroundColorAttributeName:[NSColor greenColor]};
  NSDictionary *aOff=@{NSForegroundColorAttributeName:[NSColor redColor]};
  
  NSMutableAttributedString *ms=[NSMutableAttributedString new];
  [ms appendAttributedString:[[NSAttributedString alloc] initWithString:@"S" attributes:(speccy->cpu->r.f & 0x80)?aOn:aOff]];
  [ms appendAttributedString:[[NSAttributedString alloc] initWithString:@" Z" attributes:(speccy->cpu->r.f & 0x40)?aOn:aOff]];
  [ms appendAttributedString:[[NSAttributedString alloc] initWithString:@" 3" attributes:(speccy->cpu->r.f & 0x20)?aOn:aOff]];
  [ms appendAttributedString:[[NSAttributedString alloc] initWithString:@" H" attributes:(speccy->cpu->r.f & 0x10)?aOn:aOff]];
  [ms appendAttributedString:[[NSAttributedString alloc] initWithString:@" 5" attributes:(speccy->cpu->r.f & 0x08)?aOn:aOff]];
  [ms appendAttributedString:[[NSAttributedString alloc] initWithString:@" P/V" attributes:(speccy->cpu->r.f & 0x04)?aOn:aOff]];
  [ms appendAttributedString:[[NSAttributedString alloc] initWithString:@" N" attributes:(speccy->cpu->r.f & 0x02)?aOn:aOff]];
  [ms appendAttributedString:[[NSAttributedString alloc] initWithString:@" C" attributes:(speccy->cpu->r.f & 0x01)?aOn:aOff]];
  _flags.attributedStringValue=ms;
  
  CGFloat r,g,b;
  r=(speccy->border&0xFF) /255.0;
  g=((speccy->border&0xFF00)>>8) /255.0;
  b=((speccy->border&0xFF0000)>>16) /255.0;
  
  _borderView.backColor=[NSColor colorWithRed:r green:g blue:b alpha:1];
  _micView.backColor=speccy->mic?[NSColor greenColor]:[NSColor redColor];
  _earView.backColor=speccy->ear?[NSColor greenColor]:[NSColor redColor];
  _micIn.backColor=speccy->level?[NSColor greenColor]:[NSColor redColor];
  
  _TstatesView.stringValue=[NSString stringWithFormat:@"T-States: %d",speccy->so];
  
  [self updateDisassembly:speccy];
}

-(bool)updateRegField:(NSTextField*)field reg:(int)value format:(NSString*)format
{
  NSString *str;
  str=[NSString stringWithFormat:format,value];
  
  if(![[field stringValue] isEqualToString:str])
  {
    field.stringValue=str;
    field.textColor=[NSColor coral];
    return YES;
  }
  else
  {
    field.textColor=[NSColor whiteColor];
    return NO;
  }
}

-(void)setMachine:(rvmZXSpectrum48k *)machine
{
  _machine=machine;
  [_machine luaInit:L];
  memory.get=_machine.spectrum->cpu->get;
  memory.cpu=_machine.spectrum->cpu;
  _machine.commandDispatcher.console=_consoleView;
}

-(NSAttributedString*)doCmd:(NSString *)cmd
{
  NSAttributedString *aStr=[_machine.commandDispatcher doCmd:cmd virtualMachine:L];
  
  [self update];
  return aStr;
}

@end
