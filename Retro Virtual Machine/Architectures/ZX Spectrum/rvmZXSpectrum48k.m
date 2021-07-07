//
//  rvmZXSpectrum48k.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 11/04/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmZXSpectrum48k.h"

#import "rvmTAPDecoder.h"
#import "rvmTZXDecoder.h"

//#import "rvmDCStop.h"
//#import "rvmDCRun.h"
//#import "rvmDCStep.h"
//#import "rvmDCBreak.h"
//#import "rvmDCPrint.h"

#import "rvmArchitecture.h"
//#import "rvmCommandDispatcher.h"
#import "rvmRecorderViewController.h"

//#import "rvmLuajit.h"

#import "rvmZxSpectrum48kConfigViewController.h"
#import "rvmZxSpectrum48kKeyboardConfigViewController.h"

#import "rvmAudioViewController.h"
#import "rvmVideoViewController.h"

#import "rvmSNADecoder.h"
#import "rvmZ80Decoder.h"

static bool tablesInit=false;

#define joyUp 0x8
#define joyDown 0x4
#define joyLeft 0x2
#define joyRight 0x1
#define joyFire 0x10

@interface rvmZXSpectrum48k()
{
  //NSMutableArray *keyboardFlags;
  rvmMachineKeyS keys[0x100];
  rvmMachineKeyS machineKeys[57];

  bool defaultRom;
  
  rvmAudioViewController *_audioController;
  rvmVideoViewController *_videoController;
  //NSDictionary* lastSnapshot;

  rvmGamepad *emuDevice;
  
  //bool recreatedSpectrum;
}

@end

@implementation rvmZXSpectrum48k

typedef struct {
  rvmMachineKeyS key;
  uint32 type;
}recreatedKeyS;

static recreatedKeyS reKeys[0x100];

void initRecKeys(void)
{
  for(int i=0;i<0x100;i++)
  {
    reKeys[i]=(recreatedKeyS){(rvmMachineKeyS){0,{0},{0x0},""},0};
  }
  //1
  reKeys[0x00]= (recreatedKeyS){(rvmMachineKeyS){1,{3},{0x1},"1"},0};
  reKeys[0x0b]= (recreatedKeyS){(rvmMachineKeyS){1,{3},{0x1},"1"},1};
  
  //2
  reKeys[0x08]= (recreatedKeyS){(rvmMachineKeyS){1,{3},{0x2},"2"},0};
  reKeys[0x02]= (recreatedKeyS){(rvmMachineKeyS){1,{3},{0x2},"2"},1};
  
  //3
  reKeys[0x0e]= (recreatedKeyS){(rvmMachineKeyS){1,{3},{0x4},"3"},0};
  reKeys[0x03]= (recreatedKeyS){(rvmMachineKeyS){1,{3},{0x4},"3"},1};
  
  //4
  reKeys[0x05]= (recreatedKeyS){(rvmMachineKeyS){1,{3},{0x8},"4"},0};
  reKeys[0x04]= (recreatedKeyS){(rvmMachineKeyS){1,{3},{0x8},"4"},1};
  
  //5
  reKeys[0x22]= (recreatedKeyS){(rvmMachineKeyS){1,{3},{0x10},"5"},0};
  reKeys[0x26]= (recreatedKeyS){(rvmMachineKeyS){1,{3},{0x10},"5"},1};
  
  //6
  reKeys[0x28]= (recreatedKeyS){(rvmMachineKeyS){1,{4},{0x10},"6"},0};
  reKeys[0x25]= (recreatedKeyS){(rvmMachineKeyS){1,{4},{0x10},"6"},1};
  
  //7
  reKeys[0x2e]= (recreatedKeyS){(rvmMachineKeyS){1,{4},{0x8},"7"},0};
  reKeys[0x2d]= (recreatedKeyS){(rvmMachineKeyS){1,{4},{0x8},"7"},1};
  
  //8
  reKeys[0x1f]= (recreatedKeyS){(rvmMachineKeyS){1,{4},{0x4},"8"},0};
  reKeys[0x23]= (recreatedKeyS){(rvmMachineKeyS){1,{4},{0x4},"8"},1};
  
  //9
  reKeys[0x0c]= (recreatedKeyS){(rvmMachineKeyS){1,{4},{0x2},"9"},0};
  reKeys[0x0f]= (recreatedKeyS){(rvmMachineKeyS){1,{4},{0x2},"9"},1};
  
  //0
  reKeys[0x01]= (recreatedKeyS){(rvmMachineKeyS){1,{4},{0x1},"0"},0};
  reKeys[0x11]= (recreatedKeyS){(rvmMachineKeyS){1,{4},{0x1},"0"},1};
  
  
  //Q
  reKeys[0x20]= (recreatedKeyS){(rvmMachineKeyS){1,{2},{0x1},"Q"},0};
  reKeys[0x09]= (recreatedKeyS){(rvmMachineKeyS){1,{2},{0x1},"Q"},1};
  
  //W
  reKeys[0x0d]= (recreatedKeyS){(rvmMachineKeyS){1,{2},{0x2},"W"},0};
  reKeys[0x07]= (recreatedKeyS){(rvmMachineKeyS){1,{2},{0x2},"W"},1};
  
  //E
  reKeys[0x10]= (recreatedKeyS){(rvmMachineKeyS){1,{2},{0x4},"E"},0};
  reKeys[0x06]= (recreatedKeyS){(rvmMachineKeyS){1,{2},{0x4},"E"},1};
  
  //R
  reKeys[0x80 | 0x00]= (recreatedKeyS){(rvmMachineKeyS){1,{2},{0x8},"R"},0};
  reKeys[0x80 | 0x0b]= (recreatedKeyS){(rvmMachineKeyS){1,{2},{0x8},"R"},1};
  
  //T
  reKeys[0x80 | 0x08]= (recreatedKeyS){(rvmMachineKeyS){1,{2},{0x10},"T"},0};
  reKeys[0x80 | 0x02]= (recreatedKeyS){(rvmMachineKeyS){1,{2},{0x10},"T"},1};
  
  //Y
  reKeys[0x80 | 0x0e]= (recreatedKeyS){(rvmMachineKeyS){1,{5},{0x10},"Y"},0};
  reKeys[0x80 | 0x03]= (recreatedKeyS){(rvmMachineKeyS){1,{5},{0x10},"Y"},1};
  
  //U
  reKeys[0x80 | 0x05]= (recreatedKeyS){(rvmMachineKeyS){1,{5},{0x8},"U"},0};
  reKeys[0x80 | 0x04]= (recreatedKeyS){(rvmMachineKeyS){1,{5},{0x8},"U"},1};
  
  //I
  reKeys[0x80 | 0x22]= (recreatedKeyS){(rvmMachineKeyS){1,{5},{0x4},"I"},0};
  reKeys[0x80 | 0x26]= (recreatedKeyS){(rvmMachineKeyS){1,{5},{0x4},"I"},1};
  
  //O
  reKeys[0x80 | 0x28]= (recreatedKeyS){(rvmMachineKeyS){1,{5},{0x2},"O"},0};
  reKeys[0x80 | 0x25]= (recreatedKeyS){(rvmMachineKeyS){1,{5},{0x2},"O"},1};
  
  //P
  reKeys[0x80 | 0x2e]= (recreatedKeyS){(rvmMachineKeyS){1,{5},{0x1},"P"},0};
  reKeys[0x80 | 0x2d]= (recreatedKeyS){(rvmMachineKeyS){1,{5},{0x1},"P"},1};
  
  //A
  reKeys[0x80 | 0x1f]= (recreatedKeyS){(rvmMachineKeyS){1,{1},{0x1},"A"},0};
  reKeys[0x80 | 0x23]= (recreatedKeyS){(rvmMachineKeyS){1,{1},{0x1},"A"},1};
  
  //S
  reKeys[0x80 | 0x0c]= (recreatedKeyS){(rvmMachineKeyS){1,{1},{0x2},"S"},0};
  reKeys[0x80 | 0x0f]= (recreatedKeyS){(rvmMachineKeyS){1,{1},{0x2},"S"},1};
  
  //D
  reKeys[0x80 | 0x01]= (recreatedKeyS){(rvmMachineKeyS){1,{1},{0x4},"D"},0};
  reKeys[0x80 | 0x11]= (recreatedKeyS){(rvmMachineKeyS){1,{1},{0x4},"D"},1};
  
  //F
  reKeys[0x80 | 0x20]= (recreatedKeyS){(rvmMachineKeyS){1,{1},{0x8},"F"},0};
  reKeys[0x80 | 0x09]= (recreatedKeyS){(rvmMachineKeyS){1,{1},{0x8},"F"},1};
  
  //G
  reKeys[0x80 | 0x0d]= (recreatedKeyS){(rvmMachineKeyS){1,{1},{0x10},"G"},0};
  reKeys[0x80 | 0x07]= (recreatedKeyS){(rvmMachineKeyS){1,{1},{0x10},"G"},1};
  
  //H
  reKeys[0x80 | 0x10]= (recreatedKeyS){(rvmMachineKeyS){1,{6},{0x10},"H"},0};
  reKeys[0x80 | 0x06]= (recreatedKeyS){(rvmMachineKeyS){1,{6},{0x10},"H"},1};
  
  //J
  reKeys[0x1d]= (recreatedKeyS){(rvmMachineKeyS){1,{6},{0x8},"J"},0};
  reKeys[0x12]= (recreatedKeyS){(rvmMachineKeyS){1,{6},{0x8},"J"},1};
  
  //K
  reKeys[0x13]= (recreatedKeyS){(rvmMachineKeyS){1,{6},{0x4},"K"},0};
  reKeys[0x14]= (recreatedKeyS){(rvmMachineKeyS){1,{6},{0x4},"K"},1};
  
  //L
  reKeys[0x15]= (recreatedKeyS){(rvmMachineKeyS){1,{6},{0x2},"L"},0};
  reKeys[0x17]= (recreatedKeyS){(rvmMachineKeyS){1,{6},{0x2},"L"},1};
  
  //Enter
  reKeys[0x16]= (recreatedKeyS){(rvmMachineKeyS){1,{6},{0x1},"Enter"},0};
  reKeys[0x1a]= (recreatedKeyS){(rvmMachineKeyS){1,{6},{0x1},"Enter"},1};
  
  //Shift
  reKeys[0x1c]= (recreatedKeyS){(rvmMachineKeyS){1,{0},{0x1},"Shift"},0};
  reKeys[0x19]= (recreatedKeyS){(rvmMachineKeyS){1,{0},{0x1},"Shift"},1};
  
  //Z
  reKeys[0x80 | 0x2b]= (recreatedKeyS){(rvmMachineKeyS){1,{0},{0x2},"Z"},0};
  reKeys[0x80 | 0x2f]= (recreatedKeyS){(rvmMachineKeyS){1,{0},{0x2},"Z"},1};
  
  //X
  reKeys[0x1b]= (recreatedKeyS){(rvmMachineKeyS){1,{0},{0x4},"X"},0};
  reKeys[0x18]= (recreatedKeyS){(rvmMachineKeyS){1,{0},{0x4},"X"},1};
  
  //C
  reKeys[0x21]= (recreatedKeyS){(rvmMachineKeyS){1,{0},{0x8},"C"},0};
  reKeys[0x1e]= (recreatedKeyS){(rvmMachineKeyS){1,{0},{0x8},"C"},1};
  
  //V
  reKeys[0x29]= (recreatedKeyS){(rvmMachineKeyS){1,{0},{0x10},"V"},0};
  reKeys[0x80 | 0x29]= (recreatedKeyS){(rvmMachineKeyS){1,{0},{0x10},"V"},1};
  
  //B
  reKeys[0x2b]= (recreatedKeyS){(rvmMachineKeyS){1,{7},{0x10},"B"},0};
  reKeys[0x2f]= (recreatedKeyS){(rvmMachineKeyS){1,{7},{0x10},"B"},1};
  
  //N
  reKeys[0x2c]= (recreatedKeyS){(rvmMachineKeyS){1,{7},{0x8},"N"},0};
  reKeys[0x80 | 0x2c]= (recreatedKeyS){(rvmMachineKeyS){1,{7},{0x8},"N"},1};
  
  //M
  reKeys[0x80 | 0x21]= (recreatedKeyS){(rvmMachineKeyS){1,{7},{0x4},"M"},0};
  reKeys[0x80 | 0x1e]= (recreatedKeyS){(rvmMachineKeyS){1,{7},{0x4},"M"},1};
  
  //Symb
  reKeys[0x80 | 0x12]= (recreatedKeyS){(rvmMachineKeyS){1,{7},{0x2},"Symbol"},0};
  reKeys[0x80 | 0x15]= (recreatedKeyS){(rvmMachineKeyS){1,{7},{0x2},"Symbol"},1};
  
  //Space
  reKeys[0x80 | 0x17]= (recreatedKeyS){(rvmMachineKeyS){1,{7},{0x1},"Space"},0};
  reKeys[0x80 | 0x16]= (recreatedKeyS){(rvmMachineKeyS){1,{7},{0x1},"Space"},1};
}

