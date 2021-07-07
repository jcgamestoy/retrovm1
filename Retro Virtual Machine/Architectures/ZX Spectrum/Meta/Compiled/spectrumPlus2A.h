
//(C)2014 Juan Carlos González Amestoy
#import <Foundation/Foundation.h>
#import "rvmMachineProtocol.h"

#import "z80.h"
#import "rvmTapeDecoderProtocol.h"
#import "rvmAY3819X.h"
#import "rvmAudioMixer.h"
#import "spectrum48k.h"



struct _spectrumPlus2A;
typedef struct _spectrumPlus2A{
  uint32_t border,bcol,bl;
  uint32_t fg,bg;
  int t,flash,T,M,frame,so,soundIndex;
  double soc;
  uint8_t pixel,attr,pl,al;
  uint32_t palette[16];
  uint8_t keyboard[8];
  uint8_t mic,ear;
  uint32_t level;
  uint8_t joyState;
  uint32_t cassetteT;
  //bool cassetteRunning;
  rvmTapeDecoderProtocolS *cassetteDecoder;
  //int16_t audioBuffer[882<<1];
  int16_t audioBuffer[3840<<1];
  //double audioLevelL,audioLevelR;

  rvmSpeccyStep step;
  rvmSpeccyStep frameF;
  uint8_t **ram;
  uint8_t **rom;

  z80* cpu;
  rvmAudioMixerS *mixer;
  double soundChannels[4];


//Spectrum128
//
  uint8_t memory7f; //last 0x7ffd
  uint8_t aySelect;
  rvmAY3819XT *ay;
//Spectrum +2A
//
  uint8_t memory1f;


}spectrumPlus2A;
void initPlus2A(void);
uint32_t sPlus2A_cont4T(uint32_t l,uint32_t t);
uint32_t sPlus2A_contention(z80 *z,uint16 a);
uint32_t sPlus2A_contentionIO(z80 *z,uint16 a);
uint32_t floatingBusPlus2A(z80 * z);

uint32_t* stepPlus2A(spectrumPlus2A *speccy,bool fast,uint32_t* buffer);
uint32_t* framePlus2A(spectrumPlus2A *speccy,bool fast,uint32_t* buffer);
void sPlus2A_set(z80* z,uint16_t a,uint8_t v);
uint8_t sPlus2A_get(z80* z,uint16_t a);
void sPlus2A_out(z80* z,uint16_t a,uint8_t v);
uint8_t sPlus2A_busInt(z80* z);
uint8_t sPlus2A_in(z80* z,uint16_t a);
void sPlus2A_ack(z80*z);
void sPlus2A_memoryConfig(spectrum *s,uint8 m7f,uint8 m1f);

uint8_t s128k_AYin(rvmAY3819XT *h,uint16 a);