-(id)init
{
  self=[super init];
  if(self)
  {
    //luaVM=newLua();
    gamepads=[NSMutableDictionary dictionary];
    joyEmuType=0x100;
    super.keyboardType=0;

    [self initialize];
  }
  
  return self;
}


-(void)initPtr
{
  speccy=calloc(1,sizeof(spectrum));
}

-(void)initialize
{
  //joyEmu=true;
  
  emuDevice=[rvmGamepad new];
  gamepads[[NSNumber numberWithUnsignedLongLong:(unsigned long long)emuDevice]]=@0;
  
  self.tripleBuffer=[rvmBufferChain bufferWithWidth:384 height:288];
  
  if(!tablesInit)
  {
    init48k();
    initRecKeys();
    tablesInit=YES;
  }
  
  [self initPtr];
  speccy->cpu=(z80*)calloc(1,sizeof(z80));
  
  speccy->cpu->mem=((uint8**)malloc(sizeof(uint8*)*4));
  speccy->cpu->memw=((uint8**)malloc(sizeof(uint8*)*4));
  speccy->cpu->iAknowlegde=s48k_ack;
  [self initModel];
  
  z80_init();
  z80_reset(speccy->cpu);
  //speccy->cpu->dispatch=NULL;
  //speccy->cpu->exec=NULL;
  
  //for(int i=0;i<8;i++)
    //speccy->cpu->o[i].OC=0;
  
  //speccy->cpu->op=0;
  
  speccy->palette[0]=0xff000000;
//  speccy->palette[1]=0xff881111;
//  speccy->palette[2]=0xff222288;
//  speccy->palette[3]=0xff992299;
//  speccy->palette[4]=0xff339933;
//  speccy->palette[5]=0xffAAAA44;
//  speccy->palette[6]=0xff44AAAA;
//  speccy->palette[7]=0xffBBBBBB;
//
//  speccy->palette[8]=0xff000000;
//  speccy->palette[9]=0xff991111;
//  speccy->palette[10]=0xff2222AA;
//  speccy->palette[11]=0xffBB33BB;
//  speccy->palette[12]=0xff44CC44;
//  speccy->palette[13]=0xffDDDD55;
//  speccy->palette[14]=0xff66EEEE;
//  speccy->palette[15]=0xffffffff;

  
  speccy->palette[1]=0xffcd0000;
  speccy->palette[2]=0xff0000cd;
  speccy->palette[3]=0xffcd00cd;
  speccy->palette[4]=0xff00cd00;
  speccy->palette[5]=0xffcdcd00;
  speccy->palette[6]=0xff00cdcd;
  speccy->palette[7]=0xffcdcdcd;
  
  speccy->palette[8]=0xff000000;
  speccy->palette[9]=0xffff0000;
  speccy->palette[10]=0xff0000ff;
  speccy->palette[11]=0xffff00ff;
  speccy->palette[12]=0xff00ff00;
  speccy->palette[13]=0xffffff00;
  speccy->palette[14]=0xff00ffff;
  speccy->palette[15]=0xffffffff;
  
  speccy->border=0xff000000;
  speccy->cpu->tag=speccy;
  
  for(int i=0;i<8;i++)
    speccy->keyboard[i]=0xff;
  
  [self loadDefaultRom];
  [self initKeyboard];
  
  speccy->so=speccy->soc=0;
  //self.commandDispatcher=[rvmCommandDispatcher new];
  //self.commandDispatcher.machine=self;
  //[self initCommands];
  
  //breakPoints=[NSMutableDictionary dictionary];
}

-(void)initModel
{
  speccy->ram=(uint8**)malloc(sizeof(uint8*)*3);
  speccy->rom=(uint8**)malloc(sizeof(uint8*)*1);
  
  for(int i=0;i<3;i++)
  {
    speccy->ram[i]=(uint8*)calloc(1,0x4000);
  }
  
  speccy->rom[0]=(uint8*)calloc(1,0x4000);
  
  speccy->cpu->mem[0]=speccy->rom[0];
  speccy->cpu->mem[1]=speccy->cpu->memw[1]=speccy->ram[0];
  speccy->cpu->mem[2]=speccy->cpu->memw[2]=speccy->ram[1];
  speccy->cpu->mem[3]=speccy->cpu->memw[3]=speccy->ram[2];
  
  speccy->cpu->get=s48k_get;
  speccy->cpu->set=s48k_set;
  speccy->cpu->out=s48k_out;
  speccy->cpu->in=s48k_in;
  speccy->cpu->con1=speccy->cpu->con2=s48k_contention;
  speccy->cpu->conIO=s48k_contentionIO;
  speccy->step=(rvmSpeccyStep)step48k;
  speccy->frameF=(rvmSpeccyStep)frame48k;
  speccy->cpu->busInt=s48k_busInt;
  speccy->cpu->iAknowlegde=s48k_ack;
  
  mixer=[rvmAudioMixer new];
  [mixer setChannels:1 maxVolume:4.0];
  
  speccy->mixer=&(mixer->mixerS);
  
  for(int i=0;i<1;i++)
  {
    mixer->mixerS.cVol[i]=1.0;
    mixer->mixerS.cPan[i]=0.5;
  }
}

-(uint8)inversePalette:(uint32)col
{
  for(int i=0;i<16;i++)
    if(col==speccy->palette[i]) return i;
  
  return 0;
}

-(void)deallocMemory {
  for(int i=0;i<3;i++)
    free(speccy->ram[i]);
  
  free(speccy->rom[0]);
}

-(void)dealloc
{
  //NSLog(@"dealloc");
  [self deallocMemory];
  
  free(speccy->ram);
  free(speccy->rom);
  free(speccy->cpu->mem);
  free(speccy->cpu->memw);
  
  free(speccy->cpu);
}

-(void)doFrame:(bool)fast
{
  @synchronized (self)
  {
    @synchronized(self.tapeDecoder)
    {
  //if(!self.running || self.paused) return;
      if((self.control & 0x3)!=0x1) return;
  
      uint *pt=self.tripleBuffer->work->buf;//[self.tripleBuffer work];
  
  bool c=speccy->cassetteDecoder?speccy->cassetteDecoder->running:NO;
      uint32 bn=speccy->cassetteDecoder?speccy->cassetteDecoder->blockIndex:0;
      
  speccy->frameF(speccy,fast,pt);
  if(!fast) [self.tripleBuffer swap];
      
  if(speccy->cassetteDecoder)
  {
  if(c && !speccy->cassetteDecoder->running)
    dispatch_async(dispatch_get_main_queue(),^{
     [[self.tapeDecoder cassetteView] onStop:self];
    });
  
  if((speccy->frame & 0xf) && speccy->cassetteDecoder->running)
  {
    dispatch_async(dispatch_get_main_queue(),^{
      [self.tapeDecoder cassetteView].delta=[self.tapeDecoder progress];
    });
  }
  
  if(speccy->cassetteDecoder->running && speccy->cassetteDecoder->blockIndex!=bn)
  {
    //char *pt=speccy->cassetteDecoder->blockName;
    //speccy->cassetteDecoder->blockName=NULL;
    
    dispatch_async(dispatch_get_main_queue(), ^{
      //[self.tapeDecoder cassetteView].blockTitle=[NSString stringWithFormat:@"%s",pt];
      [[self.tapeDecoder cassetteView] setBlock:self->speccy->cassetteDecoder->blockIndex];
    });
  }
  }
    }
  }
}

#pragma mark - Keyboard Handling

-(void)initKeyboard
{
  //keyboardFlags=[NSMutableArray arrayWithCapacity:256];
  
  for(int i=0;i<0x100;i++) keys[i]=((rvmMachineKeyS) {0,{0},{0}});//[keyboardFlags addObject:[NSNull null]];
  
  //Line 1 Shift,Z,X,C,V 0xfefe
  //keyboardFlags[56]=@[@[@0,@0x1]];
  machineKeys[0]=keys[56]=((rvmMachineKeyS) {1,{0},{0x1},"Shift"});
  machineKeys[1]=keys[6]=((rvmMachineKeyS) {1,{0},{0x2},"Z"});
  machineKeys[2]=keys[7]=((rvmMachineKeyS) {1,{0},{0x4},"X"});
  machineKeys[3]=keys[8]=((rvmMachineKeyS) {1,{0},{0x8},"C"});
  machineKeys[4]=keys[9]=((rvmMachineKeyS) {1,{0},{0x10},"V"});
  
  //Line 2 A,S,D,F,G 0xfdfe
  machineKeys[5]=keys[0]=((rvmMachineKeyS) {1,{1},{0x1},"A"});
  machineKeys[6]=keys[1]=((rvmMachineKeyS) {1,{1},{0x2},"S"});
  machineKeys[7]=keys[2]=((rvmMachineKeyS) {1,{1},{0x4},"D"});
  machineKeys[8]=keys[3]=((rvmMachineKeyS) {1,{1},{0x8},"F"});
  machineKeys[9]=keys[5]=((rvmMachineKeyS) {1,{1},{0x10},"G"});
  
  //Line 3 Q,W,E,R,T 0xfbfe
  
  machineKeys[10]=keys[12]=((rvmMachineKeyS) {1,{2},{0x1},"Q"});
  machineKeys[11]=keys[13]=((rvmMachineKeyS) {1,{2},{0x2},"W"});
  machineKeys[12]=keys[14]=((rvmMachineKeyS) {1,{2},{0x4},"E"});
  machineKeys[13]=keys[15]=((rvmMachineKeyS) {1,{2},{0x8},"R"});
  machineKeys[14]=keys[17]=((rvmMachineKeyS) {1,{2},{0x10},"T"});
  
  //Line 4 1,2,3,4,5 0xf7fe
  machineKeys[15]=keys[18]=((rvmMachineKeyS) {1,{3},{0x1},"1"});
  machineKeys[16]=keys[19]=((rvmMachineKeyS) {1,{3},{0x2},"2"});
  machineKeys[17]=keys[20]=((rvmMachineKeyS) {1,{3},{0x4},"3"});
  machineKeys[18]=keys[21]=((rvmMachineKeyS) {1,{3},{0x8},"4"});
  machineKeys[19]=keys[23]=((rvmMachineKeyS) {1,{3},{0x10},"5"});
  
  //Line 5 0,9,8,7,6 0xeffe
  machineKeys[20]=keys[29]=((rvmMachineKeyS) {1,{4},{0x1},"0"});
  machineKeys[21]=keys[25]=((rvmMachineKeyS) {1,{4},{0x2},"9"});
  machineKeys[22]=keys[28]=((rvmMachineKeyS) {1,{4},{0x4},"8"});
  machineKeys[23]=keys[26]=((rvmMachineKeyS) {1,{4},{0x8},"7"});
  machineKeys[24]=keys[22]=((rvmMachineKeyS) {1,{4},{0x10},"6"});
  
  //Line 6 P,O,I,U,Y 0xdffe
  machineKeys[25]=keys[35]=((rvmMachineKeyS) {1,{5},{0x1},"P"});
  machineKeys[26]=keys[31]=((rvmMachineKeyS) {1,{5},{0x2},"O"});
  machineKeys[27]=keys[34]=((rvmMachineKeyS) {1,{5},{0x4},"I"});
  machineKeys[28]=keys[32]=((rvmMachineKeyS) {1,{5},{0x8},"U"});
  machineKeys[29]=keys[16]=((rvmMachineKeyS) {1,{5},{0x10},"Y"});

  
  //Line 7 Enter,L,K,J,H 0xbffe
  machineKeys[30]=keys[36]=((rvmMachineKeyS) {1,{6},{0x1},"Enter"});
  machineKeys[31]=keys[37]=((rvmMachineKeyS) {1,{6},{0x2},"L"});
  machineKeys[32]=keys[40]=((rvmMachineKeyS) {1,{6},{0x4},"K"});
  machineKeys[33]=keys[38]=((rvmMachineKeyS) {1,{6},{0x8},"J"});
  machineKeys[34]=keys[4]=((rvmMachineKeyS) {1,{6},{0x10},"H"});

  
  //Line 8 Space,Symbol,M,N,B 0x7ffe
  machineKeys[35]=keys[49]=((rvmMachineKeyS) {1,{7},{0x1},"Space"});
  machineKeys[36]=keys[59]=((rvmMachineKeyS) {1,{7},{0x2},"Symbol"});
  machineKeys[37]=keys[46]=((rvmMachineKeyS) {1,{7},{0x4},"M"});
  machineKeys[38]=keys[45]=((rvmMachineKeyS) {1,{7},{0x8},"N"});
  machineKeys[39]=keys[11]=((rvmMachineKeyS) {1,{7},{0x10},"B"});
  
  //Shortcuts
  machineKeys[40]=keys[51]=((rvmMachineKeyS) {2,{0,4},{0x1,0x1},"Delete"});
  machineKeys[41]=keys[123]=((rvmMachineKeyS) {2,{0,3},{0x1,0x10},"CursorLeft"});
  machineKeys[42]=keys[124]=((rvmMachineKeyS) {2,{0,4},{0x1,0x4},"CursorRight"});
  machineKeys[43]=keys[125]=((rvmMachineKeyS) {2,{0,4},{0x1,0x10},"CursorDown"});
  machineKeys[44]=keys[126]=((rvmMachineKeyS) {2,{0,4},{0x1,0x8},"CursorUp"});
  
  machineKeys[45]=keys[43]=((rvmMachineKeyS) {2,{7,7},{0x2,0x8},","});
  machineKeys[46]=keys[47]=((rvmMachineKeyS) {2,{7,7},{0x2,0x4},"."});
  machineKeys[47]=keys[48]=((rvmMachineKeyS) {2,{0,3},{0x1,0x1},"Edit"});
  machineKeys[48]=keys[122]=((rvmMachineKeyS) {6,{2,1,0,5,6,7},{0x1,0x1,0x2,0x1,0x2,0x4}});
  
  machineKeys[49]=keys[41]=((rvmMachineKeyS) {2,{7,5},{0x2,0x2},";"}); //;
  machineKeys[50]=keys[39]=((rvmMachineKeyS) {2,{7,5},{0x2,0x1},"\""}); //"
  
  machineKeys[51]=keys[27]=((rvmMachineKeyS) {2,{0,3},{0x1,0x4},"TrueVideo"}); //True video
  machineKeys[52]=keys[24]=((rvmMachineKeyS) {2,{0,3},{0x1,0x8},"InvVideo"}); //Inv Video
  
  machineKeys[53]=keys[53]=((rvmMachineKeyS) {2,{0,7},{0x1,0x1},"Break"}); //Break
  machineKeys[54]=keys[58]=((rvmMachineKeyS) {2,{0,7},{0x1,0x2},"Extend"}); //Extend
  
  machineKeys[55]=keys[57]=((rvmMachineKeyS) {2,{0,3},{0x1,0x2},"CapsLock"}); //Caps Lock
  machineKeys[56]=keys[50]=((rvmMachineKeyS) {2,{0,4},{0x1,0x2},"Graphics"}); //Graphics
  
  //joy Emu
  joyEmuS[123]=1;
  joyEmuS[124]=2;
  joyEmuS[125]=4;
  joyEmuS[126]=3;
  joyEmuS[49]=10;
}

-(void)keyDown:(uint8)code
{
  @synchronized (self)
  {
    if(!super.keyboardType && joyEmuType<0x100)
    {
      uint joyCode=joyEmuS[code];
      
      if(joyCode)
      {
//        joyEmuState|=joyCode;
       //NSLog(@"Joy Down code:%.2x state %.2x",joyCode,joyEmuState);
//        [self joyState:joyEmuState];
        [self joy:emuDevice element:joyCode-1 value:1];
        return;
      }
    }
    
    rvmMachineKeyS k;
    if(super.keyboardType)
    {
      if(code==0x35) //ESC
      {
        //[self keyboardType:0];
        self.keyboardType=0;
        return;
      }
      
      k=reKeys[code].key;
    }
    else
      k=keys[code & 0x7f];
  
    //NSLog(@"Key down code: %d %d",code);
    if(!k.number) return;
  
    for(int i=0;i<k.number;i++)
    {
      if(super.keyboardType)
      {
        if(reKeys[code].type)
          speccy->keyboard[k.lines[i]]=k.codes[i] | speccy->keyboard[k.lines[i]];
        else
          speccy->keyboard[k.lines[i]]=(k.codes[i]^0xff) & speccy->keyboard[k.lines[i]];
      }
      else
        speccy->keyboard[k.lines[i]]=(k.codes[i]^0xff) & speccy->keyboard[k.lines[i]];
    }
  }
}

-(void)keyUp:(uint8)code
{
  @synchronized (self)
  {
    if(super.keyboardType) return;

    
    if(joyEmuType<0x100)
    {
      uint joyCode=joyEmuS[code];
      
      if(joyCode)
      {
//        joyEmuState&=~joyCode;
//        //NSLog(@"Joy Up code:%.2x state %.2x",joyCode,joyEmuState);
//        [self joyState:joyEmuState];
        [self joy:emuDevice element:joyCode-1 value:0];
        return;
      }
    }
    
    rvmMachineKeyS k=keys[code];
    
    if(!k.number) return;
    
    for(int i=0;i<k.number;i++)
    {
      speccy->keyboard[k.lines[i]]=k.codes[i] | speccy->keyboard[k.lines[i]];
    }
  }
}

-(rvmMachineKeyS)keysForkey:(uint)keycode
{
  //return keyboardFlags[keycode];
  return keys[keycode];
}

-(rvmMachineKeyS)keysForMachinekey:(uint)keycode
{
  return machineKeys[keycode];
}

-(void)changeKey:(uint)keycode keys:(rvmMachineKeyS*)key
{
  keys[keycode]=*key;
  [self.doc saveMain];
}

-(void)resetRam
{
  for(int i=0;i<3;i++)
  {
    for (int j=0;j<0x4000;j++)
      speccy->ram[i][j]=(j & 0x4)?0xff:0x00;
  }
    //memset(speccy->ram[i],0,0x4000);
}

-(void)resetMachine
{
  //[self resetRam];
  
  for(int i=0;i<8;i++)
    speccy->keyboard[i]=0xff;
  
  speccy->border=0xff000000;
  z80_reset(speccy->cpu);
}

-(void)joyState:(uint8)state
{
  speccy->joyState=state;
}

#pragma mark - Debugger Interface

-(void)stepInstruction
{
  //if(!self.paused) return;
  if(!(self.control & 0x2)) return;
  
  do
  {
    speccy->step(speccy, NO, self.tripleBuffer->work->buf);
  }while(*speccy->cpu->uops || speccy->T);
}

//-(void)doFrameDebug
//{
//  if(!running || paused) return;
//  
//  //uint f=speccy->frame;
//  uint *pt=[tripleBuffer work];
//  
//  do
//  {
//    if((*speccy->cpu->uops || speccy->T) && breakPoints[[NSNumber numberWithShort:speccy->cpu->r.pc]])
//    {
//      paused=YES;
//      break;
//    }
//
//      pt=speccy->step(speccy, NO, pt);
//
//  }while(speccy->t || speccy->line);
//
//}

-(void)setTapeDecoder:(id<rvmTapeDecoderProtocol>)decoder
{
  super.tapeDecoder=decoder;
  speccy->cassetteDecoder=self.tapeDecoder.decoder;
}

#pragma mark - Audio
-(int16_t *)audioBuffer
{
  return speccy->audioBuffer;
}

-(uint)audioLength
{
  return 3840;
}

-(NSViewController *)configViewController
{
  rvmZxSpectrum48kConfigViewController *vc=[[rvmZxSpectrum48kConfigViewController alloc] initWithNibName:@"rvmZxSpectrum48kConfigViewController" bundle:nil];
  
  //rvmArchitecture *a=self.doc;
  vc.view=vc.view;
  //vc.titleLabel.stringValue=a.properties[@"model"];
  //vc.machine=self;
  return vc;
}

//-(void)setRunning:(bool)r
//{
//  if((self.control & 0x1) && !r)
//  {
//    [self resetMachine];
//  }
//  
//  super.control|=0x1;
//}

-(NSDictionary*)serializeRegs
{
  return @{
           @"bc":[NSNumber numberWithShort:speccy->cpu->r.bc],
           @"de":[NSNumber numberWithShort:speccy->cpu->r.de],
           @"hl":[NSNumber numberWithShort:speccy->cpu->r.hl],
           @"af":[NSNumber numberWithShort:speccy->cpu->r.af],
           @"sp":[NSNumber numberWithShort:speccy->cpu->r.sp],
           @"ix":[NSNumber numberWithShort:speccy->cpu->r.ix],
           @"iy":[NSNumber numberWithShort:speccy->cpu->r.iy],
           @"pc":[NSNumber numberWithShort:speccy->cpu->r.pc],
           @"ir":[NSNumber numberWithShort:speccy->cpu->r.ir],
           @"bcp":[NSNumber numberWithShort:speccy->cpu->r.bcp],
           @"dep":[NSNumber numberWithShort:speccy->cpu->r.dep],
           @"hlp":[NSNumber numberWithShort:speccy->cpu->r.hlp],
           @"afp":[NSNumber numberWithShort:speccy->cpu->r.afp],
           @"tm":[NSNumber numberWithShort:speccy->cpu->r.tm],
           @"aux":[NSNumber numberWithShort:speccy->cpu->r.aux],
           @"iffw":[NSNumber numberWithShort:speccy->cpu->r.iffw],
           @"imodew":[NSNumber numberWithShort:speccy->cpu->r.imodew],
           @"mptr":[NSNumber numberWithShort:speccy->cpu->r.mptr],
           };
}

-(NSMutableDictionary *)createSnapshot
{
  @synchronized(self) {
    do
    {
      speccy->step(speccy, NO, self.tripleBuffer->work->buf);
    }while(*speccy->cpu->uops || speccy->T);
  }
  
  NSMutableDictionary *d=[NSMutableDictionary dictionary];
  
  d[@"memory"]=[self snapshotMemory];
  d[@"cpu"]=[self snapshotCpu];
  d[@"spectrum"]=[self snapshotSpectrum];
  
  d[@"thumb"]=@{@"w":[NSNumber numberWithUnsignedInt:self.tripleBuffer.width],
                @"h":[NSNumber numberWithUnsignedInt:self.tripleBuffer.height],
                @"payload":[[self.tripleBuffer dataSnapshot] base64EncodedStringWithOptions:0]};
  
  d[@"model"]=[self snapshotModel];
  
  return d;
}

-(NSMutableDictionary*)snapshotModel
{
  NSMutableDictionary *d=[NSMutableDictionary new];
  
  d[@"arch"]=@"ZX Spectrum";
  d[@"model"]=@"48k";
  d[@"submodel"]=@"48k";
  
  return d;
}

//Snapshot creation

-(NSMutableDictionary*)snapshotMemory
{
  //Todo: Custom roms.
  NSMutableDictionary *m=[NSMutableDictionary new];
  
  m[@"ram0"]=[[NSData dataWithBytes:speccy->ram[0] length:0x4000] base64EncodedStringWithOptions:0];
  m[@"ram1"]=[[NSData dataWithBytes:speccy->ram[1] length:0x4000] base64EncodedStringWithOptions:0];
  m[@"ram2"]=[[NSData dataWithBytes:speccy->ram[2] length:0x4000] base64EncodedStringWithOptions:0];
  
  return m;
}

//bc,de,hl,af,sp,ix,iy,pc,ir,bcp,dep,hlp,afp,tm,aux,iffw,imodew,mptr;
-(NSMutableDictionary*)snapshotCpu
{
  NSMutableDictionary *cpu=[NSMutableDictionary new];
  
  cpu[@"bc"]=[NSNumber numberWithUnsignedShort:speccy->cpu->r.bc];
  cpu[@"de"]=[NSNumber numberWithUnsignedShort:speccy->cpu->r.de];
  cpu[@"hl"]=[NSNumber numberWithUnsignedShort:speccy->cpu->r.hl];
  cpu[@"af"]=[NSNumber numberWithUnsignedShort:speccy->cpu->r.af];
  
  cpu[@"sp"]=[NSNumber numberWithUnsignedShort:speccy->cpu->r.sp];
  cpu[@"ix"]=[NSNumber numberWithUnsignedShort:speccy->cpu->r.ix];
  cpu[@"iy"]=[NSNumber numberWithUnsignedShort:speccy->cpu->r.iy];
  cpu[@"pc"]=[NSNumber numberWithUnsignedShort:speccy->cpu->r.pc];
  
  cpu[@"bcp"]=[NSNumber numberWithUnsignedShort:speccy->cpu->r.bcp];
  cpu[@"dep"]=[NSNumber numberWithUnsignedShort:speccy->cpu->r.dep];
  cpu[@"hlp"]=[NSNumber numberWithUnsignedShort:speccy->cpu->r.hlp];
  cpu[@"afp"]=[NSNumber numberWithUnsignedShort:speccy->cpu->r.afp];
  
  cpu[@"tm"]=[NSNumber numberWithUnsignedShort:speccy->cpu->r.tm];
  cpu[@"aux"]=[NSNumber numberWithUnsignedShort:speccy->cpu->r.aux];
  cpu[@"iffw"]=[NSNumber numberWithUnsignedShort:speccy->cpu->r.iffw];
  cpu[@"imodew"]=[NSNumber numberWithUnsignedShort:speccy->cpu->r.imodew];
  
  cpu[@"ir"]=[NSNumber numberWithUnsignedShort:speccy->cpu->r.ir];
  cpu[@"mptr"]=[NSNumber numberWithUnsignedShort:speccy->cpu->r.mptr];
  
  cpu[@"flags"]=[NSNumber numberWithUnsignedChar:speccy->cpu->flags];
  cpu[@"T"]=[NSNumber numberWithUnsignedInt:speccy->cpu->T];
  
  return cpu;
}

//int line,t,flash,T,M,frame,so,soundIndex;

-(NSMutableDictionary*)snapshotSpectrum
{
  NSMutableDictionary *s=[NSMutableDictionary new];
  
  //s[@"border"]=[NSNumber numberWithUnsignedInt:speccy->border];
  //s[@"bcol"]=[NSNumber numberWithUnsignedInt:speccy->bcol];
  //s[@"bl"]=[NSNumber numberWithUnsignedInt:speccy->bl];
  
  uint8 border=speccy->border;
  //for(border=0;speccy->border!=speccy->palette[border];border++);
  
  s[@"border"]=[NSNumber numberWithUnsignedChar:border];
  
  s[@"fg"]=[NSNumber numberWithUnsignedInt:speccy->fg];
  s[@"bg"]=[NSNumber numberWithUnsignedInt:speccy->bg];
  
  //s[@"line"]=[NSNumber numberWithInt:speccy->line];
  s[@"t"]=[NSNumber numberWithInt:speccy->t];
  s[@"T"]=[NSNumber numberWithInt:speccy->T];
  
  s[@"M"]=[NSNumber numberWithInt:speccy->M];
  s[@"frame"]=[NSNumber numberWithInt:speccy->frame];
  s[@"so"]=[NSNumber numberWithInt:speccy->so];
  s[@"soundIndex"]=[NSNumber numberWithInt:speccy->soundIndex];
  
  s[@"soc"]=[NSNumber numberWithFloat:speccy->soc];
  
  s[@"pixel"]=[NSNumber numberWithUnsignedChar:speccy->pixel];
  s[@"attr"]=[NSNumber numberWithUnsignedChar:speccy->attr];
  s[@"pl"]=[NSNumber numberWithUnsignedChar:speccy->pl];
  s[@"al"]=[NSNumber numberWithUnsignedChar:speccy->al];
  
  s[@"mic"]=[NSNumber numberWithUnsignedChar:speccy->mic];
  s[@"ear"]=[NSNumber numberWithUnsignedChar:speccy->ear];
  s[@"joyState"]=[NSNumber numberWithUnsignedChar:speccy->joyState];
  
  s[@"level"]=[NSNumber numberWithUnsignedInt:speccy->level];
  s[@"cassetteT"]=[NSNumber numberWithUnsignedInt:speccy->cassetteT];
  
  s[@"soundChannels"]=[self snapshotSoundChannels];
  
  return s;
}

-(NSMutableArray*)snapshotSoundChannels
{
  NSMutableArray *ma=[NSMutableArray new];
  
  ma[0]=[NSNumber numberWithDouble:speccy->soundChannels[0]];
  
  return ma;
}

//Snapshot loading
-(void)loadSnapshot:(NSDictionary*)snap
{
  @synchronized(self)
  {
    z80_reset(speccy->cpu);
    [self loadMemory:snap[@"memory"]];
    [self loadCpu:snap[@"cpu"]];
    [self loadSpectrum:snap[@"spectrum"]];
  }
}

-(void)loadMemory:(NSDictionary*)snap
{
  NSData *r;
  
  //r=[[NSData alloc] initWithBase64Encoding:snap[@"ram0"]];
  r=[[NSData alloc] initWithBase64EncodedString:snap[@"ram0"] options:0];
  memcpy(speccy->ram[0],r.bytes,0x4000);
  
  //r=[[NSData alloc] initWithBase64Encoding:snap[@"ram1"]];
  r=[[NSData alloc] initWithBase64EncodedString:snap[@"ram1"] options:0];
  memcpy(speccy->ram[1],r.bytes,0x4000);
  
  //r=[[NSData alloc] initWithBase64Encoding:snap[@"ram2"]];
  r=[[NSData alloc] initWithBase64EncodedString:snap[@"ram2"] options:0];
  memcpy(speccy->ram[2],r.bytes,0x4000);
}

-(void)loadCpu:(NSDictionary*)cpu
{
  speccy->cpu->r.bc=[cpu[@"bc"] unsignedShortValue];
  speccy->cpu->r.de=[cpu[@"de"] unsignedShortValue];
  speccy->cpu->r.hl=[cpu[@"hl"] unsignedShortValue];
  speccy->cpu->r.af=[cpu[@"af"] unsignedShortValue];
  
  speccy->cpu->r.sp=[cpu[@"sp"] unsignedShortValue];
  speccy->cpu->r.ix=[cpu[@"ix"] unsignedShortValue];
  speccy->cpu->r.iy=[cpu[@"iy"] unsignedShortValue];
  speccy->cpu->r.pc=[cpu[@"pc"] unsignedShortValue];

  speccy->cpu->r.bcp=[cpu[@"bcp"] unsignedShortValue];
  speccy->cpu->r.dep=[cpu[@"dep"] unsignedShortValue];
  speccy->cpu->r.hlp=[cpu[@"hlp"] unsignedShortValue];
  speccy->cpu->r.afp=[cpu[@"afp"] unsignedShortValue];

  speccy->cpu->r.tm=[cpu[@"tm"] unsignedShortValue];
  speccy->cpu->r.aux=[cpu[@"aux"] unsignedShortValue];
  speccy->cpu->r.iffw=[cpu[@"iffw"] unsignedShortValue];
  speccy->cpu->r.imodew=[cpu[@"imodew"] unsignedShortValue];

  
  speccy->cpu->r.ir=[cpu[@"ir"] unsignedShortValue];
  speccy->cpu->r.mptr=[cpu[@"mptr"] unsignedShortValue];
  
  speccy->cpu->flags=[cpu[@"flags"] unsignedCharValue];
  speccy->cpu->T=[cpu[@"T"] unsignedIntValue];
}

-(void)loadSpectrum:(NSDictionary*)s
{
  uint8 bor=[s[@"border"] unsignedCharValue];
  //speccy->border=speccy->palette[bor];
  //speccy->bcol=speccy->palette[bor];
  //speccy->bl=speccy->palette[bor];
  if(bor>0x10)
    for(uint i=0;i<16;i++)
      if(speccy->palette[i]==bor) {
        bor=i;
        break;
      }

  speccy->border=bor;
  
  speccy->fg=[s[@"fg"] unsignedIntValue];
  speccy->bg=[s[@"bg"] unsignedIntValue];
  
  //speccy->line=[s[@"line"] intValue];
  speccy->t=[s[@"t"] intValue];
  speccy->T=[s[@"T"] intValue];
  
  speccy->M=[s[@"M"] intValue];
  speccy->frame=[s[@"frame"] intValue];
  speccy->so=[s[@"so"] intValue];
  speccy->soundIndex=[s[@"soundIndex"] intValue];

  speccy->soc=[s[@"soc"] floatValue];
  
  speccy->pixel=[s[@"pixel"] unsignedCharValue];
  speccy->attr=[s[@"attr"] unsignedCharValue];
  speccy->pl=[s[@"pl"] unsignedCharValue];
  speccy->al=[s[@"al"] unsignedCharValue];
  
  speccy->attr=[s[@"mic"] unsignedCharValue];
  speccy->pl=[s[@"ear"] unsignedCharValue];
  speccy->al=[s[@"joyState"] unsignedCharValue];
  
  speccy->level=[s[@"level"] unsignedIntValue];
  speccy->cassetteT=[s[@"cassetteT"] unsignedIntValue];
  
  [self loadSoundChannels:s[@"soundChannels"]];
}

-(void)loadSoundChannels:(NSArray*)a
{
  speccy->soundChannels[0]=[a[0] doubleValue];
}

-(NSData*)imageSnapshot
{
  //return [NSData dataWithBytes:self.tripleBuffer.work length:320*240*4];
  return [self.tripleBuffer dataSnapshot];
}

#pragma mark - Rom Support

-(void)loadCustomRom:(NSData*)romData
{
  memcpy(speccy->cpu->mem[0], romData.bytes, 0x4000);
  defaultRom=NO;
}

-(void)loadDefaultRom
{
  NSFileManager *fm=[NSFileManager defaultManager];
  
  NSData *rom=[fm contentsAtPath:[[NSBundle mainBundle] pathForResource:@"Resources/Roms/ZXSpectrum48k" ofType:@"rom"]];
  memcpy(speccy->rom[0],rom.bytes,0x4000);
  defaultRom=YES;
}

-(spectrum*)spectrum
{
  return speccy;
}

-(NSViewController*)cassetteController
{
  if(!cassetteController)
  cassetteController=[[rvmRecorderViewController alloc] initWithNibName:@"rvmRecorderViewController" bundle:nil];
  return cassetteController;
}

//-(void)luaInit:(lua_State *)L
//{
//  luaVM=L;
//  callLua(L,[NSString stringWithFormat:@"local zx=require('rvm.architectures.zxspectrum.spectrum48k'); machine=zx.new(%pULL)",speccy]);
//  [self registerCommands:L];
//}

//-(void)registerCommands:(lua_State *)L
//{
//  callLua(L, @"dispatcher.register('rvm.commands.test')");
//  callLua(L, @"dispatcher.register('rvm.commands.memory')");
//  callLua(L, @"dispatcher.register('rvm.commands.memoryMap')");
//  callLua(L, @"dispatcher.register('rvm.commands.disassembler')");
//  callLua(L, @"dispatcher.register('rvm.commands.mountDisk')");
//  callLua(L, @"dispatcher.register('rvm.commands.listDisks')");
//  callLua(L, @"dispatcher.register('rvm.commands.unmountDisk')");
//  callLua(L, @"dispatcher.register('rvm.commands.diskInfo')");
//  callLua(L, @"dispatcher.register('rvm.commands.sectorData')");
//  callLua(L, @"dispatcher.register('rvm.commands.stop')");
//  callLua(L, @"dispatcher.register('rvm.commands.run')");
//  callLua(L, @"dispatcher.register('rvm.commands.step')");
//  callLua(L, @"dispatcher.register('rvm.commands.breakpoint')");
//}


-(rvmTransitionViewController *)configKeyboardViewController
{
  rvmZxSpectrum48kKeyboardConfigViewController *k=[[rvmZxSpectrum48kKeyboardConfigViewController alloc] initWithNibName:@"rvmZxSpectrum48kKeyboardConfigViewController" bundle:nil];
  
  return k;
}

//Disk interface
-(NSViewController*)diskController
{
  return nil;
}

-(void)insertDisk:(rvmDskDecoder *)disk inDrive:(uint32)drive
{
  
}

-(void)enableDrive:(uint32)drive
{
  
}

-(void)disableDrive:(uint32)drive
{
  
}

-(NSData *)machineKeysSnap
{
  return [NSData dataWithBytes:keys length:sizeof(rvmMachineKeyS)*0x100];
}

-(void)loadMachineKeys:(NSData *)data
{
  if(data) memcpy(keys, data.bytes, data.length);
}

//Sound

-(rvmAudioViewController*)audioController
{
  if(!_audioController)
  {
    _audioController=[[rvmAudioViewController alloc] initWithNibName:@"rvmAudioViewController" bundle:NULL];
  
    _audioController.mixer=mixer;
  }
  
  return _audioController;
}

-(NSData*)frameSnapshot:(NSData*)memory border:(uint8)border
{
  NSMutableData *s=[NSMutableData dataWithLength:384*288*4];
  
  if(memory)
    snap48k(speccy, (uint32*)s.bytes, (uint8*)memory.bytes,border);
  else
    snap48k(speccy, (uint32*)s.bytes, speccy->ram[0],border);
  
  return s;
}

- (void)doKempston:(uint)v e:(uint)e gamepad:(rvmGamepad*)g
{
  NSLog(@"E: %d, v:%d",e,v);
  switch(e)
  {
//    case 0: //X
//    {
//      speccy->joyState&=(0xfc | g.digitalState);
//      if(v<=25)
//      {
//        speccy->joyState|=0x2;
//      }
//      else if(v>=75)
//      {
//        speccy->joyState|=0x1;
//      }
//      break;
//    }
//    case 1: //Y
//    {
//      speccy->joyState&=(0xf3 | g.digitalState);
//      if(v<=25)
//      {
//        speccy->joyState|=0x8;
//      }
//      else if(v>=75)
//      {
//        speccy->joyState|=0x4;
//      }
//      break;
//    }
    default: //Button
    {
      //NSLog(@"Button: %d",e);
      if(e==rvmJoyDown)
      {
        if(v)
          speccy->joyState|=0x4;
        else
          speccy->joyState&=0xfb;
        
        break;
      }
      
      if(e==rvmJoyUp)
      {
        if(v)
          speccy->joyState|=0x8;
        else
          speccy->joyState&=0xf7;
        
        break;
      }
      
      if(e==rvmJoyLeft)
      {
        if(v)
          speccy->joyState|=0x2;
        else
          speccy->joyState&=0xfd;
        
        break;
      }
      
      if(e==rvmJoyRight)
      {
        if(v)
          speccy->joyState|=0x1;
        else
          speccy->joyState&=0xfe;
        
        break;
      }
      
      speccy->joyState&=0xef;
      if(v) speccy->joyState|=0x10;
      break;
      
    }
  }
}

- (void)doI2p1:(uint)v e:(uint)e gamepad:(rvmGamepad*)g
{
  uint8 *p=&speccy->keyboard[4];
  switch(e)
  {
    default: //Button
    {
      if(e==rvmJoyDown)
      {
        if(v)
          *p&=0xfb;
        else
          *p|=0x4;
        
        break;
      }
      
      if(e==rvmJoyUp)
      {
        if(v)
          *p&=0xfd;
        else
          *p|=0x2;
        
        break;
      }
      
      if(e==rvmJoyLeft)
      {
        if(v)
          *p&=0xef;
        else
          *p|=0x10;
        
        break;
      }
      
      if(e==rvmJoyRight)
      {
        if(v)
          *p&=0xf7;
        else
          *p|=0x8;
        
        break;
      }
      
      *p|=0x1;
      if(v) *p&=0xfe;
      break;
    }
  }
}

- (void)doCursor:(uint)v e:(uint)e gamepad:(rvmGamepad*)g
{
  uint8 *p=&speccy->keyboard[4];
  uint8 *p2=&speccy->keyboard[3];
  
  switch(e)
  {
    default: //Button
    {
      if(e==rvmJoyRight)
      {
        if(v)
        *p&=0xfb;
        else
        *p|=0x4;
        
        break;
      }
      
      if(e==rvmJoyUp)
      {
        if(v)
        *p&=0xf7;
        else
        *p|=0x8;
        
        break;
      }
      
      if(e==rvmJoyLeft)
      {
        if(v)
        *p2&=0xef;
        else
        *p2|=0x10;
        
        break;
      }
      
      if(e==rvmJoyDown)
      {
        if(v)
        *p&=0xef;
        else
        *p|=0x10;
        
        break;
      }
      
      *p|=0x1;
      if(v) *p&=0xfe;
      break;
    }
  }
}

- (void)doI2p2:(uint)v e:(uint)e gamepad:(rvmGamepad*)g
{
  uint8 *p=&speccy->keyboard[3];
  switch(e)
  {
    default: //Button
    {
      if(e==rvmJoyDown)
      {
        if(v)
        *p&=0xfb;
        else
        *p|=0x4;
        
        break;
      }
      
      if(e==rvmJoyRight)
      {
        if(v)
        *p&=0xfd;
        else
        *p|=0x2;
        
        break;
      }
      
      if(e==rvmJoyLeft)
      {
        if(v)
        *p&=0xfe;
        else
        *p|=0x01;
        
        break;
      }
      
      if(e==rvmJoyUp)
      {
        if(v)
        *p&=0xf7;
        else
        *p|=0x8;
        
        break;
      }
      
      *p|=0x10;
      if(v) *p&=0xef;
      break;
    }
  }
}




-(void)joy:(rvmGamepad *)g element:(uint)e value:(uint)v
{
  NSNumber *k=[NSNumber numberWithUnsignedLongLong:(unsigned long long)g];
  NSNumber *n=gamepads[k];
  e=[g joyFunction:e];
  
  uint nn;
  if(!n)
  {
    nn=0;
    gamepads[k]=@0;
  }
  else
    nn=[n unsignedIntValue];

  if(e==rvmJoySystem && v)
  {
    nn=(nn+1) & 0x3;
    if(self.onOsdEvent) self.onOsdEvent([NSString stringWithFormat:@"Gamepad connected to '%s'.",(!nn)?"Kempston":((nn==1)?"Interface II - port 1":((nn==2)?"Interface II - port 2":"Cursor"))],16,g.gamepadImage);
    gamepads[k]=[NSNumber numberWithInt:nn];
    return;
  }
  
  if(e==rvmJoySelect && v)
  {
    NSString *p;
    @synchronized(self)
    {
      if(self.control & kRvmStatePaused)
      {
        if(self.lastSnapshot)
        {
          [self loadSnapshot:self.lastSnapshot];
          self.control&=0xfffffffd;
          if(self.onOsdEvent) self.onOsdEvent(@"Last snapshot loaded",22,[NSImage imageNamed:@"photo"]);
        }
      }
      else
      {
        self.lastSnapshot=[self createSnapshot];
        NSImage *i=[self.tripleBuffer snapshot];
        p=[self.doc snapshotPath:@"snapshot"];
        [self.doc saveSnapshot:self.lastSnapshot filename:p];
        if(self.onOsdEvent) self.onOsdEvent([NSString stringWithFormat:@"Snapshot '%@' saved.",p],22,[NSImage imageNamed:@"photo"]);
        
        if(self.onFastSnap) self.onFastSnap(i);
      }
    }
    
    return;
  }
  
  if(e==rvmJoyStart && v)
  {
    //self.paused=!self.paused;
    self.control^=0x2;
    if(self.onOsdEvent)
    {
      if(self.control & kRvmStatePaused)
        self.onOsdEvent(@"Paused",22,[NSImage imageNamed:@"video"]);
      else
        self.onOsdEvent(@"Running",22,[NSImage imageNamed:@"video"]);
    }
    return;
  }
  
  switch (nn) {
    case 0:
      [self doKempston:v e:e gamepad:g];
      break;
    case 1:
      [self doI2p1:v e:e gamepad:g];
      break;
    case 2:
      [self doI2p2:v e:e gamepad:g];
      break;
    case 3:
      [self doCursor:v e:e gamepad:g];
      break;
  }
}

-(NSDictionary *)createFastSnapshot
{
  self.lastSnapshot=[self createSnapshot];
  dispatch_async(dispatch_get_main_queue(), ^{
    if(self.onOsdEvent) self.onOsdEvent(@"Snapshot taken.",22,[NSImage imageNamed:@"photo"]);
    if(self.onFastSnap) self.onFastSnap([self.tripleBuffer snapshot]);

  });
  
  return self.lastSnapshot;
}

-(rvmVideoViewController *)videoController
{
  if(!_videoController)
  {
    _videoController=[[rvmVideoViewController alloc] initWithNibName:@"rvmVideoViewController" bundle:nil];
  }
  
  return _videoController;
}

-(void)joyEmuType:(uint)type
{
  joyEmuType=type;
  gamepads[[NSNumber numberWithUnsignedLongLong:(unsigned long long)emuDevice]]=[NSNumber numberWithUnsignedInt:type];
}

-(void)setKeyboardType:(uint)type
{
  super.keyboardType=type;
  
  if(self.onOsdEvent) self.onOsdEvent([NSString stringWithFormat:@"Keyboard mode %s",(type)?"recreated ZX Spectrum":"standard"],22,(type)?[NSImage imageNamed:@"staticSpectrum48k" ]:[NSImage imageNamed:@"staticConfigKeyboard"]);
}

-(NSArray *)supportedTypes
{
  NSMutableArray *t=[[NSMutableArray alloc] initWithArray:[cassetteController tapeDecoders][0]];
  [t addObjectsFromArray:@[@"sna",@"z80"]];
  return t;
}

-(void)loadMedia:(NSURL *)filename
{
  NSString *ext=filename.pathExtension.lowercaseString;
  
  if([ext isEqualToString:@"sna"])
  {
    NSData *d=[NSData dataWithContentsOfURL:filename];
    NSDictionary *s=[self createSnapshot];
    
    NSDictionary *snap=[rvmSNADecoder import:s[@"model"] data:d machine:self onError:^(NSString *err) {
      NSAlert *a=[NSAlert new];
      
      [a addButtonWithTitle:@"Ok"];
      a.messageText=err;
      a.alertStyle=NSCriticalAlertStyle;
      
      [a beginSheetModalForWindow:self.videoController.view.window completionHandler:^(NSModalResponse returnCode) {
        
      }];
    }];
    
    if(snap) [self loadSnapshot:snap];
  }
  else if ([ext isEqualToString:@"z80"])
  {
    NSData *d=[NSData dataWithContentsOfURL:filename];
    NSDictionary *s=[self createSnapshot];
    
    NSDictionary *snap=[rvmZ80Decoder import:s[@"model"] data:d machine:self onError:^(NSString *err) {
      NSAlert *a=[NSAlert new];
      
      [a addButtonWithTitle:@"Ok"];
      a.messageText=err;
      a.alertStyle=NSCriticalAlertStyle;
      
      [a beginSheetModalForWindow:self.videoController.view.window completionHandler:^(NSModalResponse returnCode) {
        
      }];
    }];
    
    if(snap) [self loadSnapshot:snap];
  }
  else
    [cassetteController loadMediaFile:filename sound:YES];
}
@end
